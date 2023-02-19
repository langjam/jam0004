use crate::tile::Tile;
use yew::{html, Component, Html};

// TODO: make generic over const N
pub struct Board {
    board: scrabble_core::board::Board<15>,
}

impl Component for Board {
    type Message = ();
    type Properties = ();

    fn create(_ctx: &yew::Context<Self>) -> Self {
        Self {
            board: scrabble_core::board::Board::default(),
        }
    }

    fn view<'a>(&'a self, _ctx: &yew::Context<Self>) -> Html {
        let tile_component = |value: scrabble_core::tile::Tile| html! { <Tile { value } />};
        let tiles = self
            .board
            .iter()
            .cloned()
            .map(tile_component)
            .collect::<Vec<Html>>();

        html! {
            <div class="board">
                { tiles }
            </div>
        }
    }
}
