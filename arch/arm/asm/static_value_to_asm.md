gdb
========================================

path: src/static_value_to_asm/
```
(gdb) disas
Dump of assembler code for function main:
   0x00008500 <+0>:	push	{r11, lr}
   0x00008504 <+4>:	add	r11, sp, #4
   0x00008508 <+8>:	sub	sp, sp, #8
   0x0000850c <+12>:	str	r0, [r11, #-8]
   0x00008510 <+16>:	str	r1, [r11, #-12]
   0x00008514 <+20>:	bl	0x84e4 <test>
   0x00008518 <+24>:	mov	r2, r0
   0x0000851c <+28>:	ldr	r3, [pc, #16]	; 0x8534 <main+52>
   0x00008520 <+32>:	str	r2, [r3]
=> 0x00008524 <+36>:	mov	r3, #0
   0x00008528 <+40>:	mov	r0, r3
   0x0000852c <+44>:	sub	sp, r11, #4
   0x00008530 <+48>:	pop	{r11, pc}
   0x00008534 <+52>:	andeq	r0, r1, r0, ror #14
End of assembler dump.
(gdb) p/x $r3
$1 = 0x10760
(gdb) p/x $r2
$2 = 0x6
(gdb) p/x *(0x10760)
$3 = 0x6
(gdb) p/x *(0x8534)
$4 = 0x10760
(gdb) x/x 0x8534
0x8534 <main+52>:	0x00010760
(gdb) x/x $pc+16
0x8534 <main+52>:	0x00010760
(gdb) p/x $pc+16
$5 = 0x8534
(gdb) p/x $pc
$6 = 0x8524
```