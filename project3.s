.data
        input_str:        .space      1001                   # Preallocate space for 1000 characters and the null string
        invalid:          .asciiz     "Invalid Input"        # Store and null-terminate the string to be printed for invalid inputs
        null_char:        .byte       0                      # Allocate byte in memory for null char
        space_char:       .byte       32                     # Allocate byte in memory for space char
        tab_char:         .byte       9                      # Allocate byte in memory for tab char
        nl_char:          .byte       10                     # Allocate byte in memory for newline char

.text
        main:
              li $v0, 8                            # Systemcall to get the user's input
              la $a0, input_str                    # Load register with the address of the input string
              li $a1, 1001                         # Read maximum of 1001 characters from user input (including null character)
              syscall

              lb $s1, null_char
              lb $s2, nl_char
              lb $s3, space_char
              lb $s4, tab_char

              la $s0, input_str                    # Load register with address of user input
              add $t0, $zero, $zero                # Initialize counter to zero

              # This loop checks for the index of the last character in the string by checking for the null or newline characters
              Loop1:
                  add $t1, $t0, $s0                    # Get current char's address starting from first char in input str
                  lb $t2, 0($t1)                       # Load register $t2 with the current char
                  beq $t2, $s1, StringEnd              # If the current char is the null char, go to StringEnd
                  beq $t2, $s2, StringEnd              # If the current char is the newline char, go to StringEnd
                  addi $t0, $t0, 1                     # Increment counter to check next character
                  j Loop1                              # Restart Loop

              # This loop keeps track of the end of string
              StringEnd:
                  add $t3, $t0, $zero                  # Load the $t3 register with the index at the end of string
                  addi $t3, $t3, -1                    # Subtract by -1 to get char that is not null/nl
                  j StackTop                           # Jump to StackTop

              # Store the top of the stack with the null char to know when all chars in user input have been processed
              StackTop:
                  addi $sp, $sp, -1                   # Allocate space in the stack
                  sb $s1, 0($sp)                      # Store the null character
                  j Loop2                             # Jump to loop 2 to load characters onto the stack




              # This loop iterates through the chacters of the input string from the end to start and stores each character on the stack
              Loop2:
                      add $t1, $t0, $s0            # Get the current character's address
                      lb $t2, 0($t1)               # Load register $t2 with the current character
                      beq $t2, $s2, PassString     # If current char is the newline character, go to PassString (do allocate space in stack)
                      beq $t2, $s1, PassString     # If current char is the null character, go to Passstring (do allocate space in stack)
                      addi $sp, $sp, -1            # Move the stack pointer down to make room for character in the stack
                      sb $t2, 0($sp)               # Store the current character unto the stack
                      addi $t0, $t0, 1             # Increment counter to go to the next character
                      j Loop2                      # Jump back to Loop1

              PassString:
                      jal SubprogramA              # Pass the whole user input string to SubprogramA via stack



        SubprogramA:
                  addi $t3, $ra, 0

                  jal SubProgramB


        SubProgramB:
