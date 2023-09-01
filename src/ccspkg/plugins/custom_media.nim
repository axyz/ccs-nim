import std/tables
import strutils
import ../plugin, ../ast

type
  CustomMediaPluginOptions* = ref object

func newCustomMediaPlugin*(
  options: CustomMediaPluginOptions = CustomMediaPluginOptions()
): Plugin =
  let mediaTable = newTable[string, string]()

  newPlugin(
    once = proc(node: Node) =
      node.walkAtRules do (n: Node):
        if n.name == "custom-media":
          var key = ""
          var value = ""
          var isKeyDone = false
          for char in n.params:
            if not (char in Whitespace) and not isKeyDone:
              key &= $char
            else:
              isKeyDone = true
              value &= $char
          value = value.strip

          mediaTable[key] = value
          n.remove,
    atRule = proc(n: Node) =
      if n.name == "media" and n.params in mediaTable:
        n.params = mediaTable[n.params]

  )
