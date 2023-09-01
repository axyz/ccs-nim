import std/hashes
import options
import std/sequtils
import std/sugar

type
  NodeKind* = enum
    Sheet,
    Comment,
    Rule,
    AtRule,
    Decl
  
  Node* = ref NodeObj
  NodeObj* {.acyclic.} = object
    case kind*: NodeKind
    of Sheet:
      sheetParent*: Option[Node]
      sheetNodes*: seq[Node]
    of Comment:
      commentParent*: Option[Node]
      text*: string
    of Rule:
      ruleParent*: Option[Node] 
      selector*: string
      ruleNodes*: seq[Node]
      ruleListeners*: seq[proc(n: Node)]
    of AtRule:
      atRuleParent*: Option[Node] 
      name*: string
      params*: string
      atRuleNodes*: seq[Node]
    of Decl:
      declParent*: Option[Node]
      prop*: string
      value*: string

#------------------------------------------------------------------------------#

func hash*(node: Node): Hash =
  var h: Hash = 0
  case node.kind
  of Comment: h = h !& hash(node.text)
  of Sheet: h = h !& hash(node.sheetNodes)
  of Rule: h = h !& hash(node.selector) !& hash(node.ruleNodes)
  of AtRule: h = h !& hash(node.name) !& hash(node.params) !& hash(node.atRuleNodes)
  of Decl: h = h !& hash(node.prop) !& hash(node.value)
  result = !$h

func `$`*(node: Node): string =
  case node.kind
  of Comment: "/*" & node.text & "*/"
  of Sheet: $node.sheetNodes
  of Rule: node.selector & " {" & $node.ruleNodes & "}"
  of AtRule: "@" & node.name & " " & node.params & " {" & $node.atRuleNodes & "}"
  of Decl: node.prop & ": " & node.value

func `==`*(a: Node, b: Node): bool =
  # TODO: proper field comparison
  $a == $b

func newComment*(text = ""): Node =
  Node(kind: Comment, text: text)

func newDecl*(prop: string, value: string): Node =
  Node(kind: Decl, prop: prop, value: value)

func `parent=`(self: Node, parent: Node) =
  assert self.kind != Sheet
  case self.kind
  of Comment:
    self.commentParent = some(parent)
  of Rule:
    self.ruleParent = some(parent)
  of AtRule:
    self.atRuleParent = some(parent)
  of Decl:
    self.declParent = some(parent)
  else:
    discard

func add*(self: Node, child: Node) =
  case self.kind
  of Sheet:
    assert child.kind in {Comment, Rule, AtRule}
    child.parent = self
    self.sheetNodes.add(child)
  of Rule:
    assert child.kind in {Comment, Decl, AtRule}
    child.parent = self
    self.ruleNodes.add(child)
  of AtRule:
    child.parent = self
    assert child.kind in {Comment, AtRule, Rule, Decl}
    self.atRuleNodes.add(child)
  else:
    discard
    
func `children=`*(self: Node, children: seq[Node]) =
  case self.kind
  of Sheet:
    self.sheetNodes = @[]
  of Rule:
    self.ruleNodes = @[]
  of AtRule:
    self.atRuleNodes = @[]
  else:
    discard
  for child in children:
    self.add(child)

func add*(self: Node, children: seq[Node]) =
  for child in children:
    self.add(child)

proc `selector=`*(self: Node, value: string) =
  assert self.kind == Rule
  self.selector = value
  for listener in self.ruleListeners:
    listener(self)

func newSheet*(children: varargs[Node]): Node =
  result = Node(kind: Sheet, sheetNodes: @[])
  for child in children:
    assert child.kind in {Comment, AtRule, Rule}
    result.add(child)

func newRule*(selector: string, children: varargs[Node]): Node =
  result = Node(kind: Rule, selector: selector, ruleNodes: @[])
  for child in children:
    assert child.kind in {Comment, Decl, AtRule}
    result.add(child)

func newAtRule*(name: string, params: string = "", children: varargs[Node]): Node =
  result = Node(kind: AtRule, name: name, params: params, atRuleNodes: @[])
  for child in children:
    assert child.kind in {Comment, AtRule, Rule, Decl}
    result.add(child)

func children*(self: Node): seq[Node] =
  case self.kind
  of Sheet: return self.sheetNodes
  of Rule: return self.ruleNodes
  of AtRule: return self.atRuleNodes
  else: return @[]

func parent*(self: Node): Option[Node] =
  case self.kind
  of Sheet: return none(Node)
  of Comment: return self.commentParent
  of Rule: return self.ruleParent
  of AtRule: return self.atRuleParent
  of Decl: return self.declParent

func remove*(self: Node) =
  if self.parent.isSome:
    let parent = self.parent.get()
    parent.children = parent.children.filter(a => a != self)

proc walk*(self: Node, visit: proc (n: Node)) =
  for child in self.children:
    visit(child)
    walk(child, visit)

proc walkRules*(self: Node, visit: proc(n: Node)) =
  self.walk do (n: Node):
    if n.kind == Rule:
      visit(n)

proc walkDecls*(self: Node, visit: proc(n: Node)) =
  self.walk do (n: Node):
    if n.kind == Decl:
      visit(n)

proc walkAtRules*(self: Node, visit: proc(n: Node)) =
  self.walk do (n: Node):
    if n.kind == AtRule:
      visit(n)

proc walkComments*(self: Node, visit: proc(n: Node)) =
  self.walk do (n: Node):
    if n.kind == Comment:
      visit(n)

func allChildren*(self: Node): seq[Node] =
  result = @[]
  for child in self.children:
    result.add(child)
    result.add(child.allChildren)

func rules*(self: Node): seq[Node] =
  result = @[]
  for child in self.children:
    case child.kind
    of Rule: result.add(child)
    else: discard

func allRules*(self: Node): seq[Node] =
  result = @[]
  case self.kind
  of {Sheet, AtRule, Rule}:
    for node in self.children:
      case node.kind
      of Rule: 
        result.add(node)
      else: discard
      result.add(node.allRules)
  else: discard

func atRules*(self: Node): seq[Node] =
  result = @[]
  for child in self.children:
    case child.kind
    of AtRule: result.add(child)
    else: discard
    
func allAtRules*(self: Node): seq[Node] =
  result = @[]
  case self.kind
  of {Sheet, AtRule, Rule}:
    for node in self.children:
      case node.kind
      of AtRule: 
        result.add(node)
      else: discard
      result.add(node.allAtRules)
  else: discard
    
func comments*(self: Node): seq[Node] =
  result = @[]
  for child in self.children:
    case child.kind
    of Comment: result.add(child)
    else: discard

func allComments*(self: Node): seq[Node] =
  result = @[]
  for node in self.children:
    case node.kind
    of Comment: 
      result.add(node)
    else: discard
    result.add(node.allComments)

