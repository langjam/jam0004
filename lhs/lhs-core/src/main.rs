pub mod language;
pub mod runtime;
pub mod util;

use runtime::{Machine, Program};
use std::io::{self, Stdout, Write};

const BASE: u32 = 5;
const TITLE: &str = r#"
    =
  = = =
= = = =
= = = =  =
= = = = ==
=========
= LHS ==
=======

Left Hand Side
by: xiuxiu62

try running:
5454e d5451e d5413e d5413e d5421e d5112e d5434e d5421e d5424e d5413e d5455e d5525e 
d22e g 22a brd
"#;

const HELP: &str = r#"
help:  prints this message
view:  display the virtual machine
reset: resets vm state
clear: clears the screen
exit:  exits the repl
"#;
fn main() -> io::Result<()> {
    let mut machine: Machine<Stdout, 8, 8> = Machine::default();
    let stdin = io::stdin();
    let mut stdout = machine.writer.lock();

    println!("{TITLE}");

    loop {
        let mut line = String::new();

        print!("> ");
        stdout.flush()?;
        stdin.read_line(&mut line)?;
        line = line
            .chars()
            .filter(|char| *char != '\n' && *char != '\r')
            .collect();

        match line.as_str() {
            "help" => println!("{HELP}"),
            "view" => println!("{machine}"),
            "reset" => machine = Machine::default(),
            "clear" => clear_screen(),
            "exit" => {
                clear_screen();

                break;
            }
            source => match Program::try_from(source) {
                Ok(program) => machine.run(&program),
                Err(err) => println!("Failed to run program: `{err}`"),
            },
        }
    }

    Ok(())
}

fn clear_screen() {
    print!("{esc}c", esc = 27 as char);
}
