# LAB4PRT2.S [170225]
# QECE ELEC274 Lab exercise 4, part 2
###############################################################################
# Code to demonstrate I/O and character manipulation.
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
	# Prompt user to enter first word
	movia	r4, Prompt
	call	PrintStr
	# Get word user types in
	movia	r4, InBuff
	movi	r3, 64
	call	GetString
	# We could have done this better, but instructions said to copy word
	# to new location.
	movia	r3, InBuff
	movia	r4, OtherBf
	call	strcpy
	# Now get second word
	movia	r4, InBuff
	movi	r3, 64
	call GetString
	# Compare two strings. R5 will hold return value
	movia	r3, OtherBf		# r3 is source - first word typed in
	movia	r4, Inbuff		# r4 is destination, second word typed in
	call	strcmp			# compare two words
	beq		r5, r0, same	# r5 == 0 means words were same
	# Not same - determine order
	blt		r5, r0, firstless	# first word lower alphabetically
	# getting here means second word less than first alphabetically
	movia	r4, Dstlsee
	br		show
firstless:
	movia	r4, Srcless
	br		show
same:
	# same word
	movia	r4, Same
show:
	call	PrintStr
_end:
	br		_end		# nothing else to do and nowhere else to go.

# Code from previous work
	.include	JTAGPOLL.S
	.include	JTAGSTRS.S
	.include	STRINGS.S

# Static data.
Prompt1:	.asciz	"Enter first word, terminated by return key:"
Prompt2:	.asciz	"Enter second word:"
Same:		.asciz	"Words same."
Srcless:	.asciz	"First one less than second"
Dstless:	.asciz	"Second one less than first"

CRLF:	.byte	0x0D, 0x0A, 0x00
#==============================================================================

	.org	0x00001000	# where this data is to go in memory
InBuff:		.skip	64	# 64 byte buffer should be big enough
OtherBf:	.skip	64	# another 64 byte buffer

	.end				# tells assembler this is the end

