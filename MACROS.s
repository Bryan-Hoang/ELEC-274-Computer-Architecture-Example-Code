# MACROS.S [170123]
# QECE ELEC274
# Author:
#	David Athersych

.ifndef _macros_s
.equ _macros_s,1

	.macro	PUSH	reg
	subi	sp, sp, 4	# reserve space for register
	stw	\reg, 0(sp)		# store register
	.endm

	.macro	POP	reg
	ldw	\reg, 0(sp)		# top item copied to register
	addi	sp, sp, 4	# discard space
	.endm

# .altmacro needed before next macro definitions
.altmacro

# Enhanced function call - pushes arguments on stack in reverse order
        
.macro ccall func:req, arg1, args:vararg
	local argc
	argc = 0

	# Recursive reverse pusher. Think of arguments as parg1 mentioned
	# explicitly, and pargs really being parg2, parg3, ... .  Keep invoking
	# pusher on pargs (meaning parg2 becomes the new parg1, etc.)  Pusher
	# stops recursing when it is given an empty list.
	.macro pusher parg1, pargs:vararg
	# If parg1 blank, nothing to do
		.ifnb \parg1
		pusher  \pargs
		push    \parg1
		argc = argc + 1
		.endif
	.endm

	pusher  \arg1 \args
	call    \func
	# After function returns, check if there are arguments pushed.
	# If so, discard all stack space used for arguments by adding 4 bytes per
	# argument.
	.if \argc
	addi	sp, sp, argc * 4
	.endif
.endm

# Macros to push and pop several registers.  Pushed and popped in order written
# so a pshrgs r1 r2 r3   has to be followed by poprgs r3 r2 r1.

.macro pshrgs reg1, regs:vararg
	local	n
	local	off
	n = 0
	.macro countargs rr1, rn:varargs
		.ifnb	\rr1
		n = n + 1
		countargs \rn
		.endif
	.endm
	.macro pshrg rr1, rn:varargs
		.ifnb	\rr1
		stw		\rr1, off(sp)
		off = off - 4
		pshrg	\rn
	.endm

	countargs reg1, regs
	off = (n-1)*4
	subi	sp, sp, n*4		# allocate space for all registers
	pshrg	reg1, regs
.endm

.macro poprgs reg1, regs:vararg
	local	n
	local	off
	n = 0
	.macro countargs r1, rn:varargs
		.ifnb	\r1
		n = n + 1
		countargs \rn
		.endif
	.endm
	.macro poprg rr1, rn:varargs
		.ifnb	\rr1
		ldw		\rr1, off(sp)
		off = off + 4
		poprg	\rn
	.endm

	countargs reg1, regs
	off = 0
	poprg	reg1, regs
	addi	sp, sp, n*4		# free space used
.endm

.endif
