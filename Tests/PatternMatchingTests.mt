(* Wolfram Language Test file *)

<<ObjectDefinitions`


class@class1;

class1@class1[] := {base[], Null};

class1@virtual@virtMeth[x_Integer] := {this, class1, virtMeth[_Integer]};

class1@foo[] := this;
class1@foo[this_] := this;

class1@virtual@bar[] := {base, this};
class1@virtual@bar[this_, 1] := {base, this};
class1@virtual@bar[this_, 2] := {this};
class1@virtual@bar[this_, 3] := {base};
class1@virtual@bar[base_, 1, 1] := {base, this};
class1@virtual@bar[base_, 2, 1] := {this};
class1@virtual@bar[base_, 3, 1] := {base};
class1@virtual@bar[base_, this_] := {base, this};


class[class2, class1];

class2@class2[] := {base[], Null};

class2@override@virtMeth[x_Integer?Positive] := {this, class2, virtMeth[_Integer?Positive]};


class[class3, class2]

class3@class3[] := {base[], Null};

class3@override@virtMeth[x_Integer] := {this, class3, virtMeth[_Integer]};


obj1 = new @ class1[];

VerificationTest[
	obj1@foo[],
	class1[<||>, class1],
	TestID -> "class1@foo[] returns correctly"
]

VerificationTest[
	obj1@foo[1],
	1,
	TestID -> "class1@foo[this_] returns correctly"
]

VerificationTest[
	obj1@bar[],
	{object[<||>, class1], class1[<||>, class1]},
	TestID -> "class1@bar[] returns correctly"
]

VerificationTest[
	obj1@bar[1, 1],
	{object[<||>, class1], 1},
	TestID -> "class1@bar[this_, 1] returns correctly"
]

VerificationTest[
	obj1@bar[1, 2],
	{1},
	TestID -> "class1@bar[this_, 2] returns correctly"
]

VerificationTest[
	obj1@bar[1, 3],
	{object[<||>, class1]},
	TestID -> "class1@bar[this_, 3] returns correctly"
]

VerificationTest[
	obj1@bar[1, 1, 1],
	{1, class1[<||>, class1]},
	TestID -> "class1@bar[base_, 1, 1] returns correctly"
]

VerificationTest[
	obj1@bar[1, 2, 1],
	{class1[<||>, class1]},
	TestID -> "class1@bar[base_, 2, 1] returns correctly"
]

VerificationTest[
	obj1@bar[1, 3, 1],
	{1},
	TestID -> "class1@bar[base_, 3, 1] returns correctly"
]

VerificationTest[
	obj1@bar[-1, -2],
	{-1, -2},
	TestID -> "class1@bar[this_, base_] returns correctly"
]


obj2 = class1 @@ new@class2[];


VerificationTest[
	obj2@virtMeth[-1],
	{class1[<||>, class2], class1, virtMeth[_Integer]},
	TestID -> "Virtual methods are resolved correctly to class1"
]

VerificationTest[
	obj2@virtMeth[1],
	{class2[<||>, class2], class2, virtMeth[_Integer?Positive]},
	TestID -> "Virtual methods are resolved correctly to class2"
]


obj3 = class1 @@ new@class3[];


VerificationTest[
	obj3@virtMeth[-1],
	{class3[<||>, class3], class3, virtMeth[_Integer]},
	TestID -> "Virtual methods are resolved correctly to class3 (negative)"
]

VerificationTest[
	obj3@virtMeth[1],
	{class3[<||>, class3], class3, virtMeth[_Integer]},
	TestID -> "Virtual methods are resolved correctly to class3 (positive)"
]
