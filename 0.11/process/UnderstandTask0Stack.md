linux-0.12任务0堆栈需要保持干净的原因理解
================================================================================

堆栈这一块确实是有点不好理解，尤其对于为啥进程1运行前进程0的堆栈要保持“干净”这个问题，
也就是产生进程1的fork和pause为什么要用内联汇编而不能用函数调用的问题。
我的理解是:
因为fork函数的特殊性，它会“两次返回”，一次返回子进程pid，一次返回0。
如果fork和pause都采用函数调用，那么调用call pause指令压入堆栈的返回地址会覆盖call fork时压入的地址，
因为他们都在user_stack的同一个地方，因此fork第二次返回时会去执行call pause的下一条指令：
一直调用pause函数的指令，而不是call fork的下一条指令：调用init的指令，因此内核陷入死循环。
如果只是其中一个使用函数调用，堆栈只被一个函数使用，就不会出现这种情况。这个分析还是有点抽象，下面看fork和pause都使用函数调用的调试过程。

```
(gdb) b 166
Breakpoint 2 at 0x69ba: file init/main.c, line 166.
(gdb) c
Continuing.

Breakpoint 2, main () at init/main.c:166
166        move_to_user_mode();
2: /x $esp = 0x3c2d0                         //如果不使用函数调用的话，那么这个地址就是“干净”的
1: x/3i $pc
=> 0x69ba :    mov    %esp,eax
   0x69bc :    push   $0x17
   0x69be :    push   eax
(gdb) n
167        if (!fork()) {
2: /x $esp = 0x3c2d0
1: x/3i $pc
=> 0x69d5 :    call   0x64c0   //调用fork函数，将0x69da入栈，这是返回后执行的语句
   0x69da :    test   eax,eax
   0x69dc :    jne    0x69e3
(gdb) si
fork () at init/main.c:25
25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2cc
1: x/3i $pc
=> 0x64c0 :    push   ebx
   0x64c1 :    sub    $0x10,%esp
   0x64c4 :    mov    $0x2,eax
(gdb) x /x 0x3c2cc
0x3c2cc :    0x000069da    //记住这个地址！
(gdb) si
0x000064c1    25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2c8
1: x/3i $pc
=> 0x64c1 :    sub    $0x10,%esp      //腾出一点堆栈空间
   0x64c4 :    mov    $0x2,eax
   0x64c9 :    mov    eax,ebx
(gdb)
25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2b8                          //因为函数调用，弄“脏”了0x3c2d0-0x3c2b8=0x18byte
1: x/3i $pc
=> 0x64c4 :    mov    $0x2,eax
   0x64c9 :    mov    eax,ebx
   0x64cb :    mov    ebx,eax
(gdb) si
0x000064c9    25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2b8
1: x/3i $pc
=> 0x64c9 :    mov    eax,ebx
   0x64cb :    mov    ebx,eax
   0x64cd :    int    $0x80
(gdb)
0x000064cb    25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2b8
1: x/3i $pc
=> 0x64cb :    mov    ebx,eax
   0x64cd :    int    $0x80
   0x64cf :    mov    eax,ebx
(gdb)
0x000064cd    25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2b8
1: x/3i $pc
=> 0x64cd :    int    $0x80
   0x64cf :    mov    eax,ebx     //系统调用后将执行将到这里执行，子进程1的eip也是指向这里
   0x64d1 :    mov    ebx,0xc(%esp)
(gdb)
0x000078e4 in system_call ()
2: /x $esp = 0x2a18c                         //进入fork系统调用，此时使用内核堆栈，即init_task所在页面末端
1: x/3i $pc
=> 0x78e4 :    push   %ds
   0x78e5 :    push   %es
   0x78e6 :    push   %fs

(gdb)
0x00007a2b in sys_fork ()
2: /x $esp = 0x2a158
1: x/3i $pc
=> 0x7a2b :    call   0x8649
   0x7a30 :    add    $0x14,%esp
   0x7a33 :    ret
(gdb)
copy_process (nr=1, ebp=246508, edi=4092, esi=917504, gs=23, none=30987, ebx=2, ecx=22000, edx=33, orig_eax=2, fs=23, es=23, ds=23, eip=25807, cs=15, eflags=518, esp=246456, ss=23) at fork.c:72
72    {
//eip=25807=0x64cf，将返回这个地址执行；esp=246456=0x3c2b8
//0x64cf :    mov    eax,ebx
2: /x $esp = 0x2a154
1: x/3i $pc
=> 0x8649 :    push   ebp
   0x864a :    push   edi
   0x864b :    push   %esi

(gdb)
0x00007968 in ret_from_sys_call ()
2: /x $esp = 0x2a18c
1: x/3i $pc
=> 0x7968 :    iret
   0x7969 :    lea    0x0(%esi),%esi
   0x796c :    push   %ds
(gdb)
0x000064cf in fork () at init/main.c:25
25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2b8
1: x/3i $pc
=> 0x64cf :    mov    eax,ebx
   0x64d1 :    mov    ebx,0xc(%esp)
   0x64d5 :    cmpl   $0x0,0xc(%esp)

(gdb)
0x000064f6    25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2cc
1: x/3i $pc
=> 0x64f6 :    ret
   0x64f7 :    push   ebx
   0x64f8 :    sub    $0x10,%esp
(gdb)
0x000069da in main () at init/main.c:167
167        if (!fork()) {
2: /x $esp = 0x3c2d0                    //到这里fork函数调用第一次返回，堆栈恢复正常
                                                     //但是0x3c2cc里的返回地址0x69da仍在
1: x/3i $pc
=> 0x69da :    test   eax,eax
   0x69dc :    jne    0x69e3
   0x69de :    call   0x6a39
(gdb) si
0x000069dc    167        if (!fork()) {
2: /x $esp = 0x3c2d0
1: x/3i $pc
=> 0x69dc :    jne    0x69e3
   0x69de :    call   0x6a39
   0x69e3 :    call   0x64f7
(gdb)
179            pause();
2: /x $esp = 0x3c2d0
1: x/3i $pc
=> 0x69e3 :    call   0x64f7    //这是引起堆栈混乱的关键，0x3c2cc里0x69da被覆盖成0x69e8
   0x69e8 :    jmp    0x69e3    //再次调用pause，陷入循环
   0x69ea :    sub    $0x2c,%esp
(gdb)
pause () at init/main.c:26
26    inline _syscall0(int,pause)
2: /x $esp = 0x3c2cc           //调用pause的堆栈情况和fork一样，pause调用schedule函数调度执行进程1
1: x/3i $pc
=> 0x64f7 :    push   ebx
   0x64f8 :    sub    $0x10,%esp
   0x64fb :    mov    $0x1d,eax
(gdb) x /x 0x3c2cc
0x3c2cc :    0x000069e8     //fork第二次返回时的返回地址，原来是0x69da
(gdb)
0x000064f8    26    inline _syscall0(int,pause)
2: /x $esp = 0x3c2c8
1: x/3i $pc
=> 0x64f8 :    sub    $0x10,%esp
   0x64fb :    mov    $0x1d,eax
   0x6500 :    mov    eax,ebx

(gdb) b sched.c:162
Breakpoint 3 at 0x701a: file sched.c, line 162.
(gdb) c
Continuing.

Breakpoint 3, schedule () at sched.c:162
162        switch_to(next);                 //pause调用schedule函数，调度进程1出来执行
2: /x $esp = 0x2a148
1: x/3i $pc
=> 0x701a :    mov    0x18(%esp),eax
   0x701e :    shl    $0x4,eax
   0x7021 :    lea    0x20(eax),edx

(gdb)
0x00007044    162        switch_to(next);
2: /x $esp = 0x2a148
1: x/3i $pc
=> 0x7044 :    ljmp   *0x8(%esp)  //跳到进程1
   0x7048 :    cmp    ecx,0x2ab0c
   0x704e :    jne    0x7052
(gdb)
0x000064cf in fork () at init/main.c:25
25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2b8
1: x/3i $pc
=> 0x64cf :    mov    eax,ebx         //参考上面copy_process的注释，这里fork开始第二次返回
   0x64d1 :    mov    ebx,0xc(%esp)
   0x64d5 :    cmpl   $0x0,0xc(%esp)

(gdb)
0x000064f6    25    inline _syscall0(int,fork)
2: /x $esp = 0x3c2cc
1: x/3i $pc
=> 0x64f6 :    ret                       //正常的话，应该是跟第一次返回一样，返回到0x64da
   0x64f7 :    push   ebx
   0x64f8 :    sub    $0x10,%esp
(gdb)
0x000069e8 in main () at init/main.c:179 //因为0x3c2cc内容被pause修改，fork第二次返回到0x69e8,即pause的返回地址
179            pause();
2: /x $esp = 0x3c2d0
1: x/3i $pc
=> 0x69e8 :    jmp    0x69e3
   0x69ea :    sub    $0x2c,%esp
   0x69ed :    lea    0x34(%esp),eax
```