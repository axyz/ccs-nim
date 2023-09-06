discard """
output: '''
.a_hash_29 {
  b: c;
}
.a_hash_29 .foo_hash_17 {
  b: c;
}
'''
"""

import streams
import ccspkg/[ast, processor, plugins/css_modules, parser, format/ccs]

let strm = newStringStream("""
.a {
  b: c
}
.a .foo {
  b: c
}
""")

var root = parse(strm, "file.ccs")
 
func newLenHasher*(): Hasher =    
  newHasher(
    finalizer = proc(self: Hasher) =
      self.content = "hash_" & $self.content.len,
    updater = proc(self: Hasher, s: string, n: Node) =
      self.content &= $n
  )

let p = newProcessor(@[
  newCssModulesPlugin(CssModulesPluginOptions(
    newHasher: newLenHasher
  ))
])

p.process(root)

echo root.toCcs(pretty=true)
