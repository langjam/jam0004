pub mod memory;

use wasm_bindgen::prelude::wasm_bindgen;
use yew::{html, Html};

use crate::memory::Memory;

#[wasm_bindgen(start)]
pub fn entry() {
    yew::Renderer::<App>::new().render();
}

#[yew::function_component(App)]
pub fn app() -> Html {
    html! {
        <div class="application">
            <section class="app-header">
                <h1 class="app-title">{ "left hand side" }</h1>
                // <h2 class="app-subtitle">{ "a five digit state machine utilizing only the left half of your keyboard" }</h2>
                <h2 class="app-subtitle">
                    { "by " }
                    <a href="https://github.com/xiuxiu62">{ "xiuxiu62" }</a>
                </h2>
            </section>
            <section class="app-body">
                <Memory<8> />
            </section>
            <footer class="app-footer">
                <h2 class="app-footer-text">{ "a five digit state machine utilizing only the left half of your keyboard" }</h2>
            </footer>
        </div>
    }
}

pub mod cell {
    use yew::{html, Component, Properties};

    pub enum Message {
        Toggle,
    }

    #[derive(PartialEq, Properties)]
    pub struct Props {
        #[prop_or_default]
        pub ident: usize,
        #[prop_or_default]
        pub value: u8,
    }

    pub struct Cell {
        pub value: u8,
        pub active: bool,
    }

    impl Component for Cell {
        type Message = Message;
        type Properties = Props;

        fn create(ctx: &yew::Context<Self>) -> Self {
            Self {
                value: ctx.props().value,
                active: false,
            }
        }

        fn view(&self, ctx: &yew::Context<Self>) -> yew::Html {
            html! {
                <div key={ ctx.props().ident } class="memory-cell">
                    // { ctx.props().value }
                    { self.value }
                </div>
            }
        }
    }
}
