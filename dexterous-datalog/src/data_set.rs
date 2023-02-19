use crate::error::Error;
use crate::parser::{
    Atom, Const, Fact, Program, Query as QuerySyntax, Relation as RelationSyntax,
    Rule as RuleSyntax, Statement, Term as TermSyntax, Var,
};

use datafrog::{Iteration, JoinInput, Relation, Variable};

#[derive(Debug, Clone, PartialEq, PartialOrd, Ord, Eq)]
pub struct Tuple(Vec<usize>);

pub struct DataSet {
    relation_names: NamePool,
    constant_names: NamePool,
    variable_names: NamePool,

    rules: Vec<Rule>,

    iteration: Iteration,
    relations: Vec<Variable<Tuple>>,
}

impl Default for DataSet {
    fn default() -> Self {
        DataSet {
            relation_names: NamePool::default(),
            constant_names: NamePool::default(),
            variable_names: NamePool::default(),
            rules: Vec::new(),
            iteration: Iteration::new(),
            relations: Vec::new(),
        }
    }
}

impl DataSet {
    pub fn add_program(&mut self, program: &Program) -> Result<(), Error> {
        for statement in program {
            match statement {
                Statement::Fact(fact) => self.add_fact(fact)?,
                Statement::Rule(rule) => self.add_rule(rule)?,
            }
        }

        Ok(())
    }

    pub fn add_rule(&mut self, rule: &RuleSyntax) -> Result<(), Error> {
        let RuleSyntax(head, clauses) = rule;

        let mut variables = Binding::default();

        let goal = Goal::new(head, &mut variables, self)?;
        let sub_goals = clauses
            .iter()
            .map(|sub| Goal::new(sub, &mut variables, self))
            .collect::<Result<Vec<Goal>, Error>>()?;

        self.rules.push(Rule {
            variables,
            goal,
            sub_goals,
        });

        Ok(())
    }

    pub fn step(&mut self) {
        for i in 0..self.rules.len() {
            let rule = &self.rules[i];
            let new = rule.next(&self);
            self.merge_into(rule.relation(), new);
        }
    }

    pub fn run(&mut self) {
        while self.iteration.changed() {
            self.step();
        }
        println!("{}", self);
    }

    pub fn run_query(&mut self, query: &QuerySyntax) -> Result<(), Error> {
        let QuerySyntax(_sub_goals) = query;
        println!("I didn't quite get to this. :(");
        Ok(())
    }
}

impl DataSet {
    fn add_fact(&mut self, fact: &Fact) -> Result<(), Error> {
        let Fact(RelationSyntax(name), constants) = fact;

        let tuple = Tuple(
            constants
                .iter()
                .map(|Const(c)| self.constant_names.add_name(c))
                .collect(),
        );

        let new = Relation::from_vec(vec![tuple]);

        self.add_relation(name, new)?;

        Ok(())
    }

    fn declare_relation(&mut self, name: &str) -> usize {
        let rel = self.relation_names.add_name(name);
        if rel == self.relations.len() {
            self.relations.push(self.iteration.variable(name));
        }
        rel
    }

    fn merge_into(&mut self, rel: usize, to_merge: Relation<Tuple>) {
        self.relations[rel].insert(to_merge)
    }

    fn add_relation(&mut self, name: &str, new: Relation<Tuple>) -> Result<(), Error> {
        let rel = self.declare_relation(name);
        self.merge_into(rel, new);

        Ok(())
    }

    fn constants_count(&self) -> usize {
        self.constant_names.names.len()
    }
}

impl std::fmt::Display for DataSet {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for (rel, relation) in self.relations.iter().enumerate() {
            // stable is a [[tuple]] for generations
            for stable in relation.stable().iter() {
                for tuple in stable.iter() {
                    write!(f, "{}(", &self.relation_names[rel])?;
                    for elt in tuple.0.iter().map(|c| &self.constant_names[*c]) {
                        write!(f, "{elt}, ")?;
                    }
                    writeln!(f, ").")?;
                }
            }

            // recent and to_add are just one generation, so [tuple]
            for tuple in relation.recent().iter() {
                write!(f, "{}(", &self.relation_names[rel])?;
                for elt in tuple.0.iter().map(|c| &self.constant_names[*c]) {
                    write!(f, "{elt}, ")?;
                }
                writeln!(f, ").")?;
            }
        }

        Ok(())
    }
}

#[derive(Debug, Default)]
struct NamePool {
    names: Vec<String>,
}

impl NamePool {
    fn add_name(&mut self, name: &str) -> usize {
        for (i, n) in self.names.iter().enumerate() {
            if name == n {
                return i;
            }
        }

        let i = self.names.len();
        self.names.push(name.into());
        i
    }
}

impl std::ops::Index<usize> for NamePool {
    type Output = str;
    fn index(&self, index: usize) -> &Self::Output {
        &self.names[index]
    }
}

#[derive(Debug)]
enum Term {
    Constant(usize),
    Variable(usize),
}

#[derive(Debug)]
pub struct Goal {
    relation: usize,
    terms: Vec<Term>,
}

impl Goal {
    fn new(atom: &Atom, variables: &mut Binding, data: &mut DataSet) -> Result<Goal, Error> {
        let Atom(RelationSyntax(name), terms) = atom;

        let relation = data.declare_relation(name);

        let terms = terms
            .iter()
            .map(|t| match t {
                TermSyntax::Const(Const(c)) => Term::Constant(data.constant_names.add_name(c)),
                TermSyntax::Var(Var(var)) => {
                    let var_name_index = data.variable_names.add_name(var);
                    let v = variables.insert(var_name_index);
                    Term::Variable(v)
                }
            })
            .collect();

        Ok(Goal { relation, terms })
    }

    fn is_satisfied_by(&self, binding: &Binding, data: &DataSet) -> bool {
        let relation = &data.relations[self.relation];
        let tuple = self.make_tuple(binding);

        if relation.stable().iter().any(|gen| gen.contains(&tuple)) {
            return true;
        }

        relation.recent().iter().find(|t| t == &&tuple).is_some()
    }

    fn make_tuple(&self, binding: &Binding) -> Tuple {
        Tuple(
            self.terms
                .iter()
                .map(|term| match term {
                    Term::Constant(c) => *c,
                    Term::Variable(v) => binding[*v],
                })
                .collect(),
        )
    }
}

#[derive(Debug)]
pub struct Rule {
    // a mapping of all the variables in this rule and it's sub-goals into data
    // set's variable name pool.
    variables: Binding,
    goal: Goal,
    sub_goals: Vec<Goal>,
}

impl Rule {
    /// Produces a list of bindings that satisfy this rule.
    pub fn bindings(&self, data: &DataSet) -> impl Iterator<Item = Binding> {
        let mut buf = Vec::new();

        for binding in Counter::new(self.variables.len(), data.constants_count()).map(Binding) {
            for sub_goal in &self.sub_goals {
                if !sub_goal.is_satisfied_by(&binding, data) {
                    continue;
                }
            }

            buf.push(binding);
        }

        buf.into_iter()
    }

    pub fn next(&self, data: &DataSet) -> Relation<Tuple> {
        Relation::from_iter(
            self.bindings(data)
                .map(|binding| self.goal.make_tuple(&binding)),
        )
    }

    fn relation(&self) -> usize {
        self.goal.relation
    }
}

pub struct _Query {}

impl _Query {
    fn _search(&self, _data: &DataSet) -> Vec<Binding> {
        todo!()
    }
}

#[derive(Debug, Default, PartialEq, PartialOrd, Ord, Eq)]
pub struct Binding(Vec<usize>);

impl Binding {
    fn iter(&self) -> impl Iterator<Item = &usize> {
        self.0.iter()
    }

    fn len(&self) -> usize {
        self.0.len()
    }

    fn insert(&mut self, value: usize) -> usize {
        for (i, n) in self.iter().enumerate() {
            if value == *n {
                return i;
            }
        }

        let i = self.0.len();
        self.0.push(value);
        i
    }
}

impl std::ops::Index<usize> for Binding {
    type Output = usize;
    fn index(&self, index: usize) -> &Self::Output {
        &self.0[index]
    }
}

pub struct Counter {
    tup_len: usize,
    max: usize,
    end: usize,
    cursor: usize,
}

impl Counter {
    pub fn new(tup_len: usize, max: usize) -> Counter {
        Counter {
            tup_len,
            max,
            end: tup_len.pow(max as u32),
            cursor: 0,
        }
    }

    pub fn is_empty(&self) -> bool {
        self.cursor == self.end
    }
}

impl Iterator for Counter {
    type Item = Vec<usize>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.is_empty() {
            None
        } else {
            let mut buf = Vec::new();

            for i in 0..self.tup_len {
                let n = (self.cursor / self.max.pow(i as u32)) % self.max;
                buf.push(n);
            }

            self.cursor += 1;

            Some(buf)
        }
    }
}
