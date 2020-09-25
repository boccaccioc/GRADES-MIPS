.data
userPromp: .asciiz "Enter a value of n:"
nln: .asciiz "\n"

.text

main:
    li $v0, 4
    la $a0, userPromp #prompts user
    syscall

    li $v0, 5
    syscall
    move $t0, $v0 #Stores user input in $t0

    beq $t0, $zero, zero_case

    #li $v0, 4
    #la $a0, nln #new line
    #syscall
    
    li $t6, 0 #numbers for basecase
    li $t7, 1
    move $a0, $t0

    addi  $sp, $sp, -4
    sw $ra, 0($sp)
    jal recus       #returns answer in $v0
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    move $a0, $v0 # storing $v0(final value) in $a0 to print
    li $v0, 1
    syscall

    jr $ra # last return

#-------------------------------------------------------------------------------------------------------------------------------------
recus:

    addi $t1, $a0, -1 # $t1 is the value for f(n-1)
    addi $t2, $a0, -2 # $t2 is the value for f(n-2)

#-------------------------------------------------------------------------------------------------------------------------------------
    beq $t1, $t6, basecase1A # $t6 = 0, so f(n-1) = 0, value set to 1 in base case
    beq $t1, $t7, basecase2A #$t7 = 1, so f(n-1) = 1, value set to 2 in base case
                                            
    addi  $sp, $sp, -32
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $t0, 8($sp)      #SAVES DATA TO BE RELOADED AFTER JAL
    sw $t1, 12($sp)
    sw $t2, 16($sp)

    move $a0, $t1 # calling recurse with f(n-1)
    jal recus
    lw $ra, 0($sp) # restoring $ra after recurse call

    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $t0, 8($sp)      #RELOADES DATA AFTER JAL RECURSIVE CALL
    lw $t1, 12($sp)
    lw $t2, 16($sp)
    addi  $sp, $sp, 32

    mul $t1, $v0, 3 #sets $t1 to 3*f(n-1)
#-------------------------------------------------------------------------------------------------------------------------------------

second_check:
    beq $t2, $t6, basecase1B # $t6 = 0, so f(n-2) = 0, value set to 1 in base case
    beq $t2, $t7, basecase2B # $t7 = 0, so f(n-2) = 1, value set to 2 in base case

    addi  $sp, $sp, -32
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $t0, 8($sp)      #SAVES DATA TO BE RELOADED AFTER JAL
    sw $t1, 12($sp)
    sw $t2, 16($sp)

    move $a0, $t2 # calling recurse with f(n-2)
    jal recus
    lw $ra, 0($sp) # restoring $ra after recurse call

    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $t0, 8($sp)      #RELOADES DATA AFTER JAL RECURSIVE CALL
    lw $t1, 12($sp)
    lw $t2, 16($sp)
    addi  $sp, $sp, 32

    mul $t2, $v0, 4 #sets $t2 to the value of 4*f(n-2)
#-------------------------------------------------------------------------------------------------------------------------------------

end:
    li $t0, 2 #final value, starts at 2 because the +2 is only non recusive part
    add $t0, $t0, $t1
    add $t0, $t0, $t2
    move $v0, $t0 # storing $t0(final value) in $v0 to return

    jr $ra


#-------------------------------------------------------------------------------------------------------------------------------------
                    #FOR a BASECASES, sets $t1 to the value of 3*f(n-1)

basecase1A: # f(n-1) = 0, value set to 1 in base case
   li $t1, 3 # 3*1
   j second_check 

basecase2A: # f(n-1) = 1, value set to 2 in base case
    li $t1, 6 # 3*2
    j second_check 
    
#-------------------------------------------------------------------------------------------------------------------------------------
            #FOR b BASECASES, sets $t2 to the value of 4*f(n-2)

basecase1B: # f(n-2) = 0, value set to 1 in base case
    li $t2, 4 # 4*1
    j end

basecase2B: # f(n-2) = 1, value set to 2 in base case
    li $t2, 8 # 4*2
    j end
    #-------------------------------------------------------------------------------------------------------------------------------------
zero_case:
    li $a0, 1
    li $v0, 1
    syscall
    
    #la $a0, nln
    #li $v0, 4
    #syscall
    
    jr $ra