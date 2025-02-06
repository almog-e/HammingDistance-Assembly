.section .data
    EOS_mask:                        # Mask to identify the end of a string (null terminator).
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    .byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.section .text  
    .globl hamming_dist              # Declare hamming_dist globally to link with C.
    .globl string_len_calc
    .globl strCmpDiff
    .globl bit_count
    .type hamming_dist, @function       

# Function to compare two 16-byte chunks of strings and count the number of differing bits.
strCmpDiff:
    push %rbp
    movq %rsp, %rbp
      
    movdqu (%rdi), %xmm0             # Load 16 bytes from the first string into xmm0.
    movdqu (%rsi), %xmm1             # Load 16 bytes from the second string into xmm1.

    pcmpistrm $0b00011000, %xmm1, %xmm0  # Compare bytes and set bitmask of differences.
    movq %xmm0, %rax                 # Move the bitmask of differences to rax.
    movq %rax, %rdi                  # Pass the bitmask to bit_count.
    call bit_count                   # Count the number of differing bits.
   
    movq %rbp, %rsp
    pop %rbp
    ret                              # Return the result.

# Function to count the number of set bits (1s) in a given bitmask.
bit_count:
    push %rbp
    movq %rsp, %rbp
    xor %rcx, %rcx                  

count_loop:
    test %rax, %rax                  # Check if all bits have been processed.
    jz end                           # If zero, end the loop.
    bt $0, %rax                      # Test the least significant bit.
    jc increment                     # If the bit is set, increment the counter.               

skip_increment:
    shr $1, %rax                     # Shift right to process the next bit.
    jmp count_loop                   # Repeat the loop.              

increment:
    inc %rcx                         # Increment the bit count.
    shr $1, %rax                     # Shift right to process the next bit.
    jmp count_loop                   # Repeat the loop.               

end:
    movq %rcx, %rax                  # Store the result in rax.
    movq %rbp, %rsp
    pop %rbp
    ret                              # Return the bit count.



# Main function to calculate the Hamming distance between two strings.
hamming_dist:
    push %rbp
    movq %rsp, %rbp

    xor %rcx, %rcx                   # Initialize the difference counter to 0.
    counter_loop:
        # check for NULL
        movb (%rdi), %al                 # Load a byte from the first string.
        test %al, %al                    # Check if the byte is null.
        je add_len_string2               # If null, move to processing the second string.
        
        # check for NULL
        movb (%rsi), %bl                 # Load a byte from the second string.
        test %bl, %bl                    # Check if the byte is null.
        je add_len_string1               # If null, move to processing the first string.    

        count_difference:
            # check string 1
            push %rdi
            push %rsi
            push %rcx  
            call string_len_calc             # Calculate the string length.
            pop %rcx
            pop %rsi
            pop %rdi

            cmp $16, %rax                    # Check if the string length is greater than or equal to 16.
            jge check_s2                     # If so, process larger chunks.
            
            # Process small strings (less than 16 bytes).
            push %rdi
            push %rsi
            push %rcx  
            movq %rsi, %rdi
            call strCmpDiff                  # Compare and count differences for small chunks.
            pop %rcx
            pop %rsi
            pop %rdi

            cmp $16, %rax                   # Check if length <= 16 bytes
            jle both_small_strings          # If yes, handle both small strings

            push %rdi
            push %rsi
            push %rcx  
            call strCmpDiff                 # Compare 16-byte chunks
            pop %rcx
            pop %rsi
            pop %rdi
            addq %rax, %rcx                 # Add differences

            addq $16, %rsi                  # Advance to next 16-byte block
            movq %rsi, %rdi
            push %rcx  
            call string_len_calc            # Get remaining string length 
            pop %rcx
            addq %rax, %rcx                 # Update total differences
            jmp retNum

            both_small_strings:
                push %rdi
                push %rsi
                push %rcx  
                call strCmpDiff                 # Compare remaining small strings
                pop %rcx
                pop %rsi
                pop %rdi
                addq %rax, %rcx                 # Update total differences
                jmp retNum




            check_s2:
            push %rdi
            push %rsi
            push %rcx  
            movq %rsi, %rdi             # Set rdi to the second string
            call string_len_calc        # Calculate the length of the second string 
            pop %rcx
            pop %rsi
            pop %rdi
            
            cmp $16, %rax               # Check if length >= 16 bytes
            jge inc_pointers            # If yes, move to process 16-byte blocks

            push %rdi
            push %rsi
            push %rcx  
            call strCmpDiff             # Compare and count differences 
            pop %rcx
            pop %rsi
            pop %rdi
            addq %rax, %rcx             # Update total differences

            addq $16, %rdi              # Move to the next 16-byte block of the first string
            push %rcx  
            call string_len_calc        # Calculate the remaining string length 
            pop %rcx
            addq %rax, %rcx             # Update total differences
            jmp retNum                  # Return the result
        


        add_len_string1:
            push %rcx
            call string_len_calc        # Calculate the length of the first string 
            pop %rcx
            addq %rax, %rcx             # Update total differences
            jmp retNum

        add_len_string2:
            # get len of string 2 and add to rcx
            push %rcx
            movq %rsi, %rdi             # Set rdi to the second string
            call string_len_calc        # Calculate the length of the second string 
            pop %rcx
            addq %rax, %rcx             # Update total differences
            jmp retNum

    inc_pointers:
    push %rdi
    push %rsi
    push %rcx  
    call strCmpDiff             # Compare and count differences 
    pop %rcx
    pop %rsi
    pop %rdi
    addq %rax, %rcx             # Update total differences
    addq $16, %rdi              # Move to the next 16-byte block of the first string
    addq $16, %rsi              # Move to the next 16-byte block of the second string
    jmp counter_loop            # Continue comparing



    retNum:
    movq %rcx, %rax             # Store total differences in rax
    movq %rbp, %rsp
    pop %rbp
    ret                         # Return result


string_len_calc:
    pushq %rbp                  
    movq %rsp, %rbp            
    movq %rdi, %rsi             # Set rsi to the string to be scanned
    xorq %rcx, %rcx             # Initialize length counter to 0     

.find_null:
    cmpb $0, (%rsi)             # Check for null terminator
    je .done                    # If found, exit loop
    incq %rcx                   # Increment length counter
    incq %rsi                   # Move to the next character
    jmp .find_null              # Repeat until null terminator is found        

.done:
    movq    %rcx, %rax           
    movq %rbp, %rsp
    pop %rbp
    ret                         # Return string length


    