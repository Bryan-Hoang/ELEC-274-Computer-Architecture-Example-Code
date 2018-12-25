# 8SEG.S [170307]

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
# more information at www.cynosurecomputer.ca or
#     https://gitlab.com/david.athersych/ELEC274Code.git
################################################################################

###############################################################################
# 8SEG - Display value on 8 segment display.  Uses bottom 16 bits of r2 for
# value to display.
#
# Author:
# David Athersych, P.Eng. Cynosure Computer Technologies Inc.
#
# NOTE:
#	This version uses macros.
#
# HISTORY:
# 170307 DFA	First release. Intended for QECE ELEC274.
# 180225 DFA	Minor update to comments.
###############################################################################

	.equ	LED_ADDR	0x10000010	# address of 10 bit LED port

	.equ	EIGHTSEG,	0x10000020	# address of 8-segment display register
	.equ	ATESEG,		0x10000020	# compatible with code from lecture
	.equ	ByteMask,	0xFFFFFF00	# mask used to isolate 8-segs

	.DATA
Ondisp:		.word	0		# save value currently on display in 8 segment
LEDs:		.word	0		# save value currently on display in LEDs


	.TEXT

#==============================================================================
# Subroutine UpdLEDs
# Update all 10 LEDs
#
# Parameters:
#	R2	- contains 10 bit value to be displayed on LEDs
# Return value:
#	R2	- unchanged

UpdLEDs:
	subi	sp, sp, 4		# space for saved register value
	stw		r3, 0(sp)		# save R3
	movia	r3, LED_ADDR	# Address of LED output port
	stwio	r2, 0(r3)		# write parameter value to LED port
	movia	r3, LEDS		# get address of saved copy
	stw		r2, 0(r3)		# keep it - used by LEDbits (future code addition)
	ldw		r3, 0(sp)		# restore register
	addi	sp, sp, 4		# discard stack space
	ret



#==============================================================================
# Table of 8-segment patterns used to display 4-bit values 0x0 to 0xF. Note
# that each pattern takes 8 bits, so 4-segment display needs 32 bit value to
# display a 16-bit numeric value.
# (Note also that Table is kept in nonvolatile .TEXT section, not .DATA
 
Table:
	.byte	0x3F, 0x06, 0x5B, 0x4F
	.byte	0x66, 0x6D, 0x7D, 0x07
	.byte	0x7F, 0x67, 0x77, 0x7C
	.byte	0x39, 0x5E, 0x79, 0x71

Error:	.byte	0xC0				# error pattern
		.skip	3					# manual alignment to 4 byte boundary

#==============================================================================
# Subroutine Show8Seg
# Update all 4 8-segment displays on the DE0 board
#
# Parameters:
#	R2	- contains 16 bit value to be displayed in 4 4-bit groups
# Return value:
#	R2	- unchanged

Show8Seg:
	pshregs	ra, r2, r3, r4, r5, r6
	sub		r3, r3, r3		# zero r3
	movi	r5, 0x0F		# 4 bits in bottom of r5 (why?)
L1:
	andi	r4, r2, 0x0F	# bottom 4 bits of r2 in r4
	ldbu	r6, Table(r4)	# load pattern into r6 (gets 0 extended)
	or		r3, r3, r6		# OR pattern into bottom byte of r3
	srli	r2, r2, 4		# shift bottom 4 bits into bit bucket
	rori	r3, r3, 8		# rotate r3 register to right 8 bits
	srli	r5, r5, 1		# shift r5 right by 1 bit
	bne		r5, r0, L1		# aha! We were using r5 to count the loop!
	# At this point, r3 has 4 patterns - for each of the 4 displays
	movia	r5, EIGHTSEG	# address of 8-segment display
	stwio	r3, 0(r5)		# write pattern to display
	movia	r5, Ondisp		# address of local where we store a copy
	stw		r3, 0(r5)
	# done
Restore:
	popregs	r6, r5, r4, r3, r2, ra
	ret

#==============================================================================
# Subroutine One8Seg
# Update just one 8-segment display
#
# Parameters:
#	R2 -	Bottom 4 bits [3:0] contain value to display
#			Bits 4 & 5 contain position to display in 00, 01, 10 11
# Return value:
#	R2	-	Unchanged

One8Seg:
	pshregs	ra, r2, r3, r4, r5, r6
	mov		r6, r2			# save copy
	andi	r2, r2, 0x0F	# keep only bottom 4 bits
	ldbu	r2, Table(r2)	# get display pattern for this value
	# now need to figure out where to store it
	srl		r6, r6, 4		# get bits [5:4] into positions [1:0]
	sll		r6, r6, 3		# get number of bits to shift over (mul 8)
	sll		r2, r2, r6		# put pattern into correct byte position
	movia	r4, ByteMask	# Mask to clean out existing data
	rol		r4, r4, r6		# get 0 byte into correct position also
	movia	r5, Ondisp		# address of what is currently on display
	ldwu	r6, 0(r5)		# fetch display value
	and		r6, r6, r4		# zero byte we're changing
	or		r6, r6, r2		# and store new value for that byte
	movia	r3, EIGHTSEG	# address of 8-segment display
	stwio	r6, 0(r3)		# light up the leds
	stw		r6, 0(r5)		# store updated copy of led value
	br		Restore			# same epilogue
