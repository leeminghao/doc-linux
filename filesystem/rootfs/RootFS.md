Linux File System - rootfs
================================================================================

What is rootfs?
--------------------------------------------------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/filesystem/rootfs/ramfs-rootfs-initramfs.txt

History
--------------------------------------------------------------------------------

    在早期的Linux系统中, 一般就只有软盘或者硬盘被用来作为Linux的根文件系统, 因此很容易把这些设备的驱动程序集成到内核中.
但是现在根文件系统可能保存在各种存储设备上, 包括SCSI, SATA,U盘等等. 因此把这些设备驱动程序全部编译到内核中显得不太方便.
利用udevd可以实现实现内核模块的自动加载, 因此我们希望根文件系统的设备驱动程序也能够实现自动加载. 但是这里有一个矛盾,
udevd是一个可执行文件, 在根文件系统被挂载前, 是不可能执行udevd的, 但是如果udevd没有启动, 那就无法自动根据根目录来加载系统设备的驱动程序
同时也无法在/dev目录下建立相应的设备节点. 为了解决这个矛盾,于是出现了initrd(bootloader initialized RAMdisk).
initrd是一个被压缩过的小型根目录, 这个目录中包含了启动阶段中必须的驱动模块, 可执行文件和启动脚本. 包括上面提到的udevd,
当系统启动的时候, booloader会把initrd文件读到内存中,然后把initrd的起始地址告诉内核.内核在运行过程中会解压initrd,
然后把initrd挂载为根目录,然后执行根目录中的/initrc脚本,您可以在这个脚本中运行initrd中的udevd,让它来自动加载设备驱动程序以及
在/dev目录下建立必要的设备节点. 在udevd自动加载磁盘驱动程序之后，就可以mount真正的根目录，并切换到这个根目录中。
可以通过下面的方法来制作一个initrd文件。

```
# dd if=/dev/zero of=initrd.img bs=4k count=1024
# mkfs.ext2 -F initrd.img
# mount -o loop initrd.img  /mnt
# cp -r  miniroot/* /mnt
# umount /mnt
# gzip -9 initrd.img
```

通过上面的命令, 我们制作了一个4M的initrd, 其中miniroot就是一个根目录. 最后我们得到一个名为initrd.img.gz的压缩文件.
利用initrd内核在启动阶段可以顺利的加载设备驱动程序,然而initrd存在以下缺点:
* initrd大小是固定的,例如上面的压缩之前的initrd大小是4M(4k*1024), 假设您的根目录(上例中的miniroot/)总大小仅仅是1M,
  它仍然要占用4M的空间.如果您在dd阶段指定大小为1M,后来发现不够用的时候,必须按照上面的步骤重新来一次.
* initrd是一个虚拟的块设备,在上面的例子中,您可是使用fdisk对这个虚拟块设备进行分区.在内核中,对块设备的读写还要经过缓冲区管理模块,
  也就是说,当内核读取initrd中的文件内容时,缓冲区管理层会认为下层的块设备速度比较慢,因此会启用预读和缓存功能.这样initrd本身就在内存中,
  同时块设备缓冲区管理层还会保存一部分内容.

为了避免上述缺点,于是出现了initramfs,它的作用和initrd类似,您可以使用下面的方法来制作一个initramfs:

```
# find miniroot/ | cpio -c -o > initrd.img
# gzip initrd.img
```

这样得到的initrd.img大小是可变的,它取决于您的小型根目录miniroot/的总大小,由于首选使用cpio把根目录进行打包，
因此这个initramfs又被称为cpio initrd. 在系统启动阶段, bootloader除了从磁盘上机制内核镜像bzImage之外,还要加载
initrd.img.gz,然后把initrd.img.gz的起始地址传递给内核. 能不能把这两个文件合二为一呢? 答案是肯定的, 在Linux2.6的内核中,
可以把initrd.img.gz链接到内核文件(ELF格式)的一个特殊的数据段中, 这个段的名字为.init.ramfs.
其中全局变量__initramfs_start和__initramfs_end分别指向这个数据段的起始地址和结束地址.
内核启动时会对.init.ramfs段中的数据进行解压, 然后使用它作为临时的根文件系统.

别看这个过程复杂，只需要在make menuconfig中配置以下选项就可以了：

```
General setup  --->
    [*] Initial RAM filesystem and RAM disk (initramfs/initrd) support
    (../miniroot/)    Initramfs source file(s)
```

其中../miniroot/就是我们的小型根目录. 这样就只需要一个内核镜像文件就可以了. 内核在启动过程中, 必须对以下几种情况进行处理：
如果.init.ramfs数据段大小不为0(initramfs_end - initramfs_start != 0), 就说明这是initrd集成在内核数据段中.并且是cpio的initrd.
initrd是由bootloader加载到内存中的,这时bootloader会把起始地址和结束地址传递给内核,内核中的全局initrd_start和initrd_end分别
指向initrd的起始地址和结束地址。现在内核还需要判断这个initrd是新式的cpio格式的initrd还是旧的initrd.

安装根文件系统
--------------------------------------------------------------------------------

安装根文件系统是系统初始化的关键部分.这是一个相当复杂的过程,因为Linux内核允许根文件系统存放在很多不同的地方,比如:
硬盘分区,软盘,通过NFS共享的远程文件系统,甚至保存到ramdisk中(RAM中的虚拟块设备).
当系统启动时,内核就要在变量ROOT_DEV中寻找包含根文件系统的磁盘主设备号.当编译内核时,或者向最初的bootloader传递一个root
选项时,根文件系统可以被指定为/dev目录下的一个设备文件.类似的,根文件系统的安装标志存放在root_mountflags变量中.用户可以指定
这些标志,或者通过对已编译的内核映像使用rdev外部程序，或者想最初的bootloader程序传递一个合适的rootflags选项来达到.

安装根文件系统分为两个阶段:

## Stage1

内核安装特殊rootfs文件系统,该文件系统仅提供一个作为初始安装点的空目录.

#### init_rootfs

path: init/do_mounts.c
```
int __init init_rootfs(void)
{
    /* 调用register_filesystem函数注册rootfs文件系统 */
    int err = register_filesystem(&rootfs_fs_type);

    if (err)
        return err;

    if (IS_ENABLED(CONFIG_TMPFS) && !saved_root_name[0] &&
        (!root_fs_names || strstr(root_fs_names, "tmpfs"))) {
        err = shmem_init();
        is_tmpfs = true;
    } else {
        err = init_ramfs_fs();
    }

    if (err)
        unregister_filesystem(&rootfs_fs_type);

    return err;
}
```

#### rootfs_fs_type

path: init/do_mounts.c
```
static struct file_system_type rootfs_fs_type = {
	.name		= "rootfs",
	.mount		= rootfs_mount,
	.kill_sb	= kill_litter_super,
};
```

## Stage2

内核在空目录上安装实际的根文件系统.

**注意:** 内核为何要在安装实际根文件系统之前安装rootfs文件系统呢?
  rootfs文件系统允许内核容易地改变实际根文件系统.事实上,在某些情况下,内核逐个地安装和卸载几个根文件系统.



Blog
--------------------------------------------------------------------------------
* http://blog.csdn.net/zzobin/article/details/7722838 (Linux内核Ramdisk机制)
* http://www.linuxsir.org/bbs/thread336103.html (精通initramfs的构建)
* http://blog.linux.org.tw/~jserv/archives/001954.html (深入理解Linux 2.6的initramfs机制)
* http://www.ibm.com/developerworks/cn/linux/l-k26initrd/ (Linux 2.6内核的Initrd机制解析)
