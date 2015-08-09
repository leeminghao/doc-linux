binfmts.h
========================================

linux_binprm
----------------------------------------

path: include/linux/binfmts.h
```
/*
 * This structure is used to hold the arguments that are used when loading binaries.
 */
struct linux_binprm {
       char buf[BINPRM_BUF_SIZE];
#ifdef CONFIG_MMU
       struct vm_area_struct *vma;
       unsigned long vma_pages;
#else
# define MAX_ARG_PAGES  32
  struct page *page[MAX_ARG_PAGES];
#endif
        struct mm_struct *mm;
        unsigned long p; /* current top of mem */
        unsigned int
             cred_prepared:1, /* true if creds already prepared (multiple
                               * preps happen for interpreters) */
             cap_effective:1; /* true if has elevated effective capabilities,
                               * false if not; except for init which inherits
                               * its parent's caps anyway */
#ifdef __alpha__
       unsigned int taso:1;
#endif
        unsigned int recursion_depth;
        struct file * file;
        struct cred *cred;      /* new credentials */
        int unsafe;             /* how unsafe this exec is (mask of LSM_UNSAFE_*) */
        unsigned int per_clear; /* bits to clear in current->personality */
        int argc, envc;
        const char * filename;  /* Name of binary as seen by procps */
        const char * interp;    /* Name of the binary really executed. Most
                                 * of the time same as filename, but could be
                                 * different for binfmt_{misc,script} */
        unsigned interp_flags;
        unsigned interp_data;
        unsigned long loader, exec;
        char tcomm[TASK_COMM_LEN];
};
```

linux_binfmt
----------------------------------------

path: include/linux/binfmts.h
```
/*
 * This structure defines the functions that are used to load the binary formats that
 * linux accepts.
 */
struct linux_binfmt {
    struct list_head lh;
    struct module *module;
    int (*load_binary)(struct linux_binprm *);
    int (*load_shlib)(struct file *);
    int (*core_dump)(struct coredump_params *cprm);
    unsigned long min_coredump;    /* minimal dump size */
};
```

### load_binary

用于加载普通程序.

### load_shlib

用于加载共享库.

### core_dump

用于在程序错误的情况下输出内存转储. 该转储随后可以使用调试器gdb
进行分析，以便解决问题.

### min_coredump

是生成内存转储时，内存转储文件长度的下界(通常这是一个内存页的长度).
