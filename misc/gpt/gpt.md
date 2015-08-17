GUID Partition Table (简体中文)
========================================

全局唯一标识分区表（GUID Partition Table，缩写：GPT）是一个实体硬盘的分区表的结构布局的标准。
它是统一可扩展固件接口标准的一部分，它使用全局唯一标识来标识设备。它是新一代分区表格式，
用以替代 MBR 分区表。它用来解决 MBR 分区表的缺点，同时带来了一些优点。

关于主引导记录(MBR)
----------------------------------------

要理解 GPT 为何如此重要就要了解什么是 MBR 以及它有些什么缺点。MBR 分区表像下面这样把分区信息存储在第一个扇区:

HDD 上的位置 代码的用意
```
001-440 bytes 由 BIOS 启动的 MBR 启动代码
441-446 bytes MBR 硬盘签名
447-510 bytes 分区表 (主分区和扩展分区，而非逻辑分区)
511-512 bytes MBR 启动签名 0xAA55.
```

所有主分区的信息都被限制在分配给的64B空间里。为了扩展，我们采用了扩展分区。
一个扩展分区就像是 MBR 上的一个主分区，它是其他被称为逻辑分区的分区的容器。
所以一块硬盘被限制为四个主分区或者三个主分区加一个内有许多逻辑分区的扩展分区。

**MBR 导致的问题**:

只能有四个主分区或者三个主分区加一个扩展分区 (以及在扩展分区中的任意数量的逻辑分区).
如果你有三个主分区加一个扩展分区以及除此之外的空闲空间，在空闲空间之上你无法创立分区。
在扩展分区里，逻辑分区的元数据被存储在一个链表结构中。如果一个环节丢失，该元数据之后的逻辑分区全部丢失。
MBR 只支持1个字节的分区类型编码，导致许多冲突。
MBR 使用32位的 LBA 值来存储分区扇区信息。LBA 的大小以及512B的扇区大小共同限制了硬盘可寻址大小最大为2TB.
如果使用 MBR, 2TB以外的空间无法使用。

关于 GUID 分区表
----------------------------------------

全局唯一标识分区表 (GPT) 使用 GUID (或在 Linux 世界里称为 UUID) 来定义分区，它的类型和它的名称。GPT 组成如下:

HDD 上的位置 用意:
```
硬盘的第一个逻辑扇区或者第一个512B       保护分区 (Protective MBR) - 与一般 MBR 相同但是这个64B区域仅包含了一个类型为 0xEE 的主分区条目，它定义在整个硬盘上，或者大小为2TB的区域(如果硬盘超过2TB)。
硬盘的第二个逻辑扇区或者第二个512B       主 GPT 头                 - 包含唯一硬盘 GUID, 主分区表的位置，分区表的可能条目数，它本身和主分区表的 CRC32 校验值，第二(或备份) GPT 头的位置
硬盘的第二个逻辑扇区之后的16 KB (默认)   主 GPT 表                 - 128个分区条目(默认，可以更高)，每个包含大小为128B的条目(因此128个分区共占16KB)。扇区数存储为64位的 LBA 值，每个分区有一个分区类型 GUID 和一个唯一分区 GUID.
硬盘最后一个扇区前的16 KB (默认)         第二 GPT 表               - 与主表完全相同，主要用于主表损坏时的修复。
硬盘最后一个逻辑扇区或者最后一个512B     第二 GPT 头               - 包含唯一硬盘 GUID, 第二分区表的位置，分区表的可能条目数，它本身和第二分区表的 CRC32 校验值，主 GPT 头的位置。这个头用于当主头损坏时恢复 GPT 信息。
```

**GPT 的优点**:

* 使用 GUID (UUID) 来表明分区类型 - 无冲突。
* 为每个分区提供了一个唯一硬盘 GUID 和一个唯一分区 GUID - 一个好的不依赖文件系统的引用分区和硬盘的方式。
* 任意分区数 - 取决于给分区表分配的空间 - 不需要扩展和逻辑分区。GPT ，默认包含了定义128个分区的空间。当用户想要更多分区时，他可以给分区表分配更多空间 (目前只有 gdisk 支持这一特性)。
* 使用64位 LBA 存储扇区数 - 最大硬盘可寻址大小为 2 ZB.
* 存储了备份头和分区表可于主要部分损坏时进行急救。
* CRC32 校验值用于检测头和分区表的错误与损坏。

### 内核支持

内核配置选项 CONFIG_EFI_PARTITION 启用了内核级 GPT 支持 (忽略它的名称 EFI PARTITION).
这个选项必须是内建在内核中并且不能编译为可加载模块。就算 GPT 硬盘仅用来存储数据而不是启动盘，
也要打开这个选项。在 Arch [core] 源中的 linux 和 linux-lts的默认打开了这个选项。
自定义内核可通过 CONFIG_EFI_PARTITION=y 开启这个选项。

### 引导器支持

#### UEFI 系统

因为 GPT 是 UEFI 标准的一部分，因此所有 UEFI 引导器都支持 GPT 硬盘，并是从 UEFI 启动的强制要求。更多信息见 Boot loaders.

#### BIOS 系统

尽管理论上 GPT 支持 BIOS 系统，但有时会无效甚至完全不兼容。技术上 BIOS 假设为只执行 MBR 上的代码，
因此，保住了不同的分区方案的可能性。然而 BIOS 可能会执行其他的检查比如: 检查 MBR 完整性，甚至可能
是对整个 MBR 分区表(尽管通常只是第一个分区)。如果在这种情况下，下面列出了一些该问题的解决方案。
警告: 对于 Windows 来说，不支持从 BIOS/GPT 分区方案启动。如果你已安装 Windows 在 BIOS/MBR 分区方案上，
不要 转换驱动器到 GPT! 如果完成, Windows 会启动失败 - 与启动 Windows 的引导器无关。我们可以在 UEFI
模式里安装 Windows 或者使用 UEFI bootloader (它使用 GPT), 或者还原/安装 Windows 到 BIOS/GPT
混合 MBR (见分区成例).

### 支持 GPT/BIOS 分区方案的引导器:

*    GRUB
*    Syslinux
*    不支持: GRUB Legacy and LILO

解决方案

有一些从 BIOS/GPT 分区方案启动的解决办法，然而尝试这些之前尝试以引导器标准程序从 BIOS/GPT 启动。

*    在保护分区上设置 boot 参数 (类型为 0xEE). 可由 parted /dev/sdX 和 disk_toggle pmbr_boot 或 sgdisk /dev/sdX --attributes=1:set:2 完成。
*    确认没有 EFI 系统分区。
*    创建混合 MBR. 这个是寻求可用 MBR 分区的 BIOS 所需要的 (见下面的例子)。
*    重新计算保护分区中的 CHS (Cylinder/Head/Sector) 值。GPT 不需要这些值但是保护分区可能需要它们来校准以为测试它们的 BIOS 工作。
*    有可用 MBR 表的第二块硬盘意味着有可执行保护分区上代码的 BIOS.
*    自2011年以来，许多计算机如果 BIOS 选项支持的话可以从 EFI 启动。

分区工具
----------------------------------------

### GPT fdisk

GPT fdisk 是编辑 GPT 硬盘的文本模式工具集。由 gdisk, sgdisk 和 cgdisk 组成，
它们分别和来自 util-linux 的 fdisk (用于 MBR 硬盘)等价。在 [extra] 源的 gptfdisk 可用。

### Util-linux fdisk

来自 util-linux (基于 util-linux 内建的 libfdisk) 的 fdisk 工具部分支持 GPT, 但仍在测试阶段 (自从2013年10月7日).
相关的 cfdisk 和 sfdisk 仍不支持 GPT, 并在 GPT 硬盘上使用的话有可能损坏 GPT 头和分区表。

### GNU Parted

在 GNU Parted >=3.0 中，parted 命令行工具不支持任何文件系统相关的操作，并且文件系统相关代码已从 libparted 中移除，
只留下了由像 gparted 等外部程序所需要的最小代码。上游推荐使用文件系统专有工具或者像 gparted 一样的 parted
的图形界面工具 (这些叫做外部程序) 进行文件系统相关操作。

### 分区成例

#### gdisk basic

```
# gdisk /dev/sdX
o  # create new empty GUID partition table
n  # partition 1 [enter], from beginning [enter], to 100GiB [+100GiB], linux fs type [enter]
n  # partition 2 [enter], from beginning [enter], to 108GiB [+8GiB],   linux swap    [8200]
w  # write table to disk and exit
```

gdisk basic (以及混合 MBR)
提示: 使用 MB, GB 来对齐 2048 扇区。

```
# gdisk /dev/sdX
o  # create new empty GUID partition table
n  # partition 1 [enter], from beginning [enter], to 100GiB [+100GiB], linux fs type [enter]
n  # partition 2 [enter], from beginning [enter], to 108GiB [+8GiB],   linux swap    [8200]
n  # partition 3 [enter], from beginning [enter],           [+1MiB],   linux fs type [enter]
r  # recovery/transformation menu
h  # make hybrid mbr
3  # add partition 3 to hybrid mbr
Place EFI GPT (0xEE) partition first in MBR (good for GRUB)? (Y/N): N
Enter an MBR hex code (default 83): [enter]
Set the bootable flag? (Y/N): Y
Unused partition space(s) found. Use one to protect more partitions? (Y/N): N
w  # write table to disk and exit
```

#### parted basic (通过命令行选项)

```
parted --script /dev/sda mklabel gpt
parted --script --align optimal /dev/sda mkpart primary ext4 0% -8GiB mkpart primary linux-swap -8GiB 100%
```

#### sgdisk basic (自动搜寻)

得到硬盘空间 (disk space) 和交换空间 (swap space) 的值，然后设置根分区 (root partition) 空间。

    硬盘空间'下舍入'到最近的MB数值，头 GPT 元数据被扣除 (1 MB).
    交换空间'上舍入'到基于内存大小的MB数值。

diskspace=$(( $(grep sda$ /proc/partitions | awk '{print $3}') * 2 / 2048 - 1 ))
swapspace=$(( $(head -n1 /proc/meminfo | awk '{print $2}') / 1024 + 1 ))
rootspace=$(( $diskspace - $swapspace ))

运行这个 (这只是测试用模拟运行，删掉 --pretend 来写入分区表):

sgdisk --clear --new 1:0:+${rootspace}MiB --new 2:0:+${swapspace}MiB --typecode 2:8200 --pretend --print /dev/sda

从 MBR 转换为 GPT
----------------------------------------

gdisk (以及 sgdisk 和 cgdisk也是)最好的特性之一就是能无损转换 MBR 和 BSD 盘符到 GPT.
一旦转换完成，MBR 主分区和逻辑分区转换成 GPT 分区并生成有正确的分区类型 GUID 和 唯一分区 GUID.

只需打开 MBR, 用 gdisk 的"w"选项来把改变写入到硬盘(和 fdisk 类似)以转换到 GPT. 警惕所有错误并在写入硬盘之前修复它们，
因为你会有损失数据的风险。更多信息见 http://www.rodsbooks.com/gdisk/mbr2gpt.html . 转换之后，需要重新安装引导器以配置到从 GPT 启动。
注意:

    记住 GPT 在硬盘末尾存储了第二分区表。这个数据结构默认占有了33512B空间。
MBR 不具有类似数据结构，这意味着 MBR 硬盘的最后一个分区的最后一部分可能被占用进而妨碍到完全的转换。
如果这发生在你身上，你必须放弃转换，改变最后一个分区的大小，或是保留最后一个分区不转换。
    注意如果你的启动管理器是 GRUB的话, 它需要 BIOS 启动分区。如果你的 MBR 分区层不是太旧的话，
出于对齐的需要这是一个让第一个分区从2048扇区起始的好机会。这意味着开始的部分有1007 KB的空间可以
分配给 BIOS 启动分区。为此，首先用 gdisk 完成上文的 MBR->GPT 转换，之后，用 gdisk 创建新分区并
手动指定为扇区 34 - 2047, 并设置为 EF02 分区类型。
    在 RAID 模式下的基于 Intel的笔记本有一些关于备份 GPT 表损坏的问题，解决方法是尽可能使用 AHCI 替代 RAID.