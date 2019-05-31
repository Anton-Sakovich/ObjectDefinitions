(* Wolfram Language Package *)

(* Created by the Wolfram Workbench Apr 12, 2019 *)

BeginPackage["ObjectDefinitions`"]
(* Exported symbols added here with SymbolName::usage *)

class::usage="class[sym] makes symbol sym a class.
class[sym, base] makes symbol sym a class extending base.";

new::usage="new@cls[expr1, expr2, ...] instantiates a new expression of class cls using \
cls[expr1, expr2, ...] as the constructor expression.";

this::usage="this refers to an object whose method was called casted to a class \
whose definition is currently evaluating.";

base::usage="base refers to an object whose method was called casted to a class \
which is the base class of the class whose definition is currently evaluating.";

abstract::usage="abstract is a symbol which can be assigned to a method to make it abstract.";

virtual::usage="virtual is a symbol which can wrap a method pattern to make it virtual.";

override::usage="override is a symbol which can wrap a method pattern to make it override.";

object::usage="object is a base class of all classes in ObjectDefinitions.";

Begin["`Private`"]
(* Implementation of the package *)


Clear[class]

class[sym_Symbol, parent_Symbol : object] := CompoundExpression[
	sym[state_, type_][expr_] := parent[state, type][expr],
	sym /: (sym@override@lhs_ := rhs_) := addOverridenDefinition[{sym, parent}, lhs, rhs],
	sym /: (sym@virtual@lhs_ := rhs_) := CompoundExpression[
		addAbstractDefinition[sym, lhs],
		addOverridenDefinition[{sym, parent}, lhs, rhs]
	],
	sym /: (sym@lhs_sym := rhs_) := addCtorDefinition[{sym, parent}, lhs, rhs],
	sym /: (sym@lhs_ := abstract) := addAbstractDefinition[sym, lhs],
	sym /: (sym@lhs_ := rhs_) := addInstanceDefinition[sym, lhs, rhs]
]


ClearAll[addInstanceDefinition]

SetAttributes[addInstanceDefinition, HoldRest]

addInstanceDefinition[sym_, lhs_, rhs_] := SetDelayed @@ Hold[
	(this : sym[_, _])[lhs], rhs
]


ClearAll[addAbstractDefinition]

SetAttributes[addAbstractDefinition, HoldRest]

addAbstractDefinition[sym_, lhs_] := SetDelayed @@ Hold[
	sym[state_, type_][expr:lhs], type[state, type][override[expr]]
]


ClearAll[addOverridenDefinition]

SetAttributes[addOverridenDefinition, HoldRest]

addOverridenDefinition[{sym_, parent_}, lhs_, rhs_] := ReplaceAll[
	With @@ Hold[
		{
			base = parent[state, type]
		},
		Hold[rhs]
	],
	Hold[newRhs_] :> SetDelayed @@ Hold[
		(this : sym[state_, type_])[override[lhs]], newRhs
	]
]


ClearAll[addCtorDefinition]

SetAttributes[addCtorDefinition, HoldRest]

addCtorDefinition[{sym_, parent_}, lhs_, {baseInitExpr_, thisInitExpr_}] := CompoundExpression[
	With[
		{
			basef = Function @@ Hold[{base}, baseInitExpr],
			thisf = Function @@ Hold[{this}, thisInitExpr, {HoldFirst}]
		},
		TagSetDelayed @@ Hold[
			sym,
			new[lhs, this_Symbol],
			CompoundExpression[
				this = sym @@ new[basef[parent], this],
				thisf[this],
				this
			]
		]
	],
	sym /: new[expr:lhs] := Module[{this = sym[Null, sym]}, new[expr, this]]
]


Clear[new]

SetAttributes[new, HoldRest]

new::noctor = "`1` does not match any constructor.";

new[expr_, _] := CompoundExpression[
	Message[new::noctor, expr],
	$Failed
]


Clear[object];

class[object, Null];

object::nodef = "`1` does not match any pattern of `2`.";

(*This definition is required to register object[] pattern as an object's
constructor*)
object@object[] := {Null, Null};

(*This definition overrides the first definition from the two produced by
the previous definition*)
object /: new[object[], this_Symbol] := object[<||>, Last[this]];

object[_, type_][expr_] := CompoundExpression[
	Message[object::nodef, expr, type],
	$Failed
]


End[]

EndPackage[]

