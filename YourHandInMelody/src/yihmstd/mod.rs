use llvm_sys::support::LLVMAddSymbol;
use std::alloc::Layout;
use std::ffi::{c_void, CString};
use std::ops::AddAssign;

pub const SAMPLE_RATE: u32 = 44_100;

#[no_mangle]
extern "C" fn yhim_time_phase(time: f64, freq: f64) -> f64 {
    ((time % (1.0 / freq)) % 1.0) * std::f64::consts::TAU
}

#[no_mangle]
extern "C" fn yhim_sin(theta: f64) -> f64 {
    theta.sin()
}

#[no_mangle]
extern "C" fn yhim_cos(theta: f64) -> f64 {
    theta.cos()
}

#[derive(Clone)]
#[repr(C)]
struct Array {
    len: u64,
    buf: *mut u8,
    meta: *mut (Layout, u64),
}

#[no_mangle]
unsafe extern "C" fn yhim_newarray(len: u64, elem_sz: u64, align: u64) -> Array {
    let layout = Layout::from_size_align((len * elem_sz) as usize, align as usize).unwrap();
    let buf = std::alloc::alloc(layout);
    Array {
        len,
        buf,
        meta: Box::leak(Box::new((layout, 1u64))),
    }
}

#[no_mangle]
unsafe extern "C" fn yhim_duparray(arr: Array) {
    (*arr.meta).1 += 1;
}

#[no_mangle]
unsafe extern "C" fn yhim_droparray(arr: Array, dimensionality: u32) {
    let meta = &mut *arr.meta;
    meta.1 -= 1;
    // refcount is 0, deallocate
    if meta.1 == 0 {
        let meta = Box::from_raw(arr.meta);
        if dimensionality > 0 {
            let arr_buf = std::slice::from_raw_parts(arr.buf as *mut Array, arr.len as usize);
            for subarr in arr_buf {
                yhim_droparray(subarr.clone(), dimensionality - 1);
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
    let a_1 = (1. + azimuth) * std::f64::consts::PI / 4.0;
    let a_2 = (1. - azimuth) * std::f64::consts::PI / 4.0;
    let (s_1, c_1) = a_1.sin_cos();
    let (s_2, c_2) = a_2.sin_cos();
    let gain_left = 2f64.sqrt() * (c_1 - s_2);
    let gain_right = 2f64.sqrt() * (c_2 - s_1);
    Sample(sample.0 * gain_left, sample.1 * gain_right)
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
extern "C" fn yhim_skip(this: &mut SoundRecv, by: u64) {
    this.pos += by;
}

#[no_mangle]
extern "C" fn yhim_next(this: &mut SoundRecv) {
    yhim_skip(this, 1);
}

pub fn add_symbols() {
    macro_rules! syms {
        ($($name:ident),*) => { [$((stringify!($name), $name as *mut c_void)),*] };
    }
    for (name, ptr) in syms![
        yhim_time_phase,
        yhim_sin,
        yhim_cos,
        yhim_newarray,
        yhim_duparray,
        yhim_droparray,
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
