#	Author: Abdullah Wali
#	Part 2 of Lab 2	
#	MIPS floating point routines

	#####################################################
	#     						#####
	#		Text Segment			#####
	#						#####
	#####################################################

	.text
	.globl __start
	
__start:

	#  Permanent:     $s6 = Heap memory address 	$s7 = N


# Ask user for the number of Integers: N
##########################################################
	la $a0 , CountPrompt  
	li $v0 , 4
	syscall  #Print Prompt
	
	li $v0, 5  
	syscall #Get N from User
	move $s7, $v0 # Store N in $s7
	
	li $s6, 0x100000F0  
########################################################################
	
	
#Read the floats
#############################################################
	# Ask user for the N inputs and store them on heap memory
	move $s0, $s7  #copy s7 to s0 to be able to modify it 
	move $s1, $s6  # copy s6 to s1 to be able to modify it
readFloatssLoop:
	beq $s0, $0, readFloatsLoopDone
	
	la $a0 , FloatPrompt  
	li $v0 , 4
	syscall  #Print Prompt
	
	li $v0, 6
	syscall #Get the float from User
	s.s $f0, 0($s1) #store the float in heap memory 
	
	addi $s1 , $s1, 4 #move the heap pointer to next 4 bytes
	addi $s0, $s0, -1 
	j readFloatssLoop
readFloatsLoopDone:
##########################################################


# Bubble sort: 
###################################################################
	#$s0 = last, $s1 = i, $s2 = Memory address of the array	
	move $s2, $s6  #copy s7 to s0 to be able to modify it 	
	addi $s0 , $s7 , -1 #last = N-1
	
outerLoopSort:
	slt $t0 , $0 , $s0
	beq $t0 , $0, outerLoopEnd #end loop if last <= 0
	
	addi $s1 , $0 , 0  # i  = 0
	move $s2 , $s6 #reset the memory address pointer to i = 0
innerLoopSort:
	slt $t0, $s1, $s0  # t0 = i <last
	beq $t0 , $0 , innerLoopEnd #end if not 
	
	lwc1 $f4 , 0 ($s2)  # arr[i]
	lwc1 $f6, 4($s2)  #arr[i+1] 
	
	c.lt.s  $f6, $f4  #if arr[i] > arr[i+1]
	bc1f noSwap
	#swap arr[i] and arr[i+1]
	s.s $f6, 0($s2)
	s.s $f4, 4($s2)
noSwap:	
	addi $s2 , $s2, 4 #increment address
	addi $s1, $s1, 1 # i++
	j innerLoopSort
	
innerLoopEnd:
	addi $s0, $s0, -1 #last--
	j outerLoopSort
	
outerLoopEnd: 	# Done Sorting   #
 	la $a0, SortingDone
 	li $v0, 4
 	syscall # print a message saying sorting is done
###################################################################


	
#Print Array, Take user choice, and perform operations	#User Choice will be stored in s0
######################################################################
 UserPromptLoop:
	#print array
	la $a0, endl
	li $v0, 4
	syscall #printLine
	move $a0, $s6
	move $a1, $s7
	jal PrintArray
	

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

 	move $a0, $s6
 	move $a1, $s7
 	jal Count
 	#print the result
 	move $t8, $v0
 	la $a0, CountIs
 	li $v0 ,4 
 	syscall
 	move $a0, $t8
 	li $v0, 1
 	syscall #print value
 	
 	j UserPromptLoop
 	
 	case2: #Do Case1
 	addi $t0 , $0, 2 
 	bne $s0, $t0, UserPromptLoop
 	
 	move $a0, $s6
 	move $a1, $s7
 	jal meanValue
 	mov.s $f12, $f0 #set argument to result
 	la $a0, MeanValueIs
 	li $v0, 4
 	syscall #print message
 	li $v0, 2
 	syscall # print result
 	
	j UserPromptLoop
UserPromptLoopDone:
################################################################




      #######################################################
       ####    		     Functions			####
	###						###
	 #################################################




#Count		#returns number of occurences in v0	#a0 holds address, a1 holds size
#######################################################
Count:	
	move $t8, $a0 #put address in t8
	#ask for a number to query
	la $a0, chooseNum
	li $v0, 4
	syscall 
	li $v0 , 6
	syscall 
	mov.s $f4, $f0 #store number in f4
	
	li $v0, 0 #holds count of occurences
	li $t0, 0 # i = 0
CountLoop: slt $t1, $t0 ,$a1
	beq $t1, $0, CountLoopDone
	
	
	l.s $f6, ($t8) #load the word
	c.eq.s $f4, $f6 #compare to queried value
	bc1f CountNotEqual
	addi $v0, $v0, 1
	
CountNotEqual:
	addi $t0, $t0, 1 #increment i
	addi $t8 ,$t8, 4 #increment address
	j CountLoop
	
CountLoopDone:
	jr $ra
########################################################################


meanValue: #Computes mean value in an array of ints	 # $a0 holds address, $a1 holds size	# returns floating point value in f0
#############################################################	
	#if size is 0
	     bne $a1, $0, MeanValueNot0
	     li $v0, 0
	     jr $ra
	     
MeanValueNot0:

	li $t0, 0
	mtc1 $t0, $f2
	cvt.s.w $f2 , $f2 # f2 will hold sum ( f2 = 0)
	addi $t0 , $0 , 0 # i = 0 ( loop variable )
	meanValueLoop: slt $t1, $t0, $a1 #i < size
	beq $t1, $0 , meanValueLoopDone
	
	l.s $f4, 0($a0) #load the number into f4 
	add.s $f2, $f2, $f4 #add the number to sum

	addi $a0, $a0, 4 #increment a0 by 4
	addi $t0 , $t0, 1 #increment i by 1
	j meanValueLoop

	meanValueLoopDone:
	mtc1 $a1, $f6
	cvt.s.w $f6, $f6
	div.s $f0, $f2, $f6
	jr $ra
		
########################################################


#Print Array Contents to console #a0 holds address, #a1 holds size
##################################################
PrintArray:	
	addi $sp , $sp, -4
	sw $s1, ($sp) #store old s1
	move $s1, $a0 #copy memory address
	li $t0, 0  # i= 0 ( for loop)
printArrayLoop:
	slt $t1, $t0, $a1
	beq $t1, $0, printArrayLoopDone
	
	l.s $f12 , ($s1) #set Argument as arr[i]
	li $v0, 2
	syscall  #print float
	la $a0, endl
	li $v0, 4
	syscall #printLine
	
	addi $t0, $t0, 1 #add 1 to i
	addi $s1, $s1 ,4 #add 4 to memory address
	j printArrayLoop
printArrayLoopDone:
	lw $s1, 0($sp)
	addi $sp , $sp, 4 #restore s1 and return
	jr $ra
###################################################








	#####################################################
	#     						#####
	#		Data Segment			#####
	#						#####
	#####################################################
	.data 
CountPrompt: .asciiz "Enter the number of Floats to be used: "
FloatPrompt: .asciiz "Enter a Flouting point number: "
SortingDone:	.asciiz "The numbers are now Sorted:\n"
endl:	.asciiz "\n"
UserPrompt:	.asciiz "\nChoose an operation to perform:\n1.Find Count\n2.Find Average\n--> "
MeanValueIs: 	.asciiz "Mean Value is: "
chooseNum:	.asciiz "Choose a value to find its number of Occurences: "
CountIs:	.asciiz "The number of occurences of the queried value is: "
