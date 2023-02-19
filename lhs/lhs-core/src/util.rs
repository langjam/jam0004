#[macro_export]
macro_rules! hashmap {
    () => {{
        use std::collections::HashMap;

        HashMap::new()
    }};
    ($($key:expr => $value:expr),*) => {{
        use std::collections::HashMap;

        let mut map = HashMap::new();
        $(map.insert($key, $value);)*

        map
    }};
}

// Converts a value into a string representation of its given base.
// will panic if  radix is less than 2 or greater than 36).
pub fn format_radix<T>(x: T, radix: u32) -> String
where
    T: Into<u32>,
{
    let mut result = vec![];
    let mut x = x.into();

    loop {
        let m = x % radix;
        x /= radix;

        result.push(std::char::from_digit(m, radix).unwrap());
        if x == 0 {
            break;
        }
    }

    result.into_iter().rev().collect()
}
