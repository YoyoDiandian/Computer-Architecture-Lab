##############################################################################
# File: div.s
# Skeleton for ECE 154a project
##############################################################################

	.data
student:
	.asciz "Yaojia Wang" 	# Place your name in the quotations in place of Student
	.globl	student
nl:	.asciz "\n"
	.globl nl


op1:	.word 4 			# divisor for testing
op2:	.word 0xFFFFFFFF		  		# dividend for testing

	.text

	.globl main
main:					# main has to be a global label
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	mv	t0, a0			# Store argc
	mv	t1, a1			# Store argv
				
	li	a7, 4			# print_str (system call 4)
	la	a0, student		# takes the address of string as an argument 
	ecall	

	slti	t2, t0, 2		# check number of arguments
	bne     t2, zero, operands
	j	ready

operands:
	la	t0, op1
	lw	a0, 0(t0)
	la	t0, op2
	lw	a1, 0(t0)
		

ready:
	jal	divide			# go to divide code

	jal	print_result		# print operands to the console

					# Usual stuff at the end of the main
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4

	li      a7, 10
	ecall


divide:
##############################################################################
# Your code goes here.
# Should have the same functionality as running
#	divu	a2, a1, a0
# 	remu    a3, a1, a0 
# assuming a1 is unsigned divident, and a0 is unsigned divisor
##############################################################################

	# int a2 = 0;
	addi a2, x0, 0
	# int a3 = a1;
	addi a3, a1, 0
	# int a4 = a0;
	addi a4, a0, 0

	# while(a1 > a4) {
	#	 if (a4 >= 0x80000000) goto STEP1;
	# }
	shift_left:
	    bltu a1, a4, unshift
	    slli a4, a4, 1
	    lui t0, 0x80000
	    bgeu a4, t0, step1
	    j shift_left
	
	unshift:
	# a4 /= 2;
		srli a4, a4, 1
	
	# STEP1: 
	# do {
	# 	 a2 *= 2;
	# 	 if (a3 >= a4) {
	#	 	 a3 -= a4;
	# 	 	 a2 += 1;
	# 	 }
	step1:
		slli a2, a2, 1
		bltu a3, a4, step3
		sub a3, a3, a4
		addi a2, a2, 1
		j step3
	step3:
		# a4 /= 2
		srli a4, a4, 1

	# } while(a4 >= a0)
	bgeu a4, a0, step1




##############################################################################
# Do not edit below this line
##############################################################################
	jr	ra


# Prints a0, a1, a2, a3
print_result:
	mv	t0, a0
	li	a7, 4
	la	a0, nl
	ecall

	mv	a0, t0
	li	a7, 1
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a1
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a2
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	li	a7, 1
	mv	a0, a3
	ecall
	li	a7, 4
	la	a0, nl
	ecall

	jr ra
