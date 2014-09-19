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

根据我们添加的log来分析代码:

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

对比SecurityCenter.apk和Settings.apk解压缩的log我们很快就发现在调用函数processDeflatedEntry来
解压缩Settings.apk的时候在返回到mzProcessZipEntryContents函数出错不再往下执行了，出现的错误就是:

```
09-15 14:47:15.008  3661  3661 F libc    : stack corruption detected
```

这究竟是为什么呢？processDeflatedEntry函数都执行完成了，而且检查/system/priv-app/下也发现了
解压缩成功的Settings.apk(push可用),可是仅仅在函数返回过程中报出了如上所示错误.

这不科学呀! 在函数返回过程中究竟发生了什么? 为什么没有返回到调用函数中继续执行?

抱着这样的疑问，我们不得不反汇编processDefaltedEntry函数查看对应的汇编代码.
使用arm-linux-androideabi-objdump命令反汇编processDefaltedEntry函数汇编实现如下所示.

```
    # 根据arm过程调用的规定，stmdb是预先减少存储，先修改sp栈顶指针，然后将调用processDeflatedEntry
    # 函数的r4-r14寄存器值压栈,特别注意fp指针是函数的栈帧指针.
    83a8:    e92d 4ff0     stmdb    sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}

    83ac:    469b          mov    fp, r3

    83ae:    4b4f          ldr    r3, [pc, #316]    ; (84ec <processDeflatedEntry+0x144>)
    83b0:    4692          mov    sl, r2
    83b2:    4a4f          ldr    r2, [pc, #316]    ; (84f0 <processDeflatedEntry+0x148>)
    83b4:    4681          mov    r9, r0
    83b6:    447b          add    r3, pc

    # 在当前函数processDeflatedEntry栈中为临时变量分配空间大小
    # 65536 正好是64KB = readBuf + procBuf的大小
    83b8:    f5ad 3d80     sub.w    sp, sp, #65536    ; 0x10000
    # 下面是为其余的临时变量分配空间.
    83bc:    b093          sub    sp, #76    ; 0x4c

    83be:    460e          mov    r6, r1

    83c0:    5898          ldr    r0, [r3, r2]

    83c2:    f50d 3180     add.w    r1, sp, #65536    ; 0x10000
    83c6:    3144          adds    r1, #68    ; 0x44

    83c8:    2238          movs    r2, #56    ; 0x38
    83ca:    2702          movs    r7, #2
    83cc:    68f5          ldr    r5, [r6, #12]

    83ce:    6803          ldr    r3, [r0, #0]

    83d0:    f50d 4400     add.w    r4, sp, #32768    ; 0x8000

    83d4:    9001          str    r0, [sp, #4]

    83d6:    a803          add    r0, sp, #12

    83da:    f44f 4800     mov.w    r8, #32768    ; 0x8000

    83de:    600b          str    r3, [r1, #0]

    83e0:    2100          movs    r1, #0
    83e2:    f006 e8fa     blx    e5d8 <memset>
    83e6:    970e          str    r7, [sp, #56]    ; 0x38
    83e8:    4f42          ldr    r7, [pc, #264]    ; (84f4 <processDeflatedEntry+0x14c>)
    83ea:    f06f 010e     mvn.w    r1, #14
    83ee:    a803          add    r0, sp, #12
    83f0:    2338          movs    r3, #56    ; 0x38
    83f2:    447f          add    r7, pc
    83f4:    9406          str    r4, [sp, #24]
    83f6:    f8cd 801c     str.w    r8, [sp, #28]
    83fa:    463a          mov    r2, r7
    83fc:    f001 ea6a     blx    98d4 <inflateInit2_>
    8400:    4601          mov    r1, r0
    8402:    b160          cbz    r0, 841e <processDeflatedEntry+0x76>
    8404:    1d82          adds    r2, r0, #6
    8406:    d103          bne.n    8410 <processDeflatedEntry+0x68>
    8408:    483b          ldr    r0, [pc, #236]    ; (84f8 <processDeflatedEntry+0x150>)
    840a:    4639          mov    r1, r7
    840c:    4478          add    r0, pc
    840e:    e001          b.n    8414 <processDeflatedEntry+0x6c>
    8410:    483a          ldr    r0, [pc, #232]    ; (84fc <processDeflatedEntry+0x154>)
    8412:    4478          add    r0, pc
    8414:    f006 feea     bl    f1ec <printf>
    8418:    f04f 34ff     mov.w    r4, #4294967295    ; 0xffffffff
    841c:    e049          b.n    84b2 <processDeflatedEntry+0x10a>
    841e:    af11          add    r7, sp, #68    ; 0x44
    8420:    9a04          ldr    r2, [sp, #16]
    8422:    b9ba          cbnz    r2, 8454 <processDeflatedEntry+0xac>
    8424:    f5b5 4f00     cmp.w    r5, #32768    ; 0x8000
    8428:    bfb4          ite    lt
    842a:    46a8          movlt    r8, r5
    842c:    f44f 4800     movge.w    r8, #32768    ; 0x8000
    8430:    4639          mov    r1, r7
    8432:    f8d9 0000     ldr.w    r0, [r9]
    8436:    4642          mov    r2, r8
    8438:    f005 edae     blx    df98 <read>
    843c:    4540          cmp    r0, r8
    843e:    4601          mov    r1, r0
    8440:    d005          beq.n    844e <processDeflatedEntry+0xa6>
    8442:    482f          ldr    r0, [pc, #188]    ; (8500 <processDeflatedEntry+0x158>)
    8444:    4642          mov    r2, r8
    8446:    4478          add    r0, pc
    8448:    f006 fed0     bl    f1ec <printf>
    844c:    e024          b.n    8498 <processDeflatedEntry+0xf0>
    844e:    1a2d          subs    r5, r5, r0
    8450:    9703          str    r7, [sp, #12]
    8452:    9004          str    r0, [sp, #16]
    8454:    2100          movs    r1, #0
    8456:    a803          add    r0, sp, #12
    8458:    f001 eac2     blx    99e0 <inflate>
    845c:    2801          cmp    r0, #1
    845e:    4603          mov    r3, r0
    8460:    d905          bls.n    846e <processDeflatedEntry+0xc6>
    8462:    4828          ldr    r0, [pc, #160]    ; (8504 <processDeflatedEntry+0x15c>)
    8464:    4619          mov    r1, r3
    8466:    4478          add    r0, pc
    8468:    f006 fec0     bl    f1ec <printf>
    846c:    e014          b.n    8498 <processDeflatedEntry+0xf0>
    846e:    9807          ldr    r0, [sp, #28]
    8470:    b130          cbz    r0, 8480 <processDeflatedEntry+0xd8>
    8472:    2b01          cmp    r3, #1
    8474:    d1d4          bne.n    8420 <processDeflatedEntry+0x78>
    8476:    f5b0 4f00     cmp.w    r0, #32768    ; 0x8000
    847a:    d101          bne.n    8480 <processDeflatedEntry+0xd8>
    847c:    9c08          ldr    r4, [sp, #32]
    847e:    e015          b.n    84ac <processDeflatedEntry+0x104>
    8480:    9906          ldr    r1, [sp, #24]
    8482:    465a          mov    r2, fp
    8484:    4620          mov    r0, r4
    8486:    9300          str    r3, [sp, #0]
    8488:    1b09          subs    r1, r1, r4
    848a:    47d0          blx    sl
    848c:    9a00          ldr    r2, [sp, #0]
    848e:    b930          cbnz    r0, 849e <processDeflatedEntry+0xf6>
    8490:    481d          ldr    r0, [pc, #116]    ; (8508 <processDeflatedEntry+0x160>)
    8492:    4478          add    r0, pc
    8494:    f005 fcd6     bl    de44 <puts>
    8498:    f04f 34ff     mov.w    r4, #4294967295    ; 0xffffffff
    849c:    e006          b.n    84ac <processDeflatedEntry+0x104>
    849e:    f44f 4300     mov.w    r3, #32768    ; 0x8000
    84a2:    9406          str    r4, [sp, #24]
    84a4:    9307          str    r3, [sp, #28]
    84a6:    2a00          cmp    r2, #0
    84a8:    d0ba          beq.n    8420 <processDeflatedEntry+0x78>
    84aa:    e7e7          b.n    847c <processDeflatedEntry+0xd4>
    84ac:    a803          add    r0, sp, #12
    84ae:    f003 e944     blx    b738 <inflateEnd>
    84b2:    6932          ldr    r2, [r6, #16]
    84b4:    4294          cmp    r4, r2
    84b6:    d007          beq.n    84c8 <processDeflatedEntry+0x120>
    84b8:    1c63          adds    r3, r4, #1
    84ba:    d007          beq.n    84cc <processDeflatedEntry+0x124>
    84bc:    4813          ldr    r0, [pc, #76]    ; (850c <processDeflatedEntry+0x164>)
    84be:    4621          mov    r1, r4
    84c0:    4478          add    r0, pc
    84c2:    f006 fe93     bl    f1ec <printf>
    84c6:    e001          b.n    84cc <processDeflatedEntry+0x124>
    84c8:    2001          movs    r0, #1

    # 函数调用返回开始的位置
    84ca:    e000          b.n    84ce <processDeflatedEntry+0x126>
    84ce:    f50d 3180     add.w    r1, sp, #65536    ; 0x10000
    84d2:    9b01          ldr    r3, [sp, #4]
    84d4:    3144          adds    r1, #68    ; 0x44
    84d6:    680a          ldr    r2, [r1, #0]
    84d8:    6819          ldr    r1, [r3, #0]
    # 这里做了一个check
    84da:    428a          cmp    r2, r1
    84dc:    d001          beq.n    84e2 <processDeflatedEntry+0x13a>
    84de:    f004 fc95     bl    ce0c <__stack_chk_fail>

    # 出栈动作
    84e2:    b013          add    sp, #76    ; 0x4c
    84e4:    f50d 3d80     add.w    sp, sp, #65536    ; 0x10000
    # 这里就是返回到调用函数的地方,如果函数调用逻辑能够走到这里，那么就能够正常恢复调用函数的
    # 栈帧指针,就能够成功返回到调用函数中继续执行，现在
    84e8:    e8bd 8ff0     ldmia.w    sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}

    84ec:    00018c3a     .word    0x00018c3a
    84f0:    ffffff84     .word    0xffffff84
    84f4:    00011d6b     .word    0x00011d6b
    84f8:    00011d71     .word    0x00011d71
    84fc:    00011dae     .word    0x00011dae
    8500:    00011da9     .word    0x00011da9
    8504:    00011db2     .word    0x00011db2
    8508:    00011db2     .word    0x00011db2
    850c:    00011dba     .word    0x00011dba
```

从反汇编出来的processDeflatedEntry函数的汇编代码来看，先来看函数调用返回的地方:

```
```