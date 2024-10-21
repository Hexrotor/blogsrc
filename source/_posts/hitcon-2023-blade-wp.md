---
title: Hitcon 2023 Blade WP
date: 2023-09-11 01:22:27
tags: [CTF, Reverse, WP]
excerpt: "只做了这道题"
---

不太会，只做了这一道

### 表面行为分析

首先运行程序，会进入一个交互界面，然后提示可以进入 server 模式，并且 `run` 之后打印出来一串 opcode

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_run.jpg.avif)

nc 连 server，server 提示连接成功，`help` 查看指令

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_server_help.jpg.avif)

随后尝试运行这些指令，server 这边直接卡住了，但是 nc 这边出现了乱码

如图是运行 pwd 出现的乱码：

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_pwd.jpg.avif)

由于看不出来是什么，所以上 pwntools 提一下数据得到

```Python
b'T]1\xf6\x81\xc6\x00\x10\x00\x00H)\xf4T_jOX\x0f\x05PH\x92H\x83\xc2\x08S_T^j\x01X\x0f\x05U\\A\xff\xe7'
```

有点抽象，难道是 `pwd` 执行结果加密后的数据表现吗？那么 flag 有可能和这个是同一套加密，那么也许可以先找到这套加密代码，再看看程序中有无藏匿的 flag 加密后数据，从而得到原 flag。但是这个猜想不一定对，我又尝试执行了 `ls` ，得到的数据和上面的差不多，而且比较短，感觉文件名加密后不可能才这么点长。于是我将其复制到 IDA 里 c 一下，发现这玩意儿是 opcode，疑似是实现其列出的操作的代码，但是这样打印出来不知道干嘛的。

到这里程序表象已经看不出来什么了，接下来是逆向环节

### 程序逆向分析

IDA 打开能直接找到 `main` 函数 `seccomp_shell::main::hef7e76ec97275895()`

`main` 函数中直接能找到关键函数 `seccomp_shell::cli::prompt::h56d4b6fe2f13f522(&v5)`

由函数名可以推断，这个函数负责处理 cli 界面与指令，有可能是通过类似 `switch` 的方式来处理指令

根据经验，这种处理 cli 的函数前面可能会根据终端的环境变量来设置或打印一些初始化内容，所以前面的代码大概率没用，往后翻看看有无 `switch`

事实证明也确实有：

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_func_shell.jpg.avif)

上图这种 `switch` 字符串的比较方式不知道是 Rust 编译器干的还是出题人故意这样写的，总之我看着值有点像 ascii 范围就 R 了一下，结果确实是字符。应该是根据用户输入进入相应的函数，那么进 `seccomp_shell::shell::prompt::h76cecfe7bd3bdf50(v33)` 看看吧

然后就发现了刚刚打印出来的字符串，看来 server 之后进入的交互就是这个函数负责的：

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_fun_shell_p.jpg.avif)

然后继续往下看，发现了爆点

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_func_shell_flag.jpg.avif)

上图中出现了 `flag` 命令，我随即启动程序测试

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_input_flag.jpg.avif)

如图直接输 `flag` 会提示 Incorrect ，随后我在后面加参数运行也不会有报错，猜测就是把 `flag` 后面的参数拿去验证了。先进 `seccomp_shell::shell::verify::h898bf5fa26dafbab(v154, v175[3], v175[5])` 函数看看

verify有点长就不截图了，挑几个部分说一下

```c
   memcpy(dest, &unk_55DF6DF58920, 0x200uLL);
    v52 = 64LL;
    v53 = &dest[1];
    do
    {
      v54 = *(v53 - 1);
      if ( v54 > 0x3F )
        goto LABEL_53;
      v55 = tmp_addr[v52 - 1];
      tmp_addr[v52 - 1] = tmp_addr[v54];
      tmp_addr[v54] = v55;
      v56 = *v53;
      if ( *v53 > 0x3F )
        goto LABEL_53;
      v57 = tmp_addr[v52 - 2];
      tmp_addr[v52 - 2] = tmp_addr[v56];
      tmp_addr[v56] = v57;
      v53 += 2;
      v52 -= 2LL;
    }
    while ( v52 );
```

`tmp_addr` 是用户输入，长度为 64。这整个循环是在按照 `dest` 中的值来将 `tmp_addr` 的顺序打乱，而这样的循环一共有 5 个，除了每次复制到 `dest` 中的值不同以外，代码基本相同。并且复制到 `dest` 的值是常量，而代码的行为也与用户输入值没有任何关系。也就是说，可以将这 5 次打乱看作一次，我们只需要输入一串已知顺序的 64 字节字符串，然后动调得到输出的字符串，就能得到 64 位对应表，在还原 flag 时直接根据表就能还原。

```c
v58 = 0LL;                                  // exchange end
    do
    {
      v59 = tmp_addr[v58] + 1;
      LOWORD(v51) = 1;
      LOWORD(v52) = 257;
      v60 = 0;
      do
      {
        v62 = v52;
        LOWORD(v52) = v52 / v59;
        v61 = v62 % v59;
        v63 = v51;
        v51 = v60 - v51 * v52;
        LODWORD(v52) = v59;
        v59 = (v62 % v59);
        v60 = v63;
      }
      while ( v61 );
      v64 = 0;
      if ( v63 > 0 )
        v64 = v63;
      tmp_addr[v58] = ((v64 + (v63 >> 15) - v63) / 0x101u + v63 + (v63 >> 15) + 113) ^ 0x89;
      v52 = v58 + 1;
      v58 = v52;                                // v58++
    }
    while ( v52 != 64 );
```

打乱后是如上的加密，静态分析或动调都可以看出这个加密是以字节为单位的，并且这个加密的运算数似乎也与 flag 的其他位置值没有任何关系。那么有没有可能，我们可以得到一份加密前后的字节对应表，按照表就能将加密后的字节翻译为加密前的字节。

生成 0~255 的 hex 序列，然后就能粘进IDA里提取加密后的值：

```Python
for i in range(0, 256, 64):
    print(bytearray(range(i, i+64)).hex())
```

本来以为就这点，但是拉到后面一看还有个 `while ( v8 != 256 );` ，而作用范围是刚才的打乱和加密，也就是说这个过程会循环 256 次，问题不大。

得到的字节对应表与还原脚本：

```Python
# 动调得到的表
s0_255 = [0xFB, 0x7B, 0x4E, 0xBB, 0x51, 0x15, 0x8D, 0xDB, 0xB0, 0xAC, 0xA5, 0x8E, 0xAA, 0xB2, 0x60, 0xEB, 0x63, 0x5C, 0xDE, 0x42, 0x2B, 0xC6, 0xA6, 0x35, 0x30, 0x43, 0xD6, 0x5F, 0xBD, 0x24, 0xB1, 0xE3, 0x8C, 0xA7, 0xD5, 0x2A, 0x7C, 0x6D, 0x8B, 0x17, 0x9D, 0x83, 0xFE, 0x69, 0x10, 0x59, 0xA9, 0x9E, 0x0F, 0x1C, 0x66, 0x97, 0x5B, 0x61, 0xED, 0xAD, 0xE0, 0xDA, 0x27, 0x06, 0x25, 0xDC, 0x5E, 0xE7,
        0x41, 0x32, 0xD2, 0xD9, 0x8F, 0xEE, 0xAF, 0x03, 0x93, 0x3A, 0x00, 0xA2, 0xE1, 0xB3, 0xEC, 0x81, 0x9F, 0xCA, 0x58, 0xB7, 0x79, 0xFD, 0x3B, 0xA0, 0x02, 0x0C, 0xCB, 0xA8, 0x80, 0xC0, 0x16, 0x4D, 0x2F, 0x75, 0x71, 0x0A, 0x04, 0x39, 0xFF, 0xC1, 0x9C, 0xAB, 0xEF, 0xA4, 0xD8, 0xE2, 0x14, 0xC2, 0x6C, 0x64, 0x1E, 0x6B, 0x7E, 0x99, 0x2E, 0x09, 0x0B, 0x86, 0x74, 0x6A, 0xC4, 0x2D, 0x4F, 0xF9,
        0xFA, 0x94, 0xB6, 0x1F, 0x89, 0x6F, 0x5D, 0xE8, 0xEA, 0xB5, 0x5A, 0x65, 0x88, 0xC5, 0x7F, 0x77, 0x11, 0xCF, 0xF1, 0x1B, 0x3F, 0xF4, 0x48, 0x47, 0x12, 0xE4, 0xBA, 0xDF, 0xE9, 0x62, 0x6E, 0xB4, 0x96, 0xCD, 0x13, 0x53, 0x4B, 0x28, 0xD7, 0xD1, 0x33, 0xB8, 0xE6, 0x7A, 0x2C, 0x9B, 0x29, 0x44, 0x52, 0xF7, 0x20, 0xF2, 0x31, 0xD3, 0xB9, 0x40, 0xD0, 0x34, 0xF5, 0x54, 0x1A, 0x01, 0xA1, 0x92,
        0xFC, 0x85, 0x07, 0xBE, 0xDD, 0xBC, 0x19, 0xF3, 0x36, 0xF6, 0x72, 0x98, 0x4C, 0x7D, 0xC7, 0xD4, 0x45, 0x4A, 0x9A, 0xC3, 0x8A, 0xE5, 0x50, 0x46, 0xCC, 0x68, 0x76, 0x67, 0xC9, 0x0E, 0x3C, 0x57, 0xF0, 0x22, 0xBF, 0x26, 0x84, 0x0D, 0x90, 0xA3, 0xAE, 0x3D, 0x1D, 0xC8, 0x91, 0x05, 0x87, 0x70, 0x08, 0x73, 0x21, 0x49, 0x55, 0x3E, 0x37, 0x23, 0x18, 0x56, 0xCE, 0x82, 0x38, 0x95, 0x78, 0xF8]

# 生成对应字典
crypto_table = dict(zip(s0_255,range(0x100)))

# 逆向查表得到原数据
def decrypt(data: list, table: dict):
    tmp=[]
    for i in data:
        tmp.append(table[i])
    return tmp
```

得到顺序表与还原的脚本：

```Python
# get order table
source = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ{}'
replaced = 'HfVl{qPcCYNMoRi6D7Jr}espOL3FhwdWAtTGZba4Ugjvnx1QkKE2IS9yuz5BX08m'
revsere_table = [] #index是source在replace中的下标
for i in source:
    revsere_table.append(replaced.find(i))

# 还原顺序
def reverse_order(data:list, table: list):
    tmp = []
    for i in range(64):
        tmp.append(data[table[i]])
    return tmp
```

256 次就写个 for 循环就行了

### 程序如何比较

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_func_verify_1.jpg.avif)

如图是 256 次循环后的开头代码，这次 `memcpy` 加载了一块 255 字节的数据到堆中，但不是 `dest`。经过查看，这个数据又是 opcode

经过调试发现 `dest` 加载了 64 字节的数据，那么这个数据很有可能是比较数据，直接拿到脚本里去跑，解出来却是乱码。一开始以为脚本写错了，但拿个明文加密的提取的数据去跑，确实是能跑出明文的，说明比对部分还有细节。

在上图中，opcode 的某些部分被修改了，并且与加密后的输入有关，随后我又偶然发现 `if` 中对索引 `[223, 224, 225, 226]` 赋的值和 `dest` 开头的 4 字节一致，但仍然没看出来有什么比较。

继续向后看，发现会读取 TcpStream io 之类的，不然会卡住等待输入，在 nc 那边输点东西就可以继续跑

然后找到了这个函数

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/blade_func_verify_2.jpg.avif)

我一开始以为这个就是比较函数，但是仔细看发现根本没有比较的操作，而是又是在对 opcode 进行修改操作，并且将 opcode 数据发送到 nc 端，与之前那个 `if` 里的代码行为一致，应该是编译优化导致的。

看了半天确定这个程序里确实没有任何比较操作，我将目光转向那个 opcode。经过辨认发现 opcode 被修改的值是如下两个地方：

```asm
.text:0000564D3A41F1FD                 mov     eax, 1015CB52h # 加密的用户输入
.text:0000564D3A41F202                 add     eax, r12d
.text:0000564D3A41F205                 xor     eax, r13d
.text:0000564D3A41F208                 ror     eax, 0Bh
.text:0000564D3A41F20B                 not     eax
.text:0000564D3A41F20D                 xor     eax, r14d
.text:0000564D3A41F210                 cmp     eax, 526851A7h # dest
.text:0000564D3A41F215                 jnz     short loc_564D3A41F21C
```

程序中的行为是取加密后的用户输入与 `dest` 中的值写入 opcode 这两处，而这个 opcode 也很明显能看出来是在验证。但是这其中 `r12 r13 r14` 寄存器的值都是未知的，我的猜测是 opcode 前面执行的代码会影响这三个寄存器，使其在运行到此处时为定值。所以我运行了该 opcode，得到三个寄存器的值：

```asm
r12 = 0x0000000464C457F
r13 = 0x0000000746F6F72
r14 = 0x000000031F3831F
```

逆该过程脚本：

```Python
# 由于需要模拟汇编中的位运算，所以需要使用 numpy 库
def de_cmp(x):
    r12 = 0x0000000464C457F
    r13 = 0x0000000746F6F72
    r14 = 0x000000031F3831F

    x = np.uint32(x)
    x = np.uint32(x ^ r14)
    x = np.uint32(~x)
    x = np.uint32((x << 11) | (x >> (32 - 11)))
    x = np.uint32(x ^ r13)
    x = np.uint32(x - r12)
    #print(hex(x))
    x = np.int32(x)
    return [x & 0xff, (x & 0xff00) >> 8, (x & 0xff0000) >> 16, (x & 0xff000000) >> 24]
```

总的来看，整个程序其实根本没有验证 flag 的正确性，也没有执行这些 opcode，这些 opcode 只是被作为数据发送到了 nc 端

### EXP

```Python
import numpy as np
def decrypt(data: list, table: dict):
    tmp=[]
    for i in data:
        tmp.append(table[i])
    return tmp

def reverse_order(data:list, table: list):
    tmp = []
    for i in range(64):
        tmp.append(data[table[i]])
    return tmp

'''
def de_cmp(x):
    r12 = 0x0000000464C457F
    r13 = 0x0000000746F6F72
    r14 = 0x000000031F3831F
    x ^= r14
    x = ~x
    x = (x << 11) | (x >> (32 - 11))
    x ^= r13
    x -= r12
    print(hex(x))
    return [x & 0xff, (x & 0xff00) >> 8, (x & 0xff0000) >> 16, (x & 0xff000000) >> 24]
'''

def de_cmp(x):
    r12 = 0x0000000464C457F
    r13 = 0x0000000746F6F72
    r14 = 0x000000031F3831F

    x = np.uint32(x)
    x = np.uint32(x ^ r14)
    x = np.uint32(~x)
    x = np.uint32((x << 11) | (x >> (32 - 11)))
    x = np.uint32(x ^ r13)
    x = np.uint32(x - r12)
    print(hex(x))
    x = np.int32(x)
    return [x & 0xff, (x & 0xff00) >> 8, (x & 0xff0000) >> 16, (x & 0xff000000) >> 24]

# get crypto table
s0_255 = [0xFB, 0x7B, 0x4E, 0xBB, 0x51, 0x15, 0x8D, 0xDB, 0xB0, 0xAC, 0xA5, 0x8E, 0xAA, 0xB2, 0x60, 0xEB, 0x63, 0x5C, 0xDE, 0x42, 0x2B, 0xC6, 0xA6, 0x35, 0x30, 0x43, 0xD6, 0x5F, 0xBD, 0x24, 0xB1, 0xE3, 0x8C, 0xA7, 0xD5, 0x2A, 0x7C, 0x6D, 0x8B, 0x17, 0x9D, 0x83, 0xFE, 0x69, 0x10, 0x59, 0xA9, 0x9E, 0x0F, 0x1C, 0x66, 0x97, 0x5B, 0x61, 0xED, 0xAD, 0xE0, 0xDA, 0x27, 0x06, 0x25, 0xDC, 0x5E, 0xE7,
        0x41, 0x32, 0xD2, 0xD9, 0x8F, 0xEE, 0xAF, 0x03, 0x93, 0x3A, 0x00, 0xA2, 0xE1, 0xB3, 0xEC, 0x81, 0x9F, 0xCA, 0x58, 0xB7, 0x79, 0xFD, 0x3B, 0xA0, 0x02, 0x0C, 0xCB, 0xA8, 0x80, 0xC0, 0x16, 0x4D, 0x2F, 0x75, 0x71, 0x0A, 0x04, 0x39, 0xFF, 0xC1, 0x9C, 0xAB, 0xEF, 0xA4, 0xD8, 0xE2, 0x14, 0xC2, 0x6C, 0x64, 0x1E, 0x6B, 0x7E, 0x99, 0x2E, 0x09, 0x0B, 0x86, 0x74, 0x6A, 0xC4, 0x2D, 0x4F, 0xF9,
        0xFA, 0x94, 0xB6, 0x1F, 0x89, 0x6F, 0x5D, 0xE8, 0xEA, 0xB5, 0x5A, 0x65, 0x88, 0xC5, 0x7F, 0x77, 0x11, 0xCF, 0xF1, 0x1B, 0x3F, 0xF4, 0x48, 0x47, 0x12, 0xE4, 0xBA, 0xDF, 0xE9, 0x62, 0x6E, 0xB4, 0x96, 0xCD, 0x13, 0x53, 0x4B, 0x28, 0xD7, 0xD1, 0x33, 0xB8, 0xE6, 0x7A, 0x2C, 0x9B, 0x29, 0x44, 0x52, 0xF7, 0x20, 0xF2, 0x31, 0xD3, 0xB9, 0x40, 0xD0, 0x34, 0xF5, 0x54, 0x1A, 0x01, 0xA1, 0x92,
        0xFC, 0x85, 0x07, 0xBE, 0xDD, 0xBC, 0x19, 0xF3, 0x36, 0xF6, 0x72, 0x98, 0x4C, 0x7D, 0xC7, 0xD4, 0x45, 0x4A, 0x9A, 0xC3, 0x8A, 0xE5, 0x50, 0x46, 0xCC, 0x68, 0x76, 0x67, 0xC9, 0x0E, 0x3C, 0x57, 0xF0, 0x22, 0xBF, 0x26, 0x84, 0x0D, 0x90, 0xA3, 0xAE, 0x3D, 0x1D, 0xC8, 0x91, 0x05, 0x87, 0x70, 0x08, 0x73, 0x21, 0x49, 0x55, 0x3E, 0x37, 0x23, 0x18, 0x56, 0xCE, 0x82, 0x38, 0x95, 0x78, 0xF8]

crypto_table = dict(zip(s0_255,range(0x100)))

#get order table
source = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ{}'
replaced = 'HfVl{qPcCYNMoRi6D7Jr}espOL3FhwdWAtTGZba4Ugjvnx1QkKE2IS9yuz5BX08m'
revsere_table = [] #index是source在replace中的下标
for i in source:
    revsere_table.append(replaced.find(i))

#print(crypto_table)
#print(revsere_table)

cmp_data = [0x526851A7, 0x31FF2785, 0xC7D28788, 0x523F23D3, 0xAF1F1055, 0x5C94F027, 0x797A3FCD, 0xE7F02F9F, 0x3C86F045, 0x6DEAB0F9, 0x91F74290, 0x7C9A3AED, 0xDC846B01, 0x0743C86C, 0xDFF7085C, 0xA4AEE3EB]

tmp = []
for i in cmp_data:
    tmp+=de_cmp(i)
print(tmp)

for i in range(256):
    tmp = decrypt(tmp, crypto_table)
    tmp = reverse_order(tmp, revsere_table)
print(''.join(chr(i) for i in tmp))
```