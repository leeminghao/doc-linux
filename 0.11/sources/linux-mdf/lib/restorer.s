.globl sig_restore
.globl masksig_restore

sig_restore:
    addl $4,%esp
    popl %eax
    popl %ecx
    popl %edx
    popfl
    ret

masksig_restore:
    addl $4,%esp
    call ssetmask
    addl $4,%esp
    popl %eax
    popl %ecx
    popl %edx
    popfl
    ret
