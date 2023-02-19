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

enum Continuation {
    Stop,
    Continue
}
fn eval_print_loop() {
    let mut heap: [u64; 256] = [0; 256];
    loop {
	let ins = INS.load(Ordering::SeqCst);
	INS.store(0, Ordering::SeqCst);

	let cont: Continuation = match ins {
	    0xFFFF => terminate(),
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
	    0xC200..=0xC2FF => jmp_if_grt(&heap, ins),
	    0xC300..=0xC3FF => jmp_if_lst(&heap, ins),
	    _ => break,
	};
	match cont {
	    Continuation::Stop => break,
	    Continuation::Continue => continue,
	};
    }
}

// 0x0000
fn processor_idle_sleep() -> Continuation {
    thread::sleep(time::Duration::from_millis(10));
    Continuation::Continue
}

fn terminate() -> Continuation {
    Continuation::Stop
}

fn zero_acc() -> Continuation {
    ACC.store(0, Ordering::SeqCst);
    Continuation::Continue
}

fn incr_acc() -> Continuation {
    ACC.fetch_add(1, Ordering::SeqCst);
    Continuation::Continue
}

fn decr_acc() -> Continuation {
    ACC.fetch_sub(1, Ordering::SeqCst);
    Continuation::Continue
}

macro_rules! acc_shift_functions {
    ($func_name:ident, $y:tt) =>
	(fn $func_name(ins:u16) -> Continuation {
	    let amount = (ins & 0x0F) + 1;
	    let old_val = ACC.load(Ordering::SeqCst);
	    let new_val = old_val $y amount;
	    ACC.store(new_val, Ordering::SeqCst);
	    Continuation::Continue
	});
}

acc_shift_functions!(lsh, <<);
acc_shift_functions!(rsh, >>);

fn bw_not_acc() -> Continuation {
    let old_acc = ACC.load(Ordering::SeqCst);
    let new_acc = !old_acc;
    ACC.store(new_acc, Ordering::SeqCst);
    Continuation::Continue
}

fn fetch_amt_from_heap(heap: &[u64; 256], ins: u16) -> u64 {
    let index: usize = (ins & 0xFF).into();
    let amount = heap[index];
    return amount;
}

fn add_to_acc(heap: &[u64; 256], ins: u16) -> Continuation {
    let amount = fetch_amt_from_heap(&heap, ins);
    ACC.fetch_add(amount, Ordering::SeqCst);
    Continuation::Continue
}

fn sub_from_acc(heap: &[u64; 256], ins: u16) -> Continuation {
    let amount = fetch_amt_from_heap(&heap, ins);
    ACC.fetch_sub(amount, Ordering::SeqCst);
    Continuation::Continue
}

fn mul_to_acc(heap: &[u64; 256], ins: u16) -> Continuation {
    let amount = fetch_amt_from_heap(&heap, ins);
    let old_acc = ACC.load(Ordering::SeqCst);
    let new_acc = old_acc.wrapping_mul(amount);
    ACC.store(new_acc, Ordering::SeqCst);
    Continuation::Continue
}

fn div_acc(heap: &[u64; 256], ins: u16) -> Continuation {
    let amount = fetch_amt_from_heap(&heap, ins);
    let old_acc = ACC.load(Ordering::SeqCst);
    if old_acc % amount == 0 {
	ACC.store(old_acc/amount, Ordering::SeqCst);
    } else {
	ACC.store(0, Ordering::SeqCst);
    }
    Continuation::Continue
}

macro_rules! make_bin_bw_function {
    ($func_name:ident, $op:tt) =>
	(fn $func_name(heap: &[u64; 256], ins: u16) -> Continuation {
	    let index: usize = (ins & 0xFF).into();
	    let mem_val = heap[index];
	    let old_acc = ACC.load(Ordering::SeqCst);
	    let new_acc = old_acc $op mem_val;
	    ACC.store(new_acc, Ordering::SeqCst);
	    Continuation::Continue
    });
}

make_bin_bw_function!(bw_and_acc, &);
make_bin_bw_function!(bw_xor_acc, ^);
make_bin_bw_function!(bw_ior_acc, |);

fn write_acc(heap:&mut [u64; 256], ins: u16) -> Continuation {
    let index: usize = (ins & 0xFF).into();
    heap[index] = ACC.load(Ordering::SeqCst);
    Continuation::Continue
}

fn write_acc_all(heap:&mut [u64; 256]) -> Continuation {
    for index in 0..0xFF {
	write_acc(heap, index);
    }
    Continuation::Continue
}

fn set_ins(heap: &[u64; 256], ins: u16) -> Continuation {
    let index: usize = (ins & 0xFF).into();
    let value: u16 = (heap[index] & 0xFFFF) as u16;
    INS.store(value, Ordering::SeqCst);
    Continuation::Continue
}

fn deferred_jam_instruction(ins: u16) {
    std::thread::spawn( move || {
	let mut cycles = 10;
	while INS.load(Ordering::SeqCst) != 0 {
	    // Wait for reset
	    cycles -= 1; // Lol deadlock
	    thread::sleep(time::Duration::from_millis(3));
	    if cycles == 0 {
		break;
	    }
	}
	INS.store(ins, Ordering::SeqCst);
    });
}

fn set_ins_and_jam(heap: &[u64; 256], ins: u16) -> Continuation {
    set_ins(heap, ins);
    if ins != 0xBBFF {
	let next_inst = ((ins & 0x00FF) | 0xBA00) + 1;
	deferred_jam_instruction(next_inst);
    }
    Continuation::Continue
}

fn set_ins_and_jam_conditional(heap: &[u64; 256], ins: u16) -> Continuation {
    set_ins(heap, ins);
    let index: usize = (ins & 0xFF).into();
    let next_addr = (heap[index] & 0xFF0000) >> 16;
    let next_instr = (0xBC00 | next_addr) as u16;
    if next_addr > 0 {
	deferred_jam_instruction(next_instr);
    }
    Continuation::Continue
}

fn jmp_if_eq(heap: &[u64; 256], ins: u16, test: bool) -> Continuation {
    if (ACC.load(Ordering::SeqCst) == 0) == test {
	set_ins(heap, ins);
    }
    Continuation::Continue
}

macro_rules! jmp_if_cmp {
    ($func_name: ident, $cmp: tt) =>
	
	(fn $func_name(heap: &[u64; 256], ins: u16) -> Continuation {
	    let index: usize = (ins & 0xFF).into();
	    if (ACC.load(Ordering::SeqCst) $cmp heap[index]) {
		if index < 0xFF {
		    INS.store((0xFFFF & heap[index+1]) as u16, Ordering::SeqCst);
		}
	    } else {
		if index < 0xFE {
		    INS.store((0xFFFF & heap[index+2]) as u16, Ordering::SeqCst);
		}
	    }
	    Continuation::Continue
	});
}

jmp_if_cmp!(jmp_if_grt, >);
jmp_if_cmp!(jmp_if_lst, <);

