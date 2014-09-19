	.file	"stack_guard.c"
	.text
	.globl	function
	.type	function, @function
function:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$40, %esp
	movl	%gs:20, %eax
	movl	%eax, -12(%ebp)
	xorl	%eax, %eax
	movl	$0, -26(%ebp)
	movl	$0, -22(%ebp)
	movl	$0, -18(%ebp)
	movw	$0, -14(%ebp)
	movb	$97, -26(%ebp)
	movb	$98, -25(%ebp)
	movb	$99, -24(%ebp)
	movb	$100, -23(%ebp)
	movb	$101, -22(%ebp)
	movb	$102, -21(%ebp)
	movb	$103, -20(%ebp)
	movb	$104, -19(%ebp)
	movb	$105, -18(%ebp)
	movb	$106, -17(%ebp)
	movb	$107, -16(%ebp)
	movb	$108, -15(%ebp)
	movb	$109, -14(%ebp)
	movb	$110, -13(%ebp)
	movl	12(%ebp), %eax
	movl	8(%ebp), %edx
	addl	%eax, %edx
	movl	16(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -32(%ebp)
	movl	-32(%ebp), %eax
	movl	-12(%ebp), %ecx
	xorl	%gs:20, %ecx
	je	.L3
	call	__stack_chk_fail
.L3:
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	function, .-function
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	andl	$-16, %esp
	subl	$32, %esp
	movl	$3, 8(%esp)
	movl	$2, 4(%esp)
	movl	$1, (%esp)
	call	function
	movl	%eax, 24(%esp)
	movl	24(%esp), %eax
	addl	$3, %eax
	movl	%eax, 28(%esp)
	movl	$0, %eax
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 4.8.2-19ubuntu1) 4.8.2"
	.section	.note.GNU-stack,"",@progbits
