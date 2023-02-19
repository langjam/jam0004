use yew::{html, Component, Html, Properties};

#[derive(PartialEq, Properties)]
pub struct TileProperties {
    pub value: scrabble_core::tile::Tile,
}

pub struct Tile;

impl Component for Tile {
    type Message = ();
    type Properties = TileProperties;

    fn create(_ctx: &yew::Context<Self>) -> Self {
        Self {}
    }

    fn view(&self, ctx: &yew::Context<Self>) -> Html {
        html! {
            <div class = "tile">
                { ctx.props().value.ty.to_string() }
            </div>
        }
    }
}
