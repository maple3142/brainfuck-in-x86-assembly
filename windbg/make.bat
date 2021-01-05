@echo off
REM make
REM Assembles and links the 32-bit ASM program into .exe which can be used by WinDBG
REM Uses MicroSoft Macro Assembler version 6.11 and 32-bit Incremental Linker version 5.10.7303
REM Created by Huang 

REM delete related files
del lab1.lst	REM lab1可以替換成.asm檔的檔名
del lab1.obj
del lab1.ilk
del lab1.pdb
del lab1.exe

setlocal 
set INCLUDE=C:\WINdbgFolder\;	REM 這裡要設成WINdbgFolder的路徑
set LIB=C:\WINdbgFolder\;
set PATH=C:\WINdbgFolder\;

REM /c          assemble without linking
REM /coff       generate object code to be linked into flat memory model 
REM /Zi         generate symbolic debugging information for WinDBG
REM /Fl		Generate a listing file
 

ML /c /coff /Zi   lab1.asm
if errorlevel 1 goto terminate

REM /debug              generate symbolic debugging information
REM /subsystem:console  generate console application code
REM /entry:start        entry point from WinDBG to the program 
REM                           the entry point of the program must be _start

REM /out:%1.exe         output %1.exe code
REM %1.obj              input %1.obj
REM Kernel32.lib        library procedures to be invoked from the program
REM irvine32.lib
REM user32.lib

LINK /INCREMENTAL:no /debug /subsystem:console /entry:start /out:lab1.exe lab1.obj Kernel32.lib irvine32.lib user32.lib
if errorlevel 1 goto terminate

REM Display all files related to this program:
DIR lab1.*

:terminate
pause
endlocal