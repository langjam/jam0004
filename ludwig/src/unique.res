type t = int

let last = ref(0)

let fresh = () => {
  let unique = last.contents
  last := last.contents + 1
  unique
}

let compare = compare

let eq = (x, y) => x == y

let display = Belt.Int.toString

module Comparable = Belt.Id.MakeComparable({
  type t = t
  let cmp = compare
})

module Hashable = Belt.Id.MakeHashable({
  type t = t
  let eq = eq
  let hash = x => x
})
