# Object Definitions

_Object Definitions_ is a package intended to simplify making object oriented definitions in Wolfram Language.

## Object oriented definition

An _object_ from _Object Definitions_'s point of view is an expression of the form:

```Mathematica
head[data, type]
```

where `head` and `type` are both `Symbol`s and `data` is any expression representing the object's per-instance data.

Both `head` and `type` have definitions of the form:

```Mathematica
symbol[data_, type_][lhs_, caller_ : symbol] := rhs
```

which we call an _object definition_. It defines a rule between a pattern `lhs_` (which can be any pattern, not just `Blank`)
and an expression `rhs` in an object oriented way. The idea behind this definition is that `type` and `head` in

```Mathematica
head[data, type]
```

stand for the object's type (class) and the interface through which we access the object (which can also be a class) respectively.
`caller_` pattern is used to match the interface through which an object was initially accessed in case `head` has changed
since the first access because of inheritance.
