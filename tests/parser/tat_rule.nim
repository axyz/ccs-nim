import ccspkg/[test_utils, ast]

let complete = newSheet @[
  newAtRule("foo", "bar", @[
    newRule(".a", @[
      newDecl("a", "b")
    ])
  ])
]

testParse("@foo bar { .a { a: b } }", complete)

let empty = newSheet @[
  newAtRule "foo"
]

testParse("@foo;", empty)

let emptyWithParam = newSheet @[
  newAtRule("foo", "bar")
]

testParse("@foo bar;", emptyWithParam)

let multipleDeclarations = newSheet @[
  newAtRule("foo", "bar", @[
    newRule(".a", @[
      newDecl("b", "c"),
      newDecl("d", "e")
    ])
  ])
]

testParse("@foo bar { .a { b: c; d: e } }", multipleDeclarations)
testParse("@foo bar { .a { b: c; d: e; } }", multipleDeclarations)


