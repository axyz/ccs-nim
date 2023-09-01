import ccspkg/[test_utils, ast]

let expected = newSheet @[
  newComment(" hello "),
  newAtRule("foo", "bar", @[
    newRule(".hello", @[
      newDecl("aaa", "bbb !important")
    ])
  ]),
  # TOFIX: preserve space after min-width
  newAtRule("media", "screen and (min-width:768px)", @[
    newRule("._hi", @[
      newDecl("height", "100px")
    ])
  ]),
  newRule(".aaa", @[
    newDecl("foo", "bar"),
    newAtRule("media", "xx:aaa + dd ee", @[
      newDecl("a", "b"),
      newDecl("c", "d")
    ])
  ]),
  newRule(".a:hover, .c:focus + div a", @[
    newDecl("a", "b")
  ])
]

testParse("""
/* hello */ 

@foo bar { .hello { aaa: bbb !important } }

@media screen and (min-width: 768px){
  ._hi { height: 100px; }
}

.aaa { 
  foo: bar; 
  @media xx:aaa + dd ee {
    a: b; 
    c: d
  }
}

.a:hover, .c:focus + div a {
  a: b;
}
""", expected)

