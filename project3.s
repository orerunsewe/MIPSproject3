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

              la $s0, input_str                    # Load register with address of user input
              add $t0, $zero, $zero                # Initialize counter to zero

              # This loop iterates through the chacters of the input string and stores each character on the stack until it reaches the null character
              Loop1:
                      add $t1, $t0, $s0            # Get the current character's address
                      lb $t2, 0($t1)               # Load register $t2 with the current character
                      addi $sp, $sp, -1            # Move the stack pointer down to make room for character in the stack
                      sb $t2, 0($sp)               # Store the current character unto the stack
                      addi $t0, $t0, 1             # Increment counter to go to the next character 
