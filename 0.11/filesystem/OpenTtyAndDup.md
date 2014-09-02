Linux 0.11 进程1打开终端设备文件以及复制文件句柄
================================================================================

现在,计算机中已经创建了两个进程: 进程0和进程1. 在进程1完成从虚拟盘中安装根文件系统之后:

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/InstallRootFsFromRamdisk.md

需要打开标准输入设备文件和标准输出文件，标准出错输出文件为创建进程2作准备.


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
    // 根据路径名寻找最后一层目录对应的i节点,以及最顶端文件名及其长度。
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

接下来调用dir_namei函数根据路径名遍历路径所有目录文件i节点，
目的是寻找最后一个目录的的i节点以及最顶端文件名及其长度.
执行代码如下所示:

path: fs/namei.c
```
static struct m_inode * dir_namei(const char * pathname,
    int * namelen, const char ** name)
{
    char c;
    const char * basename;
    struct m_inode * dir;

    // 取指定路径名最后一层目录的i节点(在这里是"dev"目录的i节点),若出错则返回NULL,退出。
    if (!(dir = get_dir(pathname)))
        return NULL;
    ...
    return dir;
}
```

get_dir函数根据给出的路径名进行搜索,直到达到最后一层目录，并返回其对应的i节点.
其工作主要是通过连续不断地: **确定目录项** --> **通过目录项获取i节点** 来完成的
具体实现如下所示:

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
        // 通过目录文件的i节点和目录项信息，获取目录项
        if (!(bh = find_entry(&inode,thisname,namelen,&de))) { // de会指向dev目录项
            iput(inode);
            return NULL;
        }

        inr = de->inode;      // 通过目录项找到i节点号
        idev = inode->i_dev;  // 注意,这个inode是根i节点，这里通过根i节点找到设备号
        brelse(bh);
        // 路径中最后一层目录之前的各个目录文件i节点在使用完毕之后立即释放，避免浪费
        // inode_table中的空间.
        iput(inode);
        // 将dev目录文件的i节点保存在inode_table[32]的指定表项内，并将表项指针返回
        if (!(inode = iget(idev,inr)))
            return NULL;
    }
}
```

**值得注意的是**:

A. get_fs_byte函数是解析路径的核心函数，可以从路径中逐一提取字符串.其内部处理过程如下所示:

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

B. find_entry函数中最后一个参数de所指向的数据结构是目录项结构，代码如下所示:

path: include/linux/fs.h
```
struct dir_entry {         // 目录项结构
    unsigned short inode;  // 目录项所对应的目录在设备上的i节点号
    char name[NAME_LEN];   // 目录项名字,14字节
};
```
得到了i节点号，就可以得到"dev"目录项所对应目录文件的i节点，内核就可以进而通过i节点找到dev目录文件


确定目录项是由find_entry函数来完成的. 该函数的主要任务是：
利用上一级目录i节点信息和目录名称名"dev"以及长度来获取目录项结构信息,
具体过程如下:
确定目录文件中有多少个目录项，之后从目录文件对应的第一个逻辑块开始，不断将该文件的逻辑块从外设读入缓冲区，
并从中查找指定目录项，直到找到指定的目录项为止.

其具体实现如下所示:

path: include/linux/fs.h
```
#define BLOCK_SIZE 1024
...
#define DIR_ENTRIES_PER_BLOCK ((BLOCK_SIZE)/(sizeof (struct dir_entry)))
```

path: fs/namei.c
```
/*
 * find_entry()
 * 在指定的目录中寻找一个与名字匹配的目录项。返回一个含有找到目录项的高速
 * 缓冲区以及目录项本身(作为一个参数 - res_dir)。并不读目录项的 i 节点 - 如
 * 果需要的话需自己操作。
 *
 * '..'目录项,操作期间也会对几种特殊情况分别处理 - 比如横越一个伪根目录以
 * 及安装点。
 */
// 在这里传递给find_entry函数的i节点dir是根i节点的信息，name是"dev", 长度为3, *res_dir为NULL
static struct buffer_head * find_entry(struct m_inode ** dir,
    const char * name, int namelen, struct dir_entry ** res_dir)
{
    int entries;
    int block,i;
    struct buffer_head * bh;
    struct dir_entry * de;
    struct super_block * sb;

// 如果定义了 NO_TRUNCATE,则若文件名长度超过最大长度 NAME_LEN,则返回。
#ifdef NO_TRUNCATE
    if (namelen > NAME_LEN)
        return NULL;
// 如果没有定义 NO_TRUNCATE,则若文件名长度超过最大长度 NAME_LEN,则截短之。
#else
    if (namelen > NAME_LEN)
        namelen = NAME_LEN;
#endif
    // 计算根目录中目录项项数entries, i_size是文件大小也就是根目录大小。置空返回目录项结构指针。
    entries = (*dir)->i_size / (sizeof (struct dir_entry));
    *res_dir = NULL;
    if (!namelen)  // 检查文件名长度是否为0
        return NULL;

    /* check for '..', as we might have to do some "magic" for it */
    /* 检查目录项'..', 因为可能需要对其特别处理 */
    if (namelen==2 && get_fs_byte(name)=='.' && get_fs_byte(name+1)=='.') {
        /* '..' in a pseudo-root results in a faked '.' (just change namelen) */
        /* 伪根中的'..'如同一个假'.'(只需改变名字长度) */
        // 如果当前进程的根节点指针是指定的目录,则将文件名修改为'.',
        if ((*dir) == current->root)
            namelen=1;
        // 否则如果该目录的i节点号等于ROOT_INO(1)的话,说明是文件系统根节点, 则取文件系统的超级块。
        // 这里该目录是根目录所以先获取到超级块
        else if ((*dir)->i_num == ROOT_INO) {
            /* '..' over a mount-point results in 'dir' being exchanged for
             * the mounted directory-inode. NOTE! We set mounted, so that we can
             * iput the new dir */
            sb=get_super((*dir)->i_dev);
            // 如果被安装到的i节点存在,则先释放原i节点,然后对被安装到的i节点进行处理。
            // 让*dir 指向该被安装到的i节点;该i节点的引用数加 1。
            if (sb->s_imount) {
                iput(*dir);
                (*dir)=sb->s_imount;
                (*dir)->i_count++;
            }
        }
    }

    // 如果目录i节点所指向的第一个直接磁盘块号为 0,则返回 NULL,退出。
    if (!(block = (*dir)->i_zone[0]))
        return NULL;
    // 从目录i节点所在设备读取指定的目录项逻辑块块到缓冲区中,如果不成功,则返回 NULL,退出。
    if (!(bh = bread((*dir)->i_dev,block)))
        return NULL;

    // 在目录项数据块中搜索匹配指定文件名("dev")的目录项,首先让de指向逻辑块,并在不超过
    // 目录中目录项数的条件下,循环执行搜索。
    i = 0;
    de = (struct dir_entry *) bh->b_data; // 让de指向缓冲块首地址
    while (i < entries) {
        // 如果当前目录项数据块已经搜索完,还没有找到匹配的目录项,则释放当前目录项数据块。
        if ((char *)de >= BLOCK_SIZE+bh->b_data) {
            brelse(bh);
            bh = NULL;
            // 接下来再读入下一目录项数据块。若这块为空,则只要还没有搜索完目录中的所有目录项,就跳过该块,
            // 继续读下一目录项数据块。若该块不空,就让de指向该目录项数据块,继续搜索。
            if (!(block = bmap(*dir,i/DIR_ENTRIES_PER_BLOCK)) ||
                !(bh = bread((*dir)->i_dev,block))) {
                i += DIR_ENTRIES_PER_BLOCK;
                continue;
            }
            de = (struct dir_entry *) bh->b_data;
        }
        // 如果找到匹配的目录项的话,则返回该目录项结构指针和该目录项数据块指针,退出。
        if (match(namelen,name,de)) {
            *res_dir = de;  // 如果找到了"dev", 就交给res_dir指针
            return bh;
        }
        // 否则继续在目录项逻辑块中比较下一个目录项。
        de++;
        i++;
    }
    // 若指定目录中的所有目录项都搜索完还没有找到相应的目录项,则释放目录项数据块,返回NULL。
    brelse(bh);
    return NULL;
}
```

通过find_entry函数中获取目录项结构信息之后返回到get_dir函数中，在get_dir函数中从目录项中提取i节点号，
从根目录i节点中获取设备号，通过iget函数获取最后一层目录的i节点信息，参考：

https://github.com/leeminghao/doc-linux/blob/master/0.11/filesystem/InstallRootFsFromRamdisk.md

中是如何获取i节点信息的.

最后，将最后一层目录i节点对应信息和路径中文件名称返回给dir_namei函数继续处理.
执行代码如下所示:

path: fs/namei.c
```
// 现在pathname="/tty0"
static struct m_inode * dir_namei(const char * pathname,
    int * namelen, const char ** name)
{
    char c;
    const char * basename;
    struct m_inode * dir;

    // 取指定路径名最后一层目录(在这里是"dev")的i节点,若出错则返回NULL,退出。
    if (!(dir = get_dir(pathname)))
        return NULL;

    // 对路径名pathname进行搜索检测,查处最后一个'/'后面的名字字符串,计算其长度,并返回最顶
    // 层目录的 i 节点指针。
    basename = pathname;
    while ((c=get_fs_byte(pathname++)))
        if (c=='/')
            basename=pathname;
    *namelen = pathname-basename-1;  // 确定tty0名字的长度
    *name = basename;                // 得到tty0中第一个't'字符的地址
    return dir;
}
```

接下来要返回到open_namei函数中确定tty0文件的i节点，执行代码如下所示:

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
    // 根据路径名寻找最后一层目录对应的i节点,以及最顶端文件名及其长度。
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

    // 通过最后一层目录i节点以及basename为"tty0"的参数，将tty0的这一目录项载入缓冲块
    // de指向tty0文件的目录项
    bh = find_entry(&dir,basename,namelen,&de);
    if (!bh) {  // tty0目录项找到了,缓冲块不可能为空, if此时不会执行
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
    inr = de->inode;  // 得到i节点号
    dev = dir->i_dev; // 得到设备号
    brelse(bh);
    iput(dir);
    if (flag & O_EXCL) // 如果独占使用标志O_EXCL置位,则返回文件已存在出错码,退出。
        return -EEXIST;
    if (!(inode=iget(dev,inr))) // 获取tty0文件的i节点
        return -EACCES;
    // 若该i节点是一个目录的节点并且访问模式是只读或只写,或者没有访问的许可权限,则释放该
    // i节点,返回访问权限出错码,退出。
    if ((S_ISDIR(inode->i_mode) && (flag & O_ACCMODE)) ||
        !permission(inode,ACC_MODE(flag))) {
        iput(inode);
        return -EPERM;
    }
    // 更新该i节点的访问时间字段为当前时间
    inode->i_atime = CURRENT_TIME;
    if (flag & O_TRUNC) 如果设立了截0标志,则将该i节点的文件长度截为 0。
        truncate(inode);
    *res_inode = inode;  // 将此节点传递给sys_open函数
    return 0;
}
```

在获取到tty0文件的i节点以后返回到sys_open函数中继续执行.

path: fs/open.c
```
int sys_open(const char * filename,int flag,int mode)
{
    struct m_inode * inode;
    struct file * f;
    int i,fd;
    ...
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
    if (S_ISCHR(inode->i_mode)) {  // 通过检测tty0文件的i节点属性，得知它是设备文件
        if (MAJOR(inode->i_zone[0])==4) {  // 得知设备号是4
            if (current->leader && current->tty<0) {
                // 设置当前进程的tty号为该i节点的子设备号
                current->tty = MINOR(inode->i_zone[0]);
                // 设置当前进程tty对应的tty表项的父进程组号为进程的父进程组号
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
    // 根据i节点信息初始化file文件结构
    f->f_mode = inode->i_mode; // 用该i节点属性设置文件属性
    f->f_flags = flag;         // 用flag参数设置文件标示
    f->f_count = 1;            // 将文件引用计数置1
    f->f_inode = inode;        // 文件与i节点关联
    f->f_pos = 0;              // 将文件读写指针置0

    return (fd);
}
```

### dup

上面打开了标准输入设备文件. 下面要打开标准输出，标准错误输出设备文件，不同之处在于
这里使用复制文件句柄的方法. open函数返回之后进程1在tty0文件已经打开的基础上，通过
调用dup()函数，复制文件句柄,一共复制了两次.

dup()函数最终会映射到sys_dup()这个系统调用函数中，执行代码如下所示:

path: fs/fcntl.c
```
int sys_dup(unsigned int fildes)
{
    return dupfd(fildes,0);
}
```

在sys_dup函数中最终调用dupfd函数复制文件句柄，执行代码如下所示:

path: fs/fcntl.c
```
static int dupfd(unsigned int fd, unsigned int arg)
{
    if (fd >= NR_OPEN || !current->filp[fd])  // 检测是否具备复制文件句柄的条件
        return -EBADF;
    if (arg >= NR_OPEN)
        return -EINVAL;
    // 在进程1的filp[20]中寻找空闲项(此时是第2项)，以便复制文件句柄
    while (arg < NR_OPEN)
        if (current->filp[arg])
            arg++;
        else
            break;
    if (arg >= NR_OPEN)
        return -EMFILE;
    // 复制文件句柄，建立标准输出设备，并相应的增加文件引用计数,f_count为2
    current->close_on_exec &= ~(1<<arg);
    (current->filp[arg] = current->filp[fd])->f_count++;
    return arg;
}
```

类似的可以打开标准错误输出设备文件.

至此，标准输入设备文件和标准输出，标准出错输出设备文件都已经打开了.
接下来进程1要创建进程2执行shell程序，如下所示:

https://github.com/leeminghao/doc-linux/blob/master/0.11/process/CreateProcess2.md