use std::thread;
use std::time;
use std::sync::atomic::{AtomicU16, AtomicU64, Ordering};

fn main() {
    eval_print_loop();
}

//// Op codes:
//// 0000 -> Idle, loop endlessly.
//// FFFF -> Break, terminate.

static ACC: AtomicU64 = AtomicU64::new(0);
static INS: AtomicU16 = AtomicU16::new(0);

fn eval_print_loop() {
    let mut heap: [u64; 256] = [0; 256];
    loop {
	let ins = INS.load(Ordering::SeqCst);
	INS.store(0, Ordering::SeqCst);

	match ins {
	    0x0000 => processor_idle_sleep(),
	    0xA000 => zero_acc(),
	    0xA001 => incr_acc(),
	    0xA002 => decr_acc(),
	    0xA010..=0xA01F => lsh(ins),
	    0xA020..=0xA02F => rsh(ins),
	    0xA030 => bw_not_acc(),
	    0xA100..=0xA1FF => add_to_acc(&heap, ins),
	    0xA200..=0xA2FF => sub_from_acc(&heap, ins),
	    0xA300..=0xA3FF => mul_to_acc(&heap, ins),
	    0xA400..=0xA4FF => div_acc(&heap, ins),
	    0xA600..=0xA6FF => bw_and_acc(&heap, ins),
	    0xA700..=0xA7FF => bw_xor_acc(&heap, ins),
	    0xA800..=0xA8FF => bw_ior_acc(&heap, ins),
	    0xAA00..=0xAAFF => write_acc(&mut heap, ins),
	    0xAB00 => write_acc_all(&mut heap),
	    0xBA00..=0xBAFF => set_ins(& heap, ins),
	    0xBB00..=0xBBFF => set_ins_and_jam(&heap, ins),
	    0xBC00..=0xBCFF => set_ins_and_jam_conditional(&heap, ins),
	    0xC000..=0xC0FF => jmp_if_eq(&heap, ins, true),
	    0xC100..=0xC1FF => jmp_if_eq(&heap, ins, false),
	    0xFFFF => break,
	    _ => break,
	}
    }
}

// 0x0000
fn processor_idle_sleep() {
    thread::sleep(time::Duration::from_millis(10));
}

fn zero_acc() {
    ACC.store(0, Ordering::SeqCst);
}

fn incr_acc() {
    ACC.fetch_add(1, Ordering::SeqCst);
}

fn decr_acc() {
    ACC.fetch_sub(1, Ordering::SeqCst);
}

macro_rules! acc_shift_functions {
    ($func_name:ident, $y:tt) =>
	(fn $func_name(ins:u16) {
	    let amount = (ins & 0x0F) + 1;
	    let old_val = ACC.load(Ordering::SeqCst);
	    let new_val = old_val $y amount;
	    ACC.store(new_val, Ordering::SeqCst);
	});
}

acc_shift_functions!(lsh, <<);
acc_shift_functions!(rsh, >>);

fn bw_not_acc() {
    let old_acc = ACC.load(Ordering::SeqCst);
    let new_acc = !old_acc;
    ACC.store(new_acc, Ordering::SeqCst);
}

fn fetch_amt_from_heap(heap: &[u64; 256], ins: u16) -> u64 {
    let index: usize = (ins & 0xFF).into();
    let amount = heap[index];
    return amount;
}

fn add_to_acc(heap: &[u64; 256], ins: u16) {
    let amount = fetch_amt_from_heap(&heap, ins);
    ACC.fetch_add(amount, Ordering::SeqCst);
}

fn sub_from_acc(heap: &[u64; 256], ins: u16) {
    let amount = fetch_amt_from_heap(&heap, ins);
    ACC.fetch_sub(amount, Ordering::SeqCst);
}

fn mul_to_acc(heap: &[u64; 256], ins: u16) {
    let amount = fetch_amt_from_heap(&heap, ins);
    let old_acc = ACC.load(Ordering::SeqCst);
    let new_acc = old_acc.wrapping_mul(amount);
    ACC.store(new_acc, Ordering::SeqCst);
}

fn div_acc(heap: &[u64; 256], ins: u16) {
    let amount = fetch_amt_from_heap(&heap, ins);
    let old_acc = ACC.load(Ordering::SeqCst);
    if old_acc % amount == 0 {
	ACC.store(old_acc/amount, Ordering::SeqCst);
    } else {
	ACC.store(0, Ordering::SeqCst)
    }
}

macro_rules! make_bin_bw_function {
    ($func_name:ident, $op:tt) =>
	(fn $func_name(heap: &[u64; 256], ins: u16) {
	    let index: usize = (ins & 0xFF).into();
	    let mem_val = heap[index];
	    let old_acc = ACC.load(Ordering::SeqCst);
	    let new_acc = old_acc $op mem_val;
	    ACC.store(new_acc, Ordering::SeqCst);
    });
}

make_bin_bw_function!(bw_and_acc, &);
make_bin_bw_function!(bw_xor_acc, ^);
make_bin_bw_function!(bw_ior_acc, |);

fn write_acc(heap:&mut [u64; 256], ins: u16) {
    let index: usize = (ins & 0xFF).into();
    heap[index] = ACC.load(Ordering::SeqCst); 
}

fn write_acc_all(heap:&mut [u64; 256]) {
    for index in 0..0xFF {
	let acc_value = ACC.load(Ordering::SeqCst);
	heap[index] = acc_value;
    }
}

fn set_ins(heap: &[u64; 256], ins: u16) {
    let index: usize = (ins & 0xFF).into();
    let value: u16 = (heap[index] & 0xFFFF) as u16;
    INS.store(value, Ordering::SeqCst); 
}

fn deferred_jam_instruction(ins: u16) {
    std::thread::spawn( move || {
	while INS.load(Ordering::SeqCst) != 0 {
	    // Wait for reset
	    thread::sleep(time::Duration::from_millis(10));
	}
	INS.store(ins, Ordering::SeqCst);
    });
}

fn set_ins_and_jam(heap: &[u64; 256], ins: u16) {
    set_ins(heap, ins);
    if ins != 0xBBFF {
	deferred_jam_instruction(ins + 1);
    }
}

fn set_ins_and_jam_conditional(heap: &[u64; 256], ins: u16) {
    set_ins(heap, ins);
    let index: usize = (ins & 0xFF).into();
    let next_addr = (heap[index] & 0xFF0000) >> 16;
    let next_instr = (0xBC00 | next_addr) as u16;
    if next_addr > 0 {
	deferred_jam_instruction(next_instr);
    }
}

fn jmp_if_eq(heap: &[u64; 256], ins: u16, test: bool) {
    if (ACC.load(Ordering::SeqCst) == 0) == test {
	set_ins(heap, ins);
    }
}
