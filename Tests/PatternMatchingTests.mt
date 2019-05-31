(* Wolfram Language Test file *)

<<ObjectDefinitions`


class@class1;

class1@class1[] := {base[], Null};

class1@virtual@virtMeth[x_Integer] := {this, class1, virtMeth[_Integer]};


class[class2, class1];

class2@class2[] := {base[], Null};

class2@override@virtMeth[x_Integer?Positive] := {this, class2, virtMeth[_Integer?Positive]};


class[class3, class2]

class3@class3[] := {base[], Null};

class3@override@virtMeth[x_Integer] := {this, class3, virtMeth[_Integer]};


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