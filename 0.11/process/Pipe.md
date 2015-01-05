管道机制
================================================================================

实例
--------------------------------------------------------------------------------

path: samples/samples.h
```
#ifndef _SAMPLES_H
#define _SAMPLES_H

static inline __attribute__((always_inline)) int test_pipe(void)
{
    int fds[2];
    pid_t pid;
    char str1[] = "1234567890";
    char str2[10];

    if (pipe(fds) < 0) {
        return -1;
    }
    if ((pid = fork()) < 0) {
        return -1;
    } else if (pid > 0) { // parent
        close(fds[0]);
        return write(fds[1], str1, 10);
    } else { // children
        close(fds[1]);
        return read(fds[0], str2, 10);
    }
}

#endif /* _SAMPLES_H */
```

实例表现了进程间共享数据的情景：父进程把str1中的数据写入管道，子进程从管道中读出数据，
其中str1中字符长度为10字节.

管道的创建过程
--------------------------------------------------------------------------------

从技术上看，管道就是一页内存，但进程要以操作文件的方式对其进行操作，这就要求这页内存具备一些
文件属性并减少页属性。具备一些文件属性表现为，创建管道相当于创建一个文件，如进程task_struct中
*filp[20]和file_table[64]挂接、新建i节点、file_table[64]和文件i节点挂接等工作要在创建管道过程
中完成，最终使进程只要知道自己在操作管道类型的文件就可以了，其他的都不用关心。减少页属性表现为，
这页内存毕竟要当做一个文件使用，比如进程不能像访问自己用户空间的数据一样访问它，不能映射到进程的
线性地址空间内。再如，两个进程操作这个页面，一个读一个写，也不能产生页写保护异常把页面另复制一份，
否则无法共享管道。下面我们来看管道的具体创建过程。

path: fs/pipe.c
```
int sys_pipe(unsigned long * fildes)
{
    struct m_inode * inode;
    struct file * f[2];
    int fd[2];
    int i,j;

    /* 为管道文件在file_table[64]中申请空闲项.
     * 创建文件都是让当前进程(一个进程)使用，而管道文件就是为了两个进程(读管道进程和写管道进程)的
     * 使用而创建的。实例中管道是由父进程(写管道进程)创建的。父进程在创建管道时，处处为子进程
     * (读管道进程)做准备，使得子进程一旦被创建，天然就具备操作管道的能力。父进程先在
     * file_table[64]中申请“两个”空闲项，并将这两个空闲项的引用计数设置为1，表示它们被引用了，
     * 父子进程以后操作管道文件可以各用一项。*/
    j=0;
    for(i=0;j<2 && i<NR_FILE;i++)
        if (!file_table[i].f_count) // 找到空闲项，设置每项引用计数为1
            (f[j++]=i+file_table)->f_count++;
    // 如果只有一个空闲项,则释放该项(引用计数复位)。
    if (j==1)
        f[0]->f_count=0;
    // 如果没有找到两个空闲项,则返回-1。
    if (j<2)
        return -1;
    // 针对上面取得的两个文件结构项,分别分配一文件句柄,并使进程的文件结构指针分别指向这两个
    // 文件结构
    j=0;
    for(i=0;j<2 && i<NR_OPEN;i++)
        if (!current->filp[i]) {  // 找到空闲项
            current->filp[ fd[j]=i ] = f[j];
            j++;
        }
    // 如果只有一个空闲文件句柄,则释放该句柄。
    if (j==1)
        current->filp[fd[0]]=NULL;
    // 如果没有找到两个空闲句柄,则释放上面获取的两个文件结构项(复位引用计数值),并返回-1。
    if (j<2) {
        f[0]->f_count=f[1]->f_count=0;
        return -1;
    }
    // 申请创建管道 i 节点,并为管道分配缓冲区(1 页内存)。如果不成功,则相应释放两个文件句柄和文
    // 件结构项,并返回-1。
    if (!(inode=get_pipe_inode())) {
        current->filp[fd[0]] =
            current->filp[fd[1]] = NULL;
        f[0]->f_count = f[1]->f_count = 0;
        return -1;
    }
    // 初始化两个文件结构,都指向同一个i节点,读写指针都置零。
    // 第1个文件结构的文件模式置为读; 第2个文件结构的文件模式置为写。
    // 这样，父进程已经具备了操作管道文件的能力，由它创建的子进程也将天然具备操作管道文件的能力.
    f[0]->f_inode = f[1]->f_inode = inode;
    f[0]->f_pos = f[1]->f_pos = 0;
    f[0]->f_mode = 1;        /* read */
    f[1]->f_mode = 2;        /* write */
    // 将文件句柄数组复制到对应的用户数组中,
    // 现在将管道文件的两个句柄返给用户进程，即返给实例代码中的fd[2]。这个数组有两项，
    // 每一项分别存放一个句柄，这样子进程也将继承这两个文件句柄，父子两个进程就可以通过
    // 不同的文件句柄操作这个管道文件了。
    put_fs_long(fd[0],0+fildes);
    put_fs_long(fd[1],1+fildes);
    return 0;
}
```

创建管道文件i节点进程要想具备操作管道文件的能力，还要建立管道文件i节点与file_table[64]的关系。
为此调用get_pipe_inode( )函数值得注意的是，执行代码如下：

path: fs/inode.c
```

struct m_inode * get_pipe_inode(void)
{
    struct m_inode * inode;

    // 先为该管道文件在inode_table[32]中申请一个i节点
    if (!(inode = get_empty_inode()))
        return NULL;
    // 由于管道的本质就是一个内存页面，系统申请一个空闲内存页面，并将该页面的地址载入i节点。
    // 此刻inode->i_size字段承载的不再是文件大小，而是内存页面的起始地址。
    if (!(inode->i_size=get_free_page())) {
        inode->i_count = 0;
        return NULL;
    }
    // 管道文件也是文件，所以也要有i节点。有i节点就要有引用计数。在Linux 0.11中，
    // 默认操作这个管道文件的进程“能且仅能”有两个，一个是读进程，另一个是写进程，
    // 所以这里直接设置为2。
    inode->i_count = 2;    /* sum of readers/writers */
    // 复位管道头尾指针。
    PIPE_HEAD(*inode) = PIPE_TAIL(*inode) = 0;
    inode->i_pipe = 1;  // 设置管道文件属性
    return inode;
}
```

管道的操作
--------------------------------------------------------------------------------

Linux 0.11管道操作要实现的效果是，读管道进程执行时，如果管道中有未读数据，就读取数据，
没有未读数据，就挂起，这样就不会读取垃圾数据；写管道进程执行时，如果管道中有剩余空间，
就写入数据，没有剩余空间了，就挂起，这样就不会覆盖尚未读取的数据。另外，管道大小只有一个页面，
所以写或读到页面尾端后，读写指针要能够回滚到页面首端以便继续操作。

#### 写管道

写管道进程向管道中写入数据写管道进程开始执行，它会将实例中的str1数组中指定的10字节的数据循环地
写入管道内，即执行"write(fd[1],str1,10)"这行源代码。write()函数会映射到系统调用函数sys_write( )
中去执行，并最终执行到write_pipe()函数中。写完后，管道中就已经有数据可以读出，唤醒读管道进程
(唤醒了读管道进程并不等于读管道进程就立即执行)，此次写管道操作就执行完毕。执行代码如下：

path: fs/read_write.c
```
int sys_write(unsigned int fd,char * buf,int count)
{
    struct file * file;
    struct m_inode * inode;

    if (fd>=NR_OPEN || count <0 || !(file=current->filp[fd]))
        return -EINVAL;
    if (!count)
        return 0;
    inode=file->f_inode;
    if (inode->i_pipe)
        return (file->f_mode&2)?write_pipe(inode,buf,count):-EIO; // 调用写管道函数
    ...
}
```

path: fs/pipe.c
```
int write_pipe(struct m_inode * inode, char * buf, int count)
{
    int chars, size, written = 0;

    // 若将写入的字节计数值 count 还大于 0,则循环执行以下操作。
    while (count>0) {
        // 若当前管道中没有已经满了(size=0),则唤醒等待该节点的进程,如果已没有读管道者,则向进程
        // 发送SIGPIPE信号,并返回已写入的字节数并退出。若写入0字节,则返回-1。否则在该i节点上
        // 睡眠,等待管道腾出空间。
        while (!(size=(PAGE_SIZE-1)-PIPE_SIZE(*inode))) {
            wake_up(&inode->i_wait);
            if (inode->i_count != 2) { /* no readers */
                current->signal |= (1<<(SIGPIPE-1));
                return written?written:-1;
            }
            sleep_on(&inode->i_wait);
        }
        // 取管道头部到缓冲区末端空间字节数chars。
        chars = PAGE_SIZE-PIPE_HEAD(*inode);
        // 如果其大于还需要写入的字节数 count, 则chars其等于count。
        if (chars > count)
            chars = count;
        // 如果 chars 大于当前管道中空闲空间长度size,则令其等于size。
        if (chars > size)
            chars = size;
        // 写入字节计数减去此次可写入的字节数 chars,并累加已写字节数到written。
        count -= chars;
        written += chars;
        // 令size指向管道数据头部,调整当前管道数据头部指针(前移chars字节)。
        size = PIPE_HEAD(*inode);
        PIPE_HEAD(*inode) += chars;
        PIPE_HEAD(*inode) &= (PAGE_SIZE-1);
        // 从用户缓冲区复制chars个字节到管道中。对于管道i节点,其 i_size 字段中是管道缓冲块指针。
        while (chars-->0)
            ((char *)inode->i_size)[size++]=get_fs_byte(buf++);
    }
    // 唤醒等待该i节点的进程,返回已写入的字节数,退出。
    wake_up(&inode->i_wait);
    return written;
}
```

#### 读管道

读管道进程开始操作管道文件实例1中父进程创建完管道后，开始创建子进程，即读管道进程。
创建完毕后，我们不妨假设此时系统中只有读管道和写管道两个进程处于就绪态，而且读管道
进程先执行，执行实例中"read(fd[0],str2, 10)"这行源代码。read( )函数会映射到系统调用
函数sys_read()中去执行，并最终执行到read_pipe( )函数中。由于此时管道内没有任何数据，
所以此时系统会将读管道进程挂起，然后切换到写管道进程中去执行。执行代码如下：

path: fs/read_write.c
```
int sys_read(unsigned int fd,char * buf,int count)
{
    struct file * file;
    struct m_inode * inode;

    if (fd>=NR_OPEN || count<0 || !(file=current->filp[fd]))
        return -EINVAL;
    if (!count)
        return 0;
    verify_area(buf,count);
    inode = file->f_inode;
    if (inode->i_pipe)
        return (file->f_mode&1)?read_pipe(inode,buf,count):-EIO;  // 调用读管道函数.
    ...
}
```

path: fs/pipe.c
```
int read_pipe(struct m_inode * inode, char * buf, int count)
{
    int chars, size, read = 0;

    // 若欲读取的字节计数值 count 大于 0,则循环执行以下操作。
    while (count>0) {
        // 若当前管道中没有数据(size=0),则唤醒等待该节点的进程,如果已没有写管道者,则返回已读
        // 字节数,退出。否则在该 i 节点上睡眠,等待信息。
        while (!(size=PIPE_SIZE(*inode))) {
            wake_up(&inode->i_wait);
            if (inode->i_count != 2) /* are there any writers? */
                return read;
            sleep_on(&inode->i_wait);
        }
        // 取管道尾到缓冲区末端的字节数chars。如果其大于还需要读取的字节数count,则令其等于count。
        // 如果 chars 大于当前管道中含有数据的长度 size,则令其等于 size。
        chars = PAGE_SIZE-PIPE_TAIL(*inode);
        if (chars > count)
            chars = count;
        if (chars > size)
            chars = size;
        // 读字节计数减去此次可读的字节数 chars,并累加已读字节数。
        count -= chars;
        read += chars;
        // 令size指向管道尾部,调整当前管道尾指针(前移 chars 字节)。
        size = PIPE_TAIL(*inode);
        PIPE_TAIL(*inode) += chars;
        PIPE_TAIL(*inode) &= (PAGE_SIZE-1);
        // 将管道中的数据复制到用户缓冲区中。对于管道i节点,其i_size字段中是管道缓冲块指针。
        while (chars-->0)
            put_fs_byte(((char *)inode->i_size)[size++],buf++);
    }
    // 唤醒等待该管道 i 节点的进程,并返回读取的字节数。
    wake_up(&inode->i_wait);
    return read;
}
```

从前面对管道操作的介绍中不难发现，两个进程占用一个管道的标志是，在file_table[64]中两个进程
分别占据一个管道文件的file项，就可以对管道进行操作。如果进程A创建两个管道，并创建进程B.
A、B两个进程就可以利用这两个管道进行逆向的数据交互.