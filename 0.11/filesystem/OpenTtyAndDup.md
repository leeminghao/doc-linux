Linux 0.11 进程1打开终端设备文件以及复制文件句柄
================================================================================

打开标准输入文件
--------------------------------------------------------------------------------

在加载完根文件系统之后，进程1在根文件系统支持下，通过调用open()函数来打开标准输入设备文件，并
执行如下代码:

path: init/main.c
```
void init(void)
{
    int pid,i;

    setup((void *) &drive_info);
    // 创建标准输入设备,其中,/dev/tty0是该文件的路径名
    (void) open("/dev/tty0",O_RDWR,0);
    (void) dup(0);  // 创建标准输出设备
    (void) dup(0);  // 创建标准错误输出设备
    // 在标准输出设备支持下，显示信息
    printf("%d buffers = %d bytes buffer space\n\r",NR_BUFFERS,
        NR_BUFFERS*BLOCK_SIZE);
    printf("Free mem: %d bytes\n\r",memory_end-main_memory_start);
    ...
}
```

### open

open()函数执行后产生软件中断，并最终映射到内核中sys_open函数去执行，执行代码如下所示:

path: lib/open.c
```
int open(const char * filename, int flag, ...)
{
    register int res;
    va_list arg;

    va_start(arg,flag);
    __asm__("int $0x80"
        :"=a" (res)
        :"0" (__NR_open),"b" (filename),"c" (flag),
        "d" (va_arg(arg,int)));
    if (res>=0)
        return res;
    errno = -res;
    return -1;
}
```

最终通过int 0x80号中断进入sys_open函数执行，执行代码如下所示:

path: include/linux/fs.h
```
#define NR_FILE 64
...
// 文件结构(用于在文件句柄与 i 节点之间建立关系)
struct file {
    unsigned short f_mode;    // 文件操作模式(RW 位)
    unsigned short f_flags;   // 文件打开和控制的标志。
    unsigned short f_count;   // 对应文件句柄(文件描述符)数。
    struct m_inode * f_inode; // 指向对应 i 节点。
    off_t f_pos;              // 文件位置(读写偏移值)。
};
```

path: fs/file_table.c
```
struct file file_table[NR_FILE];
```

path: fs/open.c
```
//// 打开(或创建)文件系统调用函数。
// 参数:
// filename: 是文件名; flag: 是打开文件标志: 只读 O_RDONLY、只写 O_WRONLY 或读写 O_RDWR,
// 以及 O_CREAT、O_EXCL、O_APPEND 等其它一些标志的组合,若本函数创建了一个新文件,则 mode
// 用于指定使用文件的许可属性,这些属性有 S_IRWXU(文件宿主具有读、写和执行权限)、S_IRUSR
// (用户具有读文件权限)、S_IRWXG(组成员具有读、写和执行权限)等等。对于新创建的文件,这些
// 属性只应用于将来对文件的访问,创建了只读文件的打开调用也将返回一个可读写的文件句柄。
// 若操作成功则返回文件句柄(文件描述符),否则返回出错码。
int sys_open(const char * filename,int flag,int mode)
{
    struct m_inode * inode;
    struct file * f;
    int i,fd;

    // 将用户设置的模式与进程的模式屏蔽码相与,产生许可的文件模式。
    mode &= 0777 & ~current->umask;
    // 搜索进程1进程描述符中文件结构指针数组,查找一个空闲项,若已经没有空闲项,则返回出错码。
    for(fd=0 ; fd<NR_OPEN ; fd++)
        if (!current->filp[fd])
            break;
    if (fd>=NR_OPEN)
        return -EINVAL;
    // 设置执行时关闭文件句柄位图,复位对应比特位。
    current->close_on_exec &= ~(1<<fd);

    // 令f指向文件表数组开始处, 遍历空闲文件结构项(句柄引用计数为0的项),若已经没有空闲
    // 文件表结构项,则返回出错码。
    f=0+file_table;  // 获取file_table[64]首地址
    for (i=0 ; i<NR_FILE ; i++,f++)
        if (!f->f_count) break;
    if (i>=NR_FILE)
        return -EINVAL;
    // 让进程的对应文件句柄的文件结构指针指向搜索到的文件结构,并令句柄引用计数递增1。
    (current->filp[fd]=f)->f_count++;
    // 获取文件i节点
    if ((i=open_namei(filename,flag,mode,&inode))<0) {
        current->filp[fd]=NULL;
        f->f_count=0;
        return i;
    }
    /* ttys are somewhat special (ttyxx major==4, tty major==5) */
    ...
    return (fd);
}
```

注意：有关几个宏变量的区别

path: include/linux/fs.h
```
#define NR_OPEN 20   // 单个进程允许打开的最大文件数目
#define NR_INODE 32  // 系统允许内存分配的最大inode个数
#define NR_FILE 64   // 系统允许内存分配的最大file个数
#define NR_SUPER 8   // 系统允许内存分配的最大超级块个数
```

内核将调用open_namei函数，最终获取标准输入设备文件的i节点，具体执行代码如下所示:

path: fs/open_namei.c
```
// 参数:pathname - 文件路径名;flag - 文件打开标志;mode - 文件访问许可属性;
// 返回:成功返回 0,否则返回出错码;res_inode - 返回的对应文件路径名的的i节点指针。
int open_namei(const char * pathname, int flag, int mode,
    struct m_inode ** res_inode)
{
    const char * basename;
    int inr,dev,namelen;
    struct m_inode * dir, *inode;
    struct buffer_head * bh;
    struct dir_entry * de;
    // 如果文件访问许可模式标志是只读(0),但文件截0标志O_TRUNC却置位了,则改为只写标志。
    if ((flag & O_TRUNC) && !(flag & O_ACCMODE))
        flag |= O_WRONLY;
    // 使用进程的文件访问许可屏蔽码,屏蔽掉给定模式中的相应位,并添上普通文件标志。
    mode &= 0777 & ~current->umask;
    mode |= I_REGULAR;
    // 根据路径名寻找到对应的i节点,以及最顶端文件名及其长度。
    if (!(dir = dir_namei(pathname,&namelen,&basename)))
        return -ENOENT;
    // 如果最顶端文件名长度为0(例如'/usr/'这种路径名的情况),那么若打开操作不是创建,截0,
    // 则表示打开一个目录名,直接返回该目录的i节点,并退出。
    if (!namelen) {            /* special case: '/usr/' etc */
        if (!(flag & (O_ACCMODE|O_CREAT|O_TRUNC))) {
            *res_inode=dir;
            return 0;
        }
        // 否则释放该i节点,返回出错码。
        iput(dir);
        return -EISDIR;
    }
    ...
    return 0;
}
```

接下来调用dir_namei函数根据路径名寻找对应的i节点以及最顶端文件名及其长度,执行代码如下所示:

path: fs/namei.c
```
static struct m_inode * dir_namei(const char * pathname,
    int * namelen, const char ** name)
{
    char c;
    const char * basename;
    struct m_inode * dir;

    // 取指定路径名最顶层目录的 i 节点,若出错则返回 NULL,退出。
    if (!(dir = get_dir(pathname)))
        return NULL;
    // 对路径名 pathname 进行搜索检测,查处最后一个'/'后面的名字字符串,计算其长度,并返回最顶
    // 层目录的 i 节点指针。
    basename = pathname;
    while ((c=get_fs_byte(pathname++)))
        if (c=='/')
            basename=pathname;
    *namelen = pathname-basename-1;  // 确定tty0名字的长度
    *name = basename;  // 得到tty0前面'/'字符的地址
    return dir;
}
```

get_dir函数根据给出的路径名进行搜索,直到达到最顶端的目录，并返回其对应的i节点,具体实现如下所示:

path: fs/namei.c
```
static struct m_inode * get_dir(const char * pathname)
{
    char c;
    const char * thisname;
    struct m_inode * inode;
    struct buffer_head * bh;
    int namelen,inr,idev;
    struct dir_entry * de;

    // 如果进程没有设定根i节点,或者该进程根i节点的引用为 0,则系统出错,死机。
    if (!current->root || !current->root->i_count)
        panic("No root inode");
    // 如果进程的当前工作目录指针为空,或者该当前目录 i 节点的引用计数为 0,也是系统有问题,死机。
    if (!current->pwd || !current->pwd->i_count)
        panic("No cwd inode");
    // 如果用户指定的路径名的第1个字符是'/',则说明路径名是绝对路径名。则从根 i 节点开始操作。
    if ((c=get_fs_byte(pathname))=='/') {
        inode = current->root;
        pathname++;
    // 否则若第一个字符是其它字符,则表示给定的是相对路径名。应从进程的当前工作目录开始操作。
    // 则取进程当前工作目录的 i 节点。
    } else if (c)
        inode = current->pwd;
    // 否则表示路径名为空,出错。返回 NULL,退出。
    else
        return NULL;    /* empty name is bad */
    // 将取得的i节点引用计数增1。
    // 在这里找到的是根i节点，因此将从根i节点开始查找文件，这个根i节点在之前加载根文件系统时载入，
    // 同时，它被引用，其引用计数也随之增加，现在，从根i节点开始，遍历并解析"/dev/tty0"这个路径名
    // 解析过程如下.
    inode->i_count++;
    // 循环以下过程，直到找到树梢节点为止.
    while (1) {
        thisname = pathname;
        // 若该i节点不是目录节点,或者没有可进入的访问许可,则释放该i节点,返回 NULL,退出。
        if (!S_ISDIR(inode->i_mode) || !permission(inode,MAY_EXEC)) {
            iput(inode);
            return NULL;
        }
        // 从路径名开始起搜索检测字符,直到字符已是结尾符(NULL)或者是'/',此时namelen正好是当前处理
        // 目录名的长度。如果最后也是一个目录名,但其后没有加'/',则不会返回该最后目录的 i 节点!
        // 比如:/var/log/httpd,将只返回 log/目录的 i 节点。
        // 在这里从"/dev/tty0"路径名dev的'd'字符开始遍历，遇到'/'后跳出循环,namelen长度为3，这些
        // 信息将和根i节点一起，作为find_entry的参数使用
        for(namelen=0;(c=get_fs_byte(pathname++))&&(c!='/');namelen++)
            /* nothing */ ;
        // 若字符是结尾符NULL,则表明已经到达指定目录,则返回该i节点指针,退出。
        if (!c)
            return inode;
        // 调用查找指定目录和文件名的目录项函数,在当前处理目录中寻找子目录项。如果没有找到,则释放
        // 该i节点,并返回NULL,退出
        if (!(bh = find_entry(&inode,thisname,namelen,&de))) {
            iput(inode);
            return NULL;
        }
        // 取该子目录项的i节点号inr和设备号 idev,释放包含该目录项的高速缓冲块和该 i 节点。
        inr = de->inode;
        idev = inode->i_dev;
        brelse(bh);
        iput(inode);
        // 取节点号inr的i节点信息,若失败,则返回 NULL,退出。否则继续以该子目录的i节点进行操作。
        if (!(inode = iget(idev,inr)))
            return NULL;
    }
}
```

值得注意的是,get_fs_byte函数是解析路径的核心函数，可以从路径中逐一提取字符串.其内部处理过程如下所示:

path: include/asm/segment.h
```
static inline unsigned char get_fs_byte(const char * addr)
{
    unsigned register char _v;

    // movb指令可以将8位，即1字节数据移入指定寄存器(fs)
    // v 是输出的字符
    __asm__ ("movb %%fs:%1,%0":"=r" (_v):"m" (*addr));
    return _v;
}
```

path: fs/namei.c
```
int open_namei(const char * pathname, int flag, int mode,
    struct m_inode ** res_inode)
{
    const char * basename;
    int inr,dev,namelen;
    struct m_inode * dir, *inode;
    struct buffer_head * bh;
    struct dir_entry * de;
    ...

    bh = find_entry(&dir,basename,namelen,&de);
    if (!bh) {
        if (!(flag & O_CREAT)) {
            iput(dir);
            return -ENOENT;
        }
        if (!permission(dir,MAY_WRITE)) {
            iput(dir);
            return -EACCES;
        }
        inode = new_inode(dir->i_dev);
        if (!inode) {
            iput(dir);
            return -ENOSPC;
        }
        inode->i_uid = current->euid;
        inode->i_mode = mode;
        inode->i_dirt = 1;
        bh = add_entry(dir,basename,namelen,&de);
        if (!bh) {
            inode->i_nlinks--;
            iput(inode);
            iput(dir);
            return -ENOSPC;
        }
        de->inode = inode->i_num;
        bh->b_dirt = 1;
        brelse(bh);
        iput(dir);
        *res_inode = inode;
        return 0;
    }
    inr = de->inode;
    dev = dir->i_dev;
    brelse(bh);
    iput(dir);
    if (flag & O_EXCL)
        return -EEXIST;
    if (!(inode=iget(dev,inr)))
        return -EACCES;
    if ((S_ISDIR(inode->i_mode) && (flag & O_ACCMODE)) ||
        !permission(inode,ACC_MODE(flag))) {
        iput(inode);
        return -EPERM;
    }
    inode->i_atime = CURRENT_TIME;
    if (flag & O_TRUNC)
        truncate(inode);
    *res_inode = inode;
    return 0;
}
```

path: fs/open.c
```
int sys_open(const char * filename,int flag,int mode)
{
    struct m_inode * inode;
    struct file * f;
    int i,fd;
    ...
    /* ttys are somewhat special (ttyxx major==4, tty major==5) */
    if (S_ISCHR(inode->i_mode)) {
        if (MAJOR(inode->i_zone[0])==4) {
            if (current->leader && current->tty<0) {
                current->tty = MINOR(inode->i_zone[0]);
                tty_table[current->tty].pgrp = current->pgrp;
            }
        } else if (MAJOR(inode->i_zone[0])==5)
            if (current->tty<0) {
                iput(inode);
                current->filp[fd]=NULL;
                f->f_count=0;
                return -EPERM;
            }
    }
    /* Likewise with block-devices: check for floppy_change */
    if (S_ISBLK(inode->i_mode))
        check_disk_change(inode->i_zone[0]);
    f->f_mode = inode->i_mode;
    f->f_flags = flag;
    f->f_count = 1;
    f->f_inode = inode;
    f->f_pos = 0;

    return (fd);
}
```