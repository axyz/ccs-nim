discard """
output: '''
/* hello */@foo bar{.hello{aaa:bbb !important;}}@media screen{._hi{height:100px;}}.aaa{foo:bar;@media xx:aaa + dd ee{a:b;c:d;}}.a:hover, .c:focus + div a{a:b;}
'''
"""

import ccspkg/[ast, format/ccs]

let sheet = newSheet @[
  newComment(" hello "),
  newAtRule("foo", "bar", @[
    newRule(".hello", @[
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
      newDecl("c", "d")
    ])
  ]),
  newRule(".a:hover, .c:focus + div a", @[
    newDecl("a", "b")
  ])
]

echo sheet.toCcs()
