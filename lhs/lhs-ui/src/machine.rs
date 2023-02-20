use crate::{
    input::InputConsole,
    memory::Memory,
    output::{ConsoleWriter, OutputConsole},
    stack::Stack,
};
use gloo::{console, timers::callback::Interval};
use lhs_core::runtime::{self, Program};
use std::{cell::RefCell, rc::Rc};
use wasm_bindgen::UnwrapThrowExt;
use web_sys::HtmlTextAreaElement;
use yew::{function_component, html, use_state, Callback, ContextProvider, Html};

pub type MachineRef = Rc<RefCell<runtime::Machine<ConsoleWriter, 8, 8>>>;

#[function_component(Machine)]
pub fn machine() -> Html {
    let machine = Rc::new(RefCell::new(runtime::Machine::<ConsoleWriter, 8, 8>::new(
        ConsoleWriter::default(),
    )));

    let machine_clone = machine.clone();
    let run_program =
        Callback::from(move |program: Program| machine_clone.borrow_mut().run(&program));

    html! {
        <ContextProvider<MachineRef> context={machine}>
            <InputConsole run_program={run_program} />
                    <section class="machine-component">
                        <div class="machine-data-container">
                            <Memory />
                            <Stack />
                        </div>
                    </section>
            <OutputConsole />
        </ContextProvider<MachineRef>>
    }
}
