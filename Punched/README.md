# punched

Made using python 3.11 and pygame as described in requirements.txt.

Steps:
1. install python
2. create virtual env: python -m venv venv
3. source into the virtual env: (windows) .\venv\Scripts\Activate.ps1
4. pip install -r requirements.txt
5. python punched.py

Programs are saved as "tape.txt" (if this actually works 😄).

Limited testing has been performed. Like very limited. I entered text, then exited. 

Made within 4 hours during an afternoon.

# Documentation

An infinite roll of tape that has one instruction per cell.

Each cell is 2 bytes long.

The instruction is encoded by 2 bytes.

To advance the roll of tape, press 'Tab'.

To reverse the roll of tape, press 'Shift-Tab'.

To execute the current instruction, press 'Ctrl-R'.

To exit, press 'Esc'.

To reset, press 'Ctrl-Shift-Q'.

To jump to the beginning, press 'Ctrl-Tab'.

To jump to the end, press 'Ctrl-Shift-Tab'.

To jump to a specific cell, press 'Ctrl-G'.
 - This will prompt you for a cell number.

To enter a decimal number to be converted to hex, press 'Ctrl-E'.

To run the whole program, press 'Ctrl-Shift-R'.

To save the program, press 'Ctrl-S'.

To load a program, press 'Ctrl-D'.

To cancel the execution of a program, press 'Ctrl-C'.

The instruction set of the program is as follows:

0: Halt
1: Increment
2: Decrement
3: Jump forward
4: Jump backward
5: Jump to beginning
6: Jump to end
7: Jump to cell
8: Print
9: Print as hex
10: Print as decimal
11: Print as ascii
12: Print as binary
13: Print as octal
14: Print as character
15: Print as string

The program will automatically advance the tape after each instruction when being run.

To enter a hex number, press 'Shift-X' and then enter a character from the following lookup table:

1: 0, 2: 1, 3: 2, 4: 3,
q: 4, w: 5, e: 6, r: 7,
a: 8, s: 9, d: a, f: b,
z: c, x: d, c: e, v: f

When entering a decimal number, press 'Ctrl-E' and then enter a character from the following lookup table:

1. 1, 2: 2, 3: 3,
q: 4, w: 5, e: 6,
a: 7, s: 8, d: 9,
z: 0
