一个Android系统OTA升级过程由于Stack Overflow导致的失败实例
================================================================================

首先，我们大致了解下Android OTA升级的大致流程:
具体过程如下图所示: 应用层Updater同过本地socket向otad发送installupdate命令以及参数
请求otad进行ota升级，otad服务接收到命令之后fork子进程update-binary来进行真正的ota工作,
此时otad等待子进程update-binary执行，并将update-binary进行升级的进度信息和状态信息发送
给otad服务, 最终传递给应用Updater..

```
  updater(Application)
    |
installupdate(command)
    |
   otad(server) --fork--> update(otad child, real update)
```

大致了解了ota升级的流程之后，我们来看发生ota失败问题的log, 如下所示:

```
// 这个是ota对应服务中打印出来的
09-15 14:47:15.928   256   256 E OTA     : Update system failed, status=0x0006
```

这log对应的代码如下所示:

path: system/otad/commands.c
```
#define UPDATER "/data/local/tmp/update-binary"
#define ASSUMED_UPDATE_BINARY_NAME "META-INF/com/google/android/update-binary"
...
int install_update(int s, const char *update_package, const char *logfile)
{
    ...
    ZipArchive zip;
    int err = mzOpenZipArchive(update_package, &zip);
    ...
    const ZipEntry* binary_entry = mzFindZipEntry(&zip, ASSUMED_UPDATE_BINARY_NAME);
    ...
    unlink(UPDATER);
    int fd = creat(UPDATER, 0750);
    ...
    bool ok = mzExtractZipEntryToFile(&zip, binary_entry, fd);
    ...
    int pipefd[2];
    ...
    pid_t pid = fork();
    ...

    if (pid == 0) {
        ...
        char **args = malloc(sizeof(char*) * 6);
        args[0] = UPDATER;
        args[1] = EXPAND(RECOVERY_API_VERSION);
        args[2] = (char*)malloc(10);
        sprintf(args[2], "%d", pipefd[1]);
        args[3] = (char*)update_package;
        args[4] = (char*)malloc(10);
        sprintf(args[4], "%d", buddy_system_id);
        args[5] = NULL;

        execv(UPDATER, args);
        // 如果是执行execv函数失败的话那么将打印如下信息, 但是从搜集的log来看，update-binary
        // 肯定是成功执行了，因为如下的错误信息并没有打印出来.
        ALOGE("failed to execute updater: %s\n", strerror(errno));
        exit(1);
    }
    ...
    int status;
    waitpid(pid, &status, 0);
    updater_pid = -1;
    if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
        ALOGV("Update system succeeded\n");
        return 0;
    } else {
        umount(MOUNT_POINT_SYSTEM);
        umount(MOUNT_POINT_DATA);
        // 09-15 14:47:15.928   256   256 E OTA     : Update system failed, status=0x0006
        // 根据log发现是由于update-binary进程发生异常退出导致ota升级失败
        ALOGE("Update system failed, status=0x%04x\n", status);
        return status;
    }
}
```

于是check install.log这个log文件保存的是update-binary在升级过程中的各种流程信息.

其信息如下所示:

/data/data/com.android.updater/cache/install.log
```
Creating filesystem with parameters:
    Size: 671088640
    Block size: 4096
    Blocks per group: 32768
    Inodes per group: 8192
    Inode size: 256
    Journal blocks: 2560
    Label:
    Blocks: 163840
    Block groups: 5
    Reserved block group size: 39
Created filesystem with 11/40960 inodes and 5256/163840 blocks
minzip: Extracted 2 file(s)
```

查看了install.log后发现update-binary在解压缩了两个文件之后,后续流程就中断了，根据当前log
无法判断出是如何中断的，于是,

再次跟踪update-binary进程在升级过程中的log check是否有异常迹象，最终定位到如下log
```
// 这个是update-binary进程中打印出来的
09-15 14:47:15.008  3661  3661 F libc    : stack corruption detected
```

3661进程就是update-binary,发现一条非常有意思的log --> "stack corruption detected"

根据log锁定代码出错位置:

path: bionic/libc/bionic/__stack_chk_fail.cpp
```
void __stack_chk_fail() {
   __libc_fatal("stack corruption detected");
}
```

path: bionic/libc/bionic/libc_logging.cpp
```
void __libc_fatal(const char* format, ...) {
  va_list args;
  va_start(args, format);
  __libc_fatal(format, args);
  va_end(args);
  abort();
}
```

综上代码分析可知，正是由于update-binary进程因为某种原因执行了libc中的__stack_chk_fail函数
最终导致异常退出. 可是仅凭上述信息根本无法定位出具体代码出错的位置. 我们只得缩小范围, 我们
采取如下两种方法定位出出错代码函数:

* 在ota升级包中直接修改updater-script edify脚本找到是在解压缩system目录中文件出错.

* 在bootable/recovery目录中的updater和minzip目录中添加log定位出是在解压缩Settings.apk的时候出错.

出错的地方非常有意思,如下所示:
```
minzip: we will extract: targetFile = /data/buddy/system/priv-app/SecurityCenter.apk
minzip: we will call mzProcessZipEntryContents

minzip: processDeflatedEntry
minzip: processDeflatedEntry sucessuly
minzip: processDeflatedEntry finished

minzip: we have finished mzProcessZipEntryContents
minzip: Extracted file "/data/buddy/system/priv-app/SecurityCenter.apk"

minzip: we will extract: targetFile = /data/buddy/system/priv-app/Settings.apk
minzip: we will call mzProcessZipEntryContents
minzip: processDeflatedEntry
minzip: processDeflatedEntry sucessuly
```

根据log来分析代码:

path: bootable/recovery/minzip/Zip.c
```
bool mzProcessZipEntryContents(const ZipArchive *pArchive,
    const ZipEntry *pEntry, ProcessZipEntryContentsFunction processFunction,
    void *cookie)
{
    ...
    switch (pEntry->compression) {
    ...
    case DEFLATED:
        ret = processDeflatedEntry(pArchive, pEntry, processFunction, cookie);
        // log: minzip: processDeflatedEntry finished
        // 是在这个位置打印的
        break;
    }

    return ret;
}

static bool processDeflatedEntry(const ZipArchive *pArchive,
    const ZipEntry *pEntry, ProcessZipEntryContentsFunction processFunction,
    void *cookie)
{
    // log: minzip: processDeflatedEntry
    // 是在这个位置打印
    long result = -1;
    unsigned char readBuf[32 * 1024];
    unsigned char procBuf[32 * 1024];
    z_stream zstream;
    int zerr;
    long compRemaining;

    compRemaining = pEntry->compLen;

    /*
     * Initialize the zlib stream.
     */
    memset(&zstream, 0, sizeof(zstream));
    zstream.zalloc = Z_NULL;
    zstream.zfree = Z_NULL;
    zstream.opaque = Z_NULL;
    zstream.next_in = NULL;
    zstream.avail_in = 0;
    zstream.next_out = (Bytef*) procBuf;
    zstream.avail_out = sizeof(procBuf);
    zstream.data_type = Z_UNKNOWN;

    /*
     * Use the undocumented "negative window bits" feature to tell zlib
     * that there's no zlib header waiting for it.
     */
    zerr = inflateInit2(&zstream, -MAX_WBITS);
    if (zerr != Z_OK) {
        if (zerr == Z_VERSION_ERROR) {
            LOGE("Installed zlib is not compatible with linked version (%s)\n",
                ZLIB_VERSION);
        } else {
            LOGE("Call to inflateInit2 failed (zerr=%d)\n", zerr);
        }
        goto bail;
    }

    /*
     * Loop while we have data.
     */
    do {
        /* read as much as we can */
        if (zstream.avail_in == 0) {
            long getSize = (compRemaining > (long)sizeof(readBuf)) ?
                        (long)sizeof(readBuf) : compRemaining;
            LOGVV("+++ reading %ld bytes (%ld left)\n",
                getSize, compRemaining);

            int cc = read(pArchive->fd, readBuf, getSize);
            if (cc != (int) getSize) {
                LOGW("inflate read failed (%d vs %ld)\n", cc, getSize);
                goto z_bail;
            }

            compRemaining -= getSize;

            zstream.next_in = readBuf;
            zstream.avail_in = getSize;
        }

        /* uncompress the data */
        zerr = inflate(&zstream, Z_NO_FLUSH);
        if (zerr != Z_OK && zerr != Z_STREAM_END) {
            LOGD("zlib inflate call failed (zerr=%d)\n", zerr);
            goto z_bail;
        }

        /* write when we're full or when we're done */
        if (zstream.avail_out == 0 ||
            (zerr == Z_STREAM_END && zstream.avail_out != sizeof(procBuf)))
        {
            long procSize = zstream.next_out - procBuf;
            LOGVV("+++ processing %d bytes\n", (int) procSize);
            bool ret = processFunction(procBuf, procSize, cookie);
            if (!ret) {
                LOGW("Process function elected to fail (in inflate)\n");
                goto z_bail;
            }

            zstream.next_out = procBuf;
            zstream.avail_out = sizeof(procBuf);
        }
    } while (zerr == Z_OK);

    assert(zerr == Z_STREAM_END);       /* other errors should've been caught */

    // success!
    result = zstream.total_out;

z_bail:
    inflateEnd(&zstream);        /* free up any allocated structures */

bail:
    if (result != pEntry->uncompLen) {
        if (result != -1)        // error already shown?
            LOGW("Size mismatch on inflated file (%ld vs %ld)\n",
                result, pEntry->uncompLen);
        return false;
    }
    // log: minzip: processDeflatedEntry sucessuly
    // 是在这个位置打印
    return true;
}
```

对比SecurityCenter.apk和Settings.apk解压缩的log我们很快就发现
在调用函数processDeflatedEntry来解压缩Settings.apk的时候在返回到mzProcessZipEntryContents函数的时候
出错不再往下执行的，出现的错误就是:

```
09-15 14:47:15.008  3661  3661 F libc    : stack corruption detected
```

这究竟是为什么呢？processDeflatedEntry函数都执行完成了，而且检查/system/priv-app/下也发现了
解压缩成功的Settings.apk(push可用),可是仅仅在函数返回过程中报出了如上所示错误.

这不科学呀?在函数返回过程中究竟发生了什么? 抱着这样的疑问，我们不得不反汇编processDefaltedEntry函数
查看对应的汇编代码.

什么是Gcc Stack Guard保护机制呢?
--------------------------------------------------------------------------------

### 一个简单的实例

path: src/ex4/stack_guard.c
```
int function(int a, int b, int c)
{
    char buffer[14] = { 0 };
    int sum;

    buffer[0] = 'a';
    buffer[1] = 'b';
    buffer[2] = 'c';
    buffer[3] = 'd';
    buffer[4] = 'e';
    buffer[5] = 'f';
    buffer[6] = 'g';
    buffer[7] = 'h';
    buffer[8] = 'i';
    buffer[9] = 'j';
    buffer[10] = 'k';
    buffer[11] = 'l';
    buffer[12] = 'm';
    buffer[13] = 'n';

    sum = a + b + c;
    return sum;
}

int main(int argc, char **argv)
{
    int x;
    int y;

    x = function(1, 2, 3);
    y = x + 3;

    return 0;
}
```

编译为arm汇编文件如下:

```
# arm-linux-androideabi-gcc是android系统开发的arm gcc编译器
$ arm-linux-androideabi-gcc -fno-stack-protector -S stack_guard.c -o nostackguard.s
$ cat nostackguard.s
    .arch armv5te
    .fpu softvfp
    .eabi_attribute 20, 1
    .eabi_attribute 21, 1
    .eabi_attribute 23, 3
    .eabi_attribute 24, 1
    .eabi_attribute 25, 1
    .eabi_attribute 26, 2
    .eabi_attribute 30, 6
    .eabi_attribute 34, 0
    .eabi_attribute 18, 4
    .file    "stack_guard.c"
    .text
    .align    2
    .global    function
    .type    function, %function
function:
    @ args = 0, pretend = 0, frame = 40
    @ frame_needed = 1, uses_anonymous_args = 0
    @ link register save eliminated.
    str    fp, [sp, #-4]!
    add    fp, sp, #0
    sub    sp, sp, #44
    str    r0, [fp, #-32]
    str    r1, [fp, #-36]
    str    r2, [fp, #-40]
    sub    r3, fp, #24
    mov    r2, #0
    str    r2, [r3]
    add    r3, r3, #4
    mov    r2, #0
    str    r2, [r3]
    add    r3, r3, #4
    mov    r2, #0
    str    r2, [r3]
    add    r3, r3, #4
    mov    r2, #0
    strh    r2, [r3]    @ movhi
    add    r3, r3, #2
    mov    r3, #97
    strb    r3, [fp, #-24]
    mov    r3, #98
    strb    r3, [fp, #-23]
    mov    r3, #99
    strb    r3, [fp, #-22]
    mov    r3, #100
    strb    r3, [fp, #-21]
    mov    r3, #101
    strb    r3, [fp, #-20]
    mov    r3, #102
    strb    r3, [fp, #-19]
    mov    r3, #103
    strb    r3, [fp, #-18]
    mov    r3, #104
    strb    r3, [fp, #-17]
    mov    r3, #105
    strb    r3, [fp, #-16]
    mov    r3, #106
    strb    r3, [fp, #-15]
    mov    r3, #107
    strb    r3, [fp, #-14]
    mov    r3, #108
    strb    r3, [fp, #-13]
    mov    r3, #109
    strb    r3, [fp, #-12]
    mov    r3, #110
    strb    r3, [fp, #-11]
    ldr    r2, [fp, #-32]
    ldr    r3, [fp, #-36]
    add    r2, r2, r3
    ldr    r3, [fp, #-40]
    add    r3, r2, r3
    str    r3, [fp, #-8]
    ldr    r3, [fp, #-8]
    mov    r0, r3
    sub    sp, fp, #0
    @ sp needed
    ldr    fp, [sp], #4
    bx    lr
    .size    function, .-function
    .align    2
    .global    main
    .type    main, %function
main:
    @ args = 0, pretend = 0, frame = 16
    @ frame_needed = 1, uses_anonymous_args = 0
    stmfd    sp!, {fp, lr}
    add    fp, sp, #4
    sub    sp, sp, #16
    str    r0, [fp, #-16]
    str    r1, [fp, #-20]
    mov    r0, #1
    mov    r1, #2
    mov    r2, #3
    bl    function(PLT)
    str    r0, [fp, #-8]
    ldr    r3, [fp, #-8]
    add    r3, r3, #3
    str    r3, [fp, #-12]
    mov    r3, #0
    mov    r0, r3
    sub    sp, fp, #4
    @ sp needed
    ldmfd    sp!, {fp, pc}
    .size    main, .-main
    .ident    "GCC: (GNU) 4.8"
    .section    .note.GNU-stack,"",%progbits
```