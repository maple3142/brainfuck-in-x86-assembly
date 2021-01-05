.data
CurrentCell BYTE "Cell: ", 0
CurrentCellValue BYTE "Value: ", 0
.code
executeBrainfuck PROC, bf_input:PTR BYTE, bf_cells:PTR BYTE, bf_jmptbl:PTR DWORD
	; Execute program given input, cells and jump table
	mov esi, bf_input
	mov edi, bf_cells ; ptr
	jmp bf_execution_loop_cond
bf_execution_loop:
	; Process instruction
	.IF al == '>'
		inc edi ; ptr++
	.ELSEIF al == '<'
		dec edi ; ptr--
	.ELSEIF al == '+'
		; ++*ptr
		mov bl, [edi]
		inc bl
		mov [edi], bl
	.ELSEIF al == '-'
		; --*ptr
		mov bl, [edi]
		dec bl
		mov [edi], bl
	.ELSEIF al == ','
		; *ptr = getchar()
		push eax
		call ReadChar
		mov [edi], al
		pop eax
	.ELSEIF al == '.'
		; putchar(*ptr)
		push eax
		mov al, [edi]
		call Stdout_WriteChar
		pop eax
	.ELSEIF al == '['
		; while(*ptr) {
		mov bl, [edi]
		.IF bl == 0
			; esi = bf_jmptbl[esi-bf_input]
			mov ebx, esi
			sub ebx, bf_input
			shl ebx, 2
			add ebx, bf_jmptbl
			mov esi, [ebx]
		.ENDIF
	.ELSEIF al == ']'
		; }
		mov bl, [edi]
		.IF bl != 0
			; esi = bf_jmptbl[esi-bf_input]
			mov ebx, esi
			sub ebx, bf_input
			shl ebx, 2
			add ebx, bf_jmptbl
			mov esi, [ebx]
		.ENDIF
	.ELSEIF al == '#' ; Extension
		; printf("%d", *ptr)
		push eax
		xor eax, eax
		mov al, [edi]
		call Stdout_WriteDec
		pop eax
	.ELSEIF al == '!' ; Extension
		; Print current cell and its value like "Cell: index Value: value"
		pushad
		call Stdout_Crlf
		invoke Stdout_WriteString, OFFSET CurrentCell
		mov eax, edi
		sub eax, bf_cells
		call Stdout_WriteDec
		mov eax, 20h
		call Stdout_WriteChar
		invoke Stdout_WriteString, OFFSET CurrentCellValue
		xor eax, eax
		mov al, [edi]
		call Stdout_WriteDec
		call Stdout_Crlf
		popad
	.ELSEIF al == '@' ; Extension
		; Jump to current cell address
		jmp edi
	.ENDIF
	inc esi
bf_execution_loop_cond:
	mov al, [esi]
	cmp al, 0
	jne bf_execution_loop
	ret
executeBrainfuck ENDP
buildJumpTable PROC, bf_input:PTR BYTE, bf_jmptbl:PTR DWORD
	; Build jump table so that it is easier to jump between '[' and ']' token
	mov esi, bf_input
	jmp jmp_table_loop_cond
jmp_table_loop:
	.IF al == '['
		push esi
	.ELSEIF al == ']'
		pop ebx

		; Check for the stack before hand, or it will crash the program
		cmp ebp, esp
		jb jmp_table_end ; If ebp < esp means stack underflows

		; bf_jmptbl[stack.top()-bf_input] = esi
		mov ecx, ebx
		sub ecx, bf_input
		shl ecx, 2
		add ecx, bf_jmptbl
		mov [ecx], esi

		; bf_jmptbl[esi-bf_input] = stack.top()
		mov ecx, esi
		sub ecx, bf_input
		shl ecx, 2
		add ecx, bf_jmptbl
		mov [ecx], ebx
	.ENDIF
	inc esi
jmp_table_loop_cond:
	mov al, [esi]
	cmp al, 0
	jne jmp_table_loop
jmp_table_end:
	cmp ebp, esp ; ZF=1 if number of '[' and ']' are matched
	ret
buildJumpTable ENDP
