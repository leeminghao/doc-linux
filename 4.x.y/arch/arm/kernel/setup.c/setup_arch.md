setup_arch
========================================

path: arch/arm/kernel/setup.c
```
void __init setup_arch(char **cmdline_p)
{
    const struct machine_desc *mdesc;

    setup_processor();
    mdesc = setup_machine_fdt(__atags_pointer);
    if (!mdesc)
        mdesc = setup_machine_tags(__atags_pointer, __machine_arch_type);
    machine_desc = mdesc;
    machine_name = mdesc->name;
    dump_stack_set_arch_desc("%s", mdesc->name);

    if (mdesc->reboot_mode != REBOOT_HARD)
        reboot_mode = mdesc->reboot_mode;

    init_mm.start_code = (unsigned long) _text;
    init_mm.end_code   = (unsigned long) _etext;
    init_mm.end_data   = (unsigned long) _edata;
    init_mm.brk       = (unsigned long) _end;

    /* populate cmd_line too for later use, preserving boot_command_line */
    strlcpy(cmd_line, boot_command_line, COMMAND_LINE_SIZE);
    *cmdline_p = cmd_line;

    parse_early_param();

    early_paging_init(mdesc, lookup_processor_type(read_cpuid_id()));
    setup_dma_zone(mdesc);
    sanity_check_meminfo();
    arm_memblock_init(mdesc);

    paging_init(mdesc);
    request_standard_resources(mdesc);

    if (mdesc->restart)
        arm_pm_restart = mdesc->restart;

    unflatten_device_tree();

    arm_dt_init_cpu_maps();
    psci_init();
#ifdef CONFIG_SMP
    if (is_smp()) {
        if (!mdesc->smp_init || !mdesc->smp_init()) {
            if (psci_smp_available())
                smp_set_ops(&psci_smp_ops);
            else if (mdesc->smp)
                smp_set_ops(mdesc->smp);
        }
        smp_init_cpus();
        smp_build_mpidr_hash();
    }
#endif

    if (!is_smp())
        hyp_mode_check();

    reserve_crashkernel();

#ifdef CONFIG_MULTI_IRQ_HANDLER
    handle_arch_irq = mdesc->handle_irq;
#endif

#ifdef CONFIG_VT
#if defined(CONFIG_VGA_CONSOLE)
    conswitchp = &vga_con;
#elif defined(CONFIG_DUMMY_CONSOLE)
    conswitchp = &dummy_con;
#endif
#endif

    if (mdesc->init_early)
        mdesc->init_early();
}
```