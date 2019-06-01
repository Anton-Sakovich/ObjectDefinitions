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
	(this : sym[_, _])[expr_] := this[expr, sym],
	sym[state_, type_][expr_, caller_] := parent[state, type][expr, caller],
	sym /: (sym@override@lhs_ := rhs_) := addOverridenDefinition[{sym, parent}, lhs, rhs],
	sym /: (sym@virtual@lhs_ := rhs_) := CompoundExpression[
		addAbstractDefinition[sym, lhs],
		addOverridenDefinition[{sym, parent}, lhs, rhs]
	],
	(* sym@sym[...] := {base[...], ...} or sym@sym[...] := {this[...], ...}
	** are considered as a constructor definition. The first part of the List
	** must be either base[...] or this[...] to ensure that a correct expression
	** is passed to new operator. *)
	sym /: (sym@lhs_sym := (rhs : {_this | _base, _})) := addCtorDefinition[{sym, parent}, lhs, rhs],
	sym /: (sym@lhs_ := abstract) := addAbstractDefinition[sym, lhs],
	sym /: (sym@lhs_ := rhs_) := addInstanceDefinition[sym, lhs, rhs]
]


ClearAll[addInstanceDefinition]

SetAttributes[addInstanceDefinition, HoldRest]

addInstanceDefinition[sym_, lhs_, rhs_] := SetDelayed @@ Hold[
	(this : sym[_, _])[lhs, _], rhs
]


ClearAll[addAbstractDefinition]

SetAttributes[addAbstractDefinition, HoldRest]

addAbstractDefinition[sym_, lhs_] := SetDelayed @@ Hold[
	sym[state_, type_][expr:lhs, _], type[state, type][override[expr]]
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
		(this : sym[state_, type_])[override[lhs], _], newRhs
	]
]


ClearAll[addCtorDefinition]

SetAttributes[addCtorDefinition, HoldRest]

addCtorDefinition[{sym_, parent_}, lhs_, {initExpr_, ctorExpr_}] := CompoundExpression[
	With[
		{
			initFunction = Function @@ Hold[{this, base}, initExpr],
			ctorFunction = Function @@ Hold[{this}, ctorExpr, {HoldFirst}]
		},
		TagSetDelayed @@ Hold[
			sym,
			new[lhs, this_Symbol],
			CompoundExpression[
				this = sym @@ new[initFunction[sym, parent], this],
				ctorFunction[this],
				this
			]
		]
	]
]


Clear[new]

SetAttributes[new, HoldRest]

new::noctor = "`1` does not match any constructor.";

new[expr_] := Module[
	{this = Head[expr][Null, Head[expr]]},
	Catch[new[expr, this], $newMismatch]
]

new[expr_, _] := CompoundExpression[
	Message[new::noctor, expr],
	Throw[$Failed, $newMismatch]
]


Clear[object];

class[object, Null];

object::nodef = "`1` does not match any pattern of `2`.";

object /: new[object[], this_Symbol] := object[<||>, Last[this]];

object[_, _][expr_, caller_] := CompoundExpression[
	Message[object::nodef, expr, caller],
	$Failed
]


End[]

EndPackage[]

