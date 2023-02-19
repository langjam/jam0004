use lhs_core::runtime;
use yew::{html, Component};

use crate::cell::Cell;

pub struct Memory<const N: usize>(runtime::Memory<N>);

impl<const N: usize> Memory<N> {
    pub fn new() -> Self {
        Self(runtime::Memory::default())
    }
}

impl<const N: usize> Component for Memory<N> {
    type Message = ();
    type Properties = ();

    fn create(_ctx: &yew::Context<Self>) -> Self {
        Self::new()
    }

    fn view(&self, ctx: &yew::Context<Self>) -> yew::Html {
        let rows = self.0.iter().enumerate().map(|(y, row)| {
            let cells = row.iter().enumerate().map(|(x, cell)| {
                html! {
                    <Cell ident={ x } value={ *cell } />
                }
            });

            html! {
                <div key={y} class="memory-row">
                    { for cells }
                </div>
            }
        });

        html! {
            <div class="memory-container">
                <header class="memory-header">
                    <h1 class="memory-title">{ "Memory" }</h1>
                </header>
                <section class="memory-area">
                    <div class="memory">
                        { for rows }
                    </div>
                </section>
                <footer class="memory-footer">
                    <strong class="memeory-footer-text">
                      { format!(" Memory Pointer: {}", self.0.pointer).as_str() }
                    </strong>
                </footer>
            </div>
        }
    }
}
