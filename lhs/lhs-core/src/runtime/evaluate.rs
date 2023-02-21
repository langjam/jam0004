/*

Map:

z: equals, stack pointer deref == memory pointer deref
x: not equals, stack pointer deref != memory pointer deref


*/

// use super::Machine;

use super::{Machine, Program};
use crate::language::{Instruction, Move};
use std::{io::Write, mem};

impl<W: Write, const M: usize, const S: usize> Machine<W, M, S> {
    pub fn evaluate_expression(&mut self, program: &Program, expression: &[Instruction]) {
        if let Some(instruction) = expression.first() {
            match *instruction {
                Instruction::Count(n) => {
                    self.evaluate_count(program, n, expression);
                    return;
                }
                Instruction::Move(direction) => self.evaluate_move(direction),
                Instruction::Fetch => self.evaluate_fetch(),
                Instruction::Give => self.evaluate_give(),
                Instruction::Copy => self.evaluate_copy(),
                Instruction::Void => self.evaluate_void(),
                Instruction::Increment => self.evaluate_increment(),
                Instruction::Decrement => self.evaluate_decrement(),
                Instruction::Equal => self.evaluate_equals(program, expression),
                Instruction::NotEqual => self.evaluate_not_equals(program, expression),
                Instruction::To => self.evaluate_to(program),
                Instruction::Read => self.evaluate_read(),
                Instruction::Brrr => {
                    self.evaluate_brrr(program, expression);
                    return;
                }
                Instruction::Nop => unreachable!("we've already cleaned our program of Nops"),
            }
        }

        // evaluate rest of expression if there is any
        if expression.len() > 1 {
            self.evaluate_expression(program, &expression[1..]);
        }
    }

    fn evaluate_count(&mut self, program: &Program, count: usize, expression: &[Instruction]) {
        if expression.len() > 1 {
            (0..count).for_each(|_| self.evaluate_expression(program, &expression[1..]))
        }
    }

    fn evaluate_move(&mut self, direction: Move) {
        match direction {
            Move::Up => match self.memory.pointer {
                n if n < M => self.memory.pointer = self.memory.capacity - n - 2,
                _ => self.memory.pointer -= M,
            },
            Move::Down => match self.memory.pointer {
                n if n + M > self.memory.capacity - 1 => {
                    self.memory.pointer = self.memory.capacity - n - 2
                }
                _ => self.memory.pointer += M,
            },
            Move::Left => match self.memory.pointer {
                0 => self.memory.pointer = self.memory.capacity - 1,
                _ => self.memory.pointer -= 1,
            },
            Move::Right => match self.memory.pointer {
                n if n == self.memory.capacity - 1 => self.memory.pointer = 0,
                _ => self.memory.pointer += 1,
            },
        };
    }

    fn evaluate_decrement(&mut self) {
        *self.memory.current_mut() = self.memory.current().saturating_sub(1);
    }

    fn evaluate_increment(&mut self) {
        *self.memory.current_mut() = self.memory.current().saturating_add(1);
    }

    fn evaluate_fetch(&mut self) {
        *self.memory.current_mut() = mem::take(self.stack.current_mut());
        self.stack.pointer = self.stack.pointer.saturating_sub(1);
    }

    fn evaluate_give(&mut self) {
        *self.stack.current_mut() = mem::take(self.memory.current_mut());
        if self.stack.pointer < self.stack.capacity {
            self.stack.pointer += 1;
        }
    }

    fn evaluate_equals(&mut self, program: &Program, expression: &[Instruction]) {
        if self.memory.current() == self.stack.current() && expression.len() > 1 {
            self.evaluate_expression(program, &expression[1..]);
        }
    }

    fn evaluate_not_equals(&mut self, program: &Program, expression: &[Instruction]) {
        if self.memory.current() != self.stack.current() && expression.len() > 1 {
            self.evaluate_expression(program, &expression[1..]);
        }
    }

    fn evaluate_copy(&mut self) {
        *self.stack.current_mut() = *self.memory.current();
        if self.stack.pointer < self.stack.capacity {
            self.stack.pointer += 1;
        }
    }

    fn evaluate_void(&mut self) {
        *self.stack.current_mut() = 0;
    }

    // Moves program counter to the top value of the stack, moving to the end of the program if the value is not less than the program length
    fn evaluate_to(&mut self, program: &Program) {
        let program_index = mem::take(self.stack.current_mut()) as usize;
        self.stack.pointer = self.stack.pointer.saturating_sub(1);

        let program_len = program.len();
        match program_index {
            i if i < program_len => self.program_counter = i,
            _ => self.program_counter = program_len - 1,
        };
    }

    // TODO: make generic over a Writer
    fn evaluate_read(&mut self) {
        let value = *self.memory.current() as char;

        print!("{value}");
    }

    fn evaluate_brrr(&mut self, program: &Program, expression: &[Instruction]) {
        let iterations = mem::take(self.stack.previous_mut()) as usize;
        self.stack.pointer = self.stack.pointer.saturating_sub(1);

        if expression.len() > 1 {
            (0..iterations).for_each(|_| self.evaluate_expression(program, &expression[1..]))
        }
    }
}
