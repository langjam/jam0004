type t = int

let last = ref(0)

let fresh = () => {
  let unique = !last
  last := !last + 1
  unique
}

let compare = Int.compare

let display = Int.toString
