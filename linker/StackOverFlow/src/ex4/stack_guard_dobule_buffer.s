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
	.file	"stack_guard_dobule_buffer.c"
	.text
	.align	2
	.global	function
	.type	function, %function
function:
	@ args = 0, pretend = 0, frame = 56
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #56
	str	r0, [fp, #-48]
	str	r1, [fp, #-52]
	str	r2, [fp, #-56]
	ldr	r2, .L4
.LPIC0:
	add	r2, pc, r2
	ldr	r3, .L4+4
	ldr	r3, [r2, r3]
	ldr	r3, [r3]
	str	r3, [fp, #-8]


	sub	r3, fp, #36
	mov	r1, #0
	str	r1, [r3]
	add	r3, r3, #4
	mov	r1, #0
	str	r1, [r3]
	add	r3, r3, #4
	mov	r1, #0
	strh	r1, [r3]	@ movhi
	add	r3, r3, #2
	sub	r3, fp, #24
	mov	r1, #0
	str	r1, [r3]
	add	r3, r3, #4
	mov	r1, #0
	str	r1, [r3]
	add	r3, r3, #4
	mov	r1, #0
	str	r1, [r3]
	add	r3, r3, #4
	mov	r1, #0
	strh	r1, [r3]	@ movhi
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

	mov	r3, #48
	strb	r3, [fp, #-36]
	mov	r3, #49
	strb	r3, [fp, #-35]
	mov	r3, #50
	strb	r3, [fp, #-34]
	mov	r3, #51
	strb	r3, [fp, #-33]
	mov	r3, #52
	strb	r3, [fp, #-32]
	mov	r3, #53
	strb	r3, [fp, #-31]
	mov	r3, #54
	strb	r3, [fp, #-30]
	mov	r3, #55
	strb	r3, [fp, #-29]
	mov	r3, #56
	strb	r3, [fp, #-28]
	mov	r3, #57
	strb	r3, [fp, #-27]


	ldr	r1, [fp, #-48]
	ldr	r3, [fp, #-52]
	add	r1, r1, r3
	ldr	r3, [fp, #-56]
	add	r3, r1, r3
	str	r3, [fp, #-40]
	ldr	r3, [fp, #-40]
	mov	r0, r3
	ldr	r3, .L4+4
	ldr	r3, [r2, r3]
	ldr	r2, [fp, #-8]
	ldr	r3, [r3]
	cmp	r2, r3
	beq	.L3
	bl	__stack_chk_fail(PLT)
.L3:
	sub	sp, fp, #4
	@ sp needed
	ldmfd	sp!, {fp, pc}
.L5:
	.align	2
.L4:
	.word	_GLOBAL_OFFSET_TABLE_-(.LPIC0+8)
	.word	__stack_chk_guard(GOT)
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
	str	r0, [fp, #-12]
	ldr	r3, [fp, #-12]
	add	r3, r3, #3
	str	r3, [fp, #-8]
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	@ sp needed
	ldmfd	sp!, {fp, pc}
	.size	main, .-main
	.ident	"GCC: (GNU) 4.8"
	.section	.note.GNU-stack,"",%progbits
