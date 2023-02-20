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
            <div key={ ctx.props().ident }>
                // { ctx.props().value }
                { self.value }
            </div>
        }
    }
}
