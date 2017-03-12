# MATH.S [170205]
# 
###############################################################################
# MATH - some useful math routines - multiply and divide by 10
#
# Author:
# David Athersych, P.Eng. Cynosure Computer Technologies Inc.
#
# HISTORY:
# 170205 DFA	First release
###############################################################################

	.include	MACROS.S


## START MAIN ##
# Symbol definitions
	.equ	LAST_RAM_WORD,	0x007FFFFC
	.equ	JTAG_UART_BASE,	0x10001000	# base address of JTAG UART
	.equ	OFFSET_DATA,	0			# offset from base for data register
	.equ	OFFSET_STATUS,	4			# offset from base for status register
	.equ	WSPACE_MASK,	0xFFFF		# 16 bit mask used to get status bits

# Object module configuration.
	.text				# tell assembler that this is code segment
	.global	_start		# tell assembler that _start is visible to linker

	.org	0x00000000	# starting address for the following code

_start:
	# Initialize stack pointer to point to last word in memory. Stack is
	# used by hardware to store return address during function call. Stack
	# may also be used for temporary variables.
	movia	sp, LAST_RAM_WORD
	
	# Test multiply
	movi r2, 25
	call mul10
	# CONFIRMED THAT R1 contained 0XFA which is 250 in decimal
	
	# Test Divide
	movi r2, 10
	call div10
	# DIV HAS AN INFINITE LOOP. SEE DIV10 SUBROUTINE FOR DETAILS
	
	
_end:
	br		_end		# nothing else to do and nowhere else to go.





#==============================================================================
# MUL10 - multiplies number by 10
# Input - R2 - contains number to multiply by 10
# Returns - R1 - result of multiplication

mul10:
	slli	r1, r2, 3			# shift left by 3 bits same as multiplying by 8
	add		r1, r1, r2			# add another r2 multiplies by 9
	add		r1, r1, r2			# and another r2 gives us the 10th one
	ret

C_mul10:
	# C calling convention - sort of.  We take some short cuts, because we
	# don't have to save any registers - assuming r1 is the return register!
	# We also assume that sp has been set up
	subi	sp, sp, 4			# room for ra
	stw		ra, 0(sp)			# store ra on stack
	ldw		r2, 4(sp)			# you expect me to use fp, but I am sure where
								# sp points
	call	mul10				# use code above - answer in r1
	ldw		ra, 0(sp)			# retrieve return address
	addi	sp, sp, 4			# discard the space
	ret

#==============================================================================
# DIV10 - gets quotient and remainder of dividing by 10.
# This will be useful when we want
# to convert integers in order to display them in decimal.
# This code will only handle numbers between 0 and 9999.
# How it works.  Remember how you learned "long division"?  If you had to 
# divide 6254 by 10, you started by figuring out how many times you could
# subtract 10 from 62 (6 leaving remainder 2), then kept the 2 and created 25,
# which you could subtract 10 from 2 times leaving 5, which you used to create
# 54, which you could subtract 10 from 5 times leaving 4.  There were no more
# digits, so you stopped, giving 625 with remainder 4.  We use the same idea.

# This code is only necessary when processor does not implement divide.
# Input -   R2 - contains number we want to divide
# output -  R1 - address of the digits, starting with remainder
# output -	R7 - quotient

# Table of powers of 10.  Another version of this code creates the table
# on the fly, using the mul10 routine above
PlusOne:	.word	1
Tens:		.word	10, 100, 1000
# These tables seem to be in backwards order - but it makes coding easier
digits:		.byte	0, 0, 0, 0
quotient:	.word	0

div10:
	# save registers that we use for our work (r2, r5, r6, r8, r9)
	PUSH	r2					# need MACROs
	PUSH	r5
	PUSH	r6
	PUSH	r8
	PUSH	r9

	mov		r7, r0				# initial value of quotient
	# r5 will be used to work through all 4 digits
	movi	r5, 2				# magnitude minus 1
nextdigit:						# loop through all digits
	mov		r8, r0				# initial value of digit
	# figure out how many times we can subtract 10^r5 from
	# r2. We get 10^r5 from the Tens table
	slli	r6, r5, 2			# multiply r5 by 4
	
	############ PROBLEM HERE ##########
	
	# THIS IS THE LINE THAT CAUSES THE ISSUE
	# AFTER LDW R6 IS 0 SO WHEN IT GOES THROUGH THE SUBAGAIN LOOP 
	# THE BRANCH BLT R2, R6, DUNGT CONDITION NEVER HAPPENS
	# THIS CAUSES AN INFINITE LOOP
	ldw		r6, Tens(r6)		# get the divisor

	
	
	ldw		r9, PlusOne(r6)		# and the lower order number
	
	# GETTING STUCK HERE 
subagain:
	blt		r2, r6, dundgt		# is divisor bigger than number?
	# r2 still bigger or equal to divisor, so subtract once more
	addi	r8, r8, 1			# add 1 to digit
	add		r7, r7, r9			# add lower magnitude to quotient
	sub		r2, r2, r6			# subtract this magnitude
	br		subagain			# and see if we can do it again
	
	
dundgt:
	# got here because we couldn't subtract another r6
	# running accumulation of quotient in r7
	# digit just determined in r8
	# place to store digit - r5 location in digits
	stb		r8, digits(r5)		# no shift because it is byte
	# ready for next digit
	subi	r5, r5, 1			# decrement counter
	bge		r0, r5, nextdigit	# count down to 0
	# OK - done all digits and stored them - set up address to
	# return
	movia	r1, digits
	# accumulated a quotient in r7
	# restore other registers
	POP		r9
	POP		r8
	POP		r6
	POP		r5
	POP		r2
	ret


	
	 




	
