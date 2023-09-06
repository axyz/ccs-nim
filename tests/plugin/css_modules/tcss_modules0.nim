discard """
output: '''
.a_hash {
  b: c;
}
.a_hash .foo_hash {
  b: c;
}
.a_hash:hover >:is(.foo_hash) ~ .a_hash::focus .foo_hash::active {
  b: c;
}
.a_hash {
  @nest & .foo_hash:hover {
    b: c;
  }
}
'''
"""

import streams
import ccspkg/[processor, plugins/css_modules, parser, format/ccs]

let strm = newStringStream("""
.a {
  b: c
}
.a .foo {
  b: c
}
.a:hover > :is(.foo) ~ .a::focus .foo::active {
  b: c
}
.a {
  @nest & .foo:hover {
    b: c
  }
}
""")

var root = parse(strm, "file.ccs")
 
let p = newProcessor(@[
  newCssModulesPlugin(CssModulesPluginOptions(
    newHasher: newTestHasher
  ))
])

p.process(root)

echo root.toCcs(pretty=true)
