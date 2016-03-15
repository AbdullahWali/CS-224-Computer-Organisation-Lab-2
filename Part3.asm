#	Author: Abdullah Wali
#	Part 3 of Lab 2	
#	Using MIPS for matrix operations on floating point values

	#####################################################
	#     						#####
	#		Text Segment			#####
	#						#####
	#####################################################
	
		
	
#Perform first half of operations	#User Choice will be stored in s0 #array address in s6, array size in s7
######################################################################
 UserPromptLoop:
	
 	la $a0, UserPrompt
 	li $v0, 4
 	syscall #Print User Prompt
 	li $v0, 5
 	syscall #Take user Input
 	move $s0, $v0
 	
 	beq $s0, $0, UserPromptLoopDone #exit loop if input is 0
 	
 	
 	case1: #Do Case1
 	addi $t0 , $0, 1 
 	bne $s0, $t0, case2

 	jal CreateMatrix
 	move $s6, $v0
 	move $s7, $v1
 	j UserPromptLoop
 	
 	case2: #Do Case2
 	addi $t0 , $0, 2 
 	bne $s0, $t0, case3
 	
 	move  $a0, $s6
 	move $a1, $s7
 	jal CreateValue
 	j UserPromptLoop 	
 	
 	case3: #Do Case3
 	addi $t0 , $0, 3 
 	bne $s0, $t0, case4
 	
 	move  $a0, $s6
 	move $a1, $s7
 	jal DisplayMatrix 	
 	j UserPromptLoop
 		
 	case4: #Do Case4
 	addi $t0 , $0, 4 
 	bne $s0, $t0, UserPromptLoop

 	move  $a0, $s6
 	move $a1, $s7
 	jal DisplayValue
 	j UserPromptLoop
 	
UserPromptLoopDone:
################################################################


#ask for 2nd array and do operations		#s4 holds address of 2nd matrix,	$s5 holds size
####################################
	jal CreateMatrix 
	move  $s4, $v0
	move $s5, $v1

#Ask for operations
UserPromptLoop2:
	
 	la $a0, UserPrompt2
 	li $v0, 4
 	syscall #Print User Prompt
 	li $v0, 5
 	syscall #Take user Input
 	move $s0, $v0
 	
 	beq $s0, $0, UserPromptLoop2Done #exit loop if input is 0
 	
 	secondcase1: #Do Case1
 	addi $t0 , $0, 1 
 	bne $s0, $t0, secondcase2
 	
 	la $a0, SubResult
 	li $v0,4
 	syscall #print result message
 	
 	move $a0, $s4
 	move $a1, $s5
 	move $a2, $s6
 	move $a3, $s7
 	jal Substract #substract the arrays
 	
 	move $a0, $v0
 	move $a1, $v1
 	jal DisplayMatrix
 	
 	j UserPromptLoop2
 	
 	secondcase2: #Do Case2
 	addi $t0 , $0, 2 
 	bne $s0, $t0, UserPromptLoop2
 	
 	 la $a0, SubResult
 	li $v0,4
 	syscall #print result message
 	
 	move $a0, $s4
 	move $a1, $s5
 	move $a2, $s6
 	move $a3, $s7
 	jal Multiply #substract the arrays
 	
 	move $a0, $v0
 	move $a1, $v1
 	jal DisplayMatrix
 	
 	
 	j UserPromptLoop2
 	
UserPromptLoop2Done:	
	li $v0, 10
	syscall #byeee
	
	#######################################################
       ####    		     Functions			####
	###						###
	 #################################################

#Create Matrix 	#no arguments		# return:	v0, address of matrix	v1: N ( size of matrix is NxN)
###################################################
CreateMatrix:	
	la $a0, SizePrompt
	li $v0, 4
	syscall #prompt for size
	li $v0, 5
	syscall #read size
	move $v1, $v0 #put size in v1
	
	#request heap space and store in t8
	mul $t1, $v1, $v1 #t1 = NxN
	sll $a0, $t1, 2	# a0 = 4 * N*N ( number of bytes needed)
	li $v0 , 9
	syscall #request heap space
	move $t8, $v0 #store address in t8
	
	#get entries from user
	move $t3, $t8 #Copy address
	li $t0, 0 # i = 0 ( loop)
	mul $t1, $v1, $v1 #t1 = NxN
CreateMatrixLoop:
	slt $t2, $t0, $t1
	beq $t2, $0, CreateMatrixLoopDone
	
	la $a0, FloatPrompt
	li $v0, 4
	syscall #prompt for float
	li $v0, 6
	syscall #Get the float from User
	s.s $f0, ($t3) #store float
	
	addi $t0, $t0, 1 #increment i
	addi $t3, $t3, 4 #increment address
	j CreateMatrixLoop
CreateMatrixLoopDone:
	move $v0, $t8
	jr $ra
########################################################


#Create Value	#a0: address of the matrix	#a1: N of the matrix
#########################################################################
CreateValue:
	move $t8, $a0 #put a0 in t8
	
	la $a0 , rowPrompt
	li $v0, 4
	syscall #ask for row
	li $v0 , 5
	syscall #get row
	move $t0, $v0 #row is in t0
	
	la $a0 , columnPrompt
	li $v0, 4
	syscall #ask for column
	li $v0 , 5
	syscall #get column
	move $t1, $v0 #rcolumn is in t1
	
	#calculate address: 	index = row * N + column
	mul $t0, $t0, $a1 
	add $t0, $t0, $t1	#t0 holds index
	sll $t0 ,$t0, 2 #multiply index by 4
	add $t0 , $t8, $t0 #get address
	
	la $a0, FloatPrompt
	li $v0, 4
	syscall #prompt for float
	li $v0, 6
	syscall #Get the float from User
	
	#store float in address
	s.s $f0 , ($t0)
	jr $ra
##################################################################

#Display Matrix 	#a0: matrix address	#a1: N
############################################################
DisplayMatrix:
	move $t8 , $a0
	
	#outer loop
	li $t0, 0 # i = 0 
DisplayOuterLoop:
	slt $t1, $t0 , $a1
	beq $t1, $0, DisplayOuterLoopDone
	
	#inner loop
	li $t2 , 0 # j = 0 
DisplayInnerLoop:
	slt $t1, $t2 , $a1
	beq $t1, $0, DisplayInnerLoopDone
	
	l.s $f12, ($t8)
	li $v0, 2 
	syscall #print float
	la $a0, tab
	li $v0 , 4
	syscall #print tab
		
	addi $t8, $t8, 4 #increment address
	addi $t2, $t2, 1 #increment j
	j DisplayInnerLoop
DisplayInnerLoopDone:
	
	la $a0, endl
	li $v0 , 4
	syscall #print line
	
	addi $t0, $t0, 1 #increment i
	j DisplayOuterLoop
DisplayOuterLoopDone:	
	jr $ra
#####################################################################





#Display Value	#a0: address of the matrix	#a1: N of the matrix
#########################################################################
DisplayValue:
	move $t8, $a0 #put a0 in t8
	
	la $a0 , rowPrompt
	li $v0, 4
	syscall #ask for row
	li $v0 , 5
	syscall #get row
	move $t0, $v0 #row is in t0
	
	la $a0 , columnPrompt
	li $v0, 4
	syscall #ask for column
	li $v0 , 5
	syscall #get column
	move $t1, $v0 #rcolumn is in t1
	
	#calculate address: 	index = row * N + column
	mul $t0, $t0, $a1 
	add $t0, $t0, $t1	#t0 holds index
	sll $t0 ,$t0, 2 #multiply index by 4
	add $t0 , $t8, $t0 #get address
	
	l.s $f12, ($t0)
	li $v0 , 2
	syscall #print value
	la $a0, endl
	li $v0 , 4
	syscall #print line
	
	jr $ra
##################################################################

#substract 2 matrices	#a0: address 1, a1: size 1		a2: address 2, 	a3: size 2
#######################################
Substract:
	bne $a1, $a3, cannotSubstract #give error if matrices not same size
	
	li $v0, 0x10000180 #address of substraction matrix
	move $v1, $a1 #set size of sub matrix
	move $t8, $v0 #copy address to t8 to modify during operation
	
	li $t0, 0 #i = 0 ( loop ) 
	mul $a1, $a1, $a1 #a1 = N*N
SubstractLoop:
	slt $t1, $t0, $a1
	beq $t1, $0, SubstractDone

	l.s $f4, ($a0)
	l.s $f5, ($a2)
	sub.s $f4 ,$f4, $f5 #sub values 
	s.s $f4, ($t8) #store in the new matrix

	#increment addresses
	addi $t8 , $t8, 4
	addi $a2 , $a2, 4
	addi $a0, $a0, 4 
	addi $t0, $t0, 1 #inc i
	j SubstractLoop
SubstractDone:
	jr $ra


cannotSubstract:
	la $a0, SubFailed
	li $v0, 4
	syscall #print error message
	li $v0, 0x10000180 #address of substraction matrix
	li $v1, 0 #set size of sub matrix
	jr $ra
######################################################3


#substract 2 matrices	#a0: address 1, a1: size 1		a2: address 2, 	a3: size 2
#######################################
Multiply:
	bne $a1, $a3, cannotMultiply #give error if matrices not same size
	
	li $v0, 0x10000180 #address of substraction matrix
	move $v1, $a1 #set size of sub matrix
	move $t8, $v0 #copy address to t8 to modify during operation
	
	li $t0, 0 #i = 0 ( loop ) 
MultiplyOuterLoop:
	slt $t1, $t0, $a1
	beq $t1, $0, MultiplyOuterLoopDone
	
	li $t2, 0 #j = 0 ( inner loop)
MultiplyInnerLoop:
	slt $t1, $t2, $a1
	beq $t1, $0, MultiplyInnerLoopDone
	
	mul $t3, $t0, $a1
	add $t3, $t3, $t2 #t3 = i*N + j = t0*a1 + t2
	#get address of the index t3
	sll $t3, $t3, 2
	add $t3, $t3, $v0 #t3 now holds address of i*N + j in resulting matrix
	mtc1 $0, $f4
	s.s $f4, ($t3) #reset location to zero
	
	li $t7 , 0
KLoop:	#k = t7
	slt $t1, $t7, $a1
	beq $t1, $0, KLoopDone
	
	#get index of k + i*N
	mul $t4, $t0, $a1
	add $t4, $t4, $t7
	#get address of that index
	sll $t4, $t4, 2
	add $t4, $t4, $a2
	
	#get index of j + k*N
	mul $t5, $t7, $a3
	add $t5, $t5, $t2
	#get address
	sll $t5, $t5, 2
	add $t5, $t5, $a0
	
	l.s $f4 ($t4)
	l.s $f5 ($t5)
	mul.s $f6 , $f4, $f5
	l.s $f7, ($t3)
	add.s $f6, $f6, $f7
	s.s $f6, ($t3)

	addi $t7 , $t7, 1
	j KLoop
KLoopDone:

	addi $t2, $t2, 1
	j MultiplyInnerLoop
MultiplyInnerLoopDone:
	
	addi $t0, $t0, 1 #increment i
	j MultiplyOuterLoop
MultiplyOuterLoopDone:
	jr $ra


cannotMultiply:
	la $a0, SubFailed
	li $v0, 4
	syscall #print error message
	li $v0, 0x10000180 #address of substraction matrix
	li $v1, 0 #set size of sub matrix
	jr $ra
######################################################


	#####################################################
	#     						#####
	#		Data Segment			#####
	#						#####
	#####################################################
	.data 
SizePrompt: .asciiz "Enter the Size of the Matrix: "
FloatPrompt: .asciiz "Enter a Flouting point number: "
endl:	.asciiz "\n"
tab:	.asciiz "\t"
UserPrompt:	.asciiz "\nChoose an operation to perform:\n1.Create Matrix\n2.Create Value\n3.Display Matrix\n4.Display Value\n--> "
rowPrompt:	.asciiz "Enter a row: "
columnPrompt:	.asciiz "Enter a column: "
UserPrompt2:	.asciiz "\nChoose an operation to perform:\n1.Substraction\n2.Multiplication\n-->"
SubFailed:	.asciiz "\nThe matrices are of different size, cannot perform operation\n"
SubResult:	.asciiz "The Resulting matrix is: \n"
