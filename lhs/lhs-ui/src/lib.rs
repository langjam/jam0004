mod cell;
mod input;
pub mod machine;
mod memory;
mod output;
mod stack;

use machine::Machine;
use wasm_bindgen::prelude::wasm_bindgen;
use yew::{function_component, html, Html};

#[wasm_bindgen(start)]
pub fn entry() {
    yew::Renderer::<App>::new().render();
}

#[yew::function_component(App)]
pub fn app() -> Html {
    html! {
        <div>
            <Header />
            <Machine />
        </div>
    }
}

#[function_component(Header)]
fn header() -> Html {
    html! {
        <section class="app-header">
            <h1 class="app-title">
                <a href="https://github.com/xiuxiu62/lhs">
                    { "left hand side" }
                </a>
            </h1>
            <h2 class="app-subtitle">
                { "by " }
                <a href="https://github.com/xiuxiu62">{ "xiuxiu62" }</a>
            </h2>
        </section>
    }
}
