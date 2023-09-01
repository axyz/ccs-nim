discard """
output: '''
/* hello */
@foo bar {
  .hello {
    /* nested comment */
    aaa: bbb !important;
  }
}
@media screen {
  ._hi {
    height: 100px;
  }
}
.aaa {
  foo: bar;
  @media xx:aaa + dd ee {
    a: b;
    c: d;
    @nest &:deeply+inside {
      /* deeply nested comment */
      e: f;
      g: h;
    }
  }
}
.a:hover, .c:focus + div a {
  a: b;
}
'''
"""

import ccspkg/[ast, format/ccs]

let sheet = newSheet @[
  newComment(" hello "),
  newAtRule("foo", "bar", @[
    newRule(".hello", @[
      newComment(" nested comment "),
      newDecl("aaa", "bbb !important")
    ])
  ]),
  newAtRule("media", "screen", @[
    newRule("._hi", @[
      newDecl("height", "100px")
    ])
  ]),
  newRule(".aaa", @[
    newDecl("foo", "bar"),
    newAtRule("media", "xx:aaa + dd ee", @[
      newDecl("a", "b"),
      newDecl("c", "d"),
      newAtRule("nest", "&:deeply+inside", @[
        newComment(" deeply nested comment "),
        newDecl("e", "f"),
        newDecl("g", "h"),
      ])
    ])
  ]),
  newRule(".a:hover, .c:focus + div a", @[
    newDecl("a", "b")
  ])
]

echo sheet.toCcs(pretty=true)
