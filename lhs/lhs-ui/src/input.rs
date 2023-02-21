use lhs_core::runtime::Program;
use wasm_bindgen::UnwrapThrowExt;
use web_sys::HtmlTextAreaElement;
use yew::{function_component, html, use_node_ref, Callback, Html, Properties};

#[derive(PartialEq, Properties)]
pub struct Props {
    #[prop_or_default]
    pub run_program: Callback<Program>,
}

#[function_component(InputConsole)]
pub fn input_console(props: &Props) -> Html {
    // let machine = use_context::<MachineRef>().unwrap_throw();
    // TODO: move into parent context
    let input_console_ref = use_node_ref();

    // let machine_clone = machine.clone();
    let input_console = input_console_ref.clone();
    let run_program = props.run_program.clone();
    let submit = Callback::from(move |_| {
        let source = input_console
            .cast::<HtmlTextAreaElement>()
            .unwrap_throw()
            .value();
        let program = Program::try_from(&source).unwrap_throw();
        run_program.emit(program);
    });

    let input_console = input_console_ref.clone();
    let clear = Callback::from(move |_| {
        input_console
            .cast::<HtmlTextAreaElement>()
            .unwrap_throw()
            .set_value("")
    });

    html! {
        <div class="machine-component">
            <div class="console-container">
                <header class="machine-component-header">
                    <h1 class="machine-component-title">{ "Input" }</h1>
                </header>
                <textarea class="console" id="input-console" rows="40" cols="50" placeholder="code goes here" wrap="soft" spellcheck="false" ref={ input_console_ref } />
                <div class="console-button-container">
                    <button class="console-button" onclick={ submit }>{ "submit" }</button>
                    <button class="console-button" onclick={ clear }>{ "clear" }</button>
                </div>
            </div>
        </div>
    }
}
