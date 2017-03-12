# LAB4PRT1.S [170225]
# QECE ELEC274 Lab exercise 4, part 1
###############################################################################
# Code to demonstrate arithmetic, memory access and subroutines.
# Author:
#    David Athersych, P.Eng.
# History:
#	1.0	DA	Original release
#
#==============================================================================
#
# Directives - configuration information to the assembler.

# Symbol definitions
	.equ	LAST_RAM_WORD,	0x007FFFFC

# Object module configuration.
	.text				# tell assembler that this is code segment
	.global	_start		# tell assembler that _start is visible to linker

	.org	0x00000400	# starting address for the following code

_start:
	movia	sp, LAST_RAM_WORD	# set up pointer to last word in RAM
	# Prompt user to enter a word
	movia	r4, Prompt
	call	PrintStr
	# Get word user types in
	movia	r4, InBuff
	movi	r3, 64
	call	GetString
	# Print label, and word user typed
	movia	r4, Label
	call	PrintStr
	movia	r4, InBuff
	call	PrintStr
_end:
	br		_end		# nothing else to do and nowhere else to go.

# Code from previous work
	.include	JTAGPOLL.S
	.include	JTAGSTRS.S

# Static data.
Prompt:	.asciz	"Enter word, terminated by return key: "
Label:	.asciz	"You entered: "
CRLF:	.byte	0x0D, 0x0A, 0x00
#==============================================================================

	.org	0x00001000	# where this data is to go in memory
InBuff:	.skip	64		# 64 byte buffer should be big enough

	.end				# tells assembler this is the end

