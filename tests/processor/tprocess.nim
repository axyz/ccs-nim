discard """
output: '''
/* Hello World! */
@bar screen {
  .baz {
    foo: c;
  }
}
.baz {
  foo: bar;
  @bar & .xx, &:hover {
    @bar &:focus {
      foo: d;
    }
  }
}
'''
"""

import streams
import ccspkg/[processor, plugin, parser, format/ccs, ast]


let strm = newStringStream("""
/* hello */
@media screen {
  .a {
    b: c
  }
}
.aaa { 
  foo: bar;
  @nest & .xx, &:hover {
    a: removeme;
    @nest &:focus {
      c: d;
    }
  }
}
""")

var root = parse(strm, "foo")
 
let p = newProcessor(@[
  newPlugin(
    decl = proc(n: Node) = n.prop = "foo",
    atRule = proc(n: Node) = n.name = "bar" ,
  ),
  newPlugin(
    comment = proc(n: Node) = n.text = " Hello World! " ,
    rule = proc(n: Node) = n.selector = ".baz" ,
  ),
  newPlugin(
    decl = proc(n: Node) = 
      if n.value == "removeme": n.remove
  )
])

p.process(root)

echo root.toCcs(pretty=true)
