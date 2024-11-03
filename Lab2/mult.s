##############################################################################
# File: mult.s
# Skeleton for ECE 154a project
##############################################################################

	.data
student:
	.asciz "Yaojia Wang" 	# Place your name in the quotations in place of Student
	.globl	student
nl:	.asciz "\n"
	.globl nl


op1:	.word 12413				# change the multiplication operands
op2:	.word 4321			# for testing.


	.text

	.globl main
main:					# main has to be a global label
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	mv	t0, a0			# Store argc
	mv	t1, a1			# Store argv

# a7 = 8 read character
#  ecall
				
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
	jal	multiply		# go to multiply code

	jal	print_result		# print operands to the console




					# Usual stuff at the end of the main
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4
	
	li      a7, 10
	ecall


multiply:
##############################################################################
# Your code goes here.
# Should have the same functionality as running 
#	mul	a2, a1, a0
# assuming a1 and a0 stores 8 bit unsigned numbers
##############################################################################

	# int a3 = a0;
	# int a4 = a1;
	addi a3, a0, 0
	addi a4, a1, 0

	# int a2 = 0;
	addi a2, x0, 0
	# int t2 = 0;
	addi t2, x0, 0

	# do {
	step1: 
	# int t0 = a4;
	addi t0, a4, 0
	# t0 /= 2;
	srli t0, t0, 1
	# t0 *= 2;
	slli t0, t0, 1
	# int t1 = a4 - t0;
	sub t1, a4, t0

	# if (t1 != 0) {
	# 	a2 += a3;
	# }
	addi t3, x0, 0
	beq t1, t3, step2
		add a2, a2, a3

	step2:
	# a3 *= 2;
	slli a3, a3, 1
	# a4 /= 2;
	srli a4, a4, 1
	# t2++;
	addi t2, t2, 1
	# } while(t2 != 32)
	addi t3, x0, 32
	bne t2, t3, step1

##############################################################################
# Do not edit below this line
##############################################################################
	jr	ra


print_result:

# print string or integer located in a0 (code a7 = 4 for string, code a7 = 1 for integer) 
	mv	t0, a0
	li	a7, 4
	la	a0, nl
	ecall
	
# print integer
	mv	a0, t0
	li	a7, 1
	ecall
# print string
	li	a7, 4
	la	a0, nl
	ecall
	
# print integer
	li	a7, 1
	mv	a0, a1
	ecall
# print string	
	li	a7, 4
	la	a0, nl
	ecall
	
# print integer
	li	a7, 1
	mv	a0, a2
	ecall
# print string	
	li	a7, 4
	la	a0, nl
	ecall

	jr      ra