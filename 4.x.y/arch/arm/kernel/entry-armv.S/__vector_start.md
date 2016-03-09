__vector_start
========================================

Linux kernel ARM异常向量表:

__vector_start
----------------------------------------

path: arch/arm/kernel/entry-armv.S中:
```
__vectors_start:
	W(b)	vector_rst
	W(b)	vector_und
	W(ldr)	pc, __vectors_start + 0x1000 @(__stubs_start == vector + 0x1000)
	W(b)	vector_pabt
	W(b)	vector_dabt
	W(b)	vector_addrexcptn
	W(b)	vector_irq
	W(b)	vector_fiq

```
