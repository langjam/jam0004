use std::{cell::RefCell, rc::Rc};
use wasm_bindgen::{closure::Closure, JsCast};
use web_sys::{HtmlCanvasElement, WebGlRenderingContext as GL};
use yew::{html, Html, NodeRef, Properties};

#[derive(PartialEq, Properties)]
pub struct TileProperties {
    pub value: String,
}

pub struct Tile {
    node_ref: NodeRef,
}

impl yew::Component for Tile {
    type Message = ();
    type Properties = ();

    fn create(_ctx: &yew::Context<Self>) -> Self {
        Self {
            node_ref: NodeRef::default(),
        }
    }

    fn view(&self, _ctx: &yew::Context<Self>) -> Html {
        html! {
            <canvas class="tile" ref={ self.node_ref.clone() } fillText={ "hello" } />
        }
    }

    fn rendered(&mut self, _ctx: &yew::Context<Self>, first_render: bool) {
        if !first_render {
            return;
        }

        let canvas = self.node_ref.cast::<HtmlCanvasElement>().unwrap();
        let gl: GL = canvas
            .get_context("webgl")
            .unwrap()
            .unwrap()
            .dyn_into()
            .unwrap();
        Self::render_gl(gl);
    }

    // fn update(&mut self, ctx: &yew::Context<Self>, msg: Self::Message) -> bool {
    //     true
    // }

    // fn changed(&mut self, ctx: &yew::Context<Self>, _old_props: &Self::Properties) -> bool {
    //     true
    // }

    // fn prepare_state(&self) -> Option<String> {
    //     None
    // }

    // fn destroy(&mut self, ctx: &yew::Context<Self>) {}
}

impl Tile {
    fn request_animation_frame(f: &Closure<dyn FnMut()>) {
        web_sys::window()
            .unwrap()
            .request_animation_frame(f.as_ref().unchecked_ref())
            .expect("should register `requestAnimationFrame` OK");
    }

    fn render_gl(gl: GL) {
        // This should log only once -- not once per frame

        let mut timestamp = 0.0;

        let vert_code = include_str!("../shaders/basic.vert");
        let frag_code = include_str!("../shaders/basic.frag");

        // This list of vertices will draw two triangles to cover the entire canvas.
        let vertices: Vec<f32> = vec![
            -0.5, -1.0, 0.5, -1.0, -0.5, 1.0, -0.5, 1.0, 0.5, -1.0, 0.5, 1.0,
        ];
        let vertex_buffer = gl.create_buffer().unwrap();
        let verts = js_sys::Float32Array::from(vertices.as_slice());

        gl.bind_buffer(GL::ARRAY_BUFFER, Some(&vertex_buffer));
        gl.buffer_data_with_array_buffer_view(GL::ARRAY_BUFFER, &verts, GL::STATIC_DRAW);

        let vert_shader = gl.create_shader(GL::VERTEX_SHADER).unwrap();
        gl.shader_source(&vert_shader, vert_code);
        gl.compile_shader(&vert_shader);

        let frag_shader = gl.create_shader(GL::FRAGMENT_SHADER).unwrap();
        gl.shader_source(&frag_shader, frag_code);
        gl.compile_shader(&frag_shader);

        let shader_program = gl.create_program().unwrap();
        gl.attach_shader(&shader_program, &vert_shader);
        gl.attach_shader(&shader_program, &frag_shader);
        gl.link_program(&shader_program);

        gl.use_program(Some(&shader_program));

        // Attach the position vector as an attribute for the GL context.
        let position = gl.get_attrib_location(&shader_program, "a_position") as u32;
        gl.vertex_attrib_pointer_with_i32(position, 2, GL::FLOAT, false, 0, 0);
        gl.enable_vertex_attrib_array(position);

        // Attach the time as a uniform for the GL context.
        let time = gl.get_uniform_location(&shader_program, "u_time");
        gl.uniform1f(time.as_ref(), timestamp as f32);

        gl.draw_arrays(GL::TRIANGLES, 0, 6);

        // Gloo-render's request_animation_frame has this extra closure
        // wrapping logic running every frame, unnecessary cost.
        // Here constructing the wrapped closure just once.

        let cb = Rc::new(RefCell::new(None));
        *cb.borrow_mut() = Some(Closure::wrap(Box::new({
            let cb = cb.clone();
            move || {
                // This should repeat every frame
                timestamp += 20.0;
                gl.uniform1f(time.as_ref(), timestamp as f32);
                gl.draw_arrays(GL::TRIANGLES, 0, 6);
                Self::request_animation_frame(cb.borrow().as_ref().unwrap());
            }
        }) as Box<dyn FnMut()>));

        Self::request_animation_frame(cb.borrow().as_ref().unwrap());
    }
}
