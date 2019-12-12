# MIPSproject3
This MIPS program reads a string of up to 1000 characters from a user's input. 

# Steps: 
1. With a single comma as the delimiter, split the input string into multiple substrings (with the comma removed). If there is no comma in the input, the whole input string is considered a substring referred to below.
2. For each substring, remove the leading and trailing blank spaces and tab characters if any. After that
  - If the substring has zero characters or more than 4 characters or has at least one illegal character (a character outside the set described below), the program prints the message of "NaN".
  - If the substring has only the characters from '0' to '9' and from 'a'to β and from'A'to Δ, the program prints out the unsigned decimal integer corresponding to the base-N number represented by the substring. β stands for the M-th lower case letter and Δ stands for the M-th upper case letter in the English alphabet. In a base-N number, both 'a' and 'A' correspond to the decimal integer of 10, both 'b' and 'B' to 11, and so on, and both β and Δ correspond to N – 1.
  - If there are multiple substring,the numbers and the error message should be separated by a single comma.

# Requirements: 
1. The program must exit after processing one single user input.
2. The processing of the whole input string must be done in a subprogram (Subprogram A).
   The main program must call Subprogram A and pass the whole input string (not the memory address) into it via the stack. Subprogram A must return the integers and error messages (or indication of errors) corresponding to the substring back to the main program via the stack. The main program then prints out the integers and error messages one by one, with them separated by a single comma.
3. When processing each substring, Subprogram A must call another subprogram (subprogram B), where the whole substring (not the memory address) is passed into Subprogram B via the stack, and the decimal number is returned also via stack.
4. Subprogram B must call another subprogram (Subprogram C) to convert a single valid character to a decimal integer. The character should be passed to Subprogram C via the register $a0 and the integer must be returned via the register $v0.
5. The program must use one or more loops to process the characters in the user input, instead of producing multiple segments of similar code with each segment processing one single character.

# This program ran successfully in both QtSpim and MARS. 
