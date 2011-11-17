	.file	"tiny_util.c"
	.section .rdata,"dr"
___FUNCTION__.1915:
	.ascii "checked_malloc\0"
LC0:
	.ascii "p\0"
LC1:
	.ascii "tiny_util.c\0"
	.text
.globl _checked_malloc
	.def	_checked_malloc;	.scl	2;	.type	32;	.endef
_checked_malloc:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$40, %esp
	movl	8(%ebp), %eax
	movl	%eax, (%esp)
	call	_malloc
	movl	%eax, -4(%ebp)
	cmpl	$0, -4(%ebp)
	jne	L2
	movl	$LC0, 12(%esp)
	movl	$___FUNCTION__.1915, 8(%esp)
	movl	$7, 4(%esp)
	movl	$LC1, (%esp)
	call	___assert_func
L2:
	movl	-4(%ebp), %eax
	leave
	ret
	.def	_malloc;	.scl	2;	.type	32;	.endef
	.def	___assert_func;	.scl	2;	.type	32;	.endef
