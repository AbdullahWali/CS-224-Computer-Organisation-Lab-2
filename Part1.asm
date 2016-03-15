#	Author: Abdullah Wali
#	Part 1 of Lab 2	
#	Exercising MIPS floating point instructions

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
	
	
	#request heap space		If memory location is known, replace $s6 with the memory location
	#comment these out when memory is known
	#li $t0 , 4 #put the value 4 in $to ( to multiply by for later)
	#mul $a0, $v0, $t0  #Multiply the number of integers by 4 to get the number of bytes and set as arguement
	#li $v0, 9 
	#syscall #request N*4 bytes of memory from heap
	#move $s6 , $v0 #put the address of requested memory in $s6
	
	li $s6, 0x100000F0  #Uncomment and give memory address in lab
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

#Print Array Contents to console
##################################################
	move $s1, $s6 #copy memory address
	
	li $s0, 0  # i= 0 ( for loop)
printArrayLoop:
	slt $t1, $s0, $s7
	beq $t1, $0, printArrayLoopDone
	
	l.s $f12 , ($s1) #set Argument as arr[i]
	li $v0, 2
	syscall  #print float
	la $a0, endl
	li $v0, 4
	syscall #printLine
	
	addi $s0, $s0, 1 #add 1 to i
	addi $s1, $s1 ,4 #add 4 to memory address
	j printArrayLoop
printArrayLoopDone:
###################################################
					
#perform Operations
###################################################################################
#Will use the numbers in index 0 and the specified index to perform operations
	la $a0, IndexPrompt
	li $v0 , 4
	syscall #ask for an index
	la $v0, 5
	syscall #read index
	
	li $t0, 4
	mul $s0, $v0, $t0
	add $s0, $s0, $s6 #get the address of the selected index
	
	l.s $f20, ($s0) #put the number in $f20
	l.s $f22, ($s6) #put the number in the 0 index in $f22

	#Arithmetic Operations
	add.s $f0, $f20, $f22 #$f0 := $20 + $f22
	sub.s $f0, $f20, $f22 #$f0 := $20 - $f22
	mul.s $f0, $f20, $f22 #$f0 := $f20 * $f22
	div.s $f0, $f20, $f22 #$f0 := $f20 / $f22
	abs.s $f0, $f20 #$f20 := |$f22|
	neg.s $f0, $f20 #$f20 := -$f22

	#Data Movement between registers

	mov.s $f0, $f22 #move between FP registers
	mfc1 $t1, $f22 #move from FP registers 
	mtc1 $t1, $f22 #move to FP registers

	#Data conversion
	cvt.w.s $f0, $f22 #convert f22 to a word ( integer)
	cvt.s.w $f0, $f22 #convert back to a float
	######################################################

	li $v0, 10
	syscall #Byeee

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
IndexPrompt:	.asciiz "Enter the index of the number to use for operations: "
