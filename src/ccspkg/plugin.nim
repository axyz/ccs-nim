import ast

type
  Plugin* = ref object of RootObj
    once*: proc(n: Node)
    sheet*: proc(n: Node)
    sheetExit*: proc(n: Node)
    atRule*: proc(n: Node)
    atRuleExit*: proc(n: Node)
    comment*: proc(n: Node)
    commentExit*: proc(n: Node)
    decl*: proc(n: Node)
    declExit*: proc(n: Node)
    rule*: proc(n: Node)
    ruleExit*: proc(n: Node)


proc noop(n: Node) = discard

func newPlugin*(
  once: proc(n: Node) = noop,
  sheet: proc(n: Node) = noop,
  sheetExit: proc(n: Node) = noop,
  atRule: proc(n: Node) = noop,
  atRuleExit: proc(n: Node) = noop,
  comment: proc(n: Node) = noop,
  commentExit: proc(n: Node) = noop,
  decl: proc(n: Node) = noop,
  declExit: proc(n: Node) = noop,
  rule: proc(n: Node) = noop,
  ruleExit: proc(n: Node) = noop
): Plugin =
  Plugin(
    once: once, 
    sheet: sheet, 
    sheetExit: sheetExit, 
    atRule: atRule, 
    atRuleExit: atRuleExit, 
    comment: comment, 
    commentExit: commentExit, 
    decl: decl, 
    declExit: declExit, 
    rule: rule,
    ruleExit: ruleExit
  )
