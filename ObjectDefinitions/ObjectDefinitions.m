(* Wolfram Language Package *)

(* Created by the Wolfram Workbench Apr 12, 2019 *)

BeginPackage["ObjectDefinitions`"]
(* Exported symbols added here with SymbolName::usage *)

class::usage="class[s]
class[s, b]";

new::usage="";

this::usage="";

base::usage="";

abstract::usage="";

virtual::usage="";

override::usage="";

object::usage="";

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
			this = sym[state, type],
			base = parent[state, type]
		},
		Hold[rhs]
	],
	Hold[newRhs_] :> SetDelayed @@ Hold[
		sym[state_, type_][override[lhs]], newRhs
	]
]


class @ object;

object::nodef = "`1` does not match any pattern of `2`.";

object[_, type_][expr_] := CompoundExpression[
	Message[object::nodef, HoldForm[expr], type],
	$Failed
]


End[]

EndPackage[]

