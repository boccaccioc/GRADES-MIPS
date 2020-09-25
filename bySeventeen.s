.data
string1: .asciiz "enter n:"
stringSpace: .asciiz "\n"
.text

main:
    la $a0, string1
    li $v0, 4 #printing a string so 4
    syscall

    li $v0, 5 #syscall to read in user int
    syscall

    move $s0, $v0 #user input for n
    li $s1, 1 #value that is iterated for mult
loop:
    mul $a0,$s1, 17
    #move $a0, $lo #stores the lower half of mult, but not too big so ok
    li $v0, 1
    syscall
    la $a0, stringSpace
    li $v0, 4 #printing a string so 4
    syscall
    beq $s0, $s1, exit
    addi $s1, $s1, 1
    j loop
exit:
    jr $ra

    
