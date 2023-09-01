import std/strutils
import ../ast

func toCcs*(
  self: Node, 
  pretty: bool = false, 
  level: Natural = 0, 
  padding: string = "  "
): string =
  func ind(s: string): string = 
    result = if pretty: indent(s, level, padding) else: s

  func nl(): string =
    result = if pretty: "\n" else: ""

  func spc(): string =
    result = if pretty: " " else: ""

  result = ""
  case self.kind
  of Comment: 
    result &= indent(
      "/*" & self.text & "*/",
      if pretty: level else: 0, 
      padding
    )
  of Sheet: 
    for i, node in self.children:
      result &= node.toCcs(pretty, level, padding)
      if i < self.children.len - 1: result &= nl()
  of Rule:
    result &= self.selector & spc() & "{" & nl()
    for node in self.children:
      result &= node.toCcs(pretty, 1, padding) & nl()
    result &= "}"
    result = ind(result)
  of AtRule:
    result &= "@" & self.name & " " & self.params
    if self.children.len > 0:
      result &= spc() & "{" & nl()
      for node in self.children:
        result &= node.toCcs(pretty, 1, padding) & nl()
      result &= "}"
    result = ind(result)
  of Decl:
    result &= indent(
      self.prop & ":" & spc() & self.value & ";", 
      if pretty: 1 else: 0, 
      padding
    )
