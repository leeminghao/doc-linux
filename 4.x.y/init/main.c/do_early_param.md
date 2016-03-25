do_early_param
========================================

path: init/main.c
```
/* Check for early params. */
static int __init do_early_param(char *param, char *val, const char *unused)
{
    const struct obs_kernel_param *p;

    for (p = __setup_start; p < __setup_end; p++) {
        if ((p->early && parameq(param, p->str)) ||
            (strcmp(param, "console") == 0 &&
             strcmp(p->str, "earlycon") == 0)
        ) {
            if (p->setup_func(val) != 0)
                pr_warn("Malformed early option '%s'\n", param);
        }
    }
    /* We accept everything at this stage. */
    return 0;
}
```

struct obs_kernel_param
----------------------------------------

https://github.com/leeminghao/doc-linux/tree/master/4.x.y/include/linux/init.h/struct_obs_kernel_param.md

__setup_start vs __setup_end
----------------------------------------

__setup_start和setup_end在vmlinux.lds.h中定义，显然所有名为.init.setup的段
都包含在其中.

path: include/asm-generic/vmlinux.lds.h
```
#define INIT_SETUP(initsetup_align)					\
		. = ALIGN(initsetup_align);				\
		VMLINUX_SYMBOL(__setup_start) = .;			\
		*(.init.setup)						\
		VMLINUX_SYMBOL(__setup_end) = .;
```

path: arch/arm/kernel/vmlinux.lds.S
```
	.init.data : {
                ...
		INIT_SETUP(16)
                ...
	}
```

从System.map中可以看到一共包含如下函数:

```
c04cce70 T __setup_start
c04cce7c t __setup_rdinit_setup
c04cce88 t __setup_init_setup
c04cce94 t __setup_loglevel
c04ccea0 t __setup_quiet_kernel
c04cceac t __setup_debug_kernel
c04cceb8 t __setup_set_reset_devices
c04ccec4 t __setup_root_delay_setup
c04cced0 t __setup_fs_names_setup
c04ccedc t __setup_root_data_setup
c04ccee8 t __setup_rootwait_setup
c04ccef4 t __setup_root_dev_setup
c04ccf00 t __setup_readwrite
c04ccf0c t __setup_readonly
c04ccf18 t __setup_load_ramdisk
c04ccf24 t __setup_ramdisk_start_setup
c04ccf30 t __setup_prompt_ramdisk
c04ccf3c t __setup_no_initrd
c04ccf48 t __setup_retain_initrd_param
c04ccf54 t __setup_lpj_setup
c04ccf60 t __setup_early_mem
c04ccf6c t __setup_fpe_setup
c04ccf78 t __setup_user_debug_setup
c04ccf84 t __setup_early_coherent_pool
c04ccf90 t __setup_keepinitrd_setup
c04ccf9c t __setup_early_initrd
c04ccfa8 t __setup_early_vmalloc
c04ccfb4 t __setup_early_ecc
c04ccfc0 t __setup_early_nowrite
c04ccfcc t __setup_early_nocache
c04ccfd8 t __setup_early_cachepolicy
c04ccfe4 t __setup_noalign_setup
c04ccff0 t __setup_versatile_pci_slot_ignore
c04ccffc t __setup_coredump_filter_setup
c04cd008 t __setup_oops_setup
c04cd014 t __setup_setup_crash_kexec_post_notifiers
c04cd020 t __setup_strict_iomem
c04cd02c t __setup_reserve_setup
c04cd038 t __setup_file_caps_disable
c04cd044 t __setup_setup_print_fatal_signals
c04cd050 t __setup_reboot_setup
c04cd05c t __setup_cpu_idle_nopoll_setup
c04cd068 t __setup_cpu_idle_poll_setup
c04cd074 t __setup_sleep_states_setup
c04cd080 t __setup_keep_bootcon_setup
c04cd08c t __setup_console_suspend_disable
c04cd098 t __setup_console_setup
c04cd0a4 t __setup_ignore_loglevel_setup
c04cd0b0 t __setup_log_buf_len_setup
c04cd0bc t __setup_setup_forced_irqthreads
c04cd0c8 t __setup_irqpoll_setup
c04cd0d4 t __setup_irqfixup_setup
c04cd0e0 t __setup_noirqdebug_setup
c04cd0ec t __setup_ntp_tick_adj_setup
c04cd0f8 t __setup_boot_override_clock
c04cd104 t __setup_boot_override_clocksource
c04cd110 t __setup_cgroup_set_legacy_files_on_dfl
c04cd11c t __setup_cgroup_disable
c04cd128 t __setup_set_mminit_loglevel
c04cd134 t __setup_setup_slab_nomerge
c04cd140 t __setup_disable_randmaps
c04cd14c t __setup_early_memblock
c04cd158 t __setup_slab_max_order_setup
c04cd164 t __setup_noaliencache_setup
c04cd170 t __setup_set_dhash_entries
c04cd17c t __setup_set_ihash_entries
c04cd188 t __setup_set_mphash_entries
c04cd194 t __setup_set_mhash_entries
c04cd1a0 t __setup_nfs_root_setup
c04cd1ac t __setup_elevator_setup
c04cd1b8 t __setup_force_gpt_fn
c04cd1c4 t __setup_setup_io_tlb_npages
c04cd1d0 t __setup_pci_setup
c04cd1dc t __setup_fb_console_setup
c04cd1e8 t __setup_video_setup
c04cd1f4 t __setup_sysrq_always_enabled_setup
c04cd200 t __setup_param_setup_earlycon
c04cd20c t __setup_mount_param
c04cd218 t __setup_ramdisk_size
c04cd224 t __setup_mtdpart_setup
c04cd230 t __setup_netdev_boot_setup
c04cd23c t __setup_netdev_boot_setup
c04cd248 t __setup_set_thash_entries
c04cd254 t __setup_set_tcpmhash_entries
c04cd260 t __setup_set_uhash_entries
c04cd26c t __setup_vendor_class_identifier_setup
c04cd278 t __setup_nfsaddrs_config_setup
c04cd284 t __setup_ip_auto_config_setup
c04cd290 t __initcall_cpu_suspend_alloc_spearly
c04cd290 T __initcall_start
c04cd290 T __setup_end
```