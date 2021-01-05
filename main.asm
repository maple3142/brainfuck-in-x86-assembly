TITLE Brainfuck

; Constants
max_prog_size = 100000
max_cells_size = 10000

; Includes
INCLUDE Irvine32.inc
INCLUDE utils.asm
INCLUDE args.asm
INCLUDE bf.asm
INCLUDE convert.asm

main EQU start@0

.stack 8192

executeBrainfuck PROTO, bf_input:PTR BYTE, bf_cells:PTR BYTE, bf_jmptbl:PTR DWORD
buildJumpTable PROTO, bf_input:PTR BYTE, bf_jmptbl:PTR DWORD

.data
numProgram DWORD 0
program BYTE max_prog_size DUP(0)
cells BYTE max_cells_size DUP (0)
jmptbl DWORD max_prog_size DUP (0)
argc DWORD 1
argv DWORD 20 DUP(?)
FILE_NOT_FOUND BYTE "File not found: ", 0
PROG_HELP_MSG BYTE "Usage: brainfuck.exe <run|convert> <File name>", 10, 0
UNKNOWN_ACTION BYTE "Unknown action: ",0
PAREN_NOT_MATCHED BYTE "There are unmatched pairs of '[' and ']' in source code.",0
RUN BYTE "run",0
CONVERT BYTE "convert",0
mode BYTE 0 ; 1 = run, 2 = convert, other = error

.code
main PROC
	call Stdout_Init
	; Initializing argc and argv
	invoke GetArgs, ADDR argv
	mov argc, eax

	.IF argc >= 3
		; Determine if argv[1] is valid or not
		mov edx, (OFFSET argv)+4
		mov edx, [edx]
COMPARE_RUN:
		invoke Str_compare, edx, ADDR RUN
		jne COMPARE_CONVERT
		mov mode, 1
		jmp ACTION_MATCHED
COMPARE_CONVERT:
		invoke Str_compare, edx, ADDR CONVERT
		jne NOMATCH
		mov mode, 2
		jmp ACTION_MATCHED
NOMATCH:
		; Print help message when first argument is not correct
		mStdout_WriteString OFFSET UNKNOWN_ACTION
		mStdout_WriteString edx
		jmp CLEANUP_AND_EXIT
ACTION_MATCHED:
		; Take argv[2] as file input
		mov edx, (OFFSET argv)+8
		mov edx, [edx]
		invoke CreateFile, edx, GENERIC_READ, DO_NOT_SHARE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
		.IF eax == INVALID_HANDLE_VALUE
			; When file can't be opened
			mStdout_WriteString OFFSET FILE_NOT_FOUND
			mov edx, (OFFSET argv)+8
			mov edx, [edx]
			mStdout_WriteString edx
			jmp CLEANUP_AND_EXIT
		.ENDIF
		; Read file to program and close it
		invoke ReadFile, eax, ADDR program, max_prog_size, ADDR numProgram, 0
		invoke CloseHandle, eax
	.ELSE
		; Print help message when there are no enough arguments
		mStdout_WriteString OFFSET PROG_HELP_MSG
		jmp CLEANUP_AND_EXIT
	.ENDIF

	invoke buildJumpTable, ADDR program, ADDR jmptbl
	je PAREN_MATCHED
	mStdout_WriteString OFFSET PAREN_NOT_MATCHED
	jmp CLEANUP_AND_EXIT
PAREN_MATCHED:
	.IF mode == 1
		; Running brainfuck program
		invoke executeBrainfuck, ADDR program, ADDR cells, ADDR jmptbl
	.ELSEIF mode == 2
		; Convert brainfuck to c
		invoke convertBrainfuckToC, ADDR program
	.ENDIF
CLEANUP_AND_EXIT:
	call Stdout_Close
	exit
main ENDP
END main
