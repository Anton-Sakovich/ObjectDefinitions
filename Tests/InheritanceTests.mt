(* Wolfram Language Test file *)

<<ObjectDefinitions`


ClearAll[class1];

class@class1;


class1@instMeth1[] := {this, class1, instMeth1};

class1@abstMeth1[] := abstract;

class1@virtual@virtMeth1[] := {this, class1, virtMeth1};


class1@abstMeth2[] := abstract;

class1@virtual@virtMeth2[] := {this, class1, virtMeth2};


class1@abstMeth3[] := abstract;

class1@virtual@virtMeth3[] := {this, class1, virtMeth3};


ClearAll[class2];

class[class2, class1];


class2@instMeth4[] := {this, class2, instMeth4};

class2@override@abstMeth2[] := {this, class2, abstMeth2};

class2@override@virtMeth2[] := {this, class2, virtMeth2, base@override@virtMeth2[]};


ClearAll[class3];

class[class3, class2];


class3@override@abstMeth3[] := {this, class3, abstMeth3};

class3@override@virtMeth3[] := {this, class3, virtMeth3, base@override@virtMeth3[]};


ClearAll[class4];

class[class4, class3];


class4@override@abstMeth2[] := {this, class4, abstMeth2, base@override@abstMeth2[]};

class4@override@virtMeth2[] := {this, class4, virtMeth2, base@override@virtMeth2[]};


VerificationTest[
	class2[{}, class2]@instMeth1[],
	{class1[{}, class2], class1, instMeth1},
	TestID -> "Insatnce methods are inherited correctly (one step behind)"
]

VerificationTest[
	class4[{}, class4]@instMeth4[],
	{class2[{}, class4], class2, instMeth4},
	TestID -> "Insatnce methods are inherited correctly (two steps behind)"
]

VerificationTest[
	class4[{}, class4]@instMeth1[],
	{class1[{}, class4], class1, instMeth1},
	TestID -> "Insatnce methods are inherited correctly (four steps behind)"
]

VerificationTest[
	class2[{}, class2]@abstMeth2[],
	{class2[{}, class2], class2, abstMeth2},
	TestID -> "Abstracts methods are inherited correctly (one step behind)"
]

VerificationTest[
	class2[{}, class2]@virtMeth2[],
	{class2[{}, class2], class2, virtMeth2, {class1[{}, class2], class1, virtMeth2}},
	TestID -> "Virtual methods are inherited correctly (one step behind)"
]

VerificationTest[
	class3[{}, class3]@abstMeth3[],
	{class3[{}, class3], class3, abstMeth3},
	TestID -> "Abstracts methods are inherited correctly (two steps behind)"
]

VerificationTest[
	class3[{}, class3]@virtMeth3[],
	{class3[{}, class3], class3, virtMeth3, {class1[{}, class3], class1, virtMeth3}},
	TestID -> "Virtual methods are inherited correctly (two steps behind)"
]

VerificationTest[
	class4[{}, class4]@abstMeth2[],
	{class4[{}, class4], class4, abstMeth2, {class2[{}, class4], class2, abstMeth2}},
	TestID -> "Abstract methods are inherited correctly (two overrides)"
]

VerificationTest[
	class4[{}, class4]@virtMeth2[],
	{class4[{}, class4], class4, virtMeth2, {class2[{}, class4], class2, virtMeth2, {class1[{}, class4], class1, virtMeth2}}},
	TestID -> "Virtual methods are inherited correctly (two overrides)"
]