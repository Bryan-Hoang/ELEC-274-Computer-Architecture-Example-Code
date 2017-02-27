# LB2PRT1.S [170121]
# QECE ELEC274 Lab exercise 2, part 1
###############################################################################
# Code to show some computation and a simple loop
# Author:
#    David Athersych, P.Eng.
# History:
#	170121	1.0	DA	Original release
#
#==============================================================================
# Actual assembly code starts here:
#
# Directives - configuration information to the assembler.

# Symbol definitions - equivalent to #define LAST_RAM_WORD  0x007FFFFC
	.equ	LAST_RAM_WORD	0x007FFFFC

# Object module configuration.
	.text				# tell assembler that this is code segment
	.global	_start		# tell assembler that _start is visible to linker

	.org	0x00000000	# starting address for the following code

_start:
	# Initialize stack pointer to point to last word in memory. Stack is
	# used by hardware to store return address during function call. Stack
	# may also be used for temporary variables.
	movia	sp, LAST_RAM_WORD

	# Step 1. Add 10 integer values found starting at label A
	movia	r2, A		# Address of A in r2
	movi	r3, #10		# Store count in r3 (we'll count down)
	mov		r4, r0		# Use r4 for the total - initialize to 0
	br		body		# go do first one
loop:
	ldw		r5, 0(r2)	# get value R2 points to
	add		r4, r4, r5	# add value to total
	addi	r2, r2, 4	# move pointer to next number
	# done one number, figure out if more to do
	subi	r3, r3, #1	# subtract 1 from count
	brne	r3, r0, loop	# if not zero, more to do
	# get here, we're done adding numbers.  Total is in r4.
	# Step 2. Divide total by count to get average.
	movi	r3, #10		# get a 10 to divide by
	div		r5, r4, r3	# divide total by 10
    stw     r5, TOTAL(r0)	# store answer in memory	

_end:
	br		_end		# nothing else to do and nowhere else to go.

#==============================================================================

	.org	0x00000800	# where this code is to go in memory
A:		.word	4,6,8,3,16,22,0,7,11,24
TOTAL:	.skip	4		# set aside 4 bytes, but don't initialize

	.end				# tells assembler this is the end

