use std::fmt::Display;

#[derive(Debug, PartialEq)]
pub struct Memory<const N: usize> {
    pub inner: [[u8; N]; N],
    pub capacity: usize,
    pub pointer: usize,
}

impl<const N: usize> Memory<N> {
    pub fn new() -> Self {
        Self {
            inner: [[0_u8; N]; N],
            capacity: N * N,
            pointer: 0,
        }
    }

    pub fn current(&self) -> &u8 {
        let x = self.pointer % N;
        let y = self.pointer / N;

        &self.inner[y][x]
    }

    pub fn current_mut(&mut self) -> &mut u8 {
        let x = self.pointer % N;
        let y = self.pointer / N;

        &mut self.inner[y][x]
    }

    pub fn iter(&self) -> core::slice::Iter<'_, [u8; N]> {
        self.inner.iter()
    }
}

impl<const N: usize> Default for Memory<N> {
    fn default() -> Self {
        Self::new()
    }
}

impl<const N: usize> IntoIterator for Memory<N> {
    type Item = [u8; N];
    type IntoIter = core::array::IntoIter<[u8; N], N>;

    fn into_iter(self) -> Self::IntoIter {
        todo!()
    }
}

// impl<const N: usize> Display for Memory<N> {
//     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
//         let message = self.inner.iter().fold("".to_owned(), |acc, row| {
//             format!(
//                 "{acc}{} |\n",
//                 row.iter()
//                     .fold("|".to_owned(), |acc, cell| format!("{acc} {cell}"))
//             )
//         });

//         write!(f, "{message}")
//     }
// }
