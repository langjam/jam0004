type t

let fresh: unit => t

let compare: (t, t) => int

let display: t => string

module Comparable : Belt.Id.Comparable with type t = t
module Hashable : Belt.Id.Hashable with type t = t