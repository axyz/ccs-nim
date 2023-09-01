{.warning[ProveField]: on.}
import std/[os, streams]
import ccspkg/[parser, ast]
import options
import std/tables
import std/strutils
import macros

func getNestedSelector(node: Node): string =
  var selector = ""
  var n = node
  case n.kind
  of AtRule:
    if n.name != "nest": discard
    while n.parent.isSome:
      case n.parent.get.kind
      of Rule:
          selector = n.parent.get.selector & " " & n.params.replace("&", n.parent.get.selector) & selector
      else: discard
      n = n.parent.get
  else: discard
  result = selector
 
func unnest(root: Node, prefix: string = "", sheet: Node = newSheet()): Node =
  result = sheet
  for node in root.allChildren:
    if node.parent.isSome and node.parent.get.kind != Sheet:
      case node.kind
      of {Comment,Rule}:
        sheet.add(node)
      of AtRule:
        var newNode = newRule(getNestedSelector(node), node.children)
        sheet.add(newNode)
      else: discard
     
when isMainModule:
  var strm: Stream

  if paramCount() == 1:
    strm = newFileStream(commandLineParams()[0], fmRead)
  else:
    strm = newStringStream("""
@media screen {
  .a {
    b: c
  }
}
.aaa { 
  foo: bar;
  @nest & .xx, &:hover {
    a: b;
    @nest &:focus {
      c: d;
    }
  }
}
""")

  var root = parse(strm, "foo")
  root.walkAtRules do (n: Node):
    if n.name == "media":
      n.remove
  root.walkAtRules do (n: Node): debugEcho($n.kind & " " & $n.parent.get().kind)
  #root = unnest(root)

  # for node in root.allChildren:
  #   case node.kind
  #   of Rule:
  #     node.selector = ".andrea"
  #   of AtRule:
  #     node.name = "axyz"
  #   else: discard


  echo $root

let b = newSheet(@[
  newRule("empty"),
  newRule("aaa", @[
    newDecl("foo", "bar"),
    newAtRule("empty"),
    newAtRule("media", "screen", @[
      newComment("comment"),
      newRule("hello"),
      newRule("whorld", @[
        newDecl("aaa", "bbb")
      ])
    ]),
    newAtRule("media", "", @[
      newRule("hello2")
    ])
  ])
])

