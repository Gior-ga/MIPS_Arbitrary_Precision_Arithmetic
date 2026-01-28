.data  
string_buffer: .space 124
buffer_max_len: .word 123
buffer_string_len: .word 0
x: .word 0x0000000b #2^32 - 1 same as max int32_t
y: .word 0x00000001 #same as 4294967292
#need a data type thats essentially a static array and a size variable
arr1: .space 12 #12 byte array essentially 3 WORDs/96 bits needs to be a mulitiple of 4 so the cpu can do arithmetic on WORDs
arr2: .space 12 #12 byte array essentially 3 WORDs/96 bits needs to be a mulitiple of 4 so the cpu can do arithmetic on WORDs
size: .word 3 #size of the array in WORDs

.text  
.globl main  

main:
	la $t0, arr1
	la $t1, arr2
	lw $t2, size
	
	subu $sp, $sp, 12
	sw $t0, 8($sp)
	sw $t1, 4($sp)
	sw $t2, 0($sp)
	
	
	li $t2, 0
	sw $t2, 4($t0)
	li $t2, 0
	sw $t2, 4($t1)
	li $t2, 0
	sw $t2, 8($t0)
	li $t2, 0
	sw $t2, 8($t1)

	li $t2, 0
	lw $t3, y
	
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)

	lw $t2, x
	sw $t2, 0($t1)
	li $t2, 0

	sw $t3, 4($t0)
	sw $t2, 0($t0)
	sw $t2, 8($t0)

	#lw $t3, y1
	#sw $t3, 0($t0)
	#lw $t3, y2
	#sw $t3, 4($t0)
	#li $t3, 0xffffffff
	#sw $t3, 0($t0)
	#sw $t3, 4($t0)
	#sw $t3, 8($t0)
	#sw $t3, 12($t0)
	#sw $t3, 16($t0)
	#sw $t3, 20($t0)
	#sw $t3, 24($t0)
	#sw $t3, 28($t0)
	#sw $t3, 32($t0)
	#sw $t3, 36($t0)
	#sw $t3, 40($t0)
	#sw $t3, 44($t0)
	#sw $t3, 48($t0)
	#sw $t3, 52($t0)
	#sw $t3, 56($t0)

	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	
	addi $sp, $sp, 12

	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	
	jal arbitrary_precision_add
	
	move $a1, $s0
	move $a0, $sp
	move $a2, $s2

	#jal copy_space
	#addi $sp, $sp, 12
	
	la $s1, arr1
	la $a1, arr1
	la $s0, arr2
	la $a0, arr2
	

	jal arbitrary_precision_to_string
	
	jal arbitrary_precision_multiply
	
	li $v0 11
	li $a0 10
	syscall
	
	move $a0, $sp
	move $s0, $sp
	jal arbitrary_precision_to_string
	#jal arbitrary_precision_divide_16bit
	
	#li $v0, 1
	#move $a0, $v1
	#syscall
	
	li $v0, 10
	syscall


arbitrary_precision_add:
	#using $t3 as the iterator index
	li $t3, 0

	#make space on the stack for sum result
	li $t1, 4
	mul $t0, $a2, $t1
	sub $sp, $sp, $t0

	move $t5, $zero
arbitrary_precision_add_loop:
	li $t0, 4
	mul $t2, $t0, $t3
	#$t0 is the address of indexed arrays
	#$t1 and $t2 are indexed arrays
	add $t0, $a0, $t2
	lw $t1, 0($t0)
	add $t0, $a1, $t2
	lw $t2, 0($t0)
	
	#$t4 is the sum without carry
	addu $t4, $t1, $t2 
	#li $v0, 1
	#move $a0, $t4
	#syscall
	
	#li $v0, 11
	#li $a0, 10
	#syscall
	
	addu $t4, $t4, $t5
	sltu $t5, $t4, $t1

	li $t0, 4
	mul $t0, $t3, $t0
	add $t0, $sp, $t0
	sw $t4, 0($t0)

	addi $t3, 1

	bne $t3, $a2, arbitrary_precision_add_loop
	jr $ra


arbitrary_precision_subtract:
	#using $t3 as the iterator index
	li $t3, 0

	#make space on the stack for sum result
	li $t1, 4
	mul $t0, $a2, $t1
	sub $sp, $sp, $t0

	move $t5, $zero
arbitrary_precision_subtract_loop:
	li $t0, 4
	mul $t2, $t0, $t3
	#$t0 is the address of indexed arrays
	#$t1 and $t2 are indexed arrays
	add $t0, $a0, $t2
	lw $t1, 0($t0)
	add $t0, $a1, $t2
	lw $t2, 0($t0)
	
	#$t4 is the sub without borrow
	subu $t4, $t1, $t2
	subu $t4, $t4, $t5
	sltu $t5, $t1, $t4

	li $t0, 4
	mul $t0, $t3, $t0
	add $t0, $sp, $t0
	sw $t4, 0($t0)

	addi $t3, 1
	bne $t3, $a2, arbitrary_precision_subtract_loop
	jr $ra

arbitrary_precision_multiply:

	move $s4, $ra
	
	li $t0, 4
	mul $t0, $t0, $a2
	sub $sp, $sp, $t0
	move $a0, $sp
	jal nullify_space
	li $t0, 1
	sw $t0, 0($sp)

	li $t0, 4
	mul $t0, $t0, $a2
	sub $sp, $sp, $t0
	move $a0, $sp
	jal nullify_space
	
	li $t0, 4
	mul $t0, $t0, $a2
	sub $sp, $sp, $t0
	move $a0, $sp
	
	
	jal nullify_space
	
	move $a0, $s0
	
	addi $sp, $sp, -4
	sw $s4, 0($sp)

arbitrary_precision_multiply_loop:
	
	li $t0, 4
	mul $t0, $t0, $a2
	add $t1, $sp, $t0
	addi $t1, $t1, 4

	move $a0, $t1
	move $a1, $s0
	jal arbitrary_less_than
	beq $v1, $zero, arbitrary_precision_multiply_end
	
	addi $t1, $sp, 4
	move $a0, $t1
	move $a1, $s1
	
	jal arbitrary_precision_add
	
	li $t0, 4
	mul $t0, $t0, $a2
	add $t1, $sp, $t0
	
	addi $t1, $t1, 4
	move $a0, $sp
	move $a1, $t1
	
	jal copy_space

	li $t0, 4
	mul $t0, $t0, $a2
	add $sp, $sp, $t0
	
	li $t0, 4
	mul $t0, $t0, $a2
	add $t1, $sp, $t0
	addi $t1, $t1, 4
	
	move $a0, $t1
	add $t1, $t1, $t0
	move $a1, $t1

	jal arbitrary_precision_add

	move $a0, $sp

	li $t0, 4
	mul $t0, $t0, $a2
	add $t1, $sp, $t0
	add $t1, $t1, $t0
	addi $t1, $t1, 4
	move $a1, $t1
	move $a0, $sp
	
	jal copy_space


	li $t0, 4
	mul $t0, $t0, $a2
	add $sp, $sp, $t0

	j arbitrary_precision_multiply_loop

arbitrary_precision_multiply_end:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

arbitrary_precision_divide:
	li $t6, 4
	mul $t6, $t6, $s2
	
	subu $sp, $sp, $t6
	subu $sp, $sp, $t6
	subu $sp, $sp, $t6
	subu $sp, $sp, $t6
	
	subu $sp, $sp, 4
	sw $s0, 0($sp)
	
	subu $sp, $sp, 4
	sw $s1, 0($sp)
	
	subu $sp, $sp, 4
	sw $ra, 0($sp)
	
	addi $a1, $sp, 12
	add $a1, $a1, $t6
	move $a0, $s0
	move $a2, $s2
	
	jal copy_space
	
	addi $a0, $sp, 12
	
	jal nullify_space
	li $t0, 1
	sw $t0, 0($a0)
	
	add $a0, $a0, $t6
	add $a0, $a0, $t6
	jal nullify_space
	
	add $a0, $a0, $t6
	jal nullify_space
	

	lw $s5, 0($sp)
	lw $s4, 4($sp)
	lw $s3, 8($sp)
	
	addi $sp, $sp, 12

	add $a0, $sp, $t6
	move $a1, $s4
	
	jal arbitrary_less_than
	bne $v1, $zero, arbitrary_precision_divide_get_remainder
	

arbitrary_precision_divide_loop:
	add $a0, $sp, $t6
	move $a1, $s4
	
	jal arbitrary_precision_subtract
	
	move $a1, $a0
	move $a0, $sp
	
	jal copy_space
	add $sp, $sp, $t6

	add $a0, $sp, $t6
	move $a1, $s4
	
	jal arbitrary_less_than
	bne $v1, $zero, arbitrary_precision_divide_get_remainder
	
	add $t3, $sp, $t6
	add $t3, $t3, $t6
	
	move $a0, $sp
	move $a1, $t3

	jal arbitrary_precision_add
	
	move $a0, $sp
	
	jal copy_space
	add $sp, $sp, $t6

	j arbitrary_precision_divide_loop
	
arbitrary_precision_divide_get_remainder:
	
arbitrary_precision_divide_end:
	li $t0, 4
	mul $t0, $t0, $s2
	move $s0, $s3
	move $s1, $s4
	move $ra, $s5
	add $sp, $sp, $t0
	add $sp, $sp, $t0
	jr $ra

arbitrary_precision_divide_16bit:
	move $t5, $a2
	
	li $t0, 4

	mul $t0, $t5, $t0
	subu $sp, $sp, $t0
	
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a0, $sp, 8
	
	jal nullify_space
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	move $t2, $a2
	subu $t2, $t2, 1

	addi $sp, $sp, -4
	li $t0, 0
	sw $t0, 0($sp)
arbitrary_precision_divide_16bit_loop:
	li $t0, 4
	mul $t0, $t2, $t0
	add $t0, $t0, $a0
	lw $t1, 0($t0)
	lw $t0, 0($sp)
	
	# split 32 bit limb
	srl     $t3, $t1, 16
	andi    $t4, $t1, 0xFFFF

	sll     $t5, $t0, 16
	or      $t5, $t5, $t3
	divu    $t5, $a3
	mflo    $t6
	mfhi    $t0

	# x = (remainder << 16) | lo16
	sll     $t5, $t0, 16
	or      $t5, $t5, $t4
	divu    $t5, $a3
	mflo    $t7
	mfhi    $t0

	# recombine limb
	sll     $t6, $t6, 16
	or      $t1, $t6, $t7
	
	sw $t0, 0($sp)

	li $t0, 4
	mul $t0, $t2, $t0
	add $t0, $t0, $sp
	addi $t0, $t0, 4
	sw $t1, 0($t0)
	
	beq $t2, $zero, arbitrary_precision_divide_16bit_end
	addi $t2, $t2, -1
	
	j arbitrary_precision_divide_16bit_loop

arbitrary_precision_divide_16bit_end:
	lw $v1, 0($sp)
	addi $sp, $sp, 4
	move $v0, $sp
	jr $ra
	
	



arbitrary_true:
	li $t3, 0
	li $t2, 0
	li $v1, 0
arbitrary_true_loop:
	li $t0, 4
	mul $t0, $t0, $t3

	add $t4, $t0, $a0
	lw $t1, 0($t4)
	
	
	sltu $t5, $t2, $t1

	addi $t3, 1
	bne $t5, $zero, arbitrary_true_true
	bne $t3, $a2, arbitrary_true_loop
	jr $ra
arbitrary_true_true:
	li $v1, 1
	jr $ra

arbitrary_less_than:
	move $t3, $a2
	li $t0, 1
	sub $t3, $t3, $t0
	li $t5, 0
arbitrary_less_than_loop:
	li $t0, 4
	mul $t0, $t0, $t3

	add $t4, $t0, $a0
	lw $t1, 0($t4)
	add $t4, $t0, $a1
	lw $t2, 0($t4)
	
	beq $t1, $t2, skip_less_check

	sltu $t5, $t1, $t2
	beq $t5, $zero, arbitrary_less_than_false
	
	sltu $t5, $t2, $t1
	beq $t5, $zero, arbitrary_less_than_true
	
skip_less_check:
	subu $t3, $t3, 1
	addi $t0, $t3, 1
	bne $t0, $zero, arbitrary_less_than_loop
	
arbitrary_less_than_false:
	li $v1, 0
	jr $ra
arbitrary_less_than_true:
	li $v1, 1
	jr $ra
nullify_space:
	li $t3, 0
	move $t2, $a2
nullify_space_loop:
	li $t4, 4
	mul $t1, $t4, $t3
	
	add $t1, $a0, $t1
	sw $zero, 0($t1)
	
	addi $t3, $t3, 1
	bne $t3, $t2, nullify_space_loop
	jr $ra


copy_space:
	li $t3, 0
	move $t2, $a2
copy_space_loop:
	li $t4, 4
	mul $t1, $t4, $t3
	
	add $t1, $a0, $t1
	lw $t0, 0($t1)

	mul $t1, $t4, $t3
	
	add $t1, $a1, $t1
	sw $t0, 0($t1)
	
	addi $t3, $t3, 1
	bne $t3, $t2, copy_space_loop
	jr $ra


arbitrary_precision_to_string:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $t0, 4
	mul $t0, $t0, $a2
	sub $sp, $sp, $t0
	
	move $a1, $sp
	jal copy_space
	
	li $t0, 0
	sw $t0, buffer_string_len
	li $v0, 0
	li $v1, 0
arbitrary_precision_to_string_loop:
	li $a3, 10
	move $a0, $sp
	jal arbitrary_precision_divide_16bit
	
	sub $sp, $sp, 4
	sw $v0, 0($sp)

	
	lw $t0, buffer_string_len
	la $t1, string_buffer
	add $t1, $t0, $t1
	sb $v1, 0($t1)
	
	addi $t0, $t0, 1
	sw $t0, buffer_string_len
	
	lw $v0, 0($sp)
	addi $sp, $sp, 4

	move $a0, $v0
	move $a1, $sp
	li $t0, 4
	mul $t0, $t0, $a2
	add $a1, $a1, $t0

	jal copy_space
	
	move $a0, $sp
	move $a1, $s1

	li $t0, 4
	mul $t0, $t0, $a2
	add $sp, $sp, $t0

	jal arbitrary_true

	bne $v1, $zero, arbitrary_precision_to_string_loop

arbitrary_precision_to_string_print:
	lw $t5, buffer_string_len
	addi $t5, $t5, -1
	
	li $v0, 1
	la $t0, string_buffer
arbitrary_precision_to_string_print_loop:
	
	add $t1, $t0, $t5
	li $t2, 0
	lb $t2, 0($t1)
	move $a0, $t2
	syscall

	beq $t5, $zero, arbitrary_precision_to_string_end
	addi $t5, $t5, -1
	j arbitrary_precision_to_string_print_loop

arbitrary_precision_to_string_end:
	li $t0, 4
	mul $t0, $t0, $a2
	add $sp, $sp, $t0
	
	lw $ra, 0($sp)
	jr $ra

