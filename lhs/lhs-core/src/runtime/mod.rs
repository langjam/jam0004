mod error;
mod evaluate;
pub mod machine;
pub mod memory;
pub mod stack;

pub use machine::{Machine, Program};
pub use memory::Memory;
pub use stack::Stack;
