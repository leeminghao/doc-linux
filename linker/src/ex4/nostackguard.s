	.arch armv5te
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 0
	.eabi_attribute 18, 4
	.file	"stack_guard.c"
	.text
	.align	2
	.global	function
	.type	function, %function
function:
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	@ link register save eliminated.
	str	fp, [sp, #-4]!
	add	fp, sp, #0
	sub	sp, sp, #44
	str	r0, [fp, #-32]
	str	r1, [fp, #-36]
	str	r2, [fp, #-40]
	sub	r3, fp, #24
	mov	r2, #0
	str	r2, [r3]
	add	r3, r3, #4
	mov	r2, #0
	str	r2, [r3]
	add	r3, r3, #4
	mov	r2, #0
	str	r2, [r3]
	add	r3, r3, #4
	mov	r2, #0
	strh	r2, [r3]	@ movhi
	add	r3, r3, #2
	mov	r3, #97
	strb	r3, [fp, #-24]
	mov	r3, #98
	strb	r3, [fp, #-23]
	mov	r3, #99
	strb	r3, [fp, #-22]
	mov	r3, #100
	strb	r3, [fp, #-21]
	mov	r3, #101
	strb	r3, [fp, #-20]
	mov	r3, #102
	strb	r3, [fp, #-19]
	mov	r3, #103
	strb	r3, [fp, #-18]
	mov	r3, #104
	strb	r3, [fp, #-17]
	mov	r3, #105
	strb	r3, [fp, #-16]
	mov	r3, #106
	strb	r3, [fp, #-15]
	mov	r3, #107
	strb	r3, [fp, #-14]
	mov	r3, #108
	strb	r3, [fp, #-13]
	mov	r3, #109
	strb	r3, [fp, #-12]
	mov	r3, #110
	strb	r3, [fp, #-11]
	ldr	r2, [fp, #-32]
	ldr	r3, [fp, #-36]
	add	r2, r2, r3
	ldr	r3, [fp, #-40]
	add	r3, r2, r3
	str	r3, [fp, #-8]
	ldr	r3, [fp, #-8]
	mov	r0, r3
	sub	sp, fp, #0
	@ sp needed
	ldr	fp, [sp], #4
	bx	lr
	.size	function, .-function
	.align	2
	.global	main
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	mov	r0, #1
	mov	r1, #2
	mov	r2, #3
	bl	function(PLT)
	str	r0, [fp, #-8]
	ldr	r3, [fp, #-8]
	add	r3, r3, #3
	str	r3, [fp, #-12]
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	ldmfd	sp!, {fp, pc}
	.size	main, .-main
	.ident	"GCC: (GNU) 4.8"
	.section	.note.GNU-stack,"",%progbits
