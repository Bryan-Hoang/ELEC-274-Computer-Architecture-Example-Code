# MACROS.S [170123]

##### DISCLAIMER ###############################################################
# This code has been provided by David Athersych primarily to support students
# in QECE ELEC274. The receiver of this code may use it without charge, subject
# to the following conditions: (a) the receiver acknowledges that this code has
# been received without warranty or guarantee of any kind; (b) the receiver
# acknowledges that the receiver shall make the determination whether this code
# is suitable for the receiver's needs; and (c) the receiver agrees that all
# responsibility for loss or damage due to the use of the code lies with the
# receiver. Professional courtesy would suggest that the receiver report any
# errors found, and that the receiver acknowledge the source of the code. See
# more information at www.cynosurecomputer.ca.
################################################################################

# QECE ELEC274
# Author:
#	David Athersych

# Prevent multiple inclusions of this file
.ifndef	_macros_s
.equ	_macros_s,1

# Simple push and pop macros used to save/restore single register value using
# existing stack. 

	.macro	PUSH	reg
	subi	sp, sp, 4	# reserve space for register
	stw		\reg, 0(sp)	# store register
	.endm

	.macro	POP	reg
	ldw		\reg, 0(sp)	# top item copied to register
	addi	sp, sp, 4	# discard space
	.endm

############# .altmacro needed before next macro definitions ###############
# Note the use of macro definitions within macro definitions, and techniques
# to count arguments.
.altmacro

# Enhanced function call - pushes arguments on stack in reverse order, as
# appropriate for C-like function calls

# Macro ccall
# func - required argument - label of function to call
# arg1 - first argument (may be blank)
# args - second and subsequent arguments - can only be present if arg1 is.

.macro ccall func:req, arg1, args:vararg
	local argc
	argc = 0

	# Recursive reverse pusher. Think of arguments as parg1 mentioned
	# explicitly, and pargs really being parg2, parg3, ... .  Keep invoking
	# pusher on pargs (meaning parg2 becomes the new parg1, etc.)  Pusher
	# stops recursing when it is given an empty list.  Note this means the
	# last argument is the first pushed.  Also note that argc is used to
	# accumulate number of arguments pushed
	.macro pusher parg1, pargs:vararg
	# If parg1 blank, nothing to do
		.ifnb \parg1
		pusher  \pargs
		PUSH    \parg1
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

# Function prolog - initialization code for every function.  Adheres to C-like
# standard. Note that a return value is accommodated via r1 - used for single
# 32-bit return value.  Use pointer parameters for anything else.

.macro	prolog	stkspc
	subi	sp, sp, 0x24		# room for all saved registers
	stw		fp, 0x00(sp)		# store caller frame pointer at top of our saves
	stw		r2, 0x04(sp)		# arbitrary set - should be enough
	stw		r3, 0x08(sp)
	stw		r4, 0x0C(sp)
	stw		r5, 0x10(sp)
	stw		r6, 0x14(sp)
	stw		r7, 0x18(sp)
	stw		r8, 0x1C(sp)
	stw		ra, 0x20(sp)		# return address at bottom - just above parameters
	mov		fp, sp				# now our frame pointer starts where old one is
	.if	\stkspc
	subi	sp, sp, stkspc		# additional space for locals (uninitialized!!)
	.endif
.endm

.macro	epilog
	mov		sp, fp				# chop all locals and temporaries from stack
	ldw		fp, 0x00(sp)		# restore caller's frame pointer
	ldw		r2, 0x04(sp)		# arbitrary set - should be enough
	ldw		r3, 0x08(sp)
	ldw		r4, 0x0C(sp)
	ldw		r5, 0x10(sp)
	ldw		r6, 0x14(sp)
	ldw		r7, 0x18(sp)
	ldw		r8, 0x1C(sp)
	ldw		ra, 0x20(sp)		# return address at bottom - just above parameters
	addi	sp, sp, 0x24		# discard saved space on stack - function returns
								# immediately after this
.endm



# Macros to push and pop several registers.  Pushed and popped in order written
# so a pshrgs r1 r2 r3   has to be followed by poprgs r3 r2 r1.

.macro pshrgs reg1, regs:vararg
	local	n
	local	off
	n = 0
	# Local macro to count arguments. Basically expands to a set of n = n + 1
	# lines, giving a total number of arguments
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

	countargs reg1, regs	# count number of arguments
	off = (n-1) * 4			# starting value for offset calculation 
	subi	sp, sp, n*4		# allocate space for all registers
	pshrg	reg1, regs
.endm


.macro poprgs reg1, regs:vararg
	local	n
	local	off
	n = 0
	.macro countargs r1, rn:varargs		# count all arguments
		.ifnb	\r1
		n = n + 1
		countargs \rn
		.endif
	.endm
	.macro poprg rr1, rn:varargs		# restore registers by position
		.ifnb	\rr1
		ldw		\rr1, off(sp)			# must initialize 'off' before using
		off = off + 4
		poprg	\rn
	.endm

	countargs reg1, regs
	off = 0
	poprg	reg1, regs
	addi	sp, sp, n*4		# free space used
.endm

.endif
