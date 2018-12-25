# UARTPOLL.S [170114]

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
# JTAGPOLL - Code to handle reading and writing JTAG UART in polled mode.
#
# Author:
# David Athersych, P.Eng. Cynosure Computer Technologies Inc.
#
# HISTORY:
# 170114 DFA	First release, based on code found in Altera documentation
#				and on several websites.  Intended for QECE ELEC274.
# 170222 DFA	Added echo to read character routine.
###############################################################################


# Define base address for device, offsets and register masks.
	.equ	JTAG_UART_BASE,	0x10001000	# base address of JTAG UART
	.equ	UART2_BASE, 0x10001010		# base address of second serial port
	.equ	OFFSET_DATA,	0			# offset from base for data register
	.equ	OFFSET_STATUS,	4			# offset from base for status register
	.equ	WSPACE_MASK,	0xFFFF		# 16 bit mask used to get status bits
	.equ	RVALID,			0x8000		# Read data available bit in data reg.


#==============================================================================
# Subroutine PutJTAG
# Write character to UART output port - either JTAG or second UART.  Characters
# written to JTAG port will be displayed on monitor screen.  Characters written
# to second UART will go to whatever device is attached to that serial port.
# Note: The two UARTS are essentially the same (programmatically) so they are
# handled similarly.
# Parameters:
#	R2	- contains character to be displayed
# Return value:
#	nothing

	.global	PutJTAG
	.global	PutUART2

PutJTAG:
	subi	sp, sp, 8	# subtract 8 from sp, making room for two words
	stw		r3, 4(sp)	# save contents of r3
	stw		r4, 0(sp)	# and r4.
	movia	r3, JTAG_UART_BASE	# r3 points to base of UART device registers
	br		loop2		# go to common UART code
PutUART2:
	subi	sp, sp, 8	# subtract 8 from sp, making room for two words
	stw		r3, 4(sp)	# save contents of r3
	stw		r4, 0(sp)	# and r4.
	movia	r3, UART2_BASE	# r3 points to base of UART device registers
loop2:
	ldwio	r4, OFFSET_STATUS(r3)	# fetch contents of status register
	andhi	r4, r4, WSPACE_MASK		# keep only low-order 16 bits
	beq		r4, r0, loop2			# all 0? Try again
	# Get here when READY bit turns on
	stwio	r2, OFFSET_DATA(r3)		# Write character to data register
eggsit:
	# our work accomplished; restore register values
	ldw		r3, 4(sp)
	ldw		r4, 0(sp)
	addi	sp, sp, 8	# add 8 to sp, effectively discarding space on stack
	ret					# go back to calling site, all registers preserved

#==============================================================================
# Subroutine GetJTAG
# Read character from JTAG input port.  Characters read from this port will
# also be echoed back, that is, displayed on monitor screen.
# Parameters:
#	none
# Return value:
#	R2	- contains character read

	.global	GetJTAG

GetJTAG:
	subi	sp, sp, 8	# two words on stack
	stw		r3, 4(sp)
	stw		r4, 0(sp)
	movia	r3, JTAG_UART_BASE	# point to JTAG base register
loop3:
	ldwio	r2, 0(r3)			# read JTAG register
	andi	r4, r2, RVALID		# check if data available
	beq		r4, r0, loop3		# if no data, check again
	# character returned in r2
	andi	r2, r4, 0x00ff		# data in least significant byte
	# handle echo, so human can see what was typed.  Assume output is ready,
	# (fairly safe assumption if JTAG being used for human input) so just
	# write character to output port
	stwio	r2, OFFSET_DATA(r3)	# write character to data register
	# restore saved registers
	br	eggsit					# use existing exit code in PutJTAG
	
#==============================================================================
