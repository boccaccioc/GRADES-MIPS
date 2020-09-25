#
# PROGRAM
#
.text

#
# Hash function.
# Argument: $a0 (int)
# Return: $v0 = hash (int)
#
hash:
    li $t0, 13
    div $a0, $t0
    mfhi $v0 #retreiving remainder which is stored in the hi register
    jr $ra

# Initialize the hash table.
#
init_hash_table:
    
    li $t0, 0 #initially just storing pointers in hashtable, setting to zero
    li $t1, 0 #index for loop
    li $t2, 13 #sentinal value for loop
    #pointers will represent the address of memory location of a student, which will contain a pointer to the
    #next student in that linked list if there is one
init_Loop:
    beq $t1, $t2, end_Init_Loop             
    sw $zero, ARRAY($t0) #stores zero at byte index $t0(multiple of 4) in the array
    addi $t0, $t0, 4 #moves down 4 bytes in the array to store next int

    addi $t1, $t1, 1 #interated for loop
    j init_Loop
end_Init_Loop:
    jr $ra
   
#
# Insert the record unless a record with the same ID already exists in the hash table.
# If record does not exist, print "INSERT (<ID>) <Exam 1 Score> <Exam 2 Score> <Name>".
# If a record already exists, print "INSERT (<ID>) cannot insert because record exists".
# Arguments: $a0 (ID), $a1 (exam 1 score), $a2 (exam 2 score), $a3 (address of name buffer)
#
insert_student:
    move $t4, $a0 # $t4 = ID
    move $t5, $a1 # $t5 = exam 1 score
    move $t6, $a2 # $t6 = exam 2 score
    move $t7, $a3 # $t7 = address of the name buffer

    #hashing--------------------------------------------------------------------------------------------------------------------------
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal hash        #HASH value is placed in $v0
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    #---------------------------------------------------------------------------------------------------------------------------------
    mul $t3, $v0, 4 #gets the address of the correct index in the array into $t3
    lw $t1, ARRAY($t3) #$t1 becomes the pointer in the $v0'th index of the array
    beq $t1, $zero, no_previous_pointers #case where it is still an empty linked list

insert_student_loop:
    lw $t2, 0($t1) #stores ID of student in array into $t2
    beq $t2, $t4, insert_student_failed
    lw $t0, 28($t1) #switches $t0 to equal next pointer #MIGHT NEED TO CHANGE 28 in the future depending on word size
    beq $t0, $zero, insert_student_success #if next is null then goes to insert student success to add student
    move $t1, $t0 #moves $t0 (next pointer into $t1 for next loop)
    j insert_student_loop

#-----------------------------------------------------------------------------------------------------------------------------------------------
no_previous_pointers:
    li $v0, 9
    li $a0, 32# 4bytes per int, so ID+score1+score2=12bytes , and name is 16 char and char is 1 ...so 12+16=28, and pointer so 28+4=32
    syscall
    move $t0, $v0 #moving address of memory into $t0

    sw $t0, ARRAY($t3) #stores the pointer straight into the array as it was empty before
    j insert_student_continue

insert_student_success: #MAKE STUDENT THEN DO PRINTLINE
    #AT THE BOTTOM BECAUSE ONLY NEED TO ALLOCATE IF THE STUDENT IS NOT A DUPLICATE ID------------------------------------------------
    
yes_previous_pointers:
    li $v0, 9
    li $a0, 32# 4bytes per int, so ID+score1+score2=12bytes , and name is 16 char and char is 1 ...so 12+16=28, and pointer so 28+4=32
    syscall
    move $t0, $v0 #moving address of memory into $t0

    sw $t0, 28($t1) #stores pointer to new memory into next pointer spot in previous student

    j insert_student_continue

insert_student_continue:
    sw $t4, 0($t0)
    sw $t5, 4($t0)
    sw $t6, 8($t0)
    sw $zero, 28($t0) #sets the value of next pointer to zero

    li $v0, 9
    li $a0, 16
    syscall # making space for the string with the new register pointer in $v0
    move $t2, $v0
    sw $t2, 12($t0) # PUTS adress of new bytes into spot 12 in student

copy_string_loop:
    lbu $t1, 0($a3) 
    sb $t1, 0($t2) 
    addi $a3, $a3, 1 
    addi $t2, $t2, 1
    beq $t1, $zero, copied_continue
    j copy_string_loop
copied_continue:
    li $v0, 4
    move $a0, $t2
    syscall #      


    #prints out "INSERT (<ID>) <Exam 1 Score> <Exam 2 Score> <Name>"
    li $v0, 4
    la $a0, INSERT_openP
    syscall #               "INSERT ("
    li $v0, 1
    move $a0, $t4
    syscall #               "<ID>"
    li $v0, 4
    la $a0, closeP_Space
    syscall #               ") "
    li $v0, 1
    move $a0, $t5
    syscall #               <Exam 1 Score>
    li $v0, 4
    la $a0, spaceChar
    syscall #               " "
    li $v0, 1
    move $a0, $t6
    syscall #               <Exam 2 Score>
    li $v0, 4
    la $a0, spaceChar
    syscall #               " "
    li $v0, 4
    move $a0, $t7
    syscall #               <Name>
    li $v0, 4
    la $a0, nln
    syscall #               "\n" 


    jr $ra
#-----------------------------------------------------------------------------------------------------------------------------------------------

insert_student_failed: #prints "INSERT (<ID>) cannot insert because record exists"
    li $v0, 4
    la $a0, INSERT_openP
    syscall #               INSERT (
    li $v0, 1
    move $a0, $t4
    syscall #               "<ID>"
    li $v0, 4
    la $a0, closeP_cannotInsert
    syscall #               ") cannot insert because record exists"
    li $v0, 4
    la $a0, nln
    syscall #               "\n"

    jr $ra
#------------------------------------------------------------------------------------------------------------------------------------------
# Delete the record for the specified ID, if it exists in the hash table.
# If a record already exists, print "DELETE (<ID>) <Exam 1 Score> <Exam 2 Score> <Name>".
# If a record does not exist, print "DELETE (<ID>) cannot delete because record does not exist".
# Argument: $a0 (ID)
#
delete_student:
    move $t4, $a0 # moving ID into $t4

    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal hash        #HASH value is placed in $v0
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    move $t3, $v0 #moving hash into $t0
    mul $t3, $t3, 4 #hash times 4 to get array index

    lw $t1, ARRAY($t3) # $t3 will stay as pointer to array index
    beq $t1, $zero, delete_student_failed #if empty nothing to delete

delete_student_loop:
    lw $t2, 0($t1) #stores ID of student in array into $t2
    beq $t2, $t4, delete_student_success
    lw $t0, 28($t1) #switches $t0 to equal next pointer #MIGHT NEED TO CHANGE 28 in the future depending on word size
    beq $t0, $zero, delete_student_failed #if next is null then goes to insert student success to add student
    move $t1, $t0 #moves $t0 (next pointer into $t1 for next loop)
    j delete_student_loop

#------------------------------------------------------------------------------------------------------------------------------------
delete_student_success: # prints "DELETE (<ID>) <Exam 1 Score> <Exam 2 Score> <Name>", then decides which branch
    lw $t4, 0($t1) # $t4 = ID
    lw $t5, 4($t1) # $t5 = score 1
    lw $t6, 8($t1) # $t6 = score 2
    lw $t7, 12($t1) # $t7 = name
    
    
    
    li $v0, 4
    la $a0, DELETE_openP
    syscall #               "DELETE ("
    li $v0, 1
    move $a0, $t4
    syscall #               "<ID>"
    li $v0, 4
    la $a0, closeP_Space
    syscall #               ") "
    li $v0, 1
    move $a0, $t5
    syscall #               <Exam 1 Score>
    li $v0, 4
    la $a0, spaceChar
    syscall #               " "
    li $v0, 1
    move $a0, $t6
    syscall #               <Exam 2 Score>
    li $v0, 4
    la $a0, spaceChar
    syscall #               " "
    li $v0, 4
    move $a0, $t7
    syscall #               <Name>
    li $v0, 4
    la $a0, nln
    syscall #               "\n"

    move $t6, $t1 # moves pointer to register for student to be deleted into $t6

    lw $t1, ARRAY($t3) # $t3 = pointer to array index, needs to be reset here to beginning of linked list

    lw $t2, 28($t1) # $t2 is holding the pointer to the next student

    li $t7, 99 # $t7 holds a number telling the delete funtion what type of delete to execute after finding index
    # $t7 = 99 signifies that it should execute using delete last index, $t7 = 55 signifies delete middle index
    beq $t2, $zero, delete_find #if next pointer equals zero then it is in the last index
                                #else it must be middle index or first index
    li $t7, 55    #$t7 = 55 signifies delete middle index

#------------------------------------------------------------------------------------------------------------------------------------
delete_find:
    lw $t0, 0($t1) #ID of first in linked list stored in $t0
    beq $t0, $t4, delete_student_firstIndex #if first student is the student to delete branch to delete_firstIndex
delete_find_loop:
    lw $t2, 28($t1) #stores ID of student in array into $t2
    beq $t2, $t6, delete_find_continue
    lw $t0, 28($t1) #switches $t0 to equal next pointer #MIGHT NEED TO CHANGE 28 in the future depending on word size
    move $t1, $t0 #moves $t0 (next pointer into $t1 for next loop)
    j delete_find_loop
delete_find_continue: # at this point $t1 is the register of student preceding student to be deleted, and $t2 is deleted student
    beq $t7, 55, delete_student_middleIndex
    beq $t7, 99, delete_student_lastIndex

#------------------------------------------------------------------------------------------------------------------------------------
delete_student_lastIndex:
    sw $zero, 28($t1)
    
    jr $ra
delete_student_middleIndex:#first checks if it needs to branch to first index
   lw $t7, 28($t2) # moves deleted student's next pointer into $t7
   sw $t7, 28($t1) # stores deleted student's next pointer as the next pointer for preceding student causing the pointers to skip over $t2
   
   jr $ra
delete_student_firstIndex:#set pointer in the original array equal to next pointer of the first student
    lw $t1, ARRAY($t3) # $t3 = pointer to array index, needs to be reset here to beginning of linked list
    lw $t4, 28($t1) # gets next pointer of the first and only student
    sw $t4, ARRAY($t3) # sets pointer in the array equal to next pointer of first student

    jr $ra
#------------------------------------------------------------------------------------------------------------------------------------
delete_student_failed:#prints "DELETE (<ID>) cannot delete because record does not exist"
    li $v0, 4
    la $a0, DELETE_openP
    syscall #               DELETE (
    li $v0, 1
    move $a0, $t4
    syscall #               "<ID>"
    li $v0, 4
    la $a0, closeP_cannotDelete
    syscall #               ") cannot delete because record does not exist"
    li $v0, 4
    la $a0, nln
    syscall #               "\n"

    jr $ra

#------------------------------------------------------------------------------------------------------------------------------------
#
# Print all the member variables for the record with the specified ID, if it exists in the hash table.
# If a record already exists, print "LOOKUP (<ID>) <Exam 1 Score> <Exam 2 Score> <Name>".
# If a record does not exist, print "LOOKUP (<ID>) record does not exist".
# Argument: $a0 (ID)
#
lookup_student:
    move $t4, $a0 # moving ID into $t4

    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal hash        #HASH value is placed in $v0
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    move $t0, $v0 #moving hash into $t0
    mul $t0, $t0, 4 #hash times 4 to get array index

    lw $t1, ARRAY($t0)
    beq $t1, $zero, lookup_student_failed

lookup_student_loop:
    lw $t2, 0($t1) #stores ID of student in array into $t2
    beq $t2, $t4, lookup_student_success
    lw $t0, 28($t1) #switches $t0 to equal next pointer #MIGHT NEED TO CHANGE 28 in the future depending on word size
    beq $t0, $zero, lookup_student_failed #if next is null then goes to insert student success to add student
    move $t1, $t0 #moves $t0 (next pointer into $t1 for next loop)
    j lookup_student_loop


                #ONCE YOU GET THE STUDENT PLACE THE NAME AND EXAM SCORES INTO THE $t REGISTERS
#-------------------------------------------------------------------------------------------------------------------------------------------------
lookup_student_success: # prints "LOOKUP (<ID>) <Exam 1 Score> <Exam 2 Score> <Name>"
    lw $t4, 0($t1) # $t4 = ID
    lw $t5, 4($t1) # $t5 = score 1
    lw $t6, 8($t1) # $t6 = score 2
    lw $t7, 12($t1)
    #lw $t3, 12($t1) # $t7 = name
    #lw $t7, 0($t3) # $t7 = name
    
    
    li $v0, 4
    la $a0, LOOKUP_openP
    syscall #               "LOOKUP ("
    li $v0, 1
    move $a0, $t4
    syscall #               "<ID>"
    li $v0, 4
    la $a0, closeP_Space
    syscall #               ") "
    li $v0, 1
    move $a0, $t5
    syscall #               <Exam 1 Score>
    li $v0, 4
    la $a0, spaceChar
    syscall #               " "
    li $v0, 1
    move $a0, $t6
    syscall #               <Exam 2 Score>
    li $v0, 4
    la $a0, spaceChar
    syscall #               " "
    li $v0, 4
    move $a0, $t7
    syscall #               <Name>
    li $v0, 4
    la $a0, nln
    syscall #               "\n"


    jr $ra

 #------------------------------------------------------------------------------------------------------------------------------------
lookup_student_failed: # prints "LOOKUP (<ID>) record does not exist"
    li $v0, 4
    la $a0, LOOKUP_openP
    syscall #               LOOKUP (
    li $v0, 1
    move $a0, $t4
    syscall #               "<ID>"
    li $v0, 4
    la $a0, closeP_cannotLookup
    syscall #               ") record does not exist"
    li $v0, 4
    la $a0, nln
    syscall #               "\n" 

    jr $ra
   
#
# Read input and call the appropriate hash table function.
#
main:
    addi    $sp, $sp, -16
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s2, 12($sp)

    jal     init_hash_table

main_loop:
    la      $a0, PROMPT_COMMAND_TYPE    # Promt user for command type
    li      $v0, 4
    syscall

    la      $a0, COMMAND_BUFFER         # Buffer to store string input
    li      $a1, 3                      # Max number of chars to read
    li      $v0, 8                      # Read string
    syscall

    la      $a0, COMMAND_BUFFER
    jal     remove_newline

    la      $a0, COMMAND_BUFFER
    la      $a1, COMMAND_T
    jal     string_equal

    li      $t0, 1
    beq		$v0, $t0, exit_main	        # If $v0 == $t0 (== 1) (command is t) then exit program

    la      $a0, PROMPT_ID              # Promt user for student ID
    li      $v0, 4
    syscall

    li      $v0, 5                      # Read integer
    syscall

    move    $s0, $v0                    # $s0 holds the student ID

    la      $a0, PROMPT_EXAM1           # Prompt user for exam 1 score
    li      $v0, 4
    syscall

    li      $v0, 5                      # Read integer
    syscall

    move    $s1, $v0                    # $s1 holds the exam 1 score

    la      $a0, PROMPT_EXAM2           # Prompt user for exam 2 score
    li      $v0, 4
    syscall

    li      $v0, 5                      # Read integer
    syscall

    move    $s2, $v0                    # $s2 holds the exam 2 score

    la      $a0, PROMPT_NAME            # Prompt user for student name
    li      $v0, 4
    syscall

    la      $a0, NAME_BUFFER            # Buffer to store string input
    li      $a1, 16                     # Max number of chars to read
    li      $v0, 8                      # Read string
    syscall

    la      $a0, NAME_BUFFER
    jal     remove_newline

    la      $a0, COMMAND_BUFFER         # Check if command is insert
    la      $a1, COMMAND_I
    jal     string_equal
    li      $t0, 1
    beq		$v0, $t0, goto_insert

    la      $a0, COMMAND_BUFFER         # Check if command is delete
    la      $a1, COMMAND_D
    jal     string_equal
    li      $t0, 1
    beq		$v0, $t0, goto_delete

    la      $a0, COMMAND_BUFFER         # Check if command is lookup
    la      $a1, COMMAND_L
    jal     string_equal
    li      $t0, 1
    beq		$v0, $t0, goto_lookup

goto_insert:
    move    $a0, $s0
    move    $a1, $s1
    move    $a2, $s2
    la      $a3, NAME_BUFFER
    jal     insert_student
    j       main_loop

goto_delete:
    move    $a0, $s0
    jal     delete_student
    j       main_loop

goto_lookup:
    move    $a0, $s0
    jal     lookup_student
    j       main_loop

exit_main:
    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s2, 12($sp)
    addi    $sp, $sp, 16
    jr      $ra


#
# String equal function.
# Arguments: $a0 and $a1 (addresses of strings to compare)
# Return: $v0 = 0 (not equal) or 1 (equal)
#
string_equal:
    addi    $sp, $sp, -12
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)

    move    $s0, $a0
    move    $s1, $a1

    lb      $t0, 0($s0)
    lb      $t1, 0($s1)

string_equal_loop:
    beq     $t0, $t1, continue_string_equal_loop
    j       char_not_equal
continue_string_equal_loop:
    beq     $t0, $0, char_equal
    addi    $s0, $s0, 1
    addi    $s1, $s1, 1
    lb      $t0, 0($s0)
    lb      $t1, 0($s1)
    j       string_equal_loop

char_equal:
    li      $v0, 1
    j       exit_string_equal

char_not_equal:
    li      $v0, 0

exit_string_equal:
    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    addi    $sp, $sp, 12
    jr      $ra


#
# Remove newline from string.
# Argument: $a0 (address of string to remove newline from)
#
remove_newline:
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)

    lb      $t0, 0($a0)
    li      $t1, 10                     # ASCII value for newline char

remove_newline_loop:
    beq     $t0, $t1, char_is_newline
    addi    $a0, $a0, 1
    lb      $t0, 0($a0)
    j       remove_newline_loop

char_is_newline:
    sb      $0, 0($a0)

    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr      $ra



# 
# DATA
#
.data
PROMPT_COMMAND_TYPE:    .asciiz     "PROMPT (COMMAND TYPE): "
PROMPT_ID:              .asciiz     "PROMPT (ID): "
PROMPT_EXAM1:           .asciiz     "PROMPT (EXAM 1 SCORE): "
PROMPT_EXAM2:           .asciiz     "PROMPT (EXAM 2 SCORE): "
PROMPT_NAME:            .asciiz     "PROMPT (NAME): "
COMMAND_BUFFER:         .space      3                           # 3B buffer
NAME_BUFFER:            .space      16                          # 16B buffer
COMMAND_I:              .asciiz     "i"                         # Insert
COMMAND_D:              .asciiz     "d"                         # Delete
COMMAND_L:              .asciiz     "l"                         # Lookup
COMMAND_T:              .asciiz     "t"                         # Terminate

.align 2
ARRAY:                  .space      52
INSERT_openP:           .asciiz     "INSERT ("
closeP_cannotInsert:    .asciiz     ") cannot insert because record exists"

DELETE_openP:           .asciiz     "DELETE ("
closeP_cannotDelete:    .asciiz     ") cannot delete because record does not exist"

LOOKUP_openP:           .asciiz     "LOOKUP ("
closeP_cannotLookup:    .asciiz     ") record does not exist"

spaceChar:              .asciiz     " "
closeP_Space:           .asciiz     ") "
nln:                    .asciiz     "\n"