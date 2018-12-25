# CHARS.S [170307]

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
# CHARS - Simple routines to convert characters to byte values and vice versa
#
# Author:
# David Athersych, P.Eng. Cynosure Computer Technologies Inc.
#
# HISTORY:
# 170307 DFA	First release. Intended for QECE ELEC274.
###############################################################################


	.TEXT


#==============================================================================
# Subroutine CHR2BIN
# Take character between '0' and 'F' and return numeric value 0x00 to 0x0F
#
# Parameters:
#	R2	-	Contains character in range '0'..'9' 'A'..'F'
# Return value:
#	R2	-	numeric value between 0x00 and 0x0F; 0xFFFFFFFF (-1) if char
#			invalid

CHR2BIN:
	subi	sp, sp, 8
	stw		ra, 0(sp)
	stw		r3, 4(sp)
	movui	r3, '0'			# check low range
	bltu	r2, r3, c2berr	# invalid character
	movui	r3, '9'			# numbers
	bleu	r2, r3, sub0	# 0-9 range
	# Not between '0' and '9'; check for characters 'A' to 'F'
	movui	r3, 'A'			# only handle upper case - EFTS fix this!
	bltu	r2, r3, c2berr	# invalid
	movui	r3, 'F'			# upper character
	bleu	r2, r3, subA	# A-F range
	# get here because character not in range
c2berr:
	movi	r2, -1			# becomes 32-bit (-1) value
	br		done
subA:
	subi	r2, r2, 'A'		# 'A' to 'F' becomes 0 to 5
	addi	r2, r2, 10		# and now becomes 10 to 15
	br		done			# label says it all
sub0:
	subi	r2, r2, '0'		# '0' to '9' becomes 0 to 9
done:
	ldw		ra, 0(sp)
	ldw		r3, 4(sp)
	addi	sp, sp, 8
	ret


#==============================================================================
# Subroutine BIN2CHR
# Take binary value between 0 and 15 and convert to character '0'..'F'
#
# Parameters:
#	r2	-	value between 0 and 15
# Return value:
#	r2	-	character value between '0' and 'F'

BIN2CHR:
	subi	sp, sp, 8
	stw		ra, 0(sp)
	stw		r3, 4(sp)
	blt		r2, r0, b2cerr	# too small
	movi	r3, 9
	ble		r2, r3, add0	# between 0 and 9
	movi	r3, 15
	ble		r2, r3, addA	# between 10 and 15 (0x0A and 0x0F)
b2cerr:
	movi	r2, -1			# invalid value to convert
	br		done
addA:
	subi	r2, r2, 10		# values 10 to 15 becomes 0 to 5
	addi	r2, r2, 'A'		# and now becomes 'A' to 'F'
	br		done
add0:
	addi	r2, r2, '0'		# 0 to 9 becomes '0' to '9'
	br		done
