use colored::Colorize;
use llvm_sys::support::LLVMAddSymbol;
use std::alloc::Layout;
use std::f64::consts::{PI, TAU};
use std::ffi::{c_void, CString};
use std::ops::AddAssign;
use std::process::exit;

pub const SAMPLE_RATE: u32 = 44_100;

#[no_mangle]
extern "C" fn yhim_time_phase(time: f64, freq: f64) -> f64 {
    ((time * freq) % 1.) * TAU
}

#[no_mangle]
extern "C" fn yhim_sin(theta: f64) -> f64 {
    theta.sin()
}

#[no_mangle]
extern "C" fn yhim_cos(theta: f64) -> f64 {
    theta.cos()
}

#[no_mangle]
extern "C" fn yhim_exp(x: f64) -> f64 {
    x.exp()
}

#[no_mangle]
extern "C" fn yhim_sqrt(x: f64) -> f64 {
    x.sqrt()
}

#[no_mangle]
extern "C" fn yhim_ln(x: f64) -> f64 {
    x.ln()
}

#[no_mangle]
extern "C" fn yhim_log(x: f64, base: f64) -> f64 {
    x.log(base)
}

#[no_mangle]
extern "C" fn yhim_pow(base: f64, x: f64) -> f64 {
    base.powf(x)
}

#[derive(Clone)]
#[repr(C)]
struct Array {
    len: u64,
    buf: *mut u8,
    meta: *mut (Layout, u64),
}

#[no_mangle]
unsafe extern "C" fn yhim_newarray(ret: *mut Array, len: u64, elem_sz: u64, align: u64) {
    if let Ok(layout) = Layout::from_size_align((len * elem_sz) as usize, align as usize) {
        let buf = std::alloc::alloc(layout);
        ret.write(Array {
            len,
            buf,
            meta: Box::leak(Box::new((layout, 1u64))),
        })
    } else {
        eprintln!("{}: could not allocate array", "fatal error".red().bold());
        exit(1)
    }
}

#[no_mangle]
unsafe extern "C" fn yhim_duparray(arr: &Array) {
    (*arr.meta).1 += 1;
}

#[no_mangle]
unsafe extern "C" fn yhim_droparray(arr: &Array, dimensionality: u32) {
    let meta = &mut *arr.meta;
    meta.1 -= 1;
    // refcount is 0, deallocate
    if meta.1 == 0 {
        let meta = Box::from_raw(arr.meta);
        if dimensionality > 0 {
            let arr_buf = std::slice::from_raw_parts(arr.buf as *mut Array, arr.len as usize);
            for subarr in arr_buf {
                yhim_droparray(subarr, dimensionality - 1);
            }
            std::mem::forget(arr_buf);
        }
        std::alloc::dealloc(arr.buf, (*meta).0);
    }
}

#[repr(C)]
#[derive(Copy, Clone)]
pub struct Sample(pub f64, pub f64);

impl AddAssign for Sample {
    fn add_assign(&mut self, rhs: Self) {
        self.0 += rhs.0;
        self.1 += rhs.1;
    }
}

#[repr(C)]
#[derive(Clone)]
pub struct SoundRecv {
    pos: u64,
    buf: *mut Vec<Sample>,
}

impl SoundRecv {
    pub fn new() -> Self {
        Self {
            pos: 0,
            buf: Box::leak(Box::new(Vec::new())),
        }
    }

    pub unsafe fn into_buf(self) -> Vec<Sample> {
        *Box::from_raw(self.buf)
    }
}

#[no_mangle]
unsafe extern "C" fn yhim_pan(sample: Sample, azimuth: f64) -> Sample {
    let a_1 = (1. + azimuth) * PI / 4.0;
    let a_2 = (1. - azimuth) * PI / 4.0;
    let (s_1, c_1) = a_1.sin_cos();
    let (s_2, c_2) = a_2.sin_cos();
    let a_left = 1. + 2f64.sqrt() * (c_1 - s_1);
    let a_right = 1. + 2f64.sqrt() * (c_2 - s_2);
    Sample(sample.0 * a_left, sample.1 * a_right)
}

#[no_mangle]
unsafe extern "C" fn yhim_mix(this: &mut SoundRecv, sample: Sample) {
    let buf = &mut *this.buf;
    if this.pos as usize >= buf.len() {
        buf.reserve(this.pos as usize - buf.len() + 32);
        buf.resize(this.pos as usize + 32, Sample(0.0, 0.0));
    }
    buf[this.pos as usize] += sample;
}

#[no_mangle]
extern "C" fn yhim_dbg(f: f64) -> f64 {
    println!("{}", f);
    f
}

#[no_mangle]
extern "C" fn yhim_min(x: f64, y: f64) -> f64 {
    x.min(y)
}

#[no_mangle]
extern "C" fn yhim_max(x: f64, y: f64) -> f64 {
    x.max(y)
}

#[no_mangle]
extern "C" fn yhim_choose(p: bool, x: f64, y: f64) -> f64 {
    if p {
        x
    } else {
        y
    }
}

#[no_mangle]
extern "C" fn yhim_skip(this: &mut SoundRecv, by: f64) {
    this.pos += by as u64;
}

#[no_mangle]
extern "C" fn yhim_next(this: &mut SoundRecv) {
    this.pos += 1;
}

pub fn add_symbols() {
    macro_rules! syms {
        ($($name:ident),*) => { [$((stringify!($name), $name as *mut c_void)),*] };
    }
    for (name, ptr) in syms![
        yhim_time_phase,
        yhim_sin,
        yhim_cos,
        yhim_exp,
        yhim_sqrt,
        yhim_dbg,
        yhim_newarray,
        yhim_duparray,
        yhim_droparray,
        yhim_min,
        yhim_max,
        yhim_choose,
        yhim_pan,
        yhim_mix,
        yhim_skip,
        yhim_next
    ] {
        unsafe {
            let name = CString::new(name).unwrap();
            LLVMAddSymbol(name.as_ptr(), ptr);
        }
    }
}
