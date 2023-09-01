import strutils, lexer, streams, ast

#------------------------------------------------------------------------------#

func parseComment(l: Lexer): Node =
  newComment(l.str)

func parseDecl(l: var Lexer): Node =
  let prop = l.str
  assert l.next == tkColon
  assert l.next == tkWord
  var value = l.str
  while not (l.peek in {';', '}'}):
    l.skip(Whitespace)
    if not (l.peek in {';', '}'}):
      discard l.next
      value.add(" " & l.str)
  newDecl(prop, value)

func parseBlock(l: var Lexer, root: bool): seq[Node]

func parseAtRule(l: var Lexer, root: bool = false): Node =
  assert l.next == tkWord
  let name = l.str
  var params = ""
  var nodes: seq[Node] = @[]
  l.skip(Whitespace)
  if l.peek == '{':
    nodes.add(l.parseBlock(root))
  else:
    case l.next
    of tkWord:
      params = l.str
      l.skip(Whitespace)
      while not (l.peek in {'{', ';'}):
        if l.peek in WordChars and params[^1] in WordChars:
          params.add(" ")
        discard l.next
        params.add(l.str)
        l.skip(Whitespace)
      if l.peek == '{':
        nodes.add(l.parseBlock(root))
      else: discard
    else: discard
  result = newAtRule(name, params.strip)
  result.add(nodes)

func parseRule(l: var Lexer): Node =
  var selector = l.str
  l.skip(Whitespace)
  while l.peek != '{':
    if l.peek in WordChars and selector[^1] in WordChars:
      selector.add(" ")
    discard l.next
    selector.add(l.str)
    l.skip(Whitespace)
  var nodes: seq[Node] = @[]
  nodes.add(l.parseBlock(root = false))
  result = newRule(selector.strip)
  result.add(nodes)

func parseBlockChild(l: var Lexer, root: bool): seq[Node] =
  result = @[]
  l.skip(Whitespace)
  if l.peek == '}': return
  case l.next
  of tkAt:
    result.add(l.parseAtRule)
    result.add(l.parseBlockChild(root))
  of tkWord:
    if root:
      result.add(l.parseRule)
    else:
      result.add(l.parseDecl)
      if l.peek == ';':
        assert l.next == tkSemicolon
      else: discard
    result.add(l.parseBlockChild(root))
  of tkComment:
    result.add(l.parseComment)
    result.add(l.parseBlockChild(root))
  else: discard

func parseBlock(l: var Lexer, root: bool): seq[Node] =
  result = @[]
  l.skip(Whitespace)
  if l.peek != '{': return
  assert l.next == tkBlockStart
  l.skip(Whitespace)
  result.add(l.parseBlockChild(root))
  l.skip(Whitespace)
  assert l.next == tkBlockEnd

proc parse*(input: Stream, fileName: string): Node =
  var l: Lexer
  l.open(input, fileName)
  result = newSheet()
  while l.next != tkEof:
    case l.kind
    of tkComment: result.add(l.parseComment)
    of tkAt: result.add(l.parseAtRule(root = true))
    of tkWord: result.add(l.parseRule)
    else: discard
