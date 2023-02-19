use crate::compile::llvm::{SampleTy, SoundRecvTy};
use crate::compile::Units::Dimensionless;
use crate::parser::{Block, CallExpr, Expr, Item, NoteKind, Program, Span, SrcLoc, Stmt, Token};
use crate::yihmstd::SAMPLE_RATE;
use crate::SourcedError;
use anyhow::anyhow;
use inkwell::context::ContextRef;
use inkwell::types::AnyTypeEnum;
use std::collections::{HashMap, VecDeque};
use std::fmt::{Debug, Display, Formatter};
use std::ops::{Index, IndexMut};
use std::rc::Rc;
use std::str::FromStr;

#[derive(Copy, Clone, Debug, Ord, PartialOrd, Eq, PartialEq)]
enum FuncType {
    Pure,
    Sound,
    Oscillator,
}

impl Display for FuncType {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}",
            match self {
                FuncType::Pure => "pure",
                FuncType::Sound => "sound",
                FuncType::Oscillator => "oscillator",
            }
        )
    }
}

#[derive(Clone, Debug)]
struct Func {
    ty: FuncType,
    ret_ty: Type,
    params: Vec<Param>,
    name: Rc<String>,
    registers: Vec<Type>,
    blocks: Vec<BasicBlock>,
}

impl Func {
    fn new_register(&mut self, ty: Type) -> Register {
        let ret = Register(self.registers.len());
        self.registers.push(ty);
        ret
    }

    fn new_block(&mut self) -> JumpTarget {
        let ret = JumpTarget(self.blocks.len());
        self.blocks.push(BasicBlock::default());
        ret
    }

    fn callee_ret_ty(&self) -> Type {
        match self.ty {
            FuncType::Pure => self.ret_ty.clone(),
            FuncType::Sound => Type::Unit,
            FuncType::Oscillator => Type::Sample,
        }
    }
}

impl Index<JumpTarget> for Func {
    type Output = BasicBlock;

    fn index(&self, index: JumpTarget) -> &Self::Output {
        &self.blocks[index.0]
    }
}

impl IndexMut<JumpTarget> for Func {
    fn index_mut(&mut self, index: JumpTarget) -> &mut Self::Output {
        &mut self.blocks[index.0]
    }
}

impl Index<Register> for Func {
    type Output = Type;

    fn index(&self, index: Register) -> &Self::Output {
        &self.registers[index.0]
    }
}

#[derive(Clone, Debug)]
struct Param {
    name: String,
    ty: Type,
}

#[derive(Copy, Clone, Debug)]
struct Register(usize);

#[derive(Copy, Clone, Debug)]
struct JumpTarget(usize);

#[derive(Clone, Debug)]
struct BasicBlock {
    insns: Vec<Insn>,
    jump: JumpInsn,
}

impl Default for BasicBlock {
    fn default() -> Self {
        Self {
            insns: Vec::default(),
            jump: JumpInsn::Ret(None),
        }
    }
}

#[derive(Clone, Debug)]
enum JumpInsn {
    Ret(Option<Register>),
    Br(JumpTarget),
    BrIf {
        cond: Register,
        tru: JumpTarget,
        fls: JumpTarget,
    },
}

#[derive(Clone, Debug)]
enum Insn {
    Move {
        out: Register,
        from: Register,
    },
    Call {
        out: Register,
        callee: Callee,
        args: Vec<Register>,
    },
    Const {
        out: Register,
        value: DynamicValue,
    },
    DebugInfo {
        loc: SrcLoc,
    },
}

#[derive(Clone, Debug)]
enum Callee {
    Named(Rc<String>),
    Builtin(Builtin),
}

#[derive(Clone, Debug)]
enum Builtin {
    Foreign(Foreign),
    Num2Sample,
    Phase,
    Op1(UnOp),
    Op2(BinOp),
    Cmp(Comparison),
    Inc,
    ArrayLen,
    NewArray(Type),
    ArrayRef,
}

#[derive(Copy, Clone, Debug)]
enum UnOp {
    Neg,
    Plus,
    Not,
}

#[derive(Copy, Clone, Debug)]
enum BinOp {
    Add,
    Sub,
    Mul,
    Div,
    Mod,
}

impl BinOp {
    fn logarithmise(self) -> Self {
        match self {
            BinOp::Add => BinOp::Mul,
            BinOp::Sub => BinOp::Div,
            // these shouldn't usually happen
            BinOp::Mul => self,
            BinOp::Div => self,
            BinOp::Mod => self,
        }
    }
}

#[derive(Copy, Clone, Debug)]
enum Comparison {
    Lt,
    Le,
    Gt,
    Ge,
    Eq,
    Ne,
}

#[derive(Clone, Debug)]
struct Foreign {
    name: &'static str,
    has_sound_receiver: bool,
    llvm_ty: HideDbg<for<'c> fn(&ContextRef<'c>) -> AnyTypeEnum<'c>>,
    local_ty: (Type, Vec<Type>),
}

#[derive(Copy, Clone)]
struct HideDbg<T>(pub T);

impl<T> Debug for HideDbg<T> {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "..")
    }
}

#[derive(Clone, Debug)]
enum DynamicValue {
    Number(f64),
    Integer(i64),
}

#[derive(Default, Debug)]
pub struct Compiler {
    funcs: HashMap<String, Func>,
}

struct IRBuilder {
    func: Func,
    block: JumpTarget,
    scopes: ScopeSet,
}

impl IRBuilder {
    fn block(&mut self) -> &mut BasicBlock {
        &mut self.func[self.block.clone()]
    }

    fn set_block(&mut self, target: JumpTarget) {
        self.block = target;
    }
}

struct ScopeSet(VecDeque<Scope>);

impl ScopeSet {
    fn new() -> Self {
        Self(VecDeque::from([Scope::default()]))
    }

    fn top(&mut self) -> &mut Scope {
        self.0.back_mut().unwrap()
    }

    fn push(&mut self) {
        self.0.push_back(Scope::default());
    }

    fn pop(&mut self) {
        assert!(self.0.len() > 1, "cannot pop the last scope");
        self.0.pop_back();
    }

    fn lookup(&self, ident: &Token) -> anyhow::Result<&Binding> {
        for scope in self.0.iter().rev() {
            if let Some(b) = scope.bindings.get(&ident.value) {
                return Ok(b);
            }
        }
        Err(ident
            .span()
            .err(format!("name '{}' is not defined", ident.value))
            .into())
    }
}

#[derive(Default)]
struct Scope {
    bindings: HashMap<String, Binding>,
}

impl Scope {
    fn bind(&mut self, func: &mut Func, name: impl Into<String>, ty: Type) -> Register {
        let reg = func.new_register(ty);
        self.bindings.insert(
            name.into(),
            Binding {
                register: reg.clone(),
            },
        );
        reg
    }
}

struct Binding {
    register: Register,
}

#[derive(Clone, Debug, Ord, PartialOrd, Eq, PartialEq)]
enum Type {
    Unit,

    Number(Units),

    Sample,

    Integer,
    Boolean,
    Array(Box<Self>),
}

#[derive(Copy, Clone, Debug, Ord, PartialOrd, Eq, PartialEq)]
enum Units {
    Dimensionless,

    Seconds,

    Hertz,
    Semitones,

    Decibels,
}

impl Units {
    fn apply(self, op: BinOp, rhs: Units) -> Option<Self> {
        use BinOp::*;
        use Units::*;
        match (self, op, rhs) {
            (Dimensionless, Add | Sub, Decibels) => Some(Dimensionless),
            (Hertz, Add | Sub, Semitones) => Some(Dimensionless),

            (l, Add | Sub | Mod, r) => {
                if l == r {
                    Some(l)
                } else {
                    None
                }
            }

            (l, Div, r) if l == r => Some(Dimensionless),
            (Dimensionless, Mul, o) | (o, Mul, Dimensionless) | (o, Div, Dimensionless) => Some(o),

            (Seconds, Mul, Hertz) | (Hertz, Mul, Seconds) => Some(Dimensionless),
            (Dimensionless, Div, Seconds) => Some(Hertz),
            (Dimensionless, Div, Hertz) => Some(Seconds),

            _ => None,
        }
    }

    fn name(&self) -> &'static str {
        match self {
            Dimensionless => "number",
            Units::Hertz => "hertz",
            Units::Semitones => "semitones",
            Units::Decibels => "decibels",
            Units::Seconds => "seconds",
        }
    }

    fn from_name(name: &str) -> Option<Self> {
        match name {
            "num" | "number" => Some(Dimensionless),
            "hz" | "hertz" => Some(Units::Hertz),
            "st" | "semitones" => Some(Units::Semitones),
            "dB" | "decibels" => Some(Units::Decibels),
            "s" | "secs" | "seconds" => Some(Units::Seconds),
            _ => None,
        }
    }
}

impl Display for Units {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.name())
    }
}

impl Display for Type {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        use Type::*;
        write!(
            f,
            "{}",
            match self {
                Unit => "void",
                Number(u) => u.name(),
                Boolean => "bool",
                Integer => "int",
                Sample => "sample",
                Array(of) => return write!(f, "[{}]", of),
            }
        )
    }
}

impl Type {
    pub fn is_float(&self) -> Option<bool> {
        Some(match self {
            Type::Number(_) => true,
            Type::Sample => true,
            Type::Integer => false,
            Type::Boolean => false,
            _ => None?, // NaN
        })
    }

    pub fn is_sample(&self) -> bool {
        matches!(self, Type::Sample)
    }

    pub fn is_unit(&self) -> bool {
        matches!(self, Type::Unit)
    }
}

trait LocalTypable {
    const TYPE: Type;
}

impl LocalTypable for f64 {
    const TYPE: Type = Type::Number(Dimensionless);
}

impl LocalTypable for bool {
    const TYPE: Type = Type::Boolean;
}

impl LocalTypable for SampleTy {
    const TYPE: Type = Type::Sample;
}

impl LocalTypable for () {
    const TYPE: Type = Type::Unit;
}

impl Compiler {
    fn parse_type(&self, tok: &Token) -> anyhow::Result<Type> {
        Ok(match tok.value.as_str() {
            "void" => Type::Unit,
            "sample" => Type::Sample,
            "num" => Type::Number(Dimensionless),
            s if Units::from_name(s).is_some() => Type::Number(Units::from_name(s).unwrap()),
            s => Err(tok.span().err(format!("unknown type: '{}'", s)))?,
        })
    }

    fn compile_type(&self, f_ty: FuncType, hint: Option<&Token>) -> anyhow::Result<Type> {
        use FuncType::*;
        match (f_ty, hint) {
            (Sound, h) => {
                if let Some(h) = h {
                    if h.value != "void" {
                        Err(h.span().err("'sound' function must return void"))?
                    }
                }
                Ok(Type::Unit)
            }
            (Oscillator, h) => {
                if let Some(h) = h {
                    if h.value != "sample" {
                        Err(h.span().err("'oscillator' function must return a sample"))?
                    }
                }
                Ok(Type::Sample)
            }
            (Pure, None) => Ok(Type::Unit),
            (Pure, Some(h)) => Ok(self.parse_type(h)?),
        }
    }

    pub fn pre_compile(&mut self, program: &Program) -> anyhow::Result<()> {
        for item in &program.items {
            match item {
                Item::Func {
                    name,
                    ty: f_ty,
                    params,
                    ret_ty,
                    ..
                } => {
                    let name = name.value.to_owned();
                    let ty = match f_ty.value.as_str() {
                        "pure" => FuncType::Pure,
                        "oscillator" => FuncType::Oscillator,
                        "sound" => FuncType::Sound,
                        _ => Err(f_ty.span().err(
                            "Invalid function type, must be one of: 'pure', 'oscillator', 'sound'",
                        ))?,
                    };
                    self.funcs.insert(
                        name.clone(),
                        Func {
                            name: Rc::new(name),
                            registers: Vec::new(),
                            blocks: Vec::new(),
                            ty,
                            ret_ty: self.compile_type(ty, ret_ty.as_ref())?,
                            params: params
                                .iter()
                                .map(|it| {
                                    self.parse_type(&it.ty).map(|ty| Param {
                                        name: it.name.value.clone(),
                                        ty,
                                    })
                                })
                                .collect::<Result<Vec<_>, _>>()?,
                        },
                    );
                }
            }
        }
        Ok(())
    }

    pub fn compile(&mut self, program: &Program) -> anyhow::Result<()> {
        for item in &program.items {
            #[allow(unused_variables)]
            match item {
                Item::Func {
                    name, body, params, ..
                } => {
                    macro_rules! get_func {
                        () => {
                            self.funcs
                                .get_mut(&name.value)
                                .ok_or_else(|| anyhow!("func missing, you forgot to precompile"))?
                        };
                    }
                    let mut func = get_func!().clone();
                    assert!(func.registers.is_empty());
                    func.blocks.push(BasicBlock::default());
                    let mut scopes = ScopeSet::new();
                    for param in params {
                        scopes.top().bind(
                            &mut func,
                            &param.name.value,
                            self.parse_type(&param.ty)?,
                        );
                    }
                    let mut ib = IRBuilder {
                        func,
                        block: JumpTarget(0),
                        scopes,
                    };
                    self.compile_block(&mut ib, body)?;
                    for bb in &ib.func.blocks {
                        match &bb.jump {
                            JumpInsn::Ret(expr) => {
                                let expr_ty = expr
                                    .as_ref()
                                    .map(|it| ib.func[it.clone()].clone())
                                    .unwrap_or(Type::Unit);
                                if ib.func.ret_ty != expr_ty {
                                    Err(body
                                        .t_delims
                                        .1
                                        .span()
                                        .err("non-void function with no return")
                                        .note(NoteKind::Note, format!(
                                            "'{}' is a{} {} function, and must return a value of type: {}",
                                            ib.func.name,
                                            if matches!(ib.func.ty, FuncType::Oscillator) { "n" } else { "" },
                                            ib.func.ty,
                                            ib.func.ret_ty
                                        )))?
                                }
                            }
                            _ => {}
                        }
                    }
                    *get_func!() = ib.func;
                }
            }
        }
        Ok(())
    }

    fn compile_block(&self, ib: &mut IRBuilder, block: &Block) -> anyhow::Result<()> {
        ib.scopes.push();
        let mut is_unreachable = false;
        for stmt in &block.stmts {
            if is_unreachable {
                Err(stmt.span().err("statement is unreachable"))?
            }
            ib.block().insns.push(Insn::DebugInfo {
                loc: stmt.span().start,
            });
            match stmt {
                Stmt::Let { name, val, ty, .. } => {
                    let mut expr_reg = self.compile_expr(ib, val)?;
                    let mut expr_ty = ib.func[expr_reg.clone()].clone();
                    if let Some(hinted) = ty.as_ref().map(|tok| self.parse_type(tok)).transpose()? {
                        self.coerce(ib, "type hint was", &hinted, &mut expr_reg, val)?;
                        expr_ty = hinted;
                    }
                    let let_reg = ib.scopes.top().bind(&mut ib.func, &name.value, expr_ty);
                    ib.block().insns.push(Insn::Move {
                        out: let_reg,
                        from: expr_reg,
                    });
                }
                Stmt::Set { name, val, .. } => {
                    let mut expr_reg = self.compile_expr(ib, val)?;
                    let binding = ib.scopes.lookup(name)?;
                    let out = binding.register.clone();
                    let binding_type = ib.func[binding.register.clone()].clone();
                    let expr_type = &ib.func[expr_reg.clone()];
                    if &binding_type != expr_type {
                        self.coerce(ib, "variable has type", &binding_type, &mut expr_reg, val)?;
                    }
                    ib.block().insns.push(Insn::Move {
                        out,
                        from: expr_reg,
                    })
                }
                Stmt::Return {
                    t_return, value, ..
                } => {
                    ib.block().jump = JumpInsn::Ret(if let Some(expr) = value.as_ref() {
                        let mut expr_reg = self.compile_expr(ib, expr)?;
                        let expr_ty = ib.func[expr_reg.clone()].clone();
                        if expr_ty != ib.func.ret_ty {
                            self.coerce(
                                ib,
                                "function has return type",
                                &ib.func.ret_ty.clone(),
                                &mut expr_reg,
                                expr,
                            )?;
                        }
                        Some(expr_reg)
                    } else {
                        if ib.func.ret_ty != Type::Unit {
                            Err(t_return.span().err("void return in non-void function"))?
                        }
                        None
                    });
                    is_unreachable = true;
                }
                Stmt::Call(ce) => {
                    self.compile_call(ib, ce, None)?;
                }
                Stmt::For {
                    name,
                    iter,
                    block,
                    hint,
                    ..
                } => {
                    let iter_reg = self.compile_expr(ib, iter)?;
                    let component = match &ib.func[iter_reg.clone()] {
                        Type::Array(ty) => Type::to_owned(ty),
                        ty => Err(iter
                            .span()
                            .err(format!("cannot iterate over type: {}", ty))
                            .note(NoteKind::Note, "for loop target must be an array"))?,
                    };
                    ib.scopes.push();
                    let component_reg = ib.func.new_register(component.clone());
                    let bound =
                        ib.scopes
                            .top()
                            .bind(&mut ib.func, name.value.as_str(), component.clone());
                    let loop_var = ib.func.new_register(Type::Integer);
                    let array_len = ib.func.new_register(Type::Integer);
                    ib.block().insns.push(Insn::Const {
                        out: loop_var,
                        value: DynamicValue::Integer(0),
                    });
                    ib.block().insns.push(Insn::Call {
                        out: array_len,
                        callee: Callee::Builtin(Builtin::ArrayLen),
                        args: vec![iter_reg.clone()],
                    });
                    let cond = ib.func.new_register(Type::Boolean);

                    let pred_block = ib.func.new_block();
                    let body_block = ib.func.new_block();
                    let cont_block = ib.func.new_block();

                    ib.block().jump = JumpInsn::Br(pred_block);

                    ib.set_block(pred_block);
                    ib.block().insns.push(Insn::Call {
                        out: cond,
                        callee: Callee::Builtin(Builtin::Cmp(Comparison::Lt)),
                        args: vec![loop_var, array_len],
                    });
                    ib.block().jump = JumpInsn::BrIf {
                        cond,
                        tru: body_block,
                        fls: cont_block,
                    };

                    ib.set_block(body_block);
                    ib.block().insns.push(Insn::Call {
                        out: component_reg,
                        callee: Callee::Builtin(Builtin::ArrayRef),
                        args: vec![iter_reg, loop_var],
                    });
                    let mut coerced_reg = component_reg;
                    if let Some(hinted) =
                        hint.as_ref().map(|tok| self.parse_type(tok)).transpose()?
                    {
                        self.coerce(ib, "type hint was", &hinted, &mut coerced_reg, iter)?;
                    }
                    ib.block().insns.push(Insn::Move {
                        out: bound,
                        from: coerced_reg,
                    });
                    self.compile_block(ib, block)?;
                    ib.block().insns.push(Insn::Call {
                        out: loop_var,
                        callee: Callee::Builtin(Builtin::Inc),
                        args: vec![],
                    });
                    ib.block().jump = JumpInsn::Br(pred_block);

                    ib.set_block(cont_block);
                    ib.scopes.pop();
                }
                Stmt::Do {
                    name,
                    init,
                    step,
                    cond,
                    block,
                    ..
                } => {
                    let init_reg = self.compile_expr(ib, init)?;

                    ib.scopes.push();
                    let loop_ty = ib.func[init_reg].clone();
                    let loop_reg = ib
                        .scopes
                        .top()
                        .bind(&mut ib.func, name.value.as_str(), loop_ty);
                    ib.block().insns.push(Insn::Move {
                        out: loop_reg,
                        from: init_reg,
                    });

                    let pred_block = ib.func.new_block();
                    let body_block = ib.func.new_block();
                    let cont_block = ib.func.new_block();

                    ib.block().jump = JumpInsn::Br(pred_block);

                    ib.set_block(pred_block);
                    ib.block().jump = JumpInsn::BrIf {
                        cond: self.compile_expr(ib, cond)?,
                        tru: body_block,
                        fls: cont_block,
                    };

                    ib.set_block(body_block);
                    self.compile_block(ib, block)?;

                    let step = self.compile_expr(ib, step)?;
                    ib.block().insns.push(Insn::Move {
                        out: loop_reg,
                        from: step,
                    });
                    ib.block().jump = JumpInsn::Br(pred_block);

                    ib.set_block(cont_block);
                    ib.scopes.pop();
                }
            }
        }
        ib.scopes.pop();
        Ok(())
    }

    fn compile_call(
        &self,
        ib: &mut IRBuilder,
        ce: &CallExpr,
        at: Option<&Expr>,
    ) -> anyhow::Result<Register> {
        let mut args = Vec::new();
        for arg in &ce.args {
            args.push(self.compile_expr(ib, arg)?);
        }
        let (ret_ty, callee, should_sample) = self.lookup_callee(ib, ce, &mut args)?;
        match (should_sample, at) {
            (true, None) => Err(ce
                .span(None)
                .err(format!(
                    "'{}' is an oscillator function and must be sampled",
                    &ce.callee.value
                ))
                .note(
                    NoteKind::Hint,
                    "add `at phase` to sample at the given phase",
                ))?,
            (false, Some(at)) => Err(ce
                .span(Some(at))
                .err(format!(
                    "'{}' is not an oscillator function and should not be sampled",
                    &ce.callee.value
                ))
                .note(NoteKind::Hint, "remove the `at phase`"))?,
            (false, None) => {}
            (true, Some(at)) => {
                args.push(self.compile_expr(ib, at)?);
            }
        }
        let reg = ib.func.new_register(ret_ty);
        ib.block().insns.push(Insn::Call {
            out: reg.clone(),
            callee,
            args,
        });
        Ok(reg)
    }

    fn lookup_callee(
        &self,
        ib: &mut IRBuilder,
        ce: &CallExpr,
        args: &mut Vec<Register>,
    ) -> anyhow::Result<(Type, Callee, bool)> {
        let name = ce.callee.value.as_str();
        macro_rules! local_ty {
            ($t:ty) => {
                <$t as LocalTypable>::TYPE
            };
            ($t:ty:$units:expr) => {
                Type::Number($units)
            };
        }
        macro_rules! is_present {
            () => {
                false
            };
            ($id:ty) => {
                true
            };
        }
        macro_rules! builtins {
            ($(fn $(($recv:ty))? $name:ident($($arg_ty:ty$(:$units:expr)?),*) -> $ret:ty$(:$ret_units:expr)?),*$(,)?) => {
                if let Some(foreign) = match name { $(
                    concat!(stringify!($name)) => Some(Foreign {
                        local_ty: (local_ty!($ret$(:$ret_units)?), vec![$(local_ty!($arg_ty$(:$units)?),)*]),
                        llvm_ty: HideDbg(llvm::get_llvm_ty::<extern "C" fn($(*mut $recv,)? $($arg_ty),*) -> $ret>()),
                        name: concat!("yhim_", stringify!($name)),
                        has_sound_receiver: is_present!($($recv)?)
                    })
                ),*,
                    _ => None
                } {
                    if args.len() != foreign.local_ty.1.len() {
                        Err(ce.span(None).err(format!(
                            "wrong number of arguments, '{}' expected: {}, but given: {}",
                            name,
                            foreign.local_ty.1.len(),
                            args.len()
                        )))?
                    }
                    for ((reg, ty), arg) in args
                        .iter_mut()
                        .zip(foreign.local_ty.1.iter())
                        .zip(ce.args.iter())
                    {
                        self.coerce(ib, "function argument requires", &ty, reg, arg)?;
                    }
                    if foreign.has_sound_receiver && ib.func.ty != FuncType::Sound {
                        Err(ce
                            .callee
                            .span()
                            .err("sound functions must not be called from non-sound functions")
                            .note(NoteKind::Hint, "don't"))?
                    }
                    return Ok((
                        foreign.local_ty.0.clone(),
                        Callee::Builtin(Builtin::Foreign(foreign)),
                        false,
                    ));
                }
            };
        }
        match name {
            "phase" => {
                if ib.func.ty != FuncType::Oscillator {
                    Err(ce
                        .span(None)
                        .err("the 'phase' function is only available in oscillators"))?
                }
                if ce.args.len() != 0 {
                    Err(ce.span(None).err(format!(
                        "wrong number of arguments, 'phase' expected: 0, but given: {}",
                        ce.args.len()
                    )))?;
                }
                return Ok((
                    Type::Number(Dimensionless),
                    Callee::Builtin(Builtin::Phase),
                    false,
                ));
            }
            _ => {}
        }
        use Units::*;
        builtins!(
            fn time_phase(f64:Seconds, f64:Hertz) -> f64,

            fn dbg(f64) -> f64,

            fn sin(f64) -> f64,
            fn cos(f64) -> f64,
            fn exp(f64) -> f64,
            fn sqrt(f64) -> f64,
            fn ln(f64) -> f64,
            fn log(f64, f64) -> f64,
            fn pow(f64, f64) -> f64,

            fn min(f64, f64) -> f64,
            fn max(f64, f64) -> f64,
            fn choose(bool, f64, f64) -> f64,

            fn pan(SampleTy, f64) -> SampleTy,

            fn (SoundRecvTy) mix(SampleTy) -> (),
            fn (SoundRecvTy) next() -> (),
            fn (SoundRecvTy) skip(f64) -> (),
        );
        if let Some(f) = self.funcs.get(name) {
            if args.len() != f.params.len() {
                Err(ce.span(None).err(format!(
                    "wrong number of arguments, '{}' expected: {}, but given: {}",
                    name,
                    f.params.len(),
                    args.len()
                )))?
            }
            for ((reg, par), arg) in args.iter_mut().zip(f.params.iter()).zip(ce.args.iter()) {
                self.coerce(ib, "function argument requires", &par.ty, reg, arg)?;
            }
            if f.ty == FuncType::Sound && ib.func.ty != FuncType::Sound {
                Err(ce
                    .callee
                    .span()
                    .err("sound functions must not be called from non-sound functions")
                    .note(NoteKind::Hint, "don't"))?
            }
            Ok((
                f.callee_ret_ty(),
                Callee::Named(f.name.clone()),
                f.ty == FuncType::Oscillator,
            ))
        } else {
            Err(ce
                .callee
                .span()
                .err(format!("undefined function: '{}'", ce.callee.value)))?
        }
    }

    fn coerce(
        &self,
        ib: &mut IRBuilder,
        name: &str,
        ty: &Type,
        reg: &mut Register,
        span: impl Into<Span>,
    ) -> Result<(), SourcedError> {
        let src_ty = &ib.func[reg.clone()];
        use Type::*;
        match (src_ty, ty) {
            (lhs, rhs) if lhs == rhs => Ok(()),
            (Number(Dimensionless), Sample) => {
                let out = ib.func.new_register(Sample);
                ib.block().insns.push(Insn::Call {
                    out: out.clone(),
                    callee: Callee::Builtin(Builtin::Num2Sample),
                    args: vec![reg.clone()],
                });
                *reg = out;
                Ok(())
            }
            (Number(Dimensionless), Number(_)) | (Number(_), Number(Dimensionless)) => Ok(()), // what can we do
            (src_ty, ty) => Err(span.into().err(format!(
                "type mismatch, {}: {}, but expression has type: {}",
                name, ty, src_ty
            )))?,
        }
    }

    fn compile_expr(&self, ib: &mut IRBuilder, mut expr: &Expr) -> anyhow::Result<Register> {
        loop {
            break Ok(match expr {
                Expr::BinExpr { args, ops } => {
                    let get_op = |nm: &str| -> Option<(Builtin, usize)> {
                        use BinOp::*;
                        use Builtin::*;
                        use Comparison::*;
                        Some(match nm {
                            "+" => (Op2(Add), 1),
                            "-" => (Op2(Sub), 1),
                            "*" => (Op2(Mul), 2),
                            "/" => (Op2(Div), 2),
                            "%" => (Op2(Mod), 2),
                            "<" => (Cmp(Lt), 0),
                            "<=" => (Cmp(Le), 0),
                            ">" => (Cmp(Gt), 0),
                            ">=" => (Cmp(Ge), 0),
                            "==" => (Cmp(Eq), 0),
                            "!=" => (Cmp(Ne), 0),
                            _ => None?,
                        })
                    };
                    fn apply(
                        s: &Compiler,
                        ib: &mut IRBuilder,
                        mut op: Builtin,
                        mut lhs: (Register, Span),
                        mut rhs: (Register, Span),
                    ) -> anyhow::Result<(Register, Span)> {
                        use Builtin::*;
                        use Type::*;
                        let l_ty = ib.func[lhs.0].clone();
                        let r_ty = ib.func[rhs.0].clone();
                        let new_span = lhs.1.but_end(rhs.1);
                        // hack to allow for subtracting dB right off the samples...
                        if l_ty.is_sample()
                            && matches!(r_ty, Number(Units::Decibels))
                            && matches!(op, Op2(BinOp::Add | BinOp::Sub))
                        {
                            let one = ib.func.new_register(Number(Dimensionless));
                            ib.block().insns.push(Insn::Const {
                                out: one,
                                value: DynamicValue::Number(1.),
                            });
                            let new_rhs = ib.func.new_register(Number(Dimensionless));
                            ib.block().insns.push(Insn::Call {
                                out: new_rhs,
                                callee: Callee::Builtin(op),
                                args: vec![one, rhs.0],
                            });
                            op = Op2(BinOp::Mul);
                            rhs.0 = new_rhs;
                        }
                        let result_ty = match (l_ty, r_ty) {
                            (Number(_), r @ Type::Sample) => {
                                s.coerce(
                                    ib,
                                    "right value has type",
                                    &r,
                                    &mut lhs.0,
                                    new_span.clone(),
                                )?;
                                r
                            }
                            (l @ Type::Sample, Number(_)) => {
                                s.coerce(
                                    ib,
                                    "left value has type",
                                    &l,
                                    &mut rhs.0,
                                    new_span.clone(),
                                )?;
                                l
                            }
                            (Number(l), Number(r)) => match op {
                                Op2(op) => {
                                    if let Some(res) = l.apply(op, r) {
                                        Number(res)
                                    } else {
                                        Err(new_span.clone().err("operation does not have a meaningful result for the given units")
                                                .note(NoteKind::Note, format!("left hand side has units: {}", l))
                                                .note(NoteKind::Note, format!("right hand side has units: {}", r))
                                                .note(NoteKind::Hint, "you can always divide by one of a unit to remove it"))?
                                    }
                                }
                                Cmp(_) => {
                                    if l != r {
                                        Err(new_span.clone().err("numbers with unrelated units cannot be compared")
                                                .note(NoteKind::Note, format!("left hand side has units: {}", l))
                                                .note(NoteKind::Note, format!("right hand side has units: {}", r))
                                                .note(NoteKind::Hint, "you can always divide by one of a unit to remove it")
                                            )?
                                    }
                                    Boolean
                                }
                                _ => unreachable!(),
                            },
                            (l_ty, r_ty) => {
                                return Err(new_span
                                    .clone()
                                    .err(format!(
                                        "operator not applicable to types '{}' and '{}'",
                                        l_ty, r_ty
                                    ))
                                    .into())
                            }
                        };
                        let out = ib.func.new_register(result_ty);
                        ib.block().insns.push(Insn::Call {
                            out,
                            callee: Callee::Builtin(op),
                            args: vec![lhs.0, rhs.0],
                        });
                        Ok((out, new_span))
                    }
                    fn pop_apply(
                        s: &Compiler,
                        ib: &mut IRBuilder,
                        op_stack: &mut VecDeque<(Builtin, usize)>,
                        val_stack: &mut VecDeque<(Register, Span)>,
                    ) -> anyhow::Result<()> {
                        let (op, _) = op_stack.pop_back().unwrap();
                        let rhs = val_stack.pop_back().unwrap();
                        let lhs = val_stack.pop_back().unwrap();
                        val_stack.push_back(apply(s, ib, op, lhs, rhs)?);
                        Ok(())
                    }
                    let mut op_stack = VecDeque::<(Builtin, usize)>::new();
                    let mut val_stack = VecDeque::new();
                    let mut args_iter = args.iter();
                    let lhs = args_iter.next().unwrap();
                    val_stack.push_back((self.compile_expr(ib, lhs)?, lhs.span()));
                    for (op, rhs) in ops.iter().zip(args_iter) {
                        let (op, prec) = get_op(op.value.as_str()).ok_or_else(|| {
                            op.span()
                                .err(format!("unrecognised operator: '{}'", op.value.as_str()))
                        })?;
                        while let Some(true) = op_stack.back().map(|(_, p)| *p >= prec) {
                            pop_apply(self, ib, &mut op_stack, &mut val_stack)?;
                        }
                        op_stack.push_back((op, prec));
                        val_stack.push_back((self.compile_expr(ib, rhs)?, rhs.span()));
                    }
                    while !op_stack.is_empty() {
                        pop_apply(self, ib, &mut op_stack, &mut val_stack)?;
                    }
                    val_stack.pop_back().unwrap().0
                }
                Expr::UnExpr { op, arg } => {
                    let expr_reg = self.compile_expr(ib, &**arg)?;
                    let ty = ib.func[expr_reg].clone();
                    let permitted: &[&str] = match ty {
                        Type::Number(_) => &["+", "-"],
                        Type::Sample => &["+", "-"],
                        Type::Integer => &["+"],
                        Type::Boolean => &["!"],
                        Type::Unit => &[],
                        Type::Array(_) => &[],
                    };
                    if !permitted.contains(&op.value.as_str()) {
                        Err(op.span().err(format!(
                            "unary operator: '{}' is not valid for type: '{}'",
                            op.value.as_str(),
                            ty
                        )))?;
                    }
                    let out = ib.func.new_register(ty);
                    let arg = self.compile_expr(ib, &*arg)?;
                    ib.block().insns.push(Insn::Call {
                        out,
                        callee: Callee::Builtin(Builtin::Op1(match op.value.as_str() {
                            "+" => UnOp::Plus,
                            "-" => UnOp::Neg,
                            "!" => UnOp::Not,
                            _ => unreachable!(),
                        })),
                        args: vec![arg],
                    });
                    out
                }
                Expr::Literal { value, units } => {
                    use DynamicValue::*;
                    let float_val = f64::from_str(value.value.as_str())?;
                    let (value, ty) = match units.as_ref().map(|tok| (tok, tok.value.as_str())) {
                        None => (Number(float_val), Type::Number(Dimensionless)),
                        Some((tok, name)) => {
                            if let Some(units) = Units::from_name(name) {
                                (Number(float_val), Type::Number(units))
                            } else {
                                Err(tok.span().err(format!("unrecognised units: '{}'", name)))?
                            }
                        }
                    };
                    let out = ib.func.new_register(ty);
                    ib.block().insns.push(Insn::Const {
                        out: out.clone(),
                        value,
                    });
                    out
                }
                Expr::Variable { name } => {
                    use std::f64::consts::*;
                    let mut units = Dimensionless;
                    if let Some(value) = match name.value.as_str() {
                        "SAMPLE_RATE" => {
                            units = Units::Hertz;
                            Some(DynamicValue::Number(SAMPLE_RATE as f64))
                        }
                        "SAMPLE_PERIOD" => {
                            units = Units::Seconds;
                            Some(DynamicValue::Number(1. / SAMPLE_RATE as f64))
                        }
                        "E" => Some(DynamicValue::Number(E)),
                        "PI" => Some(DynamicValue::Number(PI)),
                        "TAU" => Some(DynamicValue::Number(TAU)),
                        s if regex::Regex::new("^[A-G][♯♭sf]?[0-9]?$")
                            .unwrap()
                            .is_match(s) =>
                        {
                            let mut cs = s.chars();
                            let note = cs.next().unwrap();
                            let sharp_or_octave = cs.next().unwrap();
                            let maybe_octave = cs.next();
                            let (sharp, octave) = if let Some(octave) = maybe_octave {
                                (Some(sharp_or_octave), octave)
                            } else {
                                (None, sharp_or_octave)
                            };
                            let note_semitones = [0, 2, 3 - 12, 5 - 12, 7 - 12, 8 - 12, 10 - 12]
                                [note as usize - 'A' as usize];
                            let sharp_offset = match sharp {
                                Some('♯' | 's') => 1,
                                Some('♭' | 'f') => -1,
                                _ => 0,
                            };
                            let octave_offset = octave.to_digit(10).unwrap() as i32 - 4;
                            let delta_from_a4 = octave_offset * 12 + note_semitones + sharp_offset;
                            let freq = 440.0 * 2.0_f64.powf(delta_from_a4 as f64 / 12.0);
                            units = Units::Hertz;
                            Some(DynamicValue::Number(freq))
                        }
                        _ => None,
                    } {
                        let out = ib.func.new_register(Type::Number(units));
                        ib.block().insns.push(Insn::Const { out, value });
                        out
                    } else {
                        ib.scopes.lookup(name)?.register
                    }
                }
                Expr::ParExpr { expr: e, .. } => {
                    expr = &*e;
                    continue;
                }
                Expr::Call { ce, at } => self.compile_call(ib, ce, at.as_ref().map(|it| &**it))?,
                Expr::Array { children, .. } => {
                    let (c_ty, mut child_regs) = if children.is_empty() {
                        (Type::Unit, Vec::new())
                    } else {
                        let mut c_regs = Vec::new();
                        for child in children {
                            c_regs.push(self.compile_expr(ib, child)?);
                        }
                        (ib.func[c_regs[0]].clone(), c_regs)
                    };
                    for (reg, expr) in child_regs.iter_mut().zip(children) {
                        self.coerce(ib, "array component type is", &c_ty, reg, expr)
                            .map_err(|it| {
                                it.note(
                                    NoteKind::Note,
                                    "array component type is decided from the first element",
                                )
                            })?;
                    }
                    let arr = ib.func.new_register(Type::Array(Box::new(c_ty.clone())));
                    ib.block().insns.push(Insn::Call {
                        out: arr,
                        callee: Callee::Builtin(Builtin::NewArray(c_ty)),
                        args: child_regs,
                    });
                    arr
                }
            });
        }
    }
}

pub mod llvm {
    use crate::compile::{
        BinOp, Callee, Comparison, DynamicValue, Func, FuncType, Insn, JumpInsn, Type, UnOp, Units,
    };
    use anyhow::anyhow;

    use inkwell::builder::Builder;
    use inkwell::debug_info::{AsDIScope, DICompileUnit, DebugInfoBuilder};
    use inkwell::intrinsics::Intrinsic;
    use inkwell::types::{AnyType, VoidType};
    use inkwell::values::{FloatValue, IntValue};
    use inkwell::{
        context::ContextRef,
        module::{Linkage::External, Module},
        types::{AnyTypeEnum, BasicMetadataTypeEnum, BasicType, BasicTypeEnum, FunctionType},
        values::{BasicMetadataValueEnum, BasicValue, BasicValueEnum},
        AddressSpace, FloatPredicate, IntPredicate,
    };
    use std::{cell::Cell, collections::HashMap, fmt::Write, marker::PhantomData};

    pub struct LLVMCompiler<'a, 'm> {
        pub cc: super::Compiler,
        pub module: &'a Module<'m>,
        pub dib: Option<(DebugInfoBuilder<'m>, DICompileUnit<'m>)>,
        c: Consts<'m>,
    }

    pub enum ReturnType<'a> {
        Basic(BasicTypeEnum<'a>),
        Void(VoidType<'a>),
    }

    impl<'a> ReturnType<'a> {
        fn fn_type(
            &self,
            param_types: &[BasicMetadataTypeEnum<'a>],
            is_varargs: bool,
        ) -> FunctionType<'a> {
            match self {
                ReturnType::Basic(b) => b.fn_type(param_types, is_varargs),
                ReturnType::Void(v) => v.fn_type(param_types, is_varargs),
            }
        }
    }

    pub trait Typable {
        fn get_ty<'a>(ctx: &ContextRef<'a>) -> AnyTypeEnum<'a>;

        fn return_ty<'a>(ctx: &ContextRef<'a>) -> ReturnType<'a> {
            ReturnType::Basic(Self::basic_ty(ctx))
        }

        fn basic_ty<'a>(ctx: &ContextRef<'a>) -> BasicTypeEnum<'a> {
            BasicTypeEnum::try_from(Self::get_ty(ctx)).unwrap()
        }
    }
    pub fn get_llvm_ty<T: Typable>() -> for<'a> fn(ctx: &ContextRef<'a>) -> AnyTypeEnum<'a> {
        T::get_ty
    }

    macro_rules! typable {
        (impl <$($tv:ident),*> $t:ty as |$ctx:ident| $expr:expr) => {
            impl <$($tv),*> Typable for $t
            where $($tv: Typable),* {
                fn get_ty<'a>($ctx: &ContextRef<'a>) -> AnyTypeEnum<'a> {
                    $expr.into()
                }
            }
        };
    }

    macro_rules! impl_tuple_typable {
        (impl ($($ty:ident),*$(,)?)) => {
            typable!(impl<$($ty),*> ($($ty),*) as |ctx| ctx.struct_type(&[$($ty::basic_ty(ctx)),*], false));
        }
    }
    macro_rules! tuple_typable {
        (for ($hd:ident, $($tl:ident),*)) => {
            impl_tuple_typable!(impl ($hd, $($tl),*));
            tuple_typable!(for ($($tl),*));
        };
        (for ($hd:ident)) => {
            typable!(impl<T> (T,) as |ctx| ctx.struct_type(&[T::basic_ty(ctx)], false));
        };
    }

    macro_rules! impl_fn_typable {
        (impl ($($args:ident),*)) => {
            typable!(impl<$($args),*, R> extern "C" fn($($args),*) -> R as |ctx|
                R::return_ty(ctx).fn_type(&[$($args::basic_ty(ctx).into()),*], false));
        }
    }
    macro_rules! fn_typable {
        (for ($hd:ident, $($tl:ident),*)) => {
            impl_fn_typable!(impl ($hd, $($tl),*));
            fn_typable!(for ($($tl),*));
        };
        (for ($hd:ident)) => {
            impl_fn_typable!(impl ($hd));
            typable!(impl<R> extern "C" fn() -> R as |ctx| R::return_ty(ctx).fn_type(&[], false));
        };
    }

    impl Typable for () {
        fn get_ty<'a>(ctx: &ContextRef<'a>) -> AnyTypeEnum<'a> {
            ctx.struct_type(&[], false).as_any_type_enum()
        }

        fn return_ty<'a>(ctx: &ContextRef<'a>) -> ReturnType<'a> {
            ReturnType::Void(ctx.void_type())
        }
    }

    tuple_typable!(for (A, B, C, D, E, F, G, H));
    fn_typable!(for (A, B, C, D, E, F, G, H));
    typable!(impl<T> *mut T as |ctx| T::basic_ty(ctx).ptr_type(AddressSpace::default()));
    typable!(impl<> f64 as |ctx| ctx.f64_type());
    typable!(impl<> f32 as |ctx| ctx.f32_type());
    typable!(impl<> i64 as |ctx| ctx.i64_type());
    typable!(impl<> i32 as |ctx| ctx.i32_type());
    typable!(impl<> bool as |ctx| ctx.bool_type());

    struct TypeCell<'a, T> {
        cell: Cell<Option<AnyTypeEnum<'a>>>,
        _p: PhantomData<*const T>,
    }

    impl<'a, T> Default for TypeCell<'a, T> {
        fn default() -> Self {
            Self {
                cell: Cell::new(None),
                _p: PhantomData::default(),
            }
        }
    }

    impl<'a, T> TypeCell<'a, T>
    where
        T: Typable,
    {
        fn get(&self, ctx: ContextRef<'a>) -> AnyTypeEnum<'a> {
            if let Some(ty) = self.cell.get() {
                ty
            } else {
                let ty = T::get_ty(&ctx);
                self.cell.set(Some(ty));
                ty
            }
        }

        fn get_basic(&self, ctx: ContextRef<'a>) -> BasicTypeEnum<'a> {
            self.get(ctx).try_into().unwrap()
        }
    }

    pub type SampleTy = (f64, f64);
    pub type ArrayTy = (i64, *mut (), *mut ());
    pub type SoundRecvTy = (i64, *mut ());
    #[derive(Default)]
    struct Consts<'m> {
        unit: TypeCell<'m, ()>,
        number: TypeCell<'m, f64>,
        integer: TypeCell<'m, i64>,
        boolean: TypeCell<'m, bool>,
        sample: TypeCell<'m, SampleTy>,
        array: TypeCell<'m, ArrayTy>,

        sound_recv: TypeCell<'m, SoundRecvTy>,
    }

    impl<'a, 'm> LLVMCompiler<'a, 'm> {
        pub fn new(cc: super::Compiler, module: &'a Module<'m>) -> Self {
            Self {
                cc,
                module,
                dib: None,
                c: Consts::default(),
            }
        }

        fn ctx(&self) -> ContextRef<'m> {
            self.module.get_context()
        }

        fn mangle_name(&self, func: &Func) -> String {
            let mut name = func.name.to_string();
            write!(name, "_{}", func.ty).unwrap();
            name
        }

        fn receiver_type(&self, f_ty: FuncType) -> Option<BasicTypeEnum<'m>> {
            match f_ty {
                FuncType::Pure => None,
                FuncType::Sound => Some(self.c.sound_recv.get_basic(self.ctx())),
                FuncType::Oscillator => None,
            }
        }

        fn llvm_type(&self, ty: &Type) -> BasicTypeEnum<'m> {
            match ty {
                Type::Unit => self.c.unit.get_basic(self.ctx()),
                Type::Integer => self.c.integer.get_basic(self.ctx()),
                Type::Boolean => self.c.boolean.get_basic(self.ctx()),
                Type::Number(_) => self.c.number.get_basic(self.ctx()),
                Type::Sample => self.c.sample.get_basic(self.ctx()),
                Type::Array(_) => self.c.array.get_basic(self.ctx()),
            }
        }

        fn func_type(&self, func: &Func) -> FunctionType<'m> {
            let mut args = self
                .receiver_type(func.ty)
                .into_iter()
                .map(BasicMetadataTypeEnum::from)
                .chain(
                    func.params
                        .iter()
                        .map(|it| BasicMetadataTypeEnum::from(self.llvm_type(&it.ty))),
                )
                .collect::<Vec<_>>();
            if func.ty == FuncType::Oscillator {
                // oscillator phase param
                args.push(BasicMetadataTypeEnum::from(self.ctx().f64_type()));
            }
            let ret_ty = func.callee_ret_ty();
            if ret_ty.is_unit() {
                self.ctx().void_type().fn_type(args.as_slice(), false)
            } else {
                self.llvm_type(&ret_ty).fn_type(args.as_slice(), false)
            }
        }

        pub fn compile(&self) -> anyhow::Result<()> {
            let mut ll_funcs = HashMap::new();
            for func in self.cc.funcs.values() {
                let ll_func = self.module.add_function(
                    self.mangle_name(func).as_str(),
                    self.func_type(func),
                    None,
                );
                ll_funcs.insert(func.name.as_str(), ll_func);
            }
            for func in self.cc.funcs.values() {
                let ib = self.ctx().create_builder();
                let ll_func = *ll_funcs.get(func.name.as_str()).unwrap();
                let ll_blocks = func
                    .blocks
                    .iter()
                    .enumerate()
                    .map(|(i, _)| self.ctx().append_basic_block(ll_func, &format!("bb_{}", i)))
                    .collect::<Vec<_>>();
                ib.position_at_end(ll_blocks[0]);
                let ll_reg_types = func
                    .registers
                    .iter()
                    .map(|ty| self.llvm_type(ty))
                    .collect::<Vec<_>>();
                let ll_registers = ll_reg_types
                    .iter()
                    .copied()
                    .enumerate()
                    .map(|(i, ty)| ib.build_alloca(ty, &format!("reg_{}", i)))
                    .collect::<Vec<_>>();
                let mut param_iter = ll_func.get_param_iter();
                let this = if func.ty == FuncType::Sound {
                    let this_val = param_iter.next().unwrap();
                    let this_ptr = ib.build_alloca(self.c.sound_recv.get_basic(self.ctx()), "this");
                    ib.build_store(this_ptr, this_val);
                    Some(this_ptr)
                } else {
                    None
                };
                for (i, (ll_param, param)) in param_iter.zip(func.params.iter()).enumerate() {
                    ll_param.set_name(&param.name);
                    ib.build_store(ll_registers[i], ll_param);
                }
                let phase = if func.ty == FuncType::Oscillator {
                    let phase = ll_func.get_last_param().unwrap();
                    phase.set_name("phase");
                    Some(phase)
                } else {
                    None
                };
                macro_rules! load {
                    ($reg:expr) => {{
                        let x: BasicValueEnum<'m> = ib.build_load(
                            ll_reg_types[$reg.0],
                            ll_registers[$reg.0],
                            &format!("reg_v_{}", $reg.0),
                        );
                        x
                    }};
                    ($ty:expr, $ptr:expr, $name:expr) => {{
                        let x: BasicValueEnum<'m> = ib.build_load($ty, $ptr, $name);
                        x
                    }};
                }
                macro_rules! gep {
                    ($ty:expr, $ptr:expr, $idx:expr, $name:expr) => {
                        ib.build_struct_gep($ty, $ptr, $idx, $name).unwrap()
                    };
                    (in $ty:expr, $ptr:expr, [$($idx:expr),*], $name:expr) => {
                        unsafe { ib.build_in_bounds_gep($ty, $ptr, &[$($idx)*], $name) }
                    };
                }
                for (&ll_bb, bb) in ll_blocks.iter().zip(func.blocks.iter()) {
                    ib.position_at_end(ll_bb);
                    for insn in &bb.insns {
                        match insn {
                            Insn::Move { out, from } => {
                                ib.build_store(ll_registers[out.0], load!(from));
                            }
                            Insn::Call { out, callee, args } => {
                                let load_vec = args.iter().map(|r| load!(r)).collect::<Vec<_>>();
                                let mut arg_vec = load_vec
                                    .iter()
                                    .map(|&r| BasicMetadataValueEnum::from(r))
                                    .collect::<Vec<_>>();
                                match callee {
                                    Callee::Named(name) => {
                                        let callee_fn = *ll_funcs
                                            .get(name.as_str())
                                            .ok_or_else(|| anyhow!("should not be unbound"))?;
                                        // insert receiver
                                        if self.cc.funcs.get(name.as_str()).unwrap().ty
                                            == FuncType::Sound
                                        {
                                            arg_vec.insert(
                                                0,
                                                BasicMetadataValueEnum::from(load!(
                                                    self.c.sound_recv.get_basic(self.ctx()),
                                                    this.unwrap(),
                                                    "this_copy"
                                                )),
                                            );
                                        }
                                        let call_value =
                                            ib.build_call(callee_fn, arg_vec.as_slice(), "call");
                                        if let Some(v) = call_value.try_as_basic_value().left() {
                                            ib.build_store(ll_registers[out.0], v);
                                        }
                                    }
                                    Callee::Builtin(builtin) => {
                                        use super::Builtin::*;
                                        match builtin {
                                            Num2Sample => {
                                                let base = ll_registers[out.0];
                                                let sample_ty = BasicTypeEnum::try_from(
                                                    self.c.sample.get(self.ctx()),
                                                )
                                                .unwrap();
                                                let val = arg_vec[0].into_float_value();
                                                ib.build_store(
                                                    gep!(sample_ty, base, 0, "left"),
                                                    val,
                                                );
                                                ib.build_store(
                                                    gep!(sample_ty, base, 1, "right"),
                                                    val,
                                                );
                                            }
                                            Foreign(f) => {
                                                let fv = self
                                                    .module
                                                    .get_function(f.name)
                                                    .unwrap_or_else(|| {
                                                        self.module.add_function(
                                                            f.name,
                                                            f.llvm_ty.0(&self.ctx())
                                                                .into_function_type(),
                                                            Some(External),
                                                        )
                                                    });
                                                if f.has_sound_receiver {
                                                    arg_vec.insert(
                                                        0,
                                                        BasicMetadataValueEnum::from(this.unwrap()),
                                                    );
                                                }
                                                let res =
                                                    ib.build_call(fv, arg_vec.as_slice(), "res");
                                                if let Some(v) = res.try_as_basic_value().left() {
                                                    ib.build_store(ll_registers[out.0], v);
                                                }
                                            }
                                            ArrayLen => {
                                                ib.build_store(
                                                    ll_registers[out.0],
                                                    load!(
                                                        self.ctx().i64_type(),
                                                        gep!(
                                                            self.c
                                                                .array
                                                                .get_basic(self.ctx())
                                                                .into_struct_type(),
                                                            ll_registers[args[0].0],
                                                            0,
                                                            "len_ptr"
                                                        ),
                                                        "len"
                                                    ),
                                                );
                                            }
                                            ArrayRef => {
                                                let ptr_to_buf = gep!(
                                                    self.c
                                                        .array
                                                        .get_basic(self.ctx())
                                                        .into_struct_type(),
                                                    ll_registers[args[0].0],
                                                    1,
                                                    "buf_ptr"
                                                );
                                                let buf = load!(
                                                    self.ctx()
                                                        .i8_type()
                                                        .ptr_type(AddressSpace::default()),
                                                    ptr_to_buf,
                                                    "buf"
                                                );
                                                let val_ptr = gep!(
                                                    in
                                                    ll_reg_types[out.0],
                                                    buf.into_pointer_value(),
                                                    [arg_vec[1].into_int_value()],
                                                    "ref"
                                                );
                                                let val =
                                                    load!(ll_reg_types[out.0], val_ptr, "val");
                                                ib.build_store(ll_registers[out.0], val);
                                            }
                                            NewArray(c_ty) => {
                                                let fv = self
                                                    .module
                                                    .get_function("yhim_newarray")
                                                    .unwrap_or_else(|| {
                                                        self.module.add_function(
                                                            "yhim_newarray",
                                                            get_llvm_ty::<
                                                                extern "C" fn(
                                                                    *mut ArrayTy,
                                                                    i64,
                                                                    i64,
                                                                    i64,
                                                                ),
                                                            >(
                                                            )(
                                                                &self.ctx()
                                                            )
                                                            .into_function_type(),
                                                            Some(External),
                                                        )
                                                    });
                                                let c_ll_ty = self.llvm_type(c_ty);
                                                let i64 = self.ctx().i64_type();
                                                let arr_reg = ll_registers[out.0];
                                                ib.build_call(
                                                    fv,
                                                    &[
                                                        arr_reg.into(),
                                                        i64.const_int(arg_vec.len() as u64, false)
                                                            .into(),
                                                        c_ll_ty.size_of().unwrap().into(),
                                                        i64.const_int(
                                                            std::mem::align_of::<f64>() as u64,
                                                            false,
                                                        )
                                                        .into(),
                                                    ],
                                                    "arr",
                                                )
                                                .try_as_basic_value();

                                                let ptr_to_buf = gep!(
                                                    self.c
                                                        .array
                                                        .get_basic(self.ctx())
                                                        .into_struct_type(),
                                                    arr_reg,
                                                    1,
                                                    "buf_ptr"
                                                );
                                                let buf = load!(
                                                    self.ctx()
                                                        .i8_type()
                                                        .ptr_type(AddressSpace::default()),
                                                    ptr_to_buf,
                                                    "buf"
                                                )
                                                .into_pointer_value();
                                                for (i, &val) in load_vec.iter().enumerate() {
                                                    let val_ptr = gep!(in c_ll_ty, buf, [i64.const_int(i as u64, false)], "val_ptr");
                                                    ib.build_store(val_ptr, val);
                                                }
                                            }
                                            Inc => {
                                                ib.build_store(
                                                    ll_registers[out.0],
                                                    ib.build_int_add(
                                                        self.ctx().i64_type().const_int(1, false),
                                                        load!(out).into_int_value(),
                                                        "inc",
                                                    ),
                                                );
                                            }
                                            Cmp(cmp) => {
                                                let is_float = func[args[0]].is_float().unwrap();
                                                use Comparison::*;
                                                let res = if is_float {
                                                    ib.build_float_compare(
                                                        match cmp {
                                                            Lt => FloatPredicate::OLT,
                                                            Le => FloatPredicate::OLE,
                                                            Gt => FloatPredicate::OGT,
                                                            Ge => FloatPredicate::OGE,
                                                            Eq => FloatPredicate::OEQ,
                                                            Ne => FloatPredicate::ONE,
                                                        },
                                                        arg_vec[0].into_float_value(),
                                                        arg_vec[1].into_float_value(),
                                                        "cmp",
                                                    )
                                                } else {
                                                    ib.build_int_compare(
                                                        match cmp {
                                                            Lt => IntPredicate::SLT,
                                                            Le => IntPredicate::SLE,
                                                            Gt => IntPredicate::SGT,
                                                            Ge => IntPredicate::SGE,
                                                            Eq => IntPredicate::EQ,
                                                            Ne => IntPredicate::NE,
                                                        },
                                                        arg_vec[0].into_int_value(),
                                                        arg_vec[1].into_int_value(),
                                                        "cmp",
                                                    )
                                                };
                                                ib.build_store(ll_registers[out.0], res);
                                            }
                                            Op1(unop) => {
                                                use UnOp::*;
                                                match (unop, func[args[0]].is_float().unwrap()) {
                                                    (Neg, true) => {
                                                        ib.build_store(
                                                            ll_registers[out.0],
                                                            ib.build_float_neg(
                                                                load_vec[0].into_float_value(),
                                                                "neg",
                                                            ),
                                                        );
                                                    }
                                                    (Neg, false) => {
                                                        ib.build_store(
                                                            ll_registers[out.0],
                                                            ib.build_int_neg(
                                                                load_vec[0].into_int_value(),
                                                                "neg",
                                                            ),
                                                        );
                                                    }
                                                    (Not, false) => {
                                                        ib.build_store(
                                                            ll_registers[out.0],
                                                            ib.build_not(
                                                                load_vec[0].into_int_value(),
                                                                "not",
                                                            ),
                                                        );
                                                    }
                                                    (Plus, _) => {
                                                        ib.build_store(
                                                            ll_registers[out.0],
                                                            load_vec[0],
                                                        );
                                                    }
                                                    _ => panic!(),
                                                }
                                            }
                                            Op2(mut op) => {
                                                let left_ty = &func[args[0]];
                                                let right_ty = &func[args[1]];
                                                let is_float = left_ty.is_float().unwrap();
                                                if is_float {
                                                    fn rval_sf<
                                                        'a,
                                                        const BASE: i32,
                                                        const COEFF: i32,
                                                    >(
                                                        s: &LLVMCompiler<'_, 'a>,
                                                        ib: &Builder<'a>,
                                                        fv: FloatValue<'a>,
                                                    ) -> FloatValue<'a>
                                                    {
                                                        let pow =
                                                            Intrinsic::find("llvm.pow").unwrap();
                                                        let ty = fv.get_type();
                                                        let pow = pow
                                                            .get_declaration(
                                                                s.module,
                                                                &[ty.into(), ty.into()],
                                                            )
                                                            .unwrap();
                                                        ib.build_call(
                                                            pow,
                                                            &[
                                                                ty.const_float(BASE as f64).into(),
                                                                ib.build_float_div(
                                                                    fv,
                                                                    ty.const_float(COEFF as f64),
                                                                    "exp",
                                                                )
                                                                .into(),
                                                            ],
                                                            "sf",
                                                        )
                                                        .try_as_basic_value()
                                                        .unwrap_left()
                                                        .into_float_value()
                                                    }
                                                    let right_val = match (left_ty, right_ty) {
                                                        (
                                                            Type::Number(Units::Dimensionless)
                                                            | Type::Sample,
                                                            Type::Number(Units::Decibels),
                                                        ) => {
                                                            op = op.logarithmise();
                                                            |s, b, f| rval_sf::<10, 10>(s, b, f)
                                                        }
                                                        (
                                                            Type::Number(Units::Hertz),
                                                            Type::Number(Units::Semitones),
                                                        ) => {
                                                            op = op.logarithmise();
                                                            |s, b, f| rval_sf::<2, 12>(s, b, f)
                                                        }
                                                        _ => |_s, _ib, fv| fv,
                                                    };

                                                    let f: fn(_, _, _) -> _ = match op {
                                                        BinOp::Add => {
                                                            |ib: &Builder, l: FloatValue, r| {
                                                                ib.build_float_add(l, r, "r")
                                                            }
                                                        }
                                                        BinOp::Sub => {
                                                            |ib: &Builder, l: FloatValue, r| {
                                                                ib.build_float_sub(l, r, "r")
                                                            }
                                                        }
                                                        BinOp::Mul => {
                                                            |ib: &Builder, l: FloatValue, r| {
                                                                ib.build_float_mul(l, r, "r")
                                                            }
                                                        }
                                                        BinOp::Div => {
                                                            |ib: &Builder, l: FloatValue, r| {
                                                                ib.build_float_div(l, r, "r")
                                                            }
                                                        }
                                                        BinOp::Mod => {
                                                            |ib: &Builder, l: FloatValue, r| {
                                                                ib.build_float_rem(l, r, "r")
                                                            }
                                                        }
                                                    };

                                                    if left_ty.is_sample() {
                                                        let s_ptr = ll_registers[out.0];
                                                        let l_ptr = ll_registers[args[0].0];
                                                        let r_ptr = ll_registers[args[1].0];
                                                        let s_ty = self
                                                            .c
                                                            .sample
                                                            .get(self.ctx())
                                                            .into_struct_type();
                                                        let f_ty = self.ctx().f64_type();
                                                        for i in 0..=1 {
                                                            ib.build_store(
                                                                gep!(s_ty, s_ptr, i, "s"),
                                                                f(
                                                                    &ib,
                                                                    load!(
                                                                        f_ty,
                                                                        gep!(s_ty, l_ptr, i, "lp"),
                                                                        "l"
                                                                    )
                                                                    .into_float_value(),
                                                                    right_val(
                                                                        self,
                                                                        &ib,
                                                                        load!(
                                                                            f_ty,
                                                                            gep!(
                                                                                s_ty, r_ptr, i,
                                                                                "rp"
                                                                            ),
                                                                            "r"
                                                                        )
                                                                        .into_float_value(),
                                                                    ),
                                                                ),
                                                            );
                                                        }
                                                    } else {
                                                        ib.build_store(
                                                            ll_registers[out.0],
                                                            f(
                                                                &ib,
                                                                arg_vec[0].into_float_value(),
                                                                right_val(
                                                                    self,
                                                                    &ib,
                                                                    arg_vec[1].into_float_value(),
                                                                ),
                                                            ),
                                                        );
                                                    }
                                                } else {
                                                    let f: fn(_, _, _) -> _ = match op {
                                                        BinOp::Add => {
                                                            |ib: &Builder, l: IntValue, r| {
                                                                ib.build_int_add(l, r, "r")
                                                            }
                                                        }
                                                        BinOp::Sub => {
                                                            |ib: &Builder, l: IntValue, r| {
                                                                ib.build_int_sub(l, r, "r")
                                                            }
                                                        }
                                                        BinOp::Mul => {
                                                            |ib: &Builder, l: IntValue, r| {
                                                                ib.build_int_mul(l, r, "r")
                                                            }
                                                        }
                                                        BinOp::Div => {
                                                            |ib: &Builder, l: IntValue, r| {
                                                                ib.build_int_signed_div(l, r, "r")
                                                            }
                                                        }
                                                        BinOp::Mod => {
                                                            |ib: &Builder, l: IntValue, r| {
                                                                ib.build_int_signed_rem(l, r, "r")
                                                            }
                                                        }
                                                    };
                                                    ib.build_store(
                                                        ll_registers[out.0],
                                                        f(
                                                            &ib,
                                                            arg_vec[0].into_int_value(),
                                                            arg_vec[1].into_int_value(),
                                                        ),
                                                    );
                                                }
                                            }
                                            Phase => {
                                                ib.build_store(ll_registers[out.0], phase.unwrap());
                                            }
                                        }
                                    }
                                }
                            }
                            Insn::Const { out, value } => {
                                use DynamicValue::*;
                                match value {
                                    Number(n) => {
                                        ib.build_store(
                                            ll_registers[out.0],
                                            self.ctx().f64_type().const_float(*n),
                                        );
                                    }
                                    Integer(n) => {
                                        ib.build_store(
                                            ll_registers[out.0],
                                            self.ctx().i64_type().const_int(
                                                u64::from_ne_bytes(n.to_ne_bytes()),
                                                false,
                                            ),
                                        );
                                    }
                                }
                            }
                            Insn::DebugInfo { loc } => {
                                self.dib.as_ref().map(|(db, sc)| {
                                    ib.set_current_debug_location(db.create_debug_location(
                                        self.ctx(),
                                        loc.line,
                                        loc.column,
                                        sc.as_debug_info_scope(),
                                        None,
                                    ));
                                });
                            }
                        }
                    }
                    match &bb.jump {
                        JumpInsn::Ret(arg) => {
                            if ll_func.get_type().get_return_type().is_none() {
                                ib.build_return(None);
                            } else {
                                let ret_v =
                                    arg.as_ref().map(|reg| load!(reg)).unwrap_or_else(|| {
                                        self.ctx().const_struct(&[], false).as_basic_value_enum()
                                    });
                                ib.build_return(Some(&ret_v));
                            }
                        }
                        JumpInsn::Br(target) => {
                            ib.build_unconditional_branch(ll_blocks[target.0]);
                        }
                        JumpInsn::BrIf { cond, tru, fls } => {
                            ib.build_conditional_branch(
                                load!(cond).into_int_value(),
                                ll_blocks[tru.0],
                                ll_blocks[fls.0],
                            );
                        }
                    }
                }
            }
            Ok(())
        }
    }
}
