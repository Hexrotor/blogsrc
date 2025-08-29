---
title: F2P：基于 libp2p 的 p2p 直连端口转发工具
date: 2025-08-29 18:43:12
tags: [Go, 开发, libp2p]
categories: [技术]
excerpt: "有远程访问的需求，又不想买公网服务，加上我对 libp2p 项目挺感兴趣，就写了这个小工具"
---

快一年没更新博客了，主要没啥动力写了。最近有远程访问内网服务的需求，但又不想买公网服务器。偶然间又刷到了以前玩过的 IPFS，发现其现在分离出了一个衍生项目 [libp2p](https://github.com/libp2p/libp2p)。

libp2p 是一套完整的 p2p 协议库，支持自动中继、Nat 打洞等功能。早些年我喜欢玩 BT，本来就对 p2p 很感兴趣，现在看了下这个库就决定拿它写一个类似于 FRP 这样的端口转发工具，于是 [F2P](https://github.com/Hexrotor/f2p) 就诞生了。

但由于本人主修的是二进制安全，并非开发，没有很多开发经验，所以这个项目的代码(Go) AI 辅助居多。后续我会(?)努力尝试提高代码质量，优化整个项目代码结构。如果读者对本项目感兴趣欢迎贡献代码 :\)

注意本文章记录的是一些开发背景和原理一类的东西，要快速了解如何使用 F2P 请直接 -> [https://github.com/Hexrotor/f2p](https://github.com/Hexrotor/f2p)

### F2P 大致介绍

F2P 的工作模式是 Client-Server 模式，一个可执行文件可以分别以两种模式运行，运行哪种模式由配置文件中的键值`isServer`进行区分，一个 Server 支持多个 Client 连接。每一个运行的 F2P 实例都会启动一个 libp2p 节点，所有通信将基于 libp2p 协议栈进行。

Server 与要访问的后端服务处于同一网络，Client 则是用户自己运行，这一点和 FRP 的设计不太一样。FRP 是 frps 跑在公网服务器上，其本质作用是与 frpc 通信并暴露端口到公网上，而 frpc 才是与后端服务跑在同一个网络中，衔接内网服务连接。对于 F2P 而言，运行起来则类似 ssh 转口转发。

### F2P 是如何实现 p2p 通信的

实际上我是要解释 libp2p 是如何实现 p2p 通信的。类似 BT 技术那样，libp2p 主要依赖 Kademlia DHT 进行节点发现，对 Kademlia 感兴趣可以自行了解这里不解释。libp2p 的每一个节点都有一个唯一的 PeerID，来自其节点公钥的 [MultiHash](https://richardschneider.github.io/net-ipfs-core/articles/multihash.html)，要在 DHT 中连接一个节点，指定其 PeerID 即可，libp2p 会尝试在 DHT 网络中查找 PeerID 对应的 [MultiAddress](https://richardschneider.github.io/net-ipfs-core/articles/multiaddress.html)（由对方节点自行广播），MultiAddr 中包括了传统 IPv4/6 的地址，这样就可以对该地址发起连接了。

但是到这里还有一个问题没有解释：如果双方都在 Nat 后面导致并不能直接通信，那无论怎样发起连接都是连不上的。为了解释这个问题，需要引出 libp2p 的中继 ([relay](https://docs.libp2p.io/concepts/nat/circuit-relay/)) 机制，我们并不讨论 relay 的具体实现细节，只对其作用效果简单说明。之前提到 libp2p 实际上是目前 IPFS 项目的底层协议栈实现，所以 libp2p 实际上可以直接加入 IPFS 的全球 DHT 网络，这其中不缺具有公网 IPv4 的设备，这些设备都可以提供中继功能。

对于一个 libp2p 节点，可以编写一个中继节点提供函数，比如自动从 DHT 网络中寻找距离最近的节点，函数返回的节点将被侯选注册为中继节点。

```go
func (s *Server) createAutoRelayPeerSource() func(ctx context.Context, numPeers int) <-chan peer.AddrInfo {
	return func(ctx context.Context, numPeers int) <-chan peer.AddrInfo {
		slog.Debug("Fetching closest peers for AutoRelay")
		peerChan := make(chan peer.AddrInfo)
		go func() {
			defer close(peerChan)

			closestPeers, err := s.dht.GetClosestPeers(ctx, s.host.ID().String())
			if err != nil {
				slog.Error("Failed to get closest peers", "error", err)
				return
			}

			count := 0
			for _, peerID := range closestPeers {
				if numPeers > 0 && count >= numPeers {
					break
				}

				if peerID == s.host.ID() {
					continue
				}

				addrs := s.host.Peerstore().Addrs(peerID)
				if len(addrs) == 0 {
					continue
				}

				select {
				case <-ctx.Done():
					return
				case peerChan <- peer.AddrInfo{ID: peerID, Addrs: addrs}:
					count++
				}
			}
		}()
		return peerChan
	}
}
```

在创建 libp2p 节点时应用上述中继源提供函数：

```go
node := libp2p.New(
    libp2p.EnableAutoRelayWithPeerSource(               // 配合中继源提供函数启用自动中继
        s.createAutoRelayPeerSource(),                  // 中继节点源提供函数
        autorelay.WithMaxCandidateAge(time.Minute*30),  // 中继节点最长有效时间，超过该时间会尝试更新中继源重新注册一批中继
        autorelay.WithMinInterval(time.Minute*15),      // 中继节点最短更新间隔，低于该时间不允许进行中继源更新
        autorelay.WithNumRelays(3),                     // 注册多少个中继节点为我们所用
	)
)
```

注册了中继节点后，本地节点广播的 MultiAddr 中会出现以 `p2p-circuit` 结尾的地址，表示这是一个中继地址，其他人要来连接我，就通过这个中继地址进行拨号。

```plaintext
中继连接地址样式：
/ip4/95.250.57.8/tcp/57253/p2p/12D3KooWP29YUY6qWushiW6cNxTwbbLDiPjV7yUNrsofAguB8x6U/p2p-circuit

加上 /p2p/<PeerID> 指定通过中继连接拨号的节点：
/ip4/95.250.57.8/tcp/57253/p2p/12D3KooWP29YUY6qWushiW6cNxTwbbLDiPjV7yUNrsofAguB8x6U/p2p-circuit/p2p/12D3Ko...
```

到这里我们已经大致了解了中继的工作行为，但中继归中继，也不能称之为 p2p 啊，最后是怎么实现 p2p 直连的呢？要解释这个问题又要引出 libp2p 自带的打洞 (hole-punching) 功能。

稍微了解 p2p 网络的都知道，纯靠中继是不可取的，所以 libp2p 实现了一套自动 Nat 打洞逻辑，当通过中继连接到目标节点时，libp2p 并不会立即返回一个基于中继的网络 stream，而是尝试将连接升级为 p2p 直连，最后返回直连的 stream。这个过程中 libp2p 会自动调用打洞模块尝试打穿 Nat，此时中继节点正好作为 Nat 打洞流程中的 STUN 服务器，获得 p2p 直连后才返回一个可用的 stream 用于通信，后续也就不需要中继服务器了。

通过这样一套流程下来，libp2p 可以很轻松地在大部分网络环境中实现 p2p 连接，除非设备位于严格的 Nat4 环境中。目前 IPv6 也在家庭宽带中大范围普及，就算 IPv4 Nat 环境很严格，libp2p 也能自动通过 IPv6 进行通信。对于 libp2p 我的评价是它设计得真的很不错。

### F2P 的校验机制

校验机制其实有很多方面，首先一个问题是 Client 如何确认自己要连接的 Server 就是那个真正的 Server？很简单，F2P 设计上是 Server 维护者通过网络等消息渠道自行发布 PeerID 给 Client，而这个 PeerID 实际上是 Server 节点的公钥 Hash。在连接时，libp2p 的底层应该会校验 Server 的签名以确认对方身份，并且传输将通过 [TLS 1.3](https://docs.libp2p.io/concepts/secure-comm/tls/) + [Noise](https://docs.libp2p.io/concepts/secure-comm/noise/) 进行加密，确保通信内容安全。

除此之外，密码校验功能就需要我手动实现了。在当前的设计中，服务器能可选地设置自己的主密码，并且主密码将以 Bcrypt Hash 形式存储在自身配置文件中，此外每个服务 (Service) 还可以设置独属于它们的密码，但这些密码是以明文形式存储在配置文件中的。听起来上述密码存储方式似乎并不安全，但是想想原版 FRP ，不也是 token 直接存配置文件里…… 我暂时是没有想到更好的方案。

目前 F2P v0.0.2 的版本，Client 在与 Server 建立连接后将尝试握手注册 session，此时客户端会要求输入服务器主密码，就像 ssh 登录输密码那样进行认证。在 F2P 的设计中，认证消息与服务数据传输将在两个不同的 [Protocol](https://docs.libp2p.io/concepts/fundamentals/protocols/) 中进行，我称之为 ControlStream 与 DataStream。ControlStream 是总的消息传输流，没错 F2P 设计中有一些消息机制比如认证请求包、心跳包、结束会话通知等等，其实感觉设计得有点复杂，但能用就行。DataStream 就是传输服务数据的，每个客户端只能有一个 ControlStream，而 DataStream 在每次服务请求时都可以新开一个——实际上 libp2p 底层用的 yamux 多路复用，只是暴露出的接口抽象成了多个 Stream。

### 引入 zstd 压缩以提升传输带宽上限

F2P 引入了 Cgo 编写的 zstd 压缩以减少网络开销，当然代价是 CPU 开销略有增加。libp2p 会自动选择底层连接协议，比如 quic (UDP)、TCP、WebSocket 等，而 libp2p 又在打洞时特别喜欢使用 quic 协议建立连接（因为它是基于 UDP 的），而 UDP 这个东西又是被国内运营商搞得处处限制的，所以即使是 p2p 直连，速度也不太理想。经过我的测试，普通家庭宽带撑死了能跑到 1MB/s，多数情况是不会超过 256KB/s。但曾经我也观察到过 TCP 作为底层连接时的速率变化不大，所以主要限制因素的还是双方的上行带宽。

为了尽可能提高传输带宽，我引入了 zstd 压缩传输流量，双方在发送数据时都会经过 zstd 压缩一遍看看能否减少数据量，如果压缩后并没有减小，则会发送原未压缩数据，反之则发送压缩后的数据，如此就能最大程度利用带宽。而经过我测试，zstd 增加的 CPU 开销和时延，在这 KB 级的数据大小下几乎可以忽略不计，所以目前我对这套机制是比较满意的。