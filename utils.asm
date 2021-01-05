.data
stdout HANDLE ?
pBytesWritten DWORD ?
oneByteStr BYTE ?,0
writeDecStr BYTE 20 DUP(0)

.code
Str_nextWord PROC USES ebx ecx edx esi edi, pStr:PTR BYTE, delimiter:BYTE
	; Find next delimiter in pStr, and return the pointer in eax, whether it is found or not in zf
	invoke Str_Length, pStr
	mov ecx, eax
	mov edi, pStr
	mov al, delimiter
	cld
	repne scasb ; ne=nz
	jnz NOTFOUND ; if it continues to end, zf is not set
	mov eax, edi ; if found, zf is set
	ret
NOTFOUND:
	ret
Str_nextWord ENDP

; Stdout_* functions is to replace WriteString, as it doesn't support piping to files
Stdout_Init PROC
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov stdout, eax
	ret
Stdout_Init ENDP

Stdout_close PROC
	mov eax, stdout
	invoke CloseHandle, eax
	ret
Stdout_close ENDP

Stdout_WriteString PROC, s:PTR BYTE
	pushad
	invoke Str_Length, s
	invoke WriteFile, stdout, s, eax, OFFSET pBytesWritten, 0
	popad
	ret
Stdout_WriteString ENDP

mStdout_WriteString MACRO s
	invoke Stdout_WriteString, s
ENDM

Stdout_WriteChar PROC
	; char from al
	mov [oneByteStr], al
	invoke Stdout_WriteString, OFFSET oneByteStr
	ret
Stdout_WriteChar ENDP

Stdout_Crlf PROC
	; print crlf
	mov [oneByteStr], 0ah
	invoke Stdout_WriteString, OFFSET oneByteStr
	ret
Stdout_Crlf ENDP

Stdout_WriteDec PROC
	; eax as input, print an integer
	pushad
	mov edi, OFFSET writeDecStr
	mov ebx, eax ; Backup eax
	
	; Special case: eax == 0
	.IF eax == 0
		inc edi
		mov dl, 0
		mov [edi], dl
		dec edi
		mov dl, '0'
		mov [edi], dl
		jmp write_dec_end_print
	.ENDIF

	; Move edi to the end of the digits
	jmp move_buf_end_condition
move_buf_end_loop:
	; eax = eax / 10
	xor edx, edx
	mov ecx, 10
	div ecx
	inc edi
move_buf_end_condition:
	cmp eax, 0 ; while(eax != 0)
	jne move_buf_end_loop

	; Write null byte
	mov dl, 0
	mov [edi], dl

	mov eax, ebx ; Restore

	; Using modulo and convert digits to ascii, and filling digits from the back
	jmp write_dec_condition
write_dec_loop:
	xor edx, edx
	mov ecx, 10
	div ecx ; edx:eax -> eax ... edx
	or dl, 30h ; num -> ascii char
	mov [edi], dl
	dec edi
write_dec_condition:
	cmp eax, 0
	jne write_dec_loop
	inc edi
write_dec_end_print:
	invoke Stdout_WriteString, edi
	popad
	ret
Stdout_WriteDec ENDP
