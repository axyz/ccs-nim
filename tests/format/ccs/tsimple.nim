discard """
output: '''
/* hello */@foo bar{.hello{aaa:bbb !important;}}.aaa{foo:bar;}
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
  newRule(".aaa", @[
    newDecl("foo", "bar"),
  ]),
]

echo sheet.toCcs
