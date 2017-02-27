# LB2PRT3.S [170121]
# QECE ELEC274 Lab exercise 2, part 3
###############################################################################
# Code to show some computation and a simple loop, working through a structure
# Author:
#    David Athersych, P.Eng.
# History:
#	170121	1.0	DA	Original release, based on LB2PRT1.S
#	170121	1.1	DA	Alternate method, maybe clearer
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

	# Step 1. Add 10 integer values found in structures starting at label M
	movia	r2, M		# Address of M in r2
	movi	r3, 10		# Store count in r3 (we'll count down)
	mov		r4, r0		# Use r4 for the total - initialize to 0
	## Now here's the design decision.  You could walk through memory one
	## 8 byte structure at a time, always fetching data offset 4 from the
	## address.  That's the way the high level language programmer will think
	## about it. Or you could recognize that if you offset by 4 right away,
	## then the next value is 8 from there.  The author is an old assembly
	## language programmer, so the second way is the way this code works.
	##############
	## Version 1.1 - a method that may be clearer.  Suggestion - do a side by
	## side comparison of the two pieces of code and decide for yourself which
	## version you like.
	##addi	r2, r2, 4	# point to the mark field  ####REMOVED
loop:
	ldw		r5, 4(r2)	# get mark value R2 points to - at offset 4 (bytes) in
						# the record.
	add		r4, r4, r5	# add value to total
	addi	r2, r2, 8	### DIFFERENT FROM PART 1.  SIZE OF STRUCTURE IS 8
	# done one number, figure out if more to do
	subi	r3, r3, 1	# subtract 1 from count
	brne	r3, r0, loop	# if not zero, more to do
	# get here, we're done adding numbers.  Total is in r4.
	# Step 2. Divide total by count to get average.
	movi	r3, 10		# get a 10 to divide by
	div		r5, r4, r3	# divide total by 10
    stw     r5, TOTAL(r0)	# store answer in memory	

_end:
	br		_end		# nothing else to do and nowhere else to go.

#==============================================================================

	.org	0x00001000	# where this code is to go in memory
M:		.word	12345, 56
		.word	13733, 87
		.word	10563, 64
		.word	19222, 12
		.word	8766,  92
		.word	13366, 67
		.word	14562, 71
		.word	10030, 80
		.word	11034, 78
		.word	15003, 62
TOTAL:	.skip	4		# set aside 4 bytes, but don't initialize

	.end				# tells assembler this is the end

