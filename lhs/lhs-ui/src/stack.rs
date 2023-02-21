use crate::{cell::Cell, machine::MachineRef, output::ConsoleWriter};
use lhs_core::runtime;
use yew::{function_component, html, use_context, Component, Html};

// pub struct Stack<const N: usize>(runtime::Stack<N>);

// impl<const N: usize> Stack<N> {
//     pub fn new() -> Self {
//         Self(runtime::Stack::default())
//     }
// }

// impl<const N: usize> Component for Stack<N> {
//     type Message = ();
//     type Properties = ();

//     fn create(_ctx: &yew::Context<Self>) -> Self {
//         Self::new()
//     }

//     fn view(&self, _ctx: &yew::Context<Self>) -> yew::Html {
//         let cells = self.0.iter().enumerate().map(|(x, cell)| {
//             html! {
//                 <div class="stack-cell">
//                     <Cell ident={ x } value={ *cell } />
//                 </div>
//             }
//         });

//         html! {
//             <div class="machine-data-component">
//                 <div class="stack-container">
//                     <header class="machine-component-header">
//                         <h1 class="machine-component-title">{ "Stack" }</h1>
//                     </header>
//                     <section class="stack-area">
//                         <div class="stack">
//                             { for cells }
//                         </div>
//                     </section>
//                     <footer class="machine-data-footer">
//                         <strong class="machine-data-footer-text">
//                           { format!(" pointer: {}", self.0.pointer).as_str() }
//                         </strong>
//                     </footer>
//                 </div>
//             </div>
//         }
//     }
// }

#[function_component(Stack)]
pub fn stack() -> Html {
    // TODO: handle uninitialized machine
    // NOTE: machine may always be initialized, given it is done so in a parent node,
    //     but we need to ensure this is the case
    let machine = use_context::<MachineRef>().unwrap();
    let machine_ref = machine.borrow();
    let cells = machine_ref.stack.iter().enumerate().map(|(x, cell)| {
        html! {
            <div class="stack-cell">
                <Cell ident={ x } value={ *cell } />
            </div>
        }
    });

    html! {
        <div class="machine-data-component">
            <div class="stack-container">
                <header class="machine-component-header">
                    <h1 class="machine-component-title">{ "Stack" }</h1>
                </header>
                <section class="stack-area">
                    <div class="stack">
                        { for cells }
                    </div>
                </section>
                <footer class="machine-data-footer">
                    <strong class="machine-data-footer-text">
                      { format!(" pointer: {}", machine_ref.stack.pointer).as_str() }
                    </strong>
                </footer>
            </div>
        </div>
    }
}
