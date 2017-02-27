# LAB1PART3.S [170105]
# QECE ELEC274 Lab exercise 1, part 3
###############################################################################
# Code to demonstrate arithmetic, memory access and subroutines.
# Author:
#    Dr. Naraig Manjikian, P.Eng.
# Modifications:
#    David Athersych, P.Eng.
# History:
#	1.0	NM	Original release
#	2.0	DA	Reformat, add comments
#	2.1 DA	Modifications for part 3 of exercise
#
#==============================================================================
# Design documentation:
#	C-like pseudo code equivalent to assembly code
#
#	#define	LAST_RAM_WORD	0x007FFFFC
#
#	int		r0, r2, r3, r16, sp;	// registers are globals
#	memoryat(0x00001000)	{		// I told you it was pseudo-code ...
#		int	A = 7;
#		int B = 6;
#		int C;
#		}
#
#	void Start (void)
#	{
#		sp = LAST_RAM_WORD;
#		r2 = A;
#		r3 = B;
#		Addvalues();
#		C = r2;
#	end:
#		goto end;
#	}
#		
#	void AddValues (void)
#	{
#		int		temp;
#		temp = r16;
#		r16 = r2 + r3;
#		r2 = r16;
#		r16 = temp;
#		return;
#	}
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

	# Copy values stored in memory locations.
	# Use R0 as base for indexing. Documentation states that R0 is always 0.
	# See the code at the end.  What's happening here isn't what you might
	# expect.  You will note that there is an ".org" directive just before
	# the code for A, B and C - this tells the assembler that the code is to
	# be located starting at address 0x00001000. That means that symbol A
	# is equivalent to memory address 0x00001000. The directive ".word" says
	# reserve a word (4 bytes), so the memory set aside is locations 0x1000
	# to 0x1003.  The next available location starts at 0x1004 - which is
	# where B is.  The memory reference in the next statement means "Use
	# contents of R0 as a starting address, and add offset A, giving actual
	# address for where to fetch the data."  Note in version 2 of this code,
	# a different way of addressing is used.
	ldw		r2, A(r0)
	ldw		r3, B(r0)
	call    AddValues	# parameters are in registers r2 and r3
	# <PART 3 MODIFICATION>
	# New code goes here.  Result of AddValues is in r2.  Just need to
	# place value in G into r3 and call AddValues again.
	ldw		r3, G(r0)
	call	AddValues	# parameters are in registers r2 and r3
	# </END MODIFICATION>
	stw		r2, C(r0)	# function returns answer in R2

_end:
	br		_end		# nothing else to do and nowhere else to go.

#==============================================================================
# Subroutine AddValues
# Parameters:
#	R2, R3	- contain two values to be added together
# Return value:
#	R2 - contains result of adding R2 and R3 contents

AddValues:
	subi	sp, sp, 4	# subtract 4 from sp, making room for a word.
	stw		r16, 0(sp)	# save contents of r16 at place sp points
	add		r16, r2, r3	# r16 = r2 + r3, basically
	mov		r2, r16		# want answer in r2, so copy value from r16
	ldw		r16, 0(sp)	# restore previous contents of r16
	addi	sp, sp, 4	# add 4 to sp, effectively discarding space on stack
	ret					# go back to calling site, result in R2

#==============================================================================

	.org	0x00001000	# where this code is to go in memory
A:	.word	7			# use word (4 bytes), initial value is 7
B:	.word	6			# use word (4 bytes), initial value is 6
C:	.skip	4			# set aside 4 bytes, but don't initialize
						# Documentation suggests that you might be safe
						# assuming initial contents are 0; safe programming
						# practice requires that you eschew assumptions.
# <PART 3 MODIFICATION>
G:	.word	20			# additional data
# </END MODIFICATION>

	.end				# tells assembler this is the end

