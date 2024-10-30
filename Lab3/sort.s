##############################################################################
# File: sort.s
# Skeleton for ECE 154A
##############################################################################

	.data
student:
	.asciz "Student:\n" 	# Place your name in the quotations in place of Student
	.globl	student
nl:	.asciz "\n"
	.globl nl
sort_print:
	.asciz "[Info] Sorted values\n"
	.globl sort_print
initial_print:
	.asciz "[Info] Initial values\n"
	.globl initial_print
read_msg: 
	.asciz "[Info] Reading input data\n"
	.globl read_msg
code_start_msg:
	.asciz "[Info] Entering your section of code\n"
	.globl code_start_msg

key:	.word 268632064			# Provide the base address of array where input key is stored(Assuming 0x10030000 as base address)
output:	.word 268632144			# Provide the base address of array where sorted output will be stored (Assuming 0x10030050 as base address)
numkeys:	.word 6				# Provide the number of inputs
maxnumber:	.word 10			# Provide the maximum key value


## Specify your input data-set in any order you like. I'll change the data set to verify
data1:	.word 1
data2:	.word 2
data3:	.word 3
data4:	.word 5
data5:	.word 6
data6:	.word 8

	.text

	.globl main
main:					# main has to be a global label
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address
			
	li	a7, 4			# print_str (system call 4)
	la	a0, student		# takes the address of string as an argument 
	ecall	

	jal process_arguments
	jal read_data			# Read the input data

	j	ready

process_arguments:
	
	la	t0, key
	lw	a0, 0(t0)
	la	t0, output
	lw	a1, 0(t0)
	la	t0, numkeys
	lw	a2, 0(t0)
	la	t0, maxnumber
	lw	a3, 0(t0)
	jr	ra	

### This instructions will make sure you read the data correctly
read_data:
	mv t1, a0
	li a7, 4
	la a0, read_msg
	ecall
	mv a0, t1

	la t0, data1
	lw t4, 0(t0)
	sw t4, 0(a0)
	la t0, data2
	lw t4, 0(t0)
	sw t4, 4(a0)
	la t0, data3
	lw t4, 0(t0)
	sw t4, 8(a0)
	la t0, data4
	lw t4, 0(t0)
	sw t4, 12(a0)
	la t0, data5
	lw t4, 0(t0)
	sw t4, 16(a0)
	la t0, data6
	lw t4, 0(t0)
	sw t4, 20(a0)

	jr	ra


counting_sort:
######################### 
## your code goes here ##
#########################

# 	int keys[numkeys]; 
#	int output[numkeys]; 
#	countingsort(int *keys, int *output, numkeys, maxnumber) { 
#		int count[maxnumber+1], n; 
#		for (n = 0; n++; n ≤ maxnumber) 
#			count[n] = 0; 
#		for (n = 0; n++; n < numkeys) 
#			count[keys[n]]++; 
#		for (n = 0; n++; n < maxnumber) 
#			count[n+1] = count[n] + count[n+1]; 
#		for (n = 0; n++; n < numkeys) { 
#			output[count[keys[n]]-1] = keys[n]; 
#			count[keys[n]]--; 
#		} 
#	}

#	key: a0
#	output: a1
#	numkeys: a2
#	maxnumber: a3

	# int count[maxnumber + 1];
	li t0, 4
	addi t1, a3, 1
	mul t1, t1, t0
	sub a4, sp, t1
	
	# for (n = 0; n++; n ≤ maxnumber) 
	#	 count[n] = 0;

	# int n = 0;
	li t0, 0
	mv t3, a4
	li t4, 0
	# do {
	initialize:
		# count[n] = 0;
		sw t4, 0(t3)
		addi t3, t3, 4
		# n++;
		addi t0, t0, 1
	# } while(n <= maxnumber)
		bge a3, t0, initialize
	

	# for (n = 0; n++; n < numkeys) 
	#	 count[keys[n]]++; 

	# n = 0;
	li t0, 0
	mv t3, a0
	# do {
	count_number:
		# count[keys[n]]++;
		lw t4, 0(t3)
		li t5, 4
		mul t4, t4, t5
		add t5, t4, a4
		lw t4, 0(t5)
		addi t4, t4, 1
		sw t4, 0(t5)

		addi t3, t3, 4
		# n++;
		addi t0, t0, 1
	# } while (n < numkeys)
		blt t0, a2, count_number


	# for (n = 0; n++; n < maxnumber) 
	#	 count[n+1] = count[n] + count[n+1]; 

	# n = 0;
	li t0, 0
	mv t3, a4
	# do {
	add_number:
		# countp[n + 1] = count[n] + count[n + 1];
		lw t1, 0(t3)
		lw t2, 4(t3)
		add t4, t1, t2
		sw t4, 4(t3)

		addi t3, t3, 4
		# n++;
		addi t0, t0, 1
	# } while (n < maxnumber)
		blt t0, a3, add_number
	
	
	# for (n = 0; n++; n < numkeys) { 
	#	 output[count[keys[n]]-1] = keys[n]; 
	#	 count[keys[n]]--; 
	# } 

	# n = 0;
	li t0, 0
	mv t3, a0
	# do {
	place_output:
		# output[count[keys[n]] - 1] = keys[n];
		lw t1, 0(t3)  	# keys[n]
		li t2, 4
		mul t2, t1, t2
		add t2, a4, t2 	# t2: The addresses of keys[n] elements in the count
		lw t4, 0(t2) 	# t4 = count[keys[n]]
		addi t4, t4, -1
		li t5, 4
		mul t5, t4, t5
		add t5, a1, t5
		# count[keys[n]]--;
		sw t1, 0(t5)
		sw t4, 0(t2)

		addi t3, t3, 4
		# n++;
		addi t0, t0, 1
	# } while (n < numkeys)
		blt t0, a2, place_output

#########################
 	jr ra
#########################


##################################
#Dont modify code below this line
##################################
ready:
	jal	initial_values		# print operands to the console
	
	mv 	t2, a0
	li 	a7, 4
	la 	a0, code_start_msg
	ecall
	mv 	a0, t2

	jal	counting_sort		# call counting sort algorithm

	jal	sorted_list_print


				# Usual stuff at the end of the main
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4
	jr	ra			# return to the main program

print_results:
	add t0, zero, a2 # No of elements in the list
	add t1, zero, a0 # Base address of the array
	mv t2, a0    # Save a0, which contains base address of the array

loop:	
	beq t0, zero, end_print
	addi, t0, t0, -1
	lw t3, 0(t1)
	
	li a7, 1
	mv a0, t3
	ecall

	li a7, 4
	la a0, nl
	ecall

	addi t1, t1, 4
	j loop
end_print:
	mv a0, t2 
	jr ra	

initial_values: 
	mv 	t2, a0
        addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	li a7, 4
	la a0, initial_print
	ecall
	
	mv 	a0, t2
	jal print_results
 	
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4

	jr ra

sorted_list_print:
	mv 	t2, a0
	addi	sp, sp, -4		# Move the stack pointer
	sw 	ra, 0(sp)		# save the return address

	li a7,4
	la a0,sort_print
	ecall
	
	mv a0, t2
	
	#swap a0,a1
	mv t2, a0
	mv a0, a1
	mv a1, t2
	
	jal print_results
	
    #swap back a1,a0
	mv t2, a0
	mv a0, a1
	mv a1, t2
	
	lw	ra, 0(sp)		# restore the return address
	addi	sp, sp, 4	
	jr ra
