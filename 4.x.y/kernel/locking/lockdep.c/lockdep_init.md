lockdep_init
========================================

path: kernel/locking/lockdep.c
```
void lockdep_init(void)
{
    int i;

    /*
     * Some architectures have their own start_kernel()
     * code which calls lockdep_init(), while we also
     * call lockdep_init() from the start_kernel() itself,
     * and we want to initialize the hashes only once:
     */
    if (lockdep_initialized)
        return;

    for (i = 0; i < CLASSHASH_SIZE; i++)
        INIT_LIST_HEAD(classhash_table + i);

    for (i = 0; i < CHAINHASH_SIZE; i++)
        INIT_LIST_HEAD(chainhash_table + i);

    lockdep_initialized = 1;
}
```