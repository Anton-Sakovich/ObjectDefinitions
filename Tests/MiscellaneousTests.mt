(* Wolfram Language Test file *)

VerificationTest[
	Get["ObjectDefinitions`"],
	Null,
	TestID -> "ObjectDefinitions` is loaded without messages."
]

checkIfProtected[sname_String] := ToExpression[
	sname, StandardForm,
	Function[
		{sym},
		VerificationTest[
			sym = 1,
			1,
			{Set::wrsym},
			TestID -> "Symbol "<> sname <>" is protected."
		],
		{HoldFirst}
	]
];

checkIfProtected /@ Names["ObjectDefinitions`*"]