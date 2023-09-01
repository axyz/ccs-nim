discard """
output: '''
/* hello */
@custom screen {
  .a {
    b: c;
  }
}
@custom hello {
  .d {
    e: f;
  }
}
'''
"""

import streams
import ccspkg/[processor, plugin, parser, format/ccs, ast]

type
  FooPluginOptions* = ref object
    atRule: string

func newFooPlugin*(options: FooPluginOptions = FooPluginOptions(atRule: "")): Plugin =
  newPlugin(
    atRule = proc(n: Node) = 
      if n.name == options.atRule: 
        n.name = "custom"
  )

let strm = newStringStream("""
/* hello */
@media screen {
  .a {
    b: c
  }
}
@media hello {
  .d {
    e: f
  }
}
""")

var root = parse(strm, "file.ccs")
 
let p = newProcessor(@[
  newFooPlugin(FooPluginOptions(atRule: "media"))
])

p.process(root)

echo root.toCcs(pretty=true)
