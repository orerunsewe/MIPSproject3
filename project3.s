.data
        input_str:        .space      1001                   # Preallocate space for 1000 characters and the null string
        invalid:          .asciiz     "NaN"        # Store and null-terminate the string to be printed for invalid inputs
        null_char:        .byte       0                      # Allocate byte in memory for null char
        space_char:       .byte       32                     # Allocate byte in memory for space char
        tab_char:         .byte       9                      # Allocate byte in memory for tab char
        nl_char:          .byte       10                     # Allocate byte in memory for newline char
        comma_char:       .byte       44                     # Allocate byte in memory for space char

        # Allocate space in memory for an array to store decimal values of substrings. The worst case space needed is (501x4 = 2004) when all substrings in input are of length one
        dec_array:        .align 2    .space      2004
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
              lb $s5, comma_char                # Load register $s5 with char corresponding to a comma

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
                      addi $t3, $t3, -1            # Increment counter to go to the next character
                      j Loop2                      # Jump back to Loop1

              PassString:
                      jal SubprogramA              # Pass the whole user input string to SubprogramA via stack


        # SubprogramA processes the string that has been placed on the stack
        # Strings are split into substrings by using a single comma as the delimiter. If there is no comma, the while string is considered a substring
        SubprogramA:

                  j InitializeA1

                  InitializeA1:
                  addi $t4, $ra, 0                  # Store the return address into main in register $t4
                  addi $t9, $zero, $zero            # Initialize counter

                  Start:
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
                  beq $t1, $s1, JumpToSPB           # If the current char is the null char, jump to SubProgramB to convert substring
                  addi $s6, $s6, 1                  # Add 1 to $s6 to move to next char after comma for processing the next substring
                  lb $t1, 0($s6)                    # Load $t1 with next character
                  beq $t1, $s1, InvalidSubstr       # If a null char comes right after a comma, the string is empty and Invalid

                  JumpToSPB:
                  jal SubProgramB

                  # This stores the decimal values of all substrings into memory
                  StoreValue2:
                  lw $t2, 4($sp)                    # Load $t2 with the decimal value
                  sw $t2, dec_array($t9)            # Store the decimal value in the array at index marked by counter in $t9
                  addi $t9, $t9, 4                  # Increment counter by 4 to store next decimal value
                  add $sp, $s6, $zero               # Move stack pointer to next substring to be processed
                  lb $s6, 0($s6)                    # Load $s6 with char at $s6
                  beq $s6, $s1, LoadStack           # If $t2 is null char, the top of the stack has been reached so it is the last substring. Go to LoadStack
                  j Start

                  # This loop loads the decimal values into the stack
                  LoadStack:
                  add $t2, $t2, 4
                  lw $t0, dec_array($t1)
                  sw $t0, 0($sp)
                  sub $sp, $sp, 4
                  beq $t2, $t9, JumpToMain
                  add $t1, $t1, 4
                  j LoadStack








                  # Initalize registers to be used in storing decimal value
                  #InitializeReg:
                  #add $t9, $zero, $zero                     # Initalize counter to zero
                  #la $s0, dec_array                         # Load address of array in memory to keep the decimal values of substrings as words
                  #j StoreValue




                  # This stores the decimal values of all substrings into memory
                  #StoreValue:
                  #lb $t2, 0($s6)                            # Load current character into register $t2
                  #add $t1, $t9, $s0                         # Current index in array to write to
                  #sw $s7, 0($t1)                            # Store decimal value of substring as a word into the array at index
                  #addi $t9, $t9, 4                          # Increment counter by +4 to store next word (i.e. decimal number)
                  #beq $t2, $s1, AppendNull                  # If $t2 is null char, the top of the stack has been reached so it is the last substring
                  #j SubProgramB                             # Else jump back to start SubProgramB to begin processing next substring

                  #AppendNull:
                  #add $t1, $t9, $s0                         # Current index in array to write to
                  #sb $s1, 0(t1)                             # Store the null char at the end

                  jr $ra



        # SubProgramB processes each substring that is on the stack. It returns the decimal value of a valid substring or a value of -1 if substring is invalud
        SubProgramB:

                  j StoreReturnB

                  StoreReturnB:
                  addi $t8, $ra, 0
                  j Loop4

                  # This loop is used to check for leading spaces and eliminates them by adjusting the start index of the string appropriately
                  Loop4:
                        #add $t1, $t5, $zero                 # Get the current character's address
                        lb $t2, 0($t5)                       # Load register $t2 with the current character
                        #beq $t2, $s1, PrintInvalid          # If current char is the null char, the string is empty. Therefore, invalid
                        #beq $t2, $s2, PrintInvalid          # If current char is the newline char, the string is empty. Therefore, invalid
                        bne $t2, $s3, CheckTab               # If the current char is not a space character, go to subroutine to check if it's a tab
                        beq $t5, $sp, InvalidSubstr          # If current $t5 is at $sp then all chars are spaces/tabs. Go to InvalidSubstr
                        addi $t5, $t5, -1                    # If the current char is a space, increment $t5 in stack to check next character
                        j Loop4                              # Jump back to beginning of the loop

                  # Checks if the current chacter is a tab only when it is not a space
                  CheckTab:
                        bne $t2, $s4, SetStartIndex          # If the current char is not a tab, then set char as the start index
                        beq $t5, $sp, InvalidSubstr          # If current $t5 is at $sp then all chars are spaces/tabs. Go to InvalidSubstr
                        addi $t5, $t5, -1                    # Else, increment the $t5 register to check for spaces and/or tabs in the next character in stack
                        j Loop4                              # Jump back to Loop1 to check next character

                  # Set the start index after looping through all leading spaces and tabs
                  SetStartIndex:
                        add $t5, $zero, $zero                # $t5 is now the first non-space/tab char in the substring
                        #add $t3, $s5, $zero                 # Move start index to register $t3 to use as counter in Loop2
                        j StoreSP

                  # Store stack pointer in register
                  StoreSP:
                        add $t6, $sp, $zero                  # Store $sp in $t6 so $sp is not tampered with
                        j Loop5

                  # This loop removes trailing spaces and tab chars in substring
                  Loop5:
                        lb $t2, 0($t6)                       # Load the register with the last char in the string
                        bne $t2, $s3, CheckTab2              # If current char is not a space char, check if it is a tab char
                        addi $t6, $t6, 1                     # Increment last char in string by 1 to keep checking for non space/tab char
                        j Loop5                              # Restart Loop

                  # Checks if the current char is a tab if it is not a space. Used for eliminating trailing tabs
                  CheckTab2:
                      bne $t2, $s4, SetEndIndex             # If current char is also not a tab, set as end index for string
                      addi $t6, $t6, 1                      # Increment register storing the end of the string by 1
                      j Loop5                               # Jump back to Loop5

                  # Sets the end index after looping through all trailing spaces and tabs
                  SetEndIndex:
                      add $t6, $t6, $zero                   # Store the end index in register $t6
                      j CheckValidLength                    # Jump to CheckValidLength


                  # This subroutine checks if the length of the substring is valid (not more than 4 characters)
                  CheckValidLength:
                      addi, $t1, $zero, 3                   # Initalize $t1 register to equal 3
                      sub $t0, $t5, $t6                     # Check the difference between start index and end index
                      bgt $t0, $t1, InvalidSubstr           # If the difference is greater than 3, there are more than 4 chars. Go to InvalidSubstr
                      j Initialize

                  # Initialize registers to be used to calculate decimal value of substring
                  Initialize:
                  add $t0, $zero, 1                         # Initialize $t3 to 1. Will be incremented by x30 i
                  addi $t1, $zero, 30                       # Load register $t1 with immediate 30 for calculations
                  add $s7, $zero, $zero                     # Initialize register $s7 for sum to calculate decimal value
                  j Loop6

                  # Loop through each character in  a valid substring and calculates its decimal value
                  Loop6:
                  #add $t7, $t6, $zero                      # Start reading characters for conversion from the end index in register $t6
                  lb $a0, 0($t6)                            # Load register $a0 with current character starting from character at end index $t6
                  jal SubprogramC                           # Jump to SubprogramC to convert current char then return to next instruction
                  mult $t0, $v1                             # Multiply decimal value of char by 30^n where n char position starting from the right at 0
                  mflo $t7                                  # Move result from multiplication to the $t7 register
                  add $s7, $s7, $t7                         # Add result to the sum
                  mult $t0, $t1                             # Multiply by 30 for the multiplication of the next char (30^(n+1))
                  mflo $t0                                  # Move 30^(n+1) to $t0
                  beq $t5, $t6, DecimalValue                # If the start index equal to the end index, all chars have been converted. Print the Decimal Value
                  addi $t6, $t6, 1                          # Increment end index by 1 for next char in stack
                  j Loop6                                   # Restart Loop6

                  # Return -1 if the substring is invalid
                  InvalidSubstr:
                  addi $s7, $zero, -1                       # Load $s7 with -1 if substring is invalid
                  add $sp, $t5, $zero                       # Move $sp to start of substring to unload substring from stack
                  sw $s7, 0($sp)                            # Store decimal value -1 on the stack to return to SubprogramA (indicates NaN)
                  sub $sp, $sp, 4                           # Move $sp to validate other bytes in the word
                  jr $t8                                    # Return to SubprogramA

                  # Print the decimal value of a valid substring
                  DecimalValue:
                  add $s7, $s7, $zero                       # The sum in the $s7 register is the decimal value
                  add $sp, $t5, $zero                       # Move $sp to start of substring to unload substring from stack
                  sw $s7, 0($sp)                            # Store decimal value of the substring to the stack
                  sub $sp, $sp, 4                           # Move $sp to validate other bytes in the word
                  jr $t8                                    # Return to SubprogramA





      # SubprogramC is used to convert the string characters to their corresponding decimal values, treating each character as a base-N number
      # Conversions done based on formula N = 26 + (X % 11) where X is my StudentID: 02805400
      # N = 30 so valid range is from 'a' to 't' or 'A' to 'T'
      # Characters '0' to '9' correspond to a decimal value of 0 to 9 respectively
      # Characters 'a' to 't' correspond to a decimal value of 10 to 29 respectively
      # Characters 'A' to 'T' correspond to a decimal value of 10 to 29 respectively
      # All other characters are out of range and correspond to a decimal value 0
      # Register $a0 contains current character in the string
      SubprogramC:
      add $t2, $zero, $a0                       # Copy character at $a0 to temporary register $t2
      addi $t3, $zero, 87                       # Load $t3 with reference value 87 (ascii value of 'a' - 10) for conversion
      bgt $t2, 't', InvalidSubstr               # If current character is greater than 't', it is out of range
      bge $t2, 'a', Return1                     # If current character is between 'a' and 't', go to Return1 to convert
      addi $t3, $zero, 55                       # Change reference value to 55 for uppercase characters
      bgt $t2, 'T', InvalidSubstr               # If current character is greater than 'T', it is out of range. Go to InvalidSubstr
      bge $t2, 'A', Return1                     # If current character is between 'A' and 'T', go to Return1 to convert
      addi $t3, $zero, 48                       # Change reference value to 48 for numbers
      bgt $t2, '9', InvalidSubstr               # If current character is greater than '9' it is out of range. Go to InvalidSubstr
      bge $t2, '0', Return1                     # If current char is between '0' and '9', go to Return1 to convert
      blt $t2, '0', InvalidSubstr               # For all other characters out of the range, go to InvalidSubstr

                # This subroutine calculates the decimal value of the character
                # The result is returned in $v0
                Return1:
                sub $v0, $t2, $t3         # Subtract the the reference value in $t3 from the character's 1-byte ascii value
                jr $ra                    # Return the decimal value in $v1 to Loop6
