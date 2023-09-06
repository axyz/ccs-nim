import plugin, ast

type
  Processor* = ref object of RootObj
    plugins: seq[Plugin]

func newProcessor*(plugins: seq[Plugin]): Processor =
  Processor(plugins: plugins)

proc process*(self: Processor, node: Node) =
  for p in self.plugins:
    let plugin = p
    if node.kind == Sheet: plugin.once(node)

  for p in self.plugins:
    # FIXME: see https://github.com/nim-lang/Nim/issues/16740
    let plugin = p

    node.walk do (n: Node):
      case n.kind
      of Sheet: plugin.sheet(n)
      of AtRule: plugin.atRule(n)
      of Comment: plugin.comment(n)
      of Decl: plugin.decl(n)
      of Rule: plugin.rule(n)

  for p in self.plugins:
    let plugin = p

    node.walk do (n: Node):
      case n.kind
      of Sheet: plugin.sheetExit(n)
      of AtRule: plugin.atRuleExit(n)
      of Comment: plugin.commentExit(n)
      of Decl: plugin.declExit(n)
      of Rule: plugin.ruleExit(n)


