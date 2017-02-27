# Lab3Prt2.S [170201]
# 
###############################################################################
# Lab3Prt2 - code for part 2 of lab 3 - print hex digits
#
# Author:
# David Athersych, P.Eng. Cynosure Computer Technologies Inc.
#
# HISTORY:
# 170201 DFA	First release
###############################################################################

# Actual assembly code starts here:
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

	movia	r4, MSG
	call	PrintString
	movi	r2, 0xDE
	call	PrintHex8
	movi	r2, 0xAD
	call	PrintHex8
	movi	r2, 0xBE
	call	PrintHex8
	movi	r2, 0xEF
	call	PrintHex8
_end:
	br		_end		# nothing else to do and nowhere else to go.

#==============================================================================
# Subroutine PrintChar
# Print 1 character to output device.  Taken from Lab1part2 - unchanged.
# Note that this code does not call any other functions, so it does not save
# ra.
#
# Parameters:
#	R2	- contains character to be displayed
# Return value:
#	nothing

PrintChar:
	subi	sp, sp, 8	# subtract 4 from sp, making room for a word.
	stw		r3, 4(sp)	# save contents of r3
	stw		r4, 0(sp)	# and r4.
	movia	r3, JTAG_UART_BASE	# r3 points to base of UART device registers
loop2:
	ldwio	r4, OFFSET_STATUS(r3)	# fetch contents of status register
	andhi	r4, r4, WSPACE_MASK		# keep only high-order 16 bits
	beq		r4, r0, loop2			# all 0? Try again
	# Get here when READY bit turns on
	stwio	r2, OFFSET_DATA(r3)		# Write character to data register
	# our work accomplished; restore register values
	ldw		r3, 4(sp)
	ldw		r4, 0(sp)
	addi	sp, sp, 8	# add 8 to sp, effectively discarding space on stack
	ret					# go back to calling site, all registers preserved

#==============================================================================
# Subroutine ToHexChar
# Convert 4 bit quantity at bottom of r2 to an approriate hex character
# Return the character in the low byte of r3.
hextable:	.ascii	"0123456789ABCDEF"

ToHexChar:
	andi	r2, r2, 0x0F		# isolate bottom 4 bits of r2
	ldb		r3, hextable(r2)	# use as index into hextable
	ret

#==============================================================================
# Subroutine PrintHex8
# Convert 8-bit quantity in bottom byte of r2 and prints out 2 characters

PrintHex8:
	subi	sp, sp, 8			# space on stack
	stw		ra, 4(sp)			# save return address
	stw		r2, 0(sp)			# save r2
	srli	r2, r2, 4			# get high 4 bits, because that prints first
	call	ToHexChar			# get character
	mov		r2, r3				# copy into r2
	call	PrintChar			# and print it
	ldw		r2, 0(sp)			# get original data back
	call	ToHexChar			# character for lower 4 bits
	mov		r2, r3				# copy into r2
	call	PrintChar			# and print it
	ldw		r2, 0(sp)			# restore r2
	ldw		ra, 4(sp)			# restore ra
	addi	sp, sp, 8			# discard words on stack
	ret

#==============================================================================
# Subroutine PrintString
# Print ASCIZ string to output device.  This code uses the PrintChar function
# so it needs to save ra.

# Parameters:
#	R4	- contains address of string to be displayed
# Return value:
#	nothing, but r4 will point to end of string

PrintString:
	# We will call another function, so we need to save contents of ra
	subi	sp, sp, 4			# decrement stack pointer by 1 word
	stw		ra, 0(sp)			# store ra on stack
	# We need r2 to pass one character to PrintChar
	subi	sp, sp, 4			# decrement stack pointer by 1 word
	stw		r2, 0(sp)			# store r2 on stack
	# r4 points to ASCIZ string, but we won't preserve it
loop:
	ldb		r2, 0(r4)			# fetch the byte pointed to by r4
	beq		r2, r0, done		# if byte value is 0, branch to done.
	call	PrintChar			# print character in r2
	addi	r4, r4, 1			# increment r4 pointer
	br		loop				# do next character
done:
	# add a newline character to the end
	movi	r2, '\n'			# just like C
	call	PrintChar
	# restore saved r2 contents
	ldw		r2, 0(sp)			# value at top of stack is saved r2
	ldw		ra, 4(sp)			# value below that is saved ra
	addi	sp, sp, 8			# two words off stack pointer
	ret							# return to address in ra

#==============================================================================

	.org	0x00001000	# where this code is to go in memory
MSG:.asciz	"ELEC274 Lab 3"		# 

	.end				# tells assembler this is the end

