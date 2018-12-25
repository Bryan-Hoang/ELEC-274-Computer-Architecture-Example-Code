	.org	0x20
	# Exception handler - MUST BE AT ADDRESS 0x20
	# Code uses general purpose registers r18,r19 - must be saved and restored
	subi	sp, sp, 8		# room on stack
	stw		r19, 0(sp)		# save r19
	stw		r18, 4(sp)		# save r18
	# fetch contents of ctl4 to see if it is hardware interrupt. (Note et - r24
	# is designated as exception temporary, so it doesn't need to be saved. Also
	# note that the rdctl instruction - to read a control register - can only be
	# executed in supervisor, not user mode.)
	rdctl	et, ipending
	# if at least one bit is on, it means a hardware device is requesting attention
	beq et, r0, OTHER_EXCEPTIONS	# no bits - not hardware
	# Hardware interrupt code. At this point, know there is at least one device
	# requesting attention.  A little housekeeping first - a hardware interrupt
	# is recognized AFTER pc updated, but BEFORE the instruction is executed. Have
	# to set address back, so that when interrupt handler done, the instruction
	# gets executed.
	subi	ea, ea, 4
	# Now go through all possible interrupt sources. (Only need to check lines
	# that have devices attached.)
	andi	r19, et, 1		# Check bit 0
	beq		r19, r0, NOTIRQ0
	call	EXT_IRQ0
NOTIRQ0:
	andi	r19, et, 2		# Check bit 1
	beq		r19, r0, NOTIRQ1
	call	EXT_IRQ1
	# Note that after checking line 0, check next one.  This means that ordering
	# of checks creates a handler priority.
NOTIRQ1:
	# etc.
	# Code to check for other hardware interrupts go here

	# Finally, done with all possible hardware interrupts 
	br END_HANDLER

	## Other exceptions dealt with here - instruction exception and TRAP
	## instruction
TRAP_PATTERN:	trap			# put pattern for trap instruction here
OTHER_EXCEPTIONS:
	# Check to see if instruction was a TRAP - if so, call trap handler.
	# Only quick way to confirm trap is to look at instruction that got us here
	ldw		r19, -4(ea)			# if it was TRAP, ea points to next instruction
	ldw		r18, TRAP_PATTERN(r0)	# I don't want to look up what value is ...
	bne		r19, r18, INSTFAIL	# not TRAP, handle instruction failure
	# TRAP is used as entry for system services.  Service requested is given
	# by service index in r1. Individual services may use other registers;
	# that will be specified in their description.
	# First step - confirm valid range.  If r1 is invalid, we change it to 0.
	# That means there is no system service with index 0.

	# < Code goes here >

	# After checking valid index, r1 now holds 0 or a valid index
	shli	r18, r1, 2			# shift over by 2 bits - now a word offset
	ldw		r18, handler(r18)	# get address from handler table
	jmp		r18					# could have used callr if we wanted to
								# come back here
handler:	# table of addresses
	.word	invalid_service_request
	.word	service_request_01
	.word	service_request_02
	.word	service_request_03
	<etc>	
	
	
INSTFAIL:
	# Check if reason is failed instruction - take whatever action required for
	# failed instruction
	#
	# decode instruction at $ea-4
	# if (instruction is trap)
	#	handle trap exception
	# else if (instruction is load or store)
	#	handle misaligned data address exception
	# else if (instruction is branch, bret, callr, eret, jmp, or ret)
	#	handle misaligned destination address exception
	# else if (instruction is unimplemented)
	#	handle unimplemented instruction exception
	# else if (instruction is illegal)
	#	handle illegal instruction exception
	# else if (instruction is divide) {
	#	if (denominator == 0)
	#		handle division error exception
	#	else if (instruction is signed divide and numerator == 0x80000000
	#		and denominator == 0xffffffff)
	#		handle division error exception
	#	}


	# Exit point for the exception handler
END_HANDLER:
	# restore saved register(s) - counting on stack being back to where it was
	# just after register(s) were saved
	ldw		r19, 0(sp)		# restore saved register
	addi	sp, sp, 4		# adjust stack pointer
	eret					# and done


	.org	0x100
	# Device-specific code for each hardware interrupt source
EXT_IRQ0:
	/* Instructions that handle the irq0 interrupt request should be placed here */
	ret /* Return from the interrupt-service routine */
EXT_IRQ1:
	/* Instructions that handle the irq1 interrupt request should be placed here */
	ret /* Return from the interrupt-service routine */
	
	# etc
