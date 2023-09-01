import ccspkg/[test_utils, ast]

testParse(
".foo { a: b }", 

newSheet @[
  newRule(".foo", @[
    newDecl("a", "b")
  ])
])

let multipleDeclarations = newSheet @[
  newRule(".foo", @[
    newDecl("a", "b"),
    newDecl("c", "d")
  ])
]

testParse(".foo { a: b; c: d }", multipleDeclarations)
testParse(".foo { a: b; c: d; }", multipleDeclarations)

let complexSelector = newSheet @[
  newRule(".a:hover, .c:focus + div", @[
    newDecl("a", "b")
  ])
]

testParse(".a:hover, .c:focus + div { a: b }", complexSelector)


