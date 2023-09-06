discard """
output: '''
@media screen and (min-width:768px) {
  .a {
    b: c;
  }
}
@media screen and (min-width:1024px) {
  .d {
    e: f;
  }
}
.foo {
  @nest & .bar {
    @media screen and (min-width:768px) {
      g: h;
    }
  }
}
'''
"""

import streams
import ccspkg/[processor, plugins/custom_media, parser, format/ccs]

let strm = newStringStream("""
@custom-media --tablet screen and (min-width: 768px);
@custom-media --desktop screen and (min-width: 1024px);
@media --tablet {
  .a {
    b: c
  }
}
@media --desktop {
  .d {
    e: f
  }
}
.foo {
  @nest & .bar {
    @media --tablet {
      g: h
    }
  }
}
""")

var root = parse(strm, "file.ccs")
 
let p = newProcessor(@[
  newCustomMediaPlugin()
])

p.process(root)

echo root.toCcs(pretty=true)
