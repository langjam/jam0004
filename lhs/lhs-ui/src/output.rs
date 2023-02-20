use crate::machine::MachineRef;
use gloo::console;
use std::io::Write;
use wasm_bindgen::UnwrapThrowExt;
use web_sys::HtmlTextAreaElement;
use yew::{function_component, html, use_context, use_node_ref, Callback, Html, NodeRef};

#[derive(Debug, Default, PartialEq)]
pub struct ConsoleWriter(Option<NodeRef>);

impl AsRef<Option<NodeRef>> for ConsoleWriter {
    fn as_ref(&self) -> &Option<NodeRef> {
        &self.0
    }
}

impl Write for ConsoleWriter {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        console::log!("here");
        let console = self
            .0
            .clone()
            .unwrap_throw()
            .cast::<HtmlTextAreaElement>()
            .unwrap_throw();
        console.set_value(format!("{}{}", console.value(), buf[0] as char).as_str());

        Ok(1)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        Ok(())
    }
}

#[function_component(OutputConsole)]
pub fn output_console() -> Html {
    let console_ref = use_node_ref();
    let machine_ref = use_context::<MachineRef>().unwrap_throw();

    // initialize writer node_ref
    machine_ref.clone().borrow_mut().writer.0 = Some(console_ref.clone());

    let console = console_ref.clone();
    let clear = Callback::from(move |_| {
        console
            .cast::<HtmlTextAreaElement>()
            .unwrap_throw()
            .set_value("");
    });

    html! {
        <div class="machine-component">
            <div class="console-container">
                <header class="machine-component-header">
                    <h1 class="machine-component-title">{ "Output" }</h1>
                </header>
                <textarea class="console" id="output-console" rows="40" cols="50" readonly=true wrap="soft" spellcheck="false" ref={ console_ref } />
                <div class="console-button-container">
                    <button class="console-button" onclick={ clear }>{ "clear" }</button>
                </div>
            </div>
        </div>
    }
}
