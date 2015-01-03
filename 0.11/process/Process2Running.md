Linux 0.11 进程2的执行
================================================================================

在进程1创建完进程2之后:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess2.md

接下来轮转到进程2中执行进程2的代码.

进程2的执行
--------------------------------------------------------------------------------

path: init/main.c
```
static char * argv_rc[] = { "/bin/sh", NULL };
static char * envp_rc[] = { "HOME=/", NULL };
...
void init(void)
{
    int pid,i;

    setup((void *) &drive_info);
    (void) open("/dev/tty0",O_RDWR,0);
    (void) dup(0);
    (void) dup(0);
    printf("%d buffers = %d bytes buffer space\n\r",NR_BUFFERS,
        NR_BUFFERS*BLOCK_SIZE);
    printf("Free mem: %d bytes\n\r",memory_end-main_memory_start);

    if (!(pid=fork())) { // 括号里面为进程2执行的代码
        close(0);  // 关闭标准输入设备文件
        if (open("/etc/rc",O_RDONLY,0))  // 用rc文件替换该设备文件
            _exit(1);
        execve("/bin/sh",argv_rc,envp_rc); // 加载shell程序
        _exit(2);
    }
    if (pid>0)
        while (pid != wait(&i)) // 进程1等待子进程退出，最终会切换到进程2执行.
            /* nothing */;
    ...
}
```

close函数最终会映射到sys_close函数中执行，下面我们分析sys_close函数的执行：

path: fs/open.c
```
int sys_close(unsigned int fd)
{
    struct file * filp;

    if (fd >= NR_OPEN)
        return -EINVAL;
    current->close_on_exec &= ~(1<<fd);
    // 由于进程2继承了进程1的管理信息，因此其filp[20]中文件指针存储情况与进程1是一致的.
    // 获取进程2标准输入设备文件的指针
    if (!(filp = current->filp[fd]))
        return -EINVAL;
    // 进程2与该设备文件解除关系
    current->filp[fd] = NULL;
    if (filp->f_count == 0)
        panic("Close: file count is 0");
    if (--filp->f_count)  // 该设备文件引用计数递减
        return (0);
    iput(filp->f_inode);  // 如果没有进程引用该文件则释放文件对应的i节点.
    return (0);
}
```

close(0)就是要将当前进程(进程2)的filp[20]第一项清空(就是关闭标准输入设备文件tty0)并递减
file_table[64]中f_count的计数. 接下来调用open()函数, open函数的调用过程参考:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/OpenTtyAndDup.md

在打开rc文件之后，就会在当前进程filp[20]中选择第一项来建立进程2与rc文件i节点关系，以此来达到
"rc"来替换"tty0"的效果. 接下来，进程2将要调用execve()函数开始加载shell程序，执行代码如下所示:
execve函数最终会映射到sys_execve中去执行，代码如下所示:

path: kernel/system_call.s
```
.align 2
sys_execve:
    // 把eip值 -- "所在栈空间的地址值"压栈.
    // 注意: int 0x80导致CPU硬件自动将ss、esp、eflags、cs、eip的值压栈
    lea EIP(%esp),%eax
    pushl %eax
    call do_execve
    addl $4,%esp  # 丢弃调用时压入栈的 EIP 值。
    ret
```

调用do_execve函数来加载执行shell程序
--------------------------------------------------------------------------------

接下来调用do_execve函数，其执行过程如下所示, 由于这个函数的执行过程比较长，我们分以下几个部分来介绍:

### 基础知识

path: linux/a.out.h
```
执行文件头结构。
// =============================
// unsigned long a_magic  // 执行文件魔数。使用 N_MAGIC 等宏访问。
// unsigned a_text        // 代码长度,字节数。
// unsigned a_data        // 数据长度,字节数。
// unsigned a_bss         // 文件中的未初始化数据区长度,字节数。
// unsigned a_syms        // 文件中的符号表长度,字节数。
// unsigned a_entry       // 执行开始地址。
// unsigned a_trsize      // 代码重定位信息长度,字节数。
// unsigned a_drsize      // 数据重定位信息长度,字节数。
// -----------------------------
struct exec {
  unsigned long a_magic;    /* Use macros N_MAGIC, etc for access */
  unsigned a_text;        /* length of text, in bytes */
  unsigned a_data;        /* length of data, in bytes */
  unsigned a_bss;        /* length of uninitialized data area for file, in bytes */
  unsigned a_syms;        /* length of symbol table data in file, in bytes */
  unsigned a_entry;        /* start address */
  unsigned a_trsize;        /* length of relocation info for text, in bytes */
  unsigned a_drsize;        /* length of relocation info for data, in bytes */
};
```
a.out.h 文件不属于标准 C 库,是内核专用的头文件。但由于与标准库的头文件名没有冲突,因此在
Linux 系统中一般可以放置 /usr/include/ 目录下,以供涉及相关内容的程序使用。
该头文件主要定义了二进制执行文件a.out(Assembley out) 的格式。其中包括三个数据结构和一些宏函数。
从 Linux 0.9x 版内核开始(从 0.96 开始),系统直接采用了 GNU 的头文件 a.out.h 。因此造成在 Linux
0.9x 下编译的程序不能在 Linux 0.1x 系统上运行。

下面分析一下两个a.out头文件的区别之处,并说明如何让 0.9x 下的执行文件也能在 0.1x 下运行。

本文件与GNU的 a.out.h 文件的主要区别在于exec结构的第一个字段 a_magic. GNU的该文件字段
名称是a_info ,并且把该字段又分成 3 个子域:
* 标志域(Flags)
* 机器类型域(Machine Type)
* 魔数域(Magic Number)

同时为机器类型域定义了相应的宏 N_MACHTYPE 和 N_FLAGS. 如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/a_info.png

在Linux 0.9x 系统中,对于采用静态库连接的执行文件,图中各域注释中括号内的值是该字段的默认值。
这种二进制执行文件开始处的 4 个字节是:
```
0x0b, 0x01, 0x64, 0x00
```
而这里的头文件仅定义了魔数域。因此,在Linux 0.1x系统中一个a.out格式的二进制执行文件开始的4个字节是:
```
0x0b, 0x01, 0x00, 0x00
```
可以看出,采用 GNU 的 a.out 格式的执行文件与 Linux 0.1x 系统上编译出的执行文件的区别仅在机器类型域。
因此我们可以把Linux 0.9x上的 a.out 格式执行文件的机器类型域(第 3 个字节)清零,让其运行在0.1x系统中。
只要被移植的执行文件所调用的系统调用都已经在 0.1x 系统中实现即可。
GNU 的 a.out.h 头文件与这里的 a.out.h 头文件在其它方面没有什么区别。

### do_execve

##### 检测shell文件

检测shell文件包含两个部分:

* 检测i节点属性
* 检测文件头属性

path: fs/exec.c
```
int do_execve(unsigned long * eip,long tmp,char * filename,
    char ** argv, char ** envp)
{
    struct m_inode * inode;
    struct buffer_head * bh;
    struct exec ex;
    unsigned long page[MAX_ARG_PAGES]; // MAX_ARG_PAGES = 32
    int i,argc,envc;
    int e_uid, e_gid;
    int retval;
    int sh_bang = 0;
    // 设置参数或环境变量在进程空间的初始偏移指针
    unsigned long p = PAGE_SIZE*MAX_ARG_PAGES-4;

    // eip[1]中是代码段寄存器cs(cs是int 80中断自动压栈保存的),其中的选择符不可以是内核段选择符,
    // 也即内核不能调用本函数。
    if ((0xffff & eip[1]) != 0x000f)
        panic("execve called from supervisor mode");
    // 清空参数和环境变量的页面指针数组(表)。
    for (i=0 ; i<MAX_ARG_PAGES ; i++)    /* clear page-table */
        page[i]=0;
    // 获取shell程序所在文件的i节点
    if (!(inode=namei(filename)))        /* get executables inode */
        return -ENOENT;
    argc = count(argv);  // 统计参数个数
    envc = count(envp);  // 统计环境变量个数

restart_interp:
    if (!S_ISREG(inode->i_mode)) {    /* must be regular file */
        retval = -EACCES;
        goto exec_error2;
    }
    i = inode->i_mode;
    // 通过检测shell程序i节点的uid和gid属性，来判断进程2是否由权限执行shell程序.
    // 如果文件的设置用户ID标志(set-user-id)置位的话,则后面执行进程的有效用户ID(euid)就
    // 设置为文件的用户ID,否则设置成当前进程的 euid。这里将该值暂时保存在 e_uid 变量中;
    // 如果文件的设置组ID 标志(set-group-id)置位的话,则执行进程的有效组 ID(egid)就设置为
    // 文件的组 ID。否则设置成当前进程的 egid.
    e_uid = (i & S_ISUID) ? inode->i_uid : current->euid;
    e_gid = (i & S_ISGID) ? inode->i_gid : current->egid;
    // 如果文件属于运行进程的用户,则把文件属性字右移 6 位,则最低 3 位是文件宿主的访问权限标志。
    // 否则的话如果文件与运行进程的用户属于同组,则使属性字最低 3 位是文件组用户的访问权限标志。
    // 否则属性字最低 3 位是其他用户访问该文件的权限。
    if (current->euid == inode->i_uid)
        i >>= 6;
    else if (current->egid == inode->i_gid)
        i >>= 3;
    // 如果上面相应用户没有执行权并且其他用户也没有任何权限,并且不是超级用户,则表明该文件不
    // 能被执行。于是置不可执行出错码,跳转到exec_error2处去处理。
    if (!(i & 1) &&
        !((inode->i_mode & 0111) && suser())) {
        retval = -ENOEXEC;
        goto exec_error2;
    }

    // 读取执行文件的第一块数据到高速缓冲区,若出错则置出错码,跳转到 exec_error2 处去处理。
    // 通过i节点中提供的设备号和块号(文件头的块号为i_zone[0])信息，将文件头载入缓冲块.
    if (!(bh = bread(inode->i_dev,inode->i_zone[0]))) {
        retval = -EACCES;
        goto exec_error2;
    }
    // 下面对执行文件的头结构数据进行处理,首先让ex指向执行头部分的数据结构。
    ex = *((struct exec *) bh->b_data);    /* read exec-header */
    // 如果执行文件开始的两个字节为'#!', 并且sh_bang标志没有置位,则处理脚本文件的执行。
    // 在这里处理的是shell程序，以下代码将不会被执行
    if ((bh->b_data[0] == '#') && (bh->b_data[1] == '!') && (!sh_bang)) {
        /*
         * This section does the #! interpretation.
         * Sorta complicated, but hopefully it will work.  -TYT
         */

        char buf[1023], *cp, *interp, *i_name, *i_arg;
        unsigned long old_fs;
        // 复制执行程序头一行字符'#!'后面的字符串到buf中,其中含有脚本处理程序名。
        strncpy(buf, bh->b_data+2, 1022);
        // 释放高速缓冲块和该执行文件i节点。
        brelse(bh);
        iput(inode);
        // 取第一行内容,并删除开始的空格、制表符。
        buf[1022] = '\0';
        if ((cp = strchr(buf, '\n'))) {
            *cp = '\0';
            for (cp = buf; (*cp == ' ') || (*cp == '\t'); cp++);
        }
        // 若该行没有其它内容,则出错。置出错码,跳转到 exec_error1 处。
        if (!cp || *cp == '\0') {
            retval = -ENOEXEC; /* No interpreter name found */
            goto exec_error1;
        }
        // 否则就得到了开头是脚本解释执行程序名称的一行内容。
        interp = i_name = cp;
        i_arg = 0;
        // 下面分析该行。首先取第一个字符串,其应该是脚本解释程序名,i_name指向该名称。
        for ( ; *cp && (*cp != ' ') && (*cp != '\t'); cp++) {
             if (*cp == '/')
                i_name = cp+1;
        }
        // 若文件名后还有字符,则应该是参数串,令 i_arg 指向该串。
        if (*cp) {
            *cp++ = '\0';
            i_arg = cp;
        }
        /*
         * OK, we've parsed out the interpreter name and
         * (optional) argument.
         */
         /*
          * OK,我们已经解析出解释程序的文件名以及(可选的)参数。
          */
        // 若 sh_bang 标志没有设置,则设置它,并复制指定个数的环境变量串和参数串到参数和环境空间中。
        if (sh_bang++ == 0) {
            p = copy_strings(envc, envp, page, p, 0);
            p = copy_strings(--argc, argv+1, page, p, 0);
        }
        /*
         * Splice in (1) the interpreter's name for argv[0]
         *           (2) (optional) argument to interpreter
         *           (3) filename of shell script
         *
         * This is done in reverse order, because of how the
         * user environment and arguments are stored.
         */
         /*
          * 拼接 (1) argv[0]中放解释程序的名称
          *
          * (2) (可选的)解释程序的参数
          *
          * (3) 脚本程序的名称
          *
          * 这是以逆序进行处理的,是由于用户环境和参数的存放方式造成的。
          */
          // 复制脚本程序文件名到参数和环境空间中。
        p = copy_strings(1, &filename, page, p, 1);
        // 复制解释程序的参数到参数和环境空间中。
        argc++;
        if (i_arg) {
            p = copy_strings(1, &i_arg, page, p, 2);
            argc++;
        }
        // 复制解释程序文件名到参数和环境空间中。若出错,则置出错码,跳转到 exec_error1。
        p = copy_strings(1, &i_name, page, p, 2);
        argc++;
        if (!p) {
            retval = -ENOMEM;
            goto exec_error1;
        }
        /*
         * OK, now restart the process with the interpreter's inode.
         */
        /*
         * OK,现在使用解释程序的 i 节点重启进程。
         */
         // 保留原fs段寄存器(原指向用户数据段),现置其指向内核数据段。
        old_fs = get_fs();
        set_fs(get_ds());
        // 取解释程序的 i 节点,并跳转到 restart_interp 处重新处理。
        if (!(inode=namei(interp))) { /* get executables inode */
            set_fs(old_fs);
            retval = -ENOENT;
            goto exec_error1;
        }
        set_fs(old_fs);
        goto restart_interp;
    }
    // 释放该缓冲区
    brelse(bh);
    // 下面对执行头信息进行处理。
    // 对于下列情况,将不执行程序: 如果执行文件不是需求页可执行文件(ZMAGIC)、或者代码重定位部分
    // 长度 a_trsize 不等于 0, 或者数据重定位信息长度不等于0或者代码段+数据段+堆段长度超过 50MB
    // 或者 i 节点表明的该执行文件长度小于代码段+数据段+符号表长度+执行头部分长度的总和。
    if (N_MAGIC(ex) != ZMAGIC || ex.a_trsize || ex.a_drsize ||
        ex.a_text+ex.a_data+ex.a_bss>0x3000000 ||
        inode->i_size < ex.a_text+ex.a_data+ex.a_syms+N_TXTOFF(ex)) {
        retval = -ENOEXEC;
        goto exec_error2;
    }
    // 如果执行文件执行头部分长度不等于一个内存块大小(1024 字节),也不能执行。转 exec_error2。
    if (N_TXTOFF(ex) != BLOCK_SIZE) {
        printk("%s: N_TXTOFF != BLOCK_SIZE. See a.out.h.", filename);
        retval = -ENOEXEC;
        goto exec_error2;
    }

    ...
}
```

#### 为shell程序的执行作准备

* 加载参数和环境变量
* 调整进程2的管理结构: 进程2有了自己对应的程序shell,因此要对自身task_struct进行调整以适应此变化,
  比如，原来与父进程(进程1)共享的文件，内存页面，现在要解除关系，要根据shell程序自身情况，量身定制
  LDT, 并设置代码段, 数据段，栈段等控制变量.

path: fs/exec.c
```
int do_execve(unsigned long * eip,long tmp,char * filename,
    char ** argv, char ** envp)
{
    ...
    // 如果 sh_bang 标志没有设置,则复制指定个数的环境变量字符串和参数到参数和环境空间中。
    // 若 sh_bang 标志已经设置,则表明是将运行脚本程序,此时环境变量页面已经复制,无须再复制。
    if (!sh_bang) {
        p = copy_strings(envc,envp,page,p,0); // 将环境变量复制到进程空间
        p = copy_strings(argc,argv,page,p,0); // 将参数复制到进程空间
        // 如果 p=0,则表示环境变量与参数空间页面已经被占满,容纳不下了。转至出错处理处。
        if (!p) {
            retval = -ENOMEM;
            goto exec_error2;
        }
    }

    /* OK, This is the point of no return */
    /* OK,下面开始就没有返回的地方了 */

    // 如果原程序也是一个执行程序,则释放其i节点,并让进程executable字段指向新程序i节点。
    if (current->executable)
        iput(current->executable);
    // 此时肯定没有，所以用shell程序文件的i节点设置executable
    current->executable = inode;
    // 清复位所有信号处理句柄。但对于 SIG_IGN 句柄不能复位,因此在for内需添加一条
    // if 语句:if (current->sa[I].sa_handler != SIG_IGN)。这是源代码中的一个 bug。
    for (i=0 ; i<32 ; i++)
        current->sigaction[i].sa_handler = NULL;
    // 根据执行时关闭(close_on_exec)文件句柄位图标志,关闭指定的打开文件,并复位该标志。
    for (i=0 ; i<NR_OPEN ; i++)
        if ((current->close_on_exec>>i)&1)
            sys_close(i);
    current->close_on_exec = 0;
    // 解除进程2与进程1共享的页面关系
    free_page_tables(get_base(current->ldt[1]),get_limit(0x0f));
    free_page_tables(get_base(current->ldt[2]),get_limit(0x17));
    if (last_task_used_math == current)
        last_task_used_math = NULL;
    current->used_math = 0; // 将进程2的数学协处理器的使用标志清零

    // 重新设置进程2的局部描述符表:
    // 根据a_text修改局部表中描述符基址和段限长,并将参数和环境空间页面放置在数据段末端。
    // 执行下面语句之后, p此时是以数据段起始处为原点的偏移值,仍指向参数和环境空间数据开始处,
    // 也即转换成为堆栈的指针。
    p += change_ldt(ex.a_text,page)-MAX_ARG_PAGES*PAGE_SIZE;
    // create_tables()在新进程堆栈(内核栈)中创建环境和参数变量指针表,并返回该栈指针。
    p = (unsigned long) create_tables((char *)p,argc,envc);
    // 修改当前进程各字段为新执行程序的信息。
    // 令进程代码段尾值字段 end_code = a_text;
    // 令进程数据段尾字段 end_data = a_data + a_text;
    // 令进程堆结尾字段 brk = a_text + a_data + a_bss。
    current->brk = ex.a_bss +
        (current->end_data = ex.a_data +
        (current->end_code = ex.a_text));
    // 设置进程堆栈开始字段为堆栈指针所在的页面,并重新设置进程的有效用户 id 和有效组 id。
    current->start_stack = p & 0xfffff000;
    current->euid = e_uid;
    current->egid = e_gid;
    // 初始化一页 bss 段数据,全为零。
    i = ex.a_text+ex.a_data;
    while (i&0xfff)
        put_fs_byte(0,(char *) (i++));
    // 将原调用系统中断的程序在堆栈上的代码指针替换为指向新执行程序的入口点.
    // 并将堆栈指针替换为新执行程序的堆栈指针。
    // iret指令将弹出这些堆栈数据并使得CPU去执行新的执行程序,因此不会返回到原调用系统中断的程序中去.
    // 在这里用shell程序的起始地址设置eip, 用进程2新的堆栈地址值设置esp, 这样软中断从iret返回后
    // 进程2将从shell程序开始执行.
    // int 0x80导致CPU硬件自动将ss、esp、eflags、cs、eip的值压栈
    // (gdb) p/x eip[0] - eip
    // $6 = 0x0
    // (gdb) p/x eip[1] - cs
    // $7 = 0xf
    // (gdb) p/x eip[2] - eflags
    // $8 = 0x202
    // (gdb) p/x eip[3] - esp
    // $9 = 0x3ffffd0
    // (gdb) p/x eip[4] - ss
    // $10 = 0x17
    eip[0] = ex.a_entry;  /* eip, magic happens :-) */ // 设置进程2开始执行的EIP.
    eip[3] = p;           /* esp, stack pointer */ // 设置进程2的栈顶指针.
    //
    return 0;
exec_error2:
    iput(inode);
exec_error1:
    for (i=0 ; i<MAX_ARG_PAGES ; i++)
        free_page(page[i]);
    return(retval);
}
```

shell程序开始执行后，其线性地址空间对应的程序内容并未加载，也就不存在相应的页面，
因此就会产生一个"页异常"中断.此中断会进一步调用"缺页中断"处理程序来分配该页面，并
加载一页shell程序. 执行流程如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/memory/PageFault.md

总结补充
--------------------------------------------------------------------------------

由于do_execve函数执行代码过长，下面我们对该函数进行总结和补充:

### do_execve

它是系统中断调用(int 0x80)功能号__NR_execve()调用的C处理函数,是exec()函数簇的主要实现函数.

其主要功能为:

* 执行对参数和环境变量空间页面的初始化操作.

**设置初始页面空间起始指针** -->  **初始化页面空间指针数组为NULL** -->
**根据执行文件名取执行对象的i节点** --> **计算参数个数和环境变量个数** -->
**检查文件类型,执行权限**

*  根据执行文件开始部分的头数据结构,对其中信息进行处理.

**根据被执行文件i节点读取文件头部信息** -->
**若是Shell脚本程序(第一行以"#!"开始),则分析Shell程序名及其参数,并以被执行文件作为参数执行该执行的Shell程序** -->
**执行根据文件的幻数以及段长度等信息判断是否可执行**

* 对当前调用进程进行运行新文件前初始化操作.

**指向新执行文件的i节点** --> **复位信号处理句柄** --> **根据头结构信息设置局部描述符基址和段长**
--> **设置参数和环境参数页面指针** --> **修改进程各执行字段内容**

* 替换堆栈上原调用execve()程序的返回地址为新执行程序运行地址,运行新加载的程序

execve()函数有大量对参数和环境空间的处理操作,参数和环境空间共可有MAX_ARG_PAGES个页面,
总长度可达128kB(MAX_ARG_PAGES * PAGE_SIZE = 32 * 4KB)字节。
在该空间中存放数据的方式类似于堆栈操作,即是从假设的128kB空间末端处逆向开始存放参数或环境变量字符串。
在初始时,程序定义了一个指向该空间末端(128kB-4 字节)处空间内偏移值p,该偏移值随着存放数据的增多而后退,
p明确地指出了当前参数环境空间中还剩余多少可用空间. 如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/argv_env.png

下面我们以将环境变量和参数复制为例来讲解p指针的移动过程:
```
// 设置参数或环境变量在进程空间的初始偏移指针
unsigned long p = PAGE_SIZE*MAX_ARG_PAGES-4;

// 如果sh_bang标志没有设置,则复制指定个数的环境变量字符串和参数到参数和环境空间中。
// 若sh_bang标志已经设置,则表明是将运行脚本程序,此时环境变量页面已经复制,无须再复制。
if (!sh_bang) {
    p = copy_strings(envc,envp,page,p,0); // 将环境变量复制到进程空间
    p = copy_strings(argc,argv,page,p,0); // 将参数复制到进程空间
    // 如果 p=0,则表示环境变量与参数空间页面已经被占满,容纳不下了。转至出错处理处。
    if (!p) {
        retval = -ENOMEM;
        goto exec_error2;
    }
}
```

### copy_strings

上面这段代码是do_execve中将环境变量和参数复制到进程空间的代码，复制操作由copy_strings完成，
其实现如下所示:

path: fs/exec.c
```
/*
 * 'copy_string()' copies argument/envelope strings from user
 * memory to free pages in kernel mem. These are in a format ready
 * to be put directly into the top of new user memory.
 *
 * Modified by TYT, 11/24/91 to add the from_kmem argument, which specifies
 * whether the string and the string array are from user or kernel segments:
 *
 * from_kmem     argv *        argv **
 *    0          user space    user space
 *    1          kernel space  user space
 *    2          kernel space  kernel space
 *
 * We do this by playing games with the fs segment register.  Since it
 * it is expensive to load a segment register, we try to avoid calling
 * set_fs() unless we absolutely have to.
 */
//// 复制指定个数的参数字符串到参数和环境空间。
// 参数:argc - 欲添加的参数个数; argv - 参数指针数组; page - 参数和环境空间页面指针数组。
//
// p - 在参数表空间中的偏移指针,始终指向已复制串的头部; from_kmem - 字符串来源标志。
// 在 do_execve()函数中, p初始化为指向参数表(128kB)空间的最后一个长字处,参数字符串
// 是以堆栈操作方式逆向往其中复制存放的, 因此p指针会始终指向参数字符串的头部。
// 返回: 参数和环境空间当前头部指针。
static unsigned long copy_strings(int argc,char ** argv,unsigned long *page,
        unsigned long p, int from_kmem)
{
    char *tmp, *pag=NULL;
    int len, offset = 0;
    unsigned long old_fs, new_fs;

    if (!p)
        return 0;    /* bullet-proofing */
    // 取ds寄存器值到 new_fs,并保存原 fs 寄存器值到 old_fs。
    // 注意: 在system_call中设置ds指向的是内核空间，而fs依旧指向的是用户空间
    new_fs = get_ds();
    old_fs = get_fs();
    // 如果字符串和字符串数组来自内核空间,则设置 fs 段寄存器指向内核数据段(ds)
    if (from_kmem==2)
        set_fs(new_fs);
    // 循环处理各个参数,从最后一个参数逆向开始复制,复制到指定偏移地址处.
    while (argc-- > 0) {
        // 如果字符串在用户空间而字符串数组在内核空间,则设置 fs 段寄存器指向内核数据段(ds)。
        if (from_kmem == 1)
            set_fs(new_fs);
        // 从最后一个参数开始逆向操作,取 fs 段中最后一参数指针到 tmp,如果为空,则出错死机。
        if (!(tmp = (char *)get_fs_long(((unsigned long *)argv)+argc)))
            panic("argc is wrong");
        // 如果字符串在用户空间而字符串数组在内核空间,则恢复 fs 段寄存器原值
        if (from_kmem == 1)
            set_fs(old_fs);
        // 计算该参数字符串长度 len,并使 tmp 指向该参数字符串末端
        len=0;        /* remember zero-padding */
        do {
            len++;
        } while (get_fs_byte(tmp++));
        // 如果该字符串长度超过此时参数和环境空间中还剩余的空闲长度,则恢复 fs 段寄存器并返回 0
        if (p-len < 0) {    /* this shouldn't happen - 128kB */
            set_fs(old_fs);
            return 0;
        }
        // 复制 fs 段中当前指定的参数字符串,是从该字符串尾逆向开始复制
        while (len) {
            --p; --tmp; --len;
            // 函数刚开始执行时,偏移变量 offset 被初始化为 0,因此若 offset-1<0,说明是首次复制字符串,
            // 则令其等于 p 指针在页面内的偏移值,并申请空闲页面。
            if (--offset < 0) {
                offset = p % PAGE_SIZE;
                if (from_kmem==2)
                    set_fs(old_fs);
                // 如果当前偏移值p所在的串空间页面指针数组项 page[p/PAGE_SIZE]==0,
                // 表示相应页面还不存在,则需申请新的内存空闲页面,将该页面指针填入指针数组,
                // 并且也使 pag 指向该新页面,若申请不到空闲页面则返回 0。
                if (!(pag = (char *) page[p/PAGE_SIZE]) &&
                    !(pag = (char *) page[p/PAGE_SIZE] =
                      (unsigned long *) get_free_page()))
                    return 0;
                if (from_kmem==2)
                    set_fs(new_fs);

            }
            // 从 fs 段中复制参数字符串中一字节到 pag+offset 处。
            *(pag + offset) = get_fs_byte(tmp);
        }
    }
    if (from_kmem==2)
        set_fs(old_fs);
    // 最后,返回参数和环境空间中已复制参数信息的头部偏移值.
    return p;
}
```

### change_ldt

change_ldt用于修改局部描述符表中的描述符基址和段限长,并将参数和环境空间页面放置在数据段末端。

path: fs/exec.c
```
// 重新设置进程2的局部描述符表:
// 根据a_text修改局部表中描述符基址和段限长,并将参数和环境空间页面放置在数据段末端。
// 执行下面语句之后, p此时是以数据段起始处为原点的偏移值,仍指向参数和环境空间数据开始处,
// 也即转换成为堆栈的指针。
p += change_ldt(ex.a_text,page)-MAX_ARG_PAGES*PAGE_SIZE;
```

path: fs/exec.c
```
// 参数: text_size - 执行文件头部中a_text字段给出的代码段长度值; page - 参数和环境空间页面指针数组。
// 返回: 数据段限长值(64MB)。
static unsigned long change_ldt(unsigned long text_size,unsigned long * page)
{
    unsigned long code_limit,data_limit,code_base,data_base;
    int i;

    // 根据执行文件头部 a_text 值,计算以页面长度为边界的代码段限长。并设置数据段长度为 64MB
    code_limit = text_size+PAGE_SIZE -1;
    code_limit &= 0xFFFFF000;
    data_limit = 0x4000000;

    // 取当前进程中局部描述符表代码段描述符中代码段基址,代码段基址与数据段基址相同。
    code_base = get_base(current->ldt[1]);
    data_base = code_base;

    // 重新设置局部表中代码段和数据段描述符的基址和段限长。
    set_base(current->ldt[1],code_base);
    set_limit(current->ldt[1],code_limit);
    set_base(current->ldt[2],data_base);
    set_limit(current->ldt[2],data_limit);

    /* make sure fs points to the NEW data segment */
    /* 要确信 fs 段寄存器已指向新的数据段 */
    // fs 段寄存器中放入局部表数据段描述符的选择符(0x17)。
    __asm__("pushl $0x17\n\tpop %%fs"::);

    // 将参数和环境空间已存放数据的页面(共可有MAX_ARG_PAGES页,128kB)放到数据段线性地址的
    // 末端。是调用函数 put_page()进行操作的
    data_base += data_limit;
    for (i=MAX_ARG_PAGES-1 ; i>=0 ; i--) {
        data_base -= PAGE_SIZE;
        /* 因为page[31]在为参数和环境变量空间调用get_free_page给他分配了一个空闲的
         * 物理页面用来保存参数和环境变量。但是进程2是采用线性地址来获取对应的参数和
         * 环境变量的，所以要将物理页面映射到线性地址上,就应该修改页目录表和页表的相关内容,
         * 这样进程才能通过线性地址找到相应的物理页面。put_page函数所做的工作正是将线性地址映射到物理地址
         * page[i]指向的页面是真实物理地址页面，data_base指向的是线性地址页面.
         */
        if (page[i])
            put_page(page[i],data_base);
    }
    return data_limit;
}
```

### create_tables

```
/*
* create_tables()函数在进程空间内存中解析环境变量和参数字符串,由此
* 创建指针表,并将它们的地址放到"堆栈"上,然后返回新栈的指针值。
*/
// 参数: p - 以数据段为起点的参数和环境信息偏移指针; argc - 参数个数; envc -环境变量数。
// 返回: 栈指针。
static unsigned long * create_tables(char * p,int argc,int envc)
{
    unsigned long *argv,*envp;
    unsigned long * sp;
    // 堆栈指针是以 4 字节(1 节)为边界寻址的,因此这里让 sp 为 4 的整数倍。
    sp = (unsigned long *) (0xfffffffc & (unsigned long) p);
    // sp 向下移动,空出环境参数占用的空间个数,并让环境参数指针 envp 指向该处。
    sp -= envc+1;
    envp = sp;
    // sp 向下移动,空出命令行参数指针占用的空间个数,并让 argv 指针指向该处。
    // 下面指针加 1,sp 将递增指针宽度字节值。
    sp -= argc+1;
    argv = sp;
    // 将环境参数指针 envp 和命令行参数指针以及命令行参数个数压入堆栈。
    put_fs_long((unsigned long)envp,--sp);
    put_fs_long((unsigned long)argv,--sp);
    put_fs_long((unsigned long)argc,--sp);
    // 将命令行各参数指针放入前面空出来的相应地方,最后放置一个 NULL 指针。
    while (argc-->0) {
        put_fs_long((unsigned long) p,argv++);
        while (get_fs_byte(p++)) /* nothing */ ; // p 指针前移 4 字节。
    }
    put_fs_long(0,argv);
    // 将环境变量各指针放入前面空出来的相应地方,最后放置一个 NULL 指针。
    while (envc-->0) {
        put_fs_long((unsigned long) p,envp++);
        while (get_fs_byte(p++)) /* nothing */ ;
    }
    put_fs_long(0,envp);
    return sp;
    // 返回构造的当前新堆栈指针。
}
```

create_tables() 函数用于根据给定的当前堆栈指针值 p 以及参数变量个数值 argc 和环境变量个数
envc ,在新的程序堆栈中创建环境和参数变量指针表,并返回此时的堆栈指针值 sp 。创建完毕后堆栈指
针表的形式见下图所示：

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/create_tables.png

在经过上述步骤之后，我们可以看到一个可执行程序进程的代码和数据在虚拟的线性地址空间中的
分布情况,如下图所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/proc_lineaddr_layout.png

每个进程在线性地址中都是从nr*64M的地址位置开始(nr是任务号),占用线性地址空间的范围是64M。
其中最后部的环境参数数据块最长为128K,其左面起始堆栈指针。在进程创建时bss段的第一页被初始化为全0。