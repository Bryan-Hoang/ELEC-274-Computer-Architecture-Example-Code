# STRINGS.S [170224]

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
# STRINGS provides some examples of how to work with strings.  It also contains
# code to copy and compare memory regions that don't contain nul-terminated
# strings. 
#
# Author:
# David Athersych, P.Eng. Cynosure Computer Technologies Inc.
#
# HISTORY:
# 170124 DFA	First release
###############################################################################

#
#==============================================================================
# Subroutine strcpy
# Copies contents of one string to another location.  Does not check for issues
# such as copying a string to itself or to a location that won't work.
#
# Parameters:
#	R3	- address of source string
#	R4	- address of destination
# Return value:
#	Both R3 and R4 point to ends of source and destination string respectively
#
# Note that this is not particularly efficient.  If pointers were aligned to
# word boundaries, then copy could be done 4 bytes at a time.  So, thinking
# only about source, copy up to 3 bytes to get to a word boundary, then as
# long as there is at least 4 bytes left, copy a word, and then copy remaining
# (up to 3) bytes.  But, this assumes the source and destination are aligned
# the same way.  They won't necessarily be, so clever code will have to take
# into account that accumulating words and writing words may have different
# boundaries.


strcpy:
	# Save registers
	subi	sp, sp, 8	# make room for two words.
	stw		ra, 4(sp)	# save contents of ra
	stw		r2, 0(sp)	# and r2.

cpych:
	# copy character pointed to by r3 to place pointed to by r4
	ldbu	r2, 0(r3)
	stbu	r2, 0(r4)
	# Just copy NUL? If so, our work is done
	beq		r2, r0, cpydun
	# move both source and destination pointers to next location
	addi	r3, r3, 1
	addi	r4, r4, 1
	br		cpych		# and copy next character
cpydun:
	# our work accomplished; restore register values
	ldw		ra, 4(sp)
	ldw		r2, 0(sp)
	addi	sp, sp, 8	# discard space on stack
	ret

#==============================================================================
# Subroutine strcmp
# Compares contents of one string to contents of another.
#
# Parameters:
#	R3	- address of source string
#	R4	- address of destination
# Return value:
#	Both R3 and R4 modified - if strings same length, both will point to NUL
#	terminators of respective strings.
#	R5	- 0 if strings same, negative if src < dst, positive if src > dst

strcmp:
	# Save registers
	subi	sp, sp, 12	# make room for 3 words
	stw		ra, 8(sp)	# save ra
	stw		r2, 4(sp)	# save r2
	stw		r1, 0(sp)	# save r1

cmpch:
	ldbu	r1, 0(r3)	# fetch byte from source string
	ldbu	r2, 0(r4)	# fetch byte from destination string
	sub		r5, r1, r2	# subtract r2 from r1. r5 will be 0 if chars same;
						# it will be negative if r2 from dest is larger,
						# it will be positive if r2 from dest is smaller.
	bne		r5, r0, cmpdun	# unequal - compare complete, answer in r5
	# even if subtraction gave 0 result, may still be finished. Check if
	# either (meaning both) character was NUL
	beq		r1, r0, cmpch	# both strings terminated - compare complete
	# More to do - advance pointers
	addi	r3, r3, 1
	addi	r4, r4, 1
	br		cmpch

cmpdun:
	ldw		r1, 0(sp)
	ldw		r2, 4(sp)
	ldw		ra, 8(sp)
	addi	sp, sp, 12
	ret

#==============================================================================
# Subroutine memcpy
# Copies N bytes from one memory location to another location.  Does not check
# for issues such as copying memory to itself or to location that won't work.
#
# Parameters:
#	R3	- address of source string
#	R4	- address of destination
#	R5	- count of bytes to copy
# Return value:
#	Both R3 and R4 point beyond ends of source and destination memory
#	respectively; R5 will be -1.
#
# Note that this is not particularly efficient.  If pointers were aligned to
# word boundaries, then copy could be done 4 bytes at a time.  So, thinking
# only about source, copy up to 3 bytes to get to a word boundary, then as
# long as there is at least 4 bytes left, copy a word, and then copy remaining
# (up to 3) bytes.  But, this assumes the source and destination are aligned
# the same way.  They won't necessarily be, so clever code will have to take
# into account that accumulating words and writing words may have different
# boundaries.


strcpy:
	# Save registers
	subi	sp, sp, 8	# make room for two words.
	stw		ra, 4(sp)	# save contents of ra
	stw		r2, 0(sp)	# and r2.

mcpych:
	subi	r5, r5, 1	# decrement count
	blt		r5, r0, mcpydun		# less than 0; done
	# copy character pointed to by r3 to place pointed to by r4
	ldbu	r2, 0(r3)	
	stbu	r2, 0(r4)
	# move both source and destination pointers to next location
	addi	r3, r3, 1
	addi	r4, r4, 1
	br		mcpych		# and copy next character
mcpydun:
	# our work accomplished; restore register values
	ldw		ra, 4(sp)
	ldw		r2, 0(sp)
	addi	sp, sp, 8	# discard space on stack
	ret

