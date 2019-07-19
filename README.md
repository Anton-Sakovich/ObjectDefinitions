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

## How it works

Lets create an object definition for class `person`, whose objects are of the form `person[<|"FirstName" -> "...", "LastName" -> "..."|>, person]`.

```Mathematica
ClearAll[person];
person[data_, type_][introduce[], caller_: person] := TemplateApply[
  "Hello, my name is `FirstName` `LastName`!", data
]
```

Now we can create a `person` and check how she introduces herself:
```Mathematica
max = person[<|"FirstName" -> "Max", "LastName" -> "Caulfield"|>, person];
max@introduce[]
(*"Hello, my name is Max Caulfield!"*)
```

So far so good. Lets now derive a `student` class from our `person` class, which boils down to redirecting unknown
calls to `person`:

```Mathematica
ClearAll[student];
student[data_, type_][expr_, caller_: student] := person[data, type][expr, caller];
```

Now we can create a `student` instance and she will also be able to introduce herself:
```Mathematica
victoria = student[<|"FirstName" -> "Victoria", "LastName" -> "Chase", "Affiliation" -> "Blackwell Academy"|>, student];
victoria@introduce[]
(*"Hello, my name is Victoria Chase!"*)
```

She will do so even if casted back to `person` class:

```Mathematica
(person @@ victoria)@introduce[]
(*"Hello, my name is Victoria Chase!"*)
```

At this point we might want to extend `introduce[]` method for `student` to include also affiliation. We can do so making
another object definition:

```Mathematica
student[data_, type_][introduce[], caller_: student] := StringJoin[
   person[data, type]@introduce[],
   TemplateApply[
     " I am studying at `Affiliation`.", data
   ]
];
```

Now `student`'s introduction includes affiliation as well:

```Mathematica
victoria@introduce[]
(*"Hello, my name is Victoria Chase! I am studying at Blackwell Academy."*)
```

But this extension is not polymorphic: when casted back to `person`, `victoria` uses `person`'s implementation:

```Mathematica
(person @@ victoria)@introduce[]
(*"Hello, my name is Victoria Chase!"*)
```

In OOP terms, `student`'s definition _hides_ that of `person`. We can make it polymorphic in the following way: we will make `person` redirect calls to `introduce[]` to the object's real type:

```Mathematica
person[data_, type_][introduce[], caller_: person] := type[data, type]@override@introduce[];
person[data_, type_][override@introduce[], caller_: person] := TemplateApply[
   "Hello, my name is `FirstName` `LastName`!", data
];
```

And the same with `student`'s `introduce[]`:

```Mathematica
student[data_, type_][introduce[], caller_: student] := type[data, type]@override@introduce[];
student[data_, type_][override@introduce[], caller_: student] := StringJoin[
   person[data, type]@override@introduce[],
   TemplateApply[
    " I am studying at `Affiliation`.", data
   ]
];
```

Notice that this time we use `person[data, type]@override@introduce[]` rather than `person[data, type]@introduce[]` for calling base
class' implementation to avoid recursion. Now `max` still introduces herself as a person:

```Mathematica
max@introduce[]
(*"Hello, my name is Max Caulfield!"*)
```

and `victoria` introduces herself as a student even when casted back to `person`:

```Mathematica
(person @@ victoria)@introduce[]
(*"Hello, my name is Victoria Chase! I am studying at Blackwell Academy."*)
```
