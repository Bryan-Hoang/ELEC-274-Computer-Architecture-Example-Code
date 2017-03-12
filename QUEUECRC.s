# QUEUECRC.S [170305]

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
# QUEUECRC - Fixed length (circular) queue implementation. Queue holds up to
#	64 bytes.  This implementation uses start index and count - both of which
#	can be kept in a byte.
#
# Author:
# David Athersych, P.Eng. Cynosure Computer Technologies Inc.
#
# HISTORY:
# 170305 DFA	First release. Intended for QECE ELEC274.
###############################################################################


# Define offsets for head and count within queue data structure
	.equ	Qhead, 0	# index of head in first byte
	.equ	QCount, 1	# queue population count in second byte
	.equ	QData, 2	# queue data starts in 3rd byte


#==============================================================================
# Subroutine QInit
# Initialize Queue structure. Parameter is address of 66 byte buffer.  Calling
# code uses structure address as parameter to enqueue and dequeue routines.
# Parameters:
#	R1	- address of data location - at least 66 bytes. No validity check done
# Return value:
#	R1	- unchanged

	.global	QInit

QInit:
	stb	r0, Qhead(r1)	# initialize index to 0
	stb	r0, QCount(r1)	# initialize count to 0
	ret					# that was easy ...

#==============================================================================
# Subroutine Qenqueue
# Add byte to end of queue, if there is room
# Parameters:
#	R1	- address of queue.
#	R2	- holds byte value to store in queue.
# Return value:
#	R1	- unchanged
#	R2	- success, unchanged. Upper bytes 0xFF if queue was full

	.global	Qenqueue

Qenqueue:
	# first, save registers that are needed for our work
	subi	sp, sp, 8	# two words on stack
	stw		r3, 4(sp)
	stw		r4, 0(sp)

	# First step - see if there is room
	movi	r3, 64		# queue holds at most 64 bytes
	ldb		r4, 1(r1)	# get queue current count
	beq		r4, r3, Qfull	# count indicates full
	# Current count less than full
	ldb		r3, 0(r1)	# get start index
	add		r3, r3, r4	# compute index where byte to go (count+head)
	andi	r3, r3, 63	# handle wrap-around (recall 63 = 0x3F)
	addi	r3, r3, 2	# buffer offset 2 from start of queue
	add		r3, r3, r1	# add queue base address
	stb		r2, 0(r3)	# store byte in queue
	addi	r4, r4, 1	# update count
	stb		r4, 1(r1)	# and store in count field

eggsit:
	# our work accomplished; restore register values
	ldw		r3, 4(sp)
	ldw		r4, 0(sp)
	addi	sp, sp, 8	# add 8 to sp, effectively discarding space on stack
	ret					# go back to calling site, all registers preserved

Qerr:
	# error return - byte cannot be fetched/stored - caller needs to check if
	# r2 negative upon return
	movi	r3, 0xff00	# will be sign-extended to 0xFFFFFF00
	or		r2, r2, r3	# character preserved, upper bytes 0xFF
	br		eggsit		# done

#==============================================================================
# Subroutine Qdequeue
# Add byte to end of queue, if there is room
# Parameters:
#	R1	- address of queue.
# Return value:
#	R1	- unchanged
#	R2	- retrieved byte if available; negative number if no byte available

	.global	Qdequeue

Qdequeue:
	# first, save registers that are needed for our work
	subi	sp, sp, 8	# two words on stack
	stw		r3, 4(sp)
	stw		r4, 0(sp)

	# First step - see if there is data to fetch
	ldb		r4, 1(r1)	# get queue current count
	beq		r4, r0, Qerr# count indicates empty - nothing to fetch
	# Fetch byte at head of queue and then adjust count and head
	ldb		r3, 0(r1)	# get start index
	addi	r3, r3, 2	# buffer offset 2 from start of queue
	add		r3, r3, r1	# add queue base address
	ldb		r2, 0(r3)	# fetch byte at head of queue
	subi	r4, r4, 1	# update count
	stb		r4, 1(r1)	# and store in count field
	ldb		r4, 0(r1)	# get head index (again)
	addi	r4, r4, 1	# move by 1 byte
	andi	r4, r4, 63	# handle wrap-around
	stb		r4, 0(r1)	# store head index
	br		eggsit		# done

#==============================================================================
