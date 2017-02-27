# xxxxxx.S [170114]
# 
###############################################################################
# xxxxxx illustrates how to 
#
#
# Author:
# David Athersych, P.Eng. Cynosure Computer Technologies Inc.
#
# HISTORY:
# 170114 DFA	First release
###############################################################################

#
# Directives - configuration information to the assembler.

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

	... YOUR CODE GOES HERE ...

	movia	r4, MSG
	call	PrintString
_end:
	br		_end		# nothing else to do and nowhere else to go.

#==============================================================================
# Subroutine xxxxxxx
#
# Parameters:
#	R2	- contains character to be displayed
# Return value:
#	nothing

xxxxxx:
	# Save registers
	subi	sp, sp, 8	# subtract 4 from sp, making room for a word.
	stw		r3, 4(sp)	# save contents of r3
	stw		r4, 0(sp)	# and r4.

	... YOUR CODE GOES HERE ...

	# our work accomplished; restore register values
	ldw		r3, 4(sp)
	ldw		r4, 0(sp)
	addi	sp, sp, 8	# add 8 to sp, effectively discarding space on stack
	ret					# go back to calling site, all registers preserved




#==DATA SECTION================================================================

	.org	0x00001000	# where this code (data) is to go in memory
MSG:.asciz	"bonjour, monde / hello, world"		# Canadian version

	.end				# tells assembler this is the end

