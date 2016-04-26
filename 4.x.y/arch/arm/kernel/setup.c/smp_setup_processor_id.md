smp_setup_processor_id
========================================

path: arch/arm/kernel/setup.c
```
u32 __cpu_logical_map[NR_CPUS] = { [0 ... NR_CPUS-1] = MPIDR_INVALID };

void __init smp_setup_processor_id(void)
{
    int i;
    u32 mpidr = is_smp() ? read_cpuid_mpidr() & MPIDR_HWID_BITMASK : 0;
    u32 cpu = MPIDR_AFFINITY_LEVEL(mpidr, 0);

    cpu_logical_map(0) = cpu;
    for (i = 1; i < nr_cpu_ids; ++i)
        cpu_logical_map(i) = i == cpu ? 0 : i;

    /*
     * clear __my_cpu_offset on boot CPU to avoid hang caused by
     * using percpu variable early, for example, lockdep will
     * access percpu variable inside lock_release
     */
    set_my_cpu_offset(0);

    pr_info("Booting Linux on physical CPU 0x%x\n", mpidr);
}
```