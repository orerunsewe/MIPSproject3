.data
        input_str:        .space      1001                   # Preallocate space for 1000 characters and the null string
        invalid:          .asciiz     "Invalid Input"        # Store and null-terminate the string to be printed for invalid inputs
        null_char:        .byte       0                      # Allocate byte in memory for null char
        space_char:       .byte       32                     # Allocate byte in memory for space char
        tab_char:         .byte       9                      # Allocate byte in memory for tab char
        nl_char:          .byte       10                     # Allocate byte in memory for newline char
        comma_char:       .byte       44                     # Allocate byte in memory for space char
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
                      add $t1, $t3, $s0            # Get the current character's address
                      lb $t2, 0($t1)               # Load register $t2 with the current character
                      beq $t1, $s0, PassString     # If current char is the first char in string, go to Passstring (all characters have been loaded to stack)
                      addi $sp, $sp, -1            # Move the stack pointer down to make room for character in the stack
                      sb $t2, 0($sp)               # Store the current character unto the stack
                      addi $t3, $t3, -1             # Increment counter to go to the next character
                      j Loop2                      # Jump back to Loop1

              PassString:
                      jal SubprogramA              # Pass the whole user input string to SubprogramA via stack


        # SubprogramA processes the string that has been placed on the stack
        # Strings are split into substrings by using a single comma as the delimiter. If there is no comma, the while string is considered a substring
        SubprogramA:
                  addi $t4, $ra, 0                  # Store the return address into main in register $t4
                  lb $s5, comma_char                # Load register $s5 with char corresponding to a comma
                  addi $s6, $sp, 0                  # Initialize register $s6 to start from $sp
                  addi $t0, $zero, $zero            # Intialize counter to keep track of start of substring

                  # This gets the next substring from the input string in the stack and loads it into a higher address in the stack
                  Loop3:
                  lb $t1, 0($s6)                    # Load $t1 with character at $s6
                  beq $t1, $s5, SubString           # Check if current char in substring is a comma
                  beq $t1, $s1, Substring           # Check if current char in substring is the null char
                  addi $sp, $sp, -1                 # Make room in stack to store the current char in the substring
                  sb $t1, 0($sp)                    # Store the current char in the stack
                  addi $s6, $s6, 1                  # Increment $s6 to get the the next char in substring
                  addi, $t0, $t0, 1                 # Incremement $t0 to get start of substring
                  j Loop3                           # Jump back to Loop3

                  Substring:
                  addi $t0, $t0, -1                 # Subtract 1 from counter to get right position for start index of substring
                  add $t5, $sp, $t0                 # Add $t0 to $sp to get start index of the substring. Substring is now from $t5 to $sp
                  beq $t1, $s1, Return1             # If the current char is the null char, return to main
                  addi $s6, $s6, 1                  # Add 1 to $s6 to move to next char after comma for processing the next substring
                  lb $t1, 0($s6)                    # Load $t1 with next character
                  beq $t1, $s1, Invalid             # If a null char comes right after a comma, the string is empty and Invalid


                  jal SubProgramB


        SubProgramB:


        Invalid: 
