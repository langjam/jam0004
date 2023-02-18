use crate::error::Error;
use crate::parser::{Constant, Fact, Program, Query, Relation as RelationSyntax, Statement};

use datafrog::Relation;

type Tuple = Vec<usize>;

#[derive(Default)]
pub struct DataSet {
    relation_names: NamePool,
    constant_names: NamePool,

    // a map of usize -> [tuple], where the indexes correspond to relation_names.
    relations: Vec<Relation<Tuple>>,
}

impl DataSet {
    pub fn add_program(&mut self, program: &Program) -> Result<(), Error> {
        for statement in program {
            match statement {
                Statement::Fact(fact) => self.add_fact(fact)?,
                Statement::Rule(rule) => println!("skipping rule {:?}", rule),
            }
        }

        Ok(())
    }

    pub fn run_query(&mut self, _query: &Query) -> Result<(), Error> {
        todo!()
    }
}

impl DataSet {
    fn add_fact(&mut self, fact: &Fact) -> Result<(), Error> {
        let Fact(RelationSyntax(name), constants) = fact;

        let tuple: Tuple = constants
            .iter()
            .map(|Constant(c)| self.constant_names.add_name(c))
            .collect();

        let new = Relation::from_vec(vec![tuple]);

        self.add_relation(name, new)?;

        Ok(())
    }

    fn add_relation(&mut self, name: &str, new: Relation<Tuple>) -> Result<(), Error> {
        debug_assert!(new.len() > 0);

        let rel = self.relation_names.add_name(name);

        if rel == self.relations.len() {
            self.relations.push(new);
        } else {
            // TODO: arity check?
            let mut tmp = Relation::from_vec(Vec::new());
            std::mem::swap(&mut tmp, &mut self.relations[rel]);
            self.relations[rel] = tmp.merge(new);
        }

        Ok(())
    }
}

impl std::fmt::Debug for DataSet {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for (rel, relation) in self.relations.iter().enumerate() {
            for tuple in &relation.elements {
                write!(f, "{}(", &self.relation_names[rel])?;
                for elt in tuple.iter().map(|c| &self.constant_names[*c]) {
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
