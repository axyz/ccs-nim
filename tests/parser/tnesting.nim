import ccspkg/[test_utils, ast]

let atRuleInsideRule = newSheet @[
  newRule(".foo", @[
    newAtRule("media", "x", @[
      newDecl("b", "c")
    ])
  ])
]

testParse(".foo { @media x { b: c } }", atRuleInsideRule)

let atRuleInsideAtRule = newSheet @[
  newAtRule("foo", "bar", @[
    newAtRule("media", "x", @[
      newDecl("b", "c")
    ])
  ])
]

testParse("@foo bar { @media x { b: c } }", atRuleInsideAtRule)



