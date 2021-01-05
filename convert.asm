.data
header BYTE "#include <stdio.h>",0ah,0ah,"unsigned char cells[10000]",3bh,0ah,"unsigned char *ptr = cells",3bh,0ah,0ah,"int main() {",0ah,0
right_move BYTE "++ptr",3bh,0
left_move BYTE "--ptr",3bh,0
increment BYTE "++*ptr",3bh,0
decrement BYTE "--*ptr",3bh,0
getchar BYTE "*ptr = getchar()",3bh,0
putchar BYTE "putchar(*ptr)",3bh,0
loop_start BYTE "while (*ptr) {",0
loop_end BYTE "}",0
print_num BYTE "printf(",22h,"%u",22h,", *ptr)",3bh,0
print_debug BYTE "printf(",22h,"\nCell: %d Value: %d\n",22h,", ptr-cells, *ptr)",3bh,0
jump_ptr BYTE "puts(",22h,"'@' is not currently supported in converted mode!",22h,")",3bh,0
footer BYTE "    return 0",3bh,0ah,"}",0ah,0
indentation BYTE "    ",0
newline BYTE 0ah,0
.code
convertBrainfuckToC PROC, bf_input:PTR BYTE
    mStdout_WriteString OFFSET header
    mov edx, 1 ; Indentation level
	mov esi, bf_input
	jmp bf_conversion_loop_cond
bf_conversion_loop:
	; Process instruction
    mov bl, 0 ; Is char valid?
    .IF al == '>'
		inc bl
	.ELSEIF al == '<'
		inc bl
	.ELSEIF al == '+'
		inc bl
	.ELSEIF al == '-'
		inc bl
	.ELSEIF al == ','
		inc bl
	.ELSEIF al == '.'
		inc bl
	.ELSEIF al == '['
		inc bl
	.ELSEIF al == ']'
		inc bl
        dec edx ; ']' need to decrease indentation level before
    .ELSEIF al == '#' ; Extension
        inc bl
    .ELSEIF al == '!' ; Extension
        inc bl
	.ELSEIF al == '@' ; Extension
        inc bl
	.ENDIF

    cmp bl, 0
    je invalid_char

    mov ecx, edx
LP: mStdout_WriteString OFFSET indentation
    loop LP
	.IF al == '>'
		mStdout_WriteString OFFSET right_move
	.ELSEIF al == '<'
		mStdout_WriteString OFFSET left_move
	.ELSEIF al == '+'
		mStdout_WriteString OFFSET increment
	.ELSEIF al == '-'
		mStdout_WriteString OFFSET decrement
	.ELSEIF al == ','
		mStdout_WriteString OFFSET getchar
	.ELSEIF al == '.'
		mStdout_WriteString OFFSET putchar
	.ELSEIF al == '['
		mStdout_WriteString OFFSET loop_start
        inc edx ; ']' need to decrease indentation level after
	.ELSEIF al == ']'
		mStdout_WriteString OFFSET loop_end
    .ELSEIF al == '#' ; Extension
        mStdout_WriteString OFFSET print_num
    .ELSEIF al == '!' ; Extension
        mStdout_WriteString OFFSET print_debug
	.ELSEIF al == '@' ; Extension
		mStdout_WriteString OFFSET jump_ptr
	.ENDIF
    mStdout_WriteString OFFSET newline

invalid_char:
	inc esi
bf_conversion_loop_cond:
	mov al, [esi]
	cmp al, 0
	jne bf_conversion_loop
    mStdout_WriteString OFFSET footer
	ret
convertBrainfuckToC ENDP
