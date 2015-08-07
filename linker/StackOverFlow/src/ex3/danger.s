	.file	"danger.c"
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
	subl	$32, %esp
	movl	$0, -22(%ebp)
	movl	$0, -18(%ebp)
	movl	$0, -14(%ebp)
	movw	$0, -10(%ebp)
	movb	$97, -22(%ebp)
	movb	$98, -21(%ebp)
	movb	$99, -20(%ebp)
	movb	$100, -19(%ebp)
	movb	$101, -18(%ebp)
	movb	$102, -17(%ebp)
	movb	$103, -16(%ebp)
	movb	$104, -15(%ebp)
	movb	$105, -14(%ebp)
	movb	$106, -13(%ebp)
	movb	$107, -12(%ebp)
	movb	$108, -11(%ebp)
	movb	$109, -10(%ebp)
	movb	$110, -9(%ebp)
	leal	-22(%ebp), %eax
	addl	$26, %eax
	movl	%eax, -4(%ebp)
	movl	-4(%ebp), %eax
	movl	(%eax), %eax
	leal	8(%eax), %edx
	movl	-4(%ebp), %eax
	movl	%edx, (%eax)
	movl	12(%ebp), %eax
	movl	8(%ebp), %edx
	addl	%eax, %edx
	movl	16(%ebp), %eax
	addl	%edx, %eax
	movl	%eax, -8(%ebp)
	movl	-8(%ebp), %eax
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	function, .-function
	.section	.rodata
.LC0:
	.string	"%d\n"
	.text
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
	movl	$0, 28(%esp)
	movl	$3, 8(%esp)
	movl	$2, 4(%esp)
	movl	$1, (%esp)
	call	function
	movl	$1, 28(%esp)
	movl	28(%esp), %eax
	movl	%eax, 4(%esp)
	movl	$.LC0, (%esp)
	call	printf
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 4.8.2-19ubuntu1) 4.8.2"
	.section	.note.GNU-stack,"",@progbits
