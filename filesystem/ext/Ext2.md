Linux Ext2 Filesystem
================================================================================

Introduction
--------------------------------------------------------------------------------

https://github.com/leeminghao/doc-linux/blob/master/filesystem/fs/ext2.txt

Ext2 磁盘数据结构
--------------------------------------------------------------------------------

任何Ext2分区中的第一个块从不受Ext2文件系统的管理,因为这一块是为分区的引导扇区所保留的.
Ext2分区的其余部分分成块组(block group),每个块组的分布图如下所示:

```
|------------------------------------------------------------------------------|
| 引导块 | 块组0 | ...... | 块组n
|------------------------------------------------------------------------------|
```
如图所示,一些数据结构正好可以放在一个块中,而另一些可能需要更多的块.在Ext2文件系统中的所有块组大小
相同并顺序存放,因此,内核可以从块组的整数索引很容易地得到磁盘中一个块组的位置.

块组0的分布图如下所示:

```
|-------------------------------------------------------------------------------------|
| 超级块(1) | 组描述符(n) | 数据块位图(1) | 索引节点位图(1) | 索引节点表(n) | 数据块(n)
|-------------------------------------------------------------------------------------|
```

由于内核尽可能地把属于一个文件的数据块存放在同一个块组中,所以块组减少了文件的碎片.块组中的每个块包含下列信息之一:

* 文件系统的超级块的一个拷贝
* 一组块组描述符的拷贝
* 一个数据块位图
* 一个索引节点位图
* 一个索引节点表
* 属于文件的一大块数据,即数据块.

**注意**: 通常,超级块与组描述副被复制到每个块组中,只有块组0所包含的超级块和组描述符才由内核使用,而其余的超级块和组描述符保持不变;
事实上,内核甚至不考虑它们.

超级块
--------------------------------------------------------------------------------

Ext2在磁盘上的超级块存放在一个ext2_super_block结构中:

#### ext2_super_block

path: fs/ext2/ext2.h
```
/*
 * Structure of the super block
 */
struct ext2_super_block {
	__le32	s_inodes_count;		/* Inodes count */
	__le32	s_blocks_count;		/* Blocks count */
	__le32	s_r_blocks_count;	/* Reserved blocks count */
	__le32	s_free_blocks_count;	/* Free blocks count */
	__le32	s_free_inodes_count;	/* Free inodes count */
	__le32	s_first_data_block;	/* First Data Block */
	__le32	s_log_block_size;	/* Block size */
	__le32	s_log_frag_size;	/* Fragment size */
	__le32	s_blocks_per_group;	/* # Blocks per group */
	__le32	s_frags_per_group;	/* # Fragments per group */
	__le32	s_inodes_per_group;	/* # Inodes per group */
	__le32	s_mtime;		/* Mount time */
	__le32	s_wtime;		/* Write time */
	__le16	s_mnt_count;		/* Mount count */
	__le16	s_max_mnt_count;	/* Maximal mount count */
	__le16	s_magic;		/* Magic signature */
	__le16	s_state;		/* File system state */
	__le16	s_errors;		/* Behaviour when detecting errors */
	__le16	s_minor_rev_level; 	/* minor revision level */
	__le32	s_lastcheck;		/* time of last check */
	__le32	s_checkinterval;	/* max. time between checks */
	__le32	s_creator_os;		/* OS */
	__le32	s_rev_level;		/* Revision level */
	__le16	s_def_resuid;		/* Default uid for reserved blocks */
	__le16	s_def_resgid;		/* Default gid for reserved blocks */
	/*
	 * These fields are for EXT2_DYNAMIC_REV superblocks only.
	 *
	 * Note: the difference between the compatible feature set and
	 * the incompatible feature set is that if there is a bit set
	 * in the incompatible feature set that the kernel doesn't
	 * know about, it should refuse to mount the filesystem.
	 *
	 * e2fsck's requirements are more strict; if it doesn't know
	 * about a feature in either the compatible or incompatible
	 * feature set, it must abort and not try to meddle with
	 * things it doesn't understand...
	 */
	__le32	s_first_ino; 		/* First non-reserved inode */
	__le16   s_inode_size; 		/* size of inode structure */
	__le16	s_block_group_nr; 	/* block group # of this superblock */
	__le32	s_feature_compat; 	/* compatible feature set */
	__le32	s_feature_incompat; 	/* incompatible feature set */
	__le32	s_feature_ro_compat; 	/* readonly-compatible feature set */
	__u8	s_uuid[16];		/* 128-bit uuid for volume */
	char	s_volume_name[16]; 	/* volume name */
	char	s_last_mounted[64]; 	/* directory where last mounted */
	__le32	s_algorithm_usage_bitmap; /* For compression */
	/*
	 * Performance hints.  Directory preallocation should only
	 * happen if the EXT2_COMPAT_PREALLOC flag is on.
	 */
	__u8	s_prealloc_blocks;	/* Nr of blocks to try to preallocate*/
	__u8	s_prealloc_dir_blocks;	/* Nr to preallocate for dirs */
	__u16	s_padding1;
	/*
	 * Journaling support valid if EXT3_FEATURE_COMPAT_HAS_JOURNAL set.
	 */
	__u8	s_journal_uuid[16];	/* uuid of journal superblock */
	__u32	s_journal_inum;		/* inode number of journal file */
	__u32	s_journal_dev;		/* device number of journal file */
	__u32	s_last_orphan;		/* start of list of inodes to delete */
	__u32	s_hash_seed[4];		/* HTREE hash seed */
	__u8	s_def_hash_version;	/* Default hash version to use */
	__u8	s_reserved_char_pad;
	__u16	s_reserved_word_pad;
	__le32	s_default_mount_opts;
 	__le32	s_first_meta_bg; 	/* First metablock block group */
	__u32	s_reserved[190];	/* Padding to the end of the block */
};
```