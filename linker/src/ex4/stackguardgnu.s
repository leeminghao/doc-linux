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
	.fnstart
	@ args = 0, pretend = 0, frame = 40
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	.save {fp, lr}
	.setfp fp, sp, #4
	add	fp, sp, #4
	.pad #40
	sub	sp, sp, #40
	str	r0, [fp, #-32]
	str	r1, [fp, #-36]
	str	r2, [fp, #-40]


	ldr	r3, .L4
	ldr	r3, [r3, #0]
	str	r3, [fp, #-8]


	sub	r3, fp, #24
	mov	r2, #0
	str	r2, [r3, #0]
	add	r3, r3, #4
	mov	r2, #0
	str	r2, [r3, #0]
	add	r3, r3, #4
	mov	r2, #0
	str	r2, [r3, #0]
	add	r3, r3, #4
	mov	r2, #0
	strh	r2, [r3, #0]	@ movhi
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
	str	r3, [fp, #-28]
	ldr	r3, [fp, #-28]
	mov	r0, r3


	ldr	r3, .L4
	ldr	r2, [fp, #-8]
	ldr	r3, [r3, #0]
	cmp	r2, r3
	beq	.L3
	bl	__stack_chk_fail
.L3:
	sub	sp, fp, #4
	ldmfd	sp!, {fp, pc}
.L5:
	.align	2
.L4:
	.word	__stack_chk_guard
	.fnend

	.size	function, .-function
	.align	2
	.global	main
	.type	main, %function
main:
	.fnstart
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	.save {fp, lr}
	.setfp fp, sp, #4
	add	fp, sp, #4
	.pad #16
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	mov	r0, #1
	mov	r1, #2
	mov	r2, #3
	bl	function
	str	r0, [fp, #-12]
	ldr	r3, [fp, #-12]
	add	r3, r3, #3
	str	r3, [fp, #-8]
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	ldmfd	sp!, {fp, pc}
	.fnend
	.size	main, .-main
	.ident	"GCC: (Sourcery CodeBench Lite 2013.05-24) 4.7.3"
	.section	.note.GNU-stack,"",%progbits
