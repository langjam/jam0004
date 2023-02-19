"""
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

"""

from enum import Enum
import pygame
from multiprocessing import Process

class WindowState(Enum):
    EXITING = 0
    JUMPING = 1
    ENTERING_HEX = 2
    ENTERING_DEC = 3
    DISPLAYING = 4
    EXECUTING = 5
    

tape = [0]
current_cell = 0
entering_text = ""
proc = None

hex_lookup = {
    '1': 0, '2': 1, '3': 2, '4': 3,
    'q': 4, 'w': 5, 'e': 6, 'r': 7,
    'a': 8, 's': 9, 'd': 10, 'f': 11,
    'z': 12, 'x': 13, 'c': 14, 'v': 15
}

dec_lookup = {
    '1': 1, '2': 2, '3': 3,
    'q': 4, 'w': 5, 'e': 6,
    'a': 7, 's': 8, 'd': 9,
    'z': 0
}

def verify_cell(contents: int) -> bool:
    if contents < 0 or contents > 255:
        return False
    return True

def run_program(tape, current_cell):
    while True:
        # Execute the current instruction
        instruction = tape[current_cell]
        execute(instruction)

def execute(instruction):
    if instruction == 0:
        # Halt
        return WindowState.EXITING
    elif instruction == 1:
        # Increment
        tape[current_cell] += 1
        return WindowState.DISPLAYING
    elif instruction == 2:
        # Decrement
        tape[current_cell] -= 1
        return WindowState.DISPLAYING
    elif instruction == 3:
        # Jump forward
        current_cell += 1
        if current_cell >= len(tape):
            tape.append(0)
        return WindowState.DISPLAYING
    elif instruction == 4:
        # Jump backward
        current_cell -= 1
        return WindowState.DISPLAYING
    elif instruction == 5:
        # Jump to beginning
        current_cell = 0
        return WindowState.DISPLAYING
    elif instruction == 6:
        # Jump to end
        current_cell = len(tape) - 1
        return WindowState.DISPLAYING
    elif instruction == 7:
        # Jump to cell
        current_cell = tape[current_cell + 1]
        return WindowState.DISPLAYING
    elif instruction == 8:
        # Print
        print(tape[current_cell])
        return WindowState.DISPLAYING
    elif instruction == 9:
        # Print as hex
        print(hex(tape[current_cell]))
        return WindowState.DISPLAYING
    elif instruction == 10:
        # Print as decimal
        print(tape[current_cell])
        return WindowState.DISPLAYING
    elif instruction == 11:
        # Print as ascii
        print(chr(tape[current_cell]))
        return WindowState.DISPLAYING
    elif instruction == 12:
        # Print as binary
        print(bin(tape[current_cell]))
        return WindowState.DISPLAYING
    elif instruction == 13:
        # Print as octal
        print(oct(tape[current_cell]))
        return WindowState.DISPLAYING
    elif instruction == 14:
        # Print as character
        print(chr(tape[current_cell]))
        return WindowState.DISPLAYING
    elif instruction == 15:
        # Print as string
        string = ""
        i = current_cell + 1
        while tape[i] != 0:
            string += chr(tape[i])
            i += 1

def handle_input(state) -> WindowState:
    global tape, current_cell, proc, entering_text

    mods = pygame.key.get_mods()
    
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            return WindowState.EXITING

        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                return WindowState.EXITING
        
            elif event.key == pygame.K_TAB:
                if state == WindowState.DISPLAYING:
                    if mods and mods & pygame.KMOD_SHIFT:
                        # Retract the tape
                        if current_cell > 0:
                            current_cell -= 1
                        return WindowState.DISPLAYING
                    else: 
                        # Advance the tape
                        current_cell += 1
                        if current_cell >= len(tape):
                            tape.append(0)
                        return WindowState.DISPLAYING
                elif state == WindowState.ENTERING_HEX:
                    tape[current_cell] = int(entering_text, 16)
                    return WindowState.DISPLAYING
                elif state == WindowState.ENTERING_DEC:
                    tape[current_cell] = int(entering_text)
                    return WindowState.DISPLAYING
            
            elif event.key == pygame.K_g:
                if mods and mods & pygame.KMOD_CTRL:
                    entering_text = ""
                    return WindowState.JUMPING
                
            elif event.key == pygame.K_e:
                if mods and mods & pygame.KMOD_CTRL:
                    entering_text = ""
                    return WindowState.ENTERING_DEC
            
            elif event.key == pygame.K_r:
                if mods and mods & pygame.KMOD_CTRL:
                    if mods and mods & pygame.KMOD_SHIFT:
                        # Run the program
                        proc = Process(target=run_program, args=(tape, current_cell))
                        proc.start()
                        return WindowState.EXECUTING
                    else:
                        # Execute the current instruction
                        instruction = tape[current_cell]
                        execute(instruction)
                        

            elif event.key == pygame.K_q:
                if mods and mods & pygame.KMOD_CTRL:
                    if mods and mods & pygame.KMOD_SHIFT:
                        # Exit
                        return WindowState.EXITING
                    else:
                        # Reset
                        tape = [0]
                        current_cell = 0
                        return WindowState.DISPLAYING

            elif event.key == pygame.K_s:
                if mods and mods & pygame.KMOD_CTRL:
                    # Save
                    with open("tape.txt", "w") as f:
                        for cell in tape:
                            f.write(str(cell) + "\n")

            elif event.key == pygame.K_d:
                if mods and mods & pygame.KMOD_CTRL:
                    # Load
                    with open("tape.txt", "r") as f:
                        tape = [int(cell) for cell in f.readlines()]
            
            elif event.key == pygame.K_c:
                if mods and mods & pygame.KMOD_CTRL:
                    # Cancel the execution of the program
                    proc.terminate()
                    return WindowState.DISPLAYING

            elif event.key == pygame.K_x:
                if mods and mods & pygame.KMOD_SHIFT:
                    # enter a hex value from the lookup table
                    entering_text = ""
                    return WindowState.ENTERING_HEX

            if state == WindowState.ENTERING_HEX:
                if len(entering_text) < 4:
                    entering_text += str(hex_lookup[event.unicode])
                else:
                    tape[current_cell] = int(entering_text, 16)
                    return WindowState.DISPLAYING
                
                return WindowState.ENTERING_HEX
            
            elif state == WindowState.ENTERING_DEC:
                if int(entering_text + str(event.unicode)) < 256:
                    entering_text += str(dec_lookup[event.unicode])
                else:
                    tape[current_cell] = int(entering_text)
                    return WindowState.DISPLAYING
                
    return state



def draw_cell(state: WindowState, screen, bg_color=(0, 0, 0), fg_color=(255, 255, 255)):
    global tape, current_cell, entering_text

    screen.fill(bg_color)
    font = pygame.font.SysFont("monospace", 100)

    
    if state == WindowState.ENTERING_HEX or state == WindowState.ENTERING_DEC:
        label = font.render(entering_text, 1, fg_color)
    elif state == WindowState.DISPLAYING:
        label = font.render(hex(current_cell)[2:], 1, fg_color)
    else:
        label = font.render("BYE", 1, fg_color)

    screen.blit(label, (10, 10))
    pygame.display.update()

    
    



if __name__=="__main__":
    state = WindowState.DISPLAYING

    background_color = (0, 0, 0)
    (width, height) = (300, 200)

    pygame.init()

    screen = pygame.display.set_mode((width, height))
    pygame.display.set_caption("Punched Tape")
    screen.fill(background_color)

    pygame.display.flip()

    
    while state != WindowState.EXITING:
        state = handle_input(state)
        draw_cell(state, screen)
        if proc is not None:
            if not proc.is_alive():
                proc = None
                state = WindowState.DISPLAYING
            proc.join(0.1)
    
    pygame.quit()