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
    addl $4,%esp
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
    unsigned long page[MAX_ARG_PAGES];
    int i,argc,envc;
    int e_uid, e_gid;
    int retval;
    int sh_bang = 0;
    // 设置参数或环境变量在进程空间的初始偏移指针
    unsigned long p=PAGE_SIZE*MAX_ARG_PAGES-4;

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
    // 长度 a_trsize 不等于 0、或者数据重定位信息长度不等于 0、或者代码段+数据段+堆段长度超过 50MB、
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

    // 重新设置进程2的局部描述符表
    // 根据 a_text 修改局部表中描述符基址和段限长,并将参数和环境空间页面放置在数据段末端。
    // 执行下面语句之后,p 此时是以数据段起始处为原点的偏移值,仍指向参数和环境空间数据开始处,
    // 也即转换成为堆栈的指针。
    p += change_ldt(ex.a_text,page)-MAX_ARG_PAGES*PAGE_SIZE;
    // create_tables()在新用户堆栈中创建环境和参数变量指针表,并返回该堆栈指针。
    p = (unsigned long) create_tables((char *)p,argc,envc);
    // 修改当前进程各字段为新执行程序的信息。
    // 令进程代码段尾值字段 end_code = a_text;
    // 令进程数据段尾字段 end_data = a_data + a_text;
    // 令进程堆结尾字段 brk = a_text + a_data + a_bss。
    current->brk = ex.a_bss +
        (current->end_data = ex.a_data +
        (current->end_code = ex.a_text));
    current->start_stack = p & 0xfffff000;
    // 设置进程堆栈开始字段为堆栈指针所在的页面,并重新设置进程的有效用户 id 和有效组 id。
    current->euid = e_uid;
    current->egid = e_gid;
    // 初始化一页 bss 段数据,全为零。
    i = ex.a_text+ex.a_data;
    while (i&0xfff)
        put_fs_byte(0,(char *) (i++));
    // 将原调用系统中断的程序在堆栈上的代码指针替换为指向新执行程序的入口点,并将堆栈指针替换
    // 为新执行程序的堆栈指针。返回指令将弹出这些堆栈数据并使得 CPU 去执行新的执行程序,因此不会
    // 返回到原调用系统中断的程序中去了。
    eip[0] = ex.a_entry;        /* eip, magic happens :-) */
    eip[3] = p;            /* stack pointer */
    return 0;
exec_error2:
    iput(inode);
exec_error1:
    for (i=0 ; i<MAX_ARG_PAGES ; i++)
        free_page(page[i]);
    return(retval);
}
```