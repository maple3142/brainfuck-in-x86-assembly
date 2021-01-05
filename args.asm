.data
arguments_buffer BYTE 1000 DUP(0)
tmp DWORD ?
.code
GetArgs PROC, argv:PTR DWORD
    ; Write arguments to argv char array and return argc through eax
    call GetCommandLine
    mov ecx, 0
    mov edi, OFFSET arguments_buffer
    mov edx, argv
LP: mov esi, eax
    invoke Str_nextWord, eax, ' '
    jnz NOTFOUND

    ; Copy current token to edi
    dec eax
    mov bl, [eax]
    mov BYTE PTR [eax], 0
    invoke Str_copy, esi, edi
    mov [eax], bl
    inc eax

    ; If current's token is not empty string, add it to argv and increment argc
    pushad
    invoke Str_Length, edi
    mov tmp, eax
    popad
    mov ebx, tmp
    .IF ebx != 0
        mov [edx], edi
        add edx, 4
        inc ecx
    .ENDIF

    ; Increase current buffer pointer edi
    mov ebx, eax
    sub ebx, esi
    add edi, ebx

    jmp LP
NOTFOUND:
    ; Handle final token
    invoke Str_copy, esi, edi
    pushad
    invoke Str_Length, edi
    mov tmp, eax
    popad
    mov ebx, tmp
    .IF ebx != 0
        mov [edx], edi
        add edx, 4
        inc ecx
    .ENDIF

    ; Return argc through eax
    mov eax, ecx
    ret
GetArgs ENDP
