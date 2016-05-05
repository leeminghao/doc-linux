Buffer vs Cache
========================================

什么是buffer/cache？
----------------------------------------

buffer和cache是两个在计算机技术中被用滥的名词，放在不通语境下会有不同的意义。

* 在Linux的内存管理中

  这里的buffer指Linux内存的：Buffer cache。这里的cache指Linux内存中的：Page cache。翻译成中文可以
  叫做缓冲区缓存和页面缓存。

在历史上，它们一个(buffer)被用来当成对io设备写的缓存，而另一个(cache)被用来当作对io设备的读缓存，
这里的io设备，主要指的是块设备文件和文件系统上的普通文件。但是现在，它们的意义已经不一样了。
在当前的内核中，page cache顾名思义就是针对内存页的缓存，说白了就是，如果有内存是以page进行
分配管理的，都可以使用page cache作为其缓存来管理使用。当然，不是所有的内存都是以页（page）进行
管理的，也有很多是针对块(block)进行管理的，这部分内存使用如果要用到cache功能，则都集中到
buffer cache中来使用。（从这个角度出发，是不是buffer cache改名叫做block cache更好？）
然而，也不是所有块（block）都有固定长度，系统上块的长度主要是根据所使用的块设备决定的，
而页长度在X86上无论是32位还是64位都是4k。

明白了这两套缓存系统的区别，就可以理解它们究竟都可以用来做什么了。

什么是page cache
----------------------------------------

Page cache主要用来作为文件系统上的文件数据的缓存来用，尤其是针对当进程对文件有read／write操作的
时候。如果你仔细想想的话，作为可以映射文件到内存的系统调用：mmap是不是很自然的也应该用到page cache?
在当前的系统实现里，page cache也被作为其它文件类型的缓存设备来用，所以事实上page cache也负责了
大部分的块设备文件的缓存工作。

什么是buffer cache
----------------------------------------

Buffer cache则主要是设计用来在系统对块设备进行读写的时候，对块进行数据缓存的系统来使用。
这意味着某些对块的操作会使用buffer cache进行缓存，比如我们在格式化文件系统的时候。
一般情况下两个缓存系统是一起配合使用的，比如当我们对一个文件进行写操作的时候，page cache的
内容会被改变，而buffer cache则可以用来将page标记为不同的缓冲区，并记录是哪一个缓冲区被修改了。
这样，内核在后续执行脏数据的回写（writeback）时，就不用将整个page写回，而只需要写回修改的部分即可。

如何回收cache？
----------------------------------------

Linux内核会在内存将要耗尽的时候，触发内存回收的工作，以便释放出内存给急需内存的进程使用。
一般情况下，这个操作中主要的内存释放都来自于对buffer／cache的释放。尤其是被使用更多的cache空间。
既然它主要用来做缓存，只是在内存够用的时候加快进程对文件的读写速度，那么在内存压力较大的情况下，
当然有必要清空释放cache，作为free空间分给相关进程使用。所以一般情况下，我们认为buffer/cache空间
可以被释放，这个理解是正确的。

但是这种清缓存的工作也并不是没有成本。理解cache是干什么的就可以明白清缓存必须保证cache中的数据
跟对应文件中的数据一致，才能对cache进行释放。所以伴随着cache清除的行为的，一般都是系统IO飙高。
因为内核要对比cache中的数据和对应硬盘文件上的数据是否一致，如果不一致需要写回，之后才能回收。

在系统中除了内存将被耗尽的时候可以清缓存以外，我们还可以使用下面这个文件来人工触发缓存清除的操作：

```
# cat /proc/sys/vm/drop_caches
1

// 表示清除pagecache
# echo 1 > /proc/sys/vm/drop_caches

// 表示清除回收slab分配器中的对象（包括目录项缓存和inode缓存）。slab分配器是内核中管理内存的
// 一种机制，其中很多缓存数据实现都是用的pagecache。
# echo 2 > /proc/sys/vm/drop_caches

// 表示清除pagecache和slab分配器中的缓存对象。
# echo 3 > /proc/sys/vm/drop_caches
```

cache都能被回收么？
----------------------------------------

我们分析了cache能被回收的情况，那么有没有不能被回收的cache呢？当然有。我们先来看第一种情况：

### tmpfs

大家知道Linux提供一种“临时”文件系统叫做tmpfs，它可以将内存的一部分空间拿来当做文件系统使用，
使内存空间可以当做目录文件来用。现在绝大多数Linux系统都有一个叫做/dev的tmpfs目录，

```
# dd if=/dev/zero of=/dev/testfile bs=4096 count=300000 // 800MB
```

我们在dev目录下创建了一个800MB左右的文件，并通过前后free命令的对比发现，cached增长了800MB，
我们可以人工触发内存回收看看现在到底能回收多少内存：

```
# echo 3 > /proc/sys/vm/drop_caches
```

可以看到，cached占用的空间并没有像我们想象的那样完全被释放.
这是我们分析的第一种cache不能被回收的情况。

### 共享内存

共享内存是系统提供给我们的一种常用的进程间通信（IPC）方式，但是这种通信方式不能在shell中申请和使用，
所以我们需要一个简单的测试程序，代码如下：

```
# cat shm.c

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <string.h>

#define MEMSIZE 2048*1024*1023

int
main()
{
    int shmid;
    char *ptr;
    pid_t pid;
    struct shmid_ds buf;
    int ret;

    shmid = shmget(IPC_PRIVATE, MEMSIZE, 0600);
    if (shmid<0) {
        perror("shmget()");
        exit(1);
    }

    ret = shmctl(shmid, IPC_STAT, &buf);
    if (ret < 0) {
        perror("shmctl()");
        exit(1);
    }

    printf("shmid: %d\n", shmid);
    printf("shmsize: %d\n", buf.shm_segsz);

    buf.shm_segsz *= 2;

    ret = shmctl(shmid, IPC_SET, &buf);
    if (ret < 0) {
        perror("shmctl()");
        exit(1);
    }

    ret = shmctl(shmid, IPC_SET, &buf);
    if (ret < 0) {
        perror("shmctl()");
        exit(1);
    }

    printf("shmid: %d\n", shmid);
    printf("shmsize: %d\n", buf.shm_segsz);


    pid = fork();
    if (pid<0) {
        perror("fork()");
        exit(1);
    }
    if (pid==0) {
        ptr = shmat(shmid, NULL, 0);
        if (ptr==(void*)-1) {
            perror("shmat()");
            exit(1);
        }
        bzero(ptr, MEMSIZE);
        strcpy(ptr, "Hello!");
        exit(0);
    } else {
        wait(NULL);
        ptr = shmat(shmid, NULL, 0);
        if (ptr==(void*)-1) {
            perror("shmat()");
            exit(1);
        }
        puts(ptr);
        exit(0);
    }
}
```

程序功能很简单，就是申请一段不到2G共享内存，然后打开一个子进程对这段共享内存做一个初始化操作，
父进程等子进程初始化完之后输出一下共享内存的内容，然后退出。但是退出之前并没有删除这段共享内存。
我们来看看这个程序执行前后的内存使用：

```
# free -g
             total       used       free     shared    buffers     cached
Mem:           126         30         95          0          0         16
-/+ buffers/cache:         14        111
Swap:            2          0          2
# ./shm
shmid: 294918
shmsize: 2145386496
shmid: 294918
shmsize: -4194304
Hello!
# free -g
             total       used       free     shared    buffers     cached
Mem:           126         32         93          0          0         18
-/+ buffers/cache:         14        111
Swap:            2          0          2
cached空间由16G涨到了18G。那么这段cache能被回收么？继续测试：

# echo 3 > /proc/sys/vm/drop_caches
# free -g
             total       used       free     shared    buffers     cached
Mem:           126         32         93          0          0         18
-/+ buffers/cache:         14        111
Swap:            2          0          2
```

结果是仍然不可回收。大家可以观察到，这段共享内存即使没人使用，仍然会长期存放在cache中，
直到其被删除。删除方法有两种，一种是程序中使用shmctl()去IPC_RMID，另一种是使用ipcrm命令。
我们来删除试试：

```
# ipcs -m

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00005feb 0          root       666        12000      4
0x00005fe7 32769      root       666        524288     2
0x00005fe8 65538      root       666        2097152    2
0x00038c0e 131075     root       777        2072       1
0x00038c14 163844     root       777        5603392    0
0x00038c09 196613     root       777        221248     0
0x00000000 294918     root       600        2145386496 0

# ipcrm -m 294918
# ipcs -m

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00005feb 0          root       666        12000      4
0x00005fe7 32769      root       666        524288     2
0x00005fe8 65538      root       666        2097152    2
0x00038c0e 131075     root       777        2072       1
0x00038c14 163844     root       777        5603392    0
0x00038c09 196613     root       777        221248     0

# free -g
             total       used       free     shared    buffers     cached
Mem:           126         30         95          0          0         16
-/+ buffers/cache:         14        111
Swap:            2          0          2
```

删除共享内存后，cache被正常释放了。这个行为与tmpfs的逻辑类似。内核底层在实现共享内存（shm）、
消息队列（msg）和信号量数组（sem）这些POSIX:XSI的IPC机制的内存存储时，使用的都是tmpfs。
这也是为什么共享内存的操作逻辑与tmpfs类似的原因。当然，一般情况下是shm占用的内存更多，
所以我们在此重点强调共享内存的使用。说到共享内存，Linux还给我们提供了另外一种共享内存的方法，就是：

### mmap

mmap()是一个非常重要的系统调用，这仅从mmap本身的功能描述上是看不出来的。从字面上看，
mmap就是将一个文件映射进进程的虚拟内存地址，之后就可以通过操作内存的方式对文件的内容进行操作。
但是实际上这个调用的用途是很广泛的。当malloc申请内存时，小段内存内核使用sbrk处理，而大段内存
就会使用mmap。当系统调用exec族函数执行时，因为其本质上是将一个可执行文件加载到内存执行，
所以内核很自然的就可以使用mmap方式进行处理。我们在此仅仅考虑一种情况，就是使用mmap进行
共享内存的申请时，会不会跟shmget()一样也使用cache？

同样，我们也需要一个简单的测试程序：

```
# cat mmap.c
#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>

#define MEMSIZE 1024*1024*1023*2
#define MPFILE "./mmapfile"

int main()
{
    void *ptr;
    int fd;

    fd = open(MPFILE, O_RDWR);
    if (fd < 0) {
        perror("open()");
        exit(1);
    }

    ptr = mmap(NULL, MEMSIZE, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANON, fd, 0);
    if (ptr == NULL) {
        perror("malloc()");
        exit(1);
    }

    printf("%p\n", ptr);
    bzero(ptr, MEMSIZE);

    sleep(100);

    munmap(ptr, MEMSIZE);
    close(fd);

    exit(1);
}
```

这次我们干脆不用什么父子进程的方式了，就一个进程，申请一段2G的mmap共享内存，然后初始化这段
空间之后等待100秒，再解除影射所以我们需要在它sleep这100秒内检查我们的系统内存使用
，看看它用的是什么空间？当然在这之前要先创建一个2G的文件./mmapfile。结果如下：

```
# dd if=/dev/zero of=mmapfile bs=1G count=2
# echo 3 > /proc/sys/vm/drop_caches
# free -g
             total       used       free     shared    buffers     cached
Mem:           126         30         95          0          0         16
-/+ buffers/cache:         14        111
Swap:            2          0          2
```

然后执行测试程序：

```
# ./mmap &
[1] 19157
0x7f1ae3635000
# free -g
             total       used       free     shared    buffers     cached
Mem:           126         32         93          0          0         18
-/+ buffers/cache:         14        111
Swap:            2          0          2

# echo 3 > /proc/sys/vm/drop_caches
# free -g
             total       used       free     shared    buffers     cached
Mem:           126         32         93          0          0         18
-/+ buffers/cache:         14        111
Swap:            2          0          2
```

我们可以看到，在程序执行期间，cached一直为18G，比之前涨了2G，并且此时这段cache仍然无法被回收。
然后我们等待100秒之后程序结束。

```
#
[1]+  Exit 1                  ./mmap
#
# free -g
             total       used       free     shared    buffers     cached
Mem:           126         30         95          0          0         16
-/+ buffers/cache:         14        111
Swap:            2          0          2
```

程序退出之后，cached占用的空间被释放。这样我们可以看到，使用mmap申请标志状态为MAP_SHARED的内存，
内核也是使用的cache进行存储的。在进程对相关内存没有释放之前，这段cache也是不能被正常释放的。
实际上，mmap的MAP_SHARED方式申请的内存，在内核中也是由tmpfs实现的。由此我们也可以推测，
由于共享库的只读部分在内存中都是以mmap的MAP_SHARED方式进行管理，实际上它们也都是要占用cache且
无法被释放的。

最后

我们通过三个测试例子，发现Linux系统内存中的cache并不是在所有情况下都能被释放当做空闲空间用的。
并且也也明确了，即使可以释放cache，也并不是对系统来说没有成本的。总结一下要点，
我们应该记得这样几点：

* 当cache作为文件缓存被释放的时候会引发IO变高，这是cache加快文件访问速度所要付出的成本。
* tmpfs中存储的文件会占用cache空间，除非文件删除否则这个cache不会被自动释放。
* 使用shmget方式申请的共享内存会占用cache空间，除非共享内存被ipcrm或者使用shmctl去IPC_RMID，
  否则相关的cache空间都不会被自动释放。
* 使用mmap方法申请的MAP_SHARED标志的内存会占用cache空间，除非进程将这段内存munmap，
  否则相关的cache空间都不会被自动释放。

实际上shmget、mmap的共享内存，在内核层都是通过tmpfs实现的，tmpfs实现的存储用的都是cache。
当理解了这些的时候，希望大家对free命令的理解可以达到我们说的第三个层次。我们应该明白，
内存的使用并不是简单的概念，cache也并不是真的可以当成空闲空间用的。如果我们要真正深刻理解
你的系统上的内存到底使用的是否合理，是需要理解清楚很多更细节知识，并且对相关业务的实现做
更细节判断的。
