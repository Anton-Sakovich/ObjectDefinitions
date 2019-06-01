(* Wolfram Language Test file *)

<<ObjectDefinitions`


logOutput = {};


class@simple1;

simple1@simple1[x_] := {
	base[],
	this[[1, "x"]] = x
}

simple1@simple1[] := {
	this[0],
	Null
}


class[simple2, simple1]

simple2@simple2[x_, y_] := {
	base[x],
	this[[1, "y"]] = y
}

simple2@simple2[x_] := {
	this[x, x],
	Null
}

simple2@simple2[] := {
	this[0],
	Null
}


class@class1;

class1@class1[x_] := {
	base[],
	(*******************
	Here
		this = class1[<||>, type]
	must hold, where type is the initial type passed to new operator.
	********************)
	this[[1, "x"]] = x;
	(*******************
	Here
		this = class1[<|"x" -> 1|>, type]
	must hold, where type is the initial type passed to new operator.
	********************)
	AppendTo[logOutput, this@instMeth[]];
	AppendTo[logOutput, this@virtMeth[]];
};

class1@virtual@virtMeth[] := {this, class1, virtMeth};

class1@instMeth[] := {this, class1, instMeth};


class[class2, class1]

class2@class2[x_, y_] := {
	base[x],
	(*******************
	Here
		this = class2[<|"x" -> 1|>, type]
	must hold, where type is the initial type passed to new operator.
	********************)
	this[[1, "y"]] = y;
	(*******************
	Here
		this = class2[<|"x" -> 1, "y" -> 2|>, type]
	must hold, where type is the initial type passed to new operator.
	********************)
	AppendTo[logOutput, this@instMeth[]];
	AppendTo[logOutput, this@virtMeth[]];
}

class2@override@virtMeth[] := {this, class2, virtMeth};


VerificationTest[
	new@object[],
	object[<||>, object],
	TestID -> "object is instantiated correctly"
]


VerificationTest[
	new@simple1[1],
	simple1[<|"x" -> 1|>, simple1],
	TestID -> "Derived class is instantiated correctly (one step)"
]

VerificationTest[
	new@simple2[1, 2],
	simple2[<|"x" -> 1, "y" -> 2|>, simple2],
	TestID -> "Derived class is instantiated correctly (two steps)"
]


VerificationTest[
	new@simple1[],
	simple1[<|"x" -> 0|>, simple1],
	TestID -> "Constructor is correctly initialized by the same class (one step, simple1)"
]

VerificationTest[
	new@simple2[3],
	simple2[<|"x" -> 3, "y" -> 3|>, simple2],
	TestID -> "Constructor is correctly initialized by the same class (one step, simple2)"
]

VerificationTest[
	new@simple2[],
	simple2[<|"x" -> 0, "y" -> 0|>, simple2],
	TestID -> "Constructor is correctly initialized by the same class (two steps)"
]


VerificationTest[
	{
		new@class1[1],
		logOutput
	},
	{
		class1[<|"x" -> 1|>, class1],
		{
			{class1[<|"x" -> 1|>, class1], class1, instMeth},
			{class1[<|"x" -> 1|>, class1], class1, virtMeth}
		}
	},
	TestID -> "Methods are correctly resolved in ctor when defined in the same class"
]

logOutput = {};

VerificationTest[
	{
		new@class2[1, 2],
		logOutput
	},
	{
		class2[<|"x" -> 1, "y" -> 2|>, class2],
		{
			(*The following two expressions must be evaluated inside class1's ctor*)
			{class1[<|"x" -> 1|>, class2], class1, instMeth},
			{class2[<|"x" -> 1|>, class2], class2, virtMeth},
			(*The following two expressions must be evaluated inside class2's ctor*)
			{class1[<|"x" -> 1, "y" -> 2|>, class2], class1, instMeth},
			{class2[<|"x" -> 1, "y" -> 2|>, class2], class2, virtMeth}
		}
	},
	TestID -> "Methods are correctly resolved in ctor when inherited from base class"
]