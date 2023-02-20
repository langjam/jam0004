#[derive(Debug, PartialEq)]
pub struct Stack<const N: usize> {
    pub inner: [u8; N],
    pub capacity: usize,
    pub pointer: usize,
}

impl<const N: usize> Stack<N> {
    pub fn new() -> Self {
        Self {
            inner: [0_u8; N],
            capacity: N,
            pointer: 0,
        }
    }

    pub fn current(&self) -> &u8 {
        &self.inner[self.pointer]
    }

    pub fn current_mut(&mut self) -> &mut u8 {
        &mut self.inner[self.pointer]
    }

    pub fn previous(&self) -> &u8 {
        &self.inner[self.pointer.saturating_sub(1)]
    }

    pub fn previous_mut(&mut self) -> &mut u8 {
        &mut self.inner[self.pointer.saturating_sub(1)]
    }

    pub fn iter(&self) -> core::slice::Iter<'_, u8> {
        self.inner.iter()
    }

    pub fn into_iter(self) -> core::array::IntoIter<u8, N> {
        self.inner.into_iter()
    }
}

impl<const N: usize> Default for Stack<N> {
    fn default() -> Self {
        Self::new()
    }
}
