# A brainfuck interpreter written in x86 assembly for Windows

## Build

Run `make.bat`.

## Usage

`brainfuck.exe <run|convert> <file name>`

`run` will execute the brainfuck file.

`convert` will transform it into C source code.

## Extensions

Other than standard 8 symbols in traditional Brainfuck, there are 3 more symbols added.

* `#`: Print current cell value in decimal.
* `!`: Print debug info like `Cell: 1 Value: 2`
* `@`: Jump to current pointer (move `eip` directly to execute shellcode)
