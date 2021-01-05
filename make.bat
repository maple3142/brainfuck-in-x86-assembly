@echo off

setlocal
SET ENTRY=main
SET OUTPUT=brainfuck
set INCLUDE=.\windbg\;
set LIB=.\windbg\;
set PATH=.\windbg\;

del %OUTPUT%.exe

ML /c /coff /Zi %ENTRY%.asm
if errorlevel 1 goto terminate

LINK /INCREMENTAL:no /debug /subsystem:console /entry:start /out:%ENTRY%.exe %ENTRY%.obj Kernel32.lib irvine32.lib user32.lib
if errorlevel 1 goto terminate

ren %ENTRY%.exe %OUTPUT%.exe
del /Q %ENTRY%.obj
del /Q %ENTRY%.pdb
echo Build success

:terminate
endlocal
