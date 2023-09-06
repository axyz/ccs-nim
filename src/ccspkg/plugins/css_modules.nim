import std/tables
import strutils
import std/re
import ../plugin, ../ast

type
  CssModulesPluginOptions* = ref object
    newHasher*: proc(): Hasher

  Hasher* = ref object
    content*: string
    finalizer: proc(self: Hasher)
    updater: proc(self: Hasher, s: string, n: Node)
    finalized: bool

func newHasher*(
  finalizer: proc(self: Hasher) = proc(self: Hasher) =
    discard,
  updater: proc(self: Hasher, s: string, n: Node) = proc(self: Hasher, s: string, n: Node) =
    self.content &= s
): Hasher =
  Hasher(
    content: "", 
    finalizer: finalizer,
    updater: updater,
    finalized: false
  )

proc update(self: Hasher, s: string, n: Node) =
  if self.finalized: discard
  self.updater(self, s, n)

proc finalize(self: Hasher): string =
  if not self.finalized: self.finalizer(self)
  self.finalized = true
  self.content

proc replaceWithHashedClasses*(str: string, t: TableRef[string, Hasher]): string =
  let reClass = re"(\.[\w-_][\w\d-_]*)"
  let doneTable = newTable[string, bool]()
  let classes = findall(str, reClass)
  result = str
  for class in classes:
    if not doneTable.contains(class):
      result = replace(result, class, class & "_" & t[class].finalize)
      doneTable[class] = true

func newContentHasher*(): Hasher =    
  newHasher(
    finalizer = proc(self: Hasher) =
      self.content = "hash_" & $self.content.len
  )

func newTestHasher*(): Hasher =    
  newHasher(
    finalizer = proc(self: Hasher) = self.content = "hash"
  )

func newCssModulesPlugin*(
  options: CssModulesPluginOptions = CssModulesPluginOptions(
    newHasher: newContentHasher
  )
): Plugin =
  let classTable = newTable[string, Hasher]()
  let reClass = re"(\.[\w-_][\w\d-_]*)"

  newPlugin(
    rule = proc(n: Node) = 
      let classes = findall(n.selector, reClass)
      for class in classes:
        if not classTable.contains(class):
          let hasher = options.newHasher()
          hasher.update(class, n)
          classTable[class] = hasher
        else:
          classTable[class].update(class, n),

    atRule = proc(n: Node) = 
      let classes = findall(n.params, reClass)
      for class in classes:
        if not classTable.contains(class):
          let hasher = options.newHasher()
          hasher.update(class, n)
          classTable[class] = hasher
        else:
          classTable[class].update(class, n),

    ruleExit = proc(n: Node) = 
      n.selector = replaceWithHashedClasses(n.selector, classTable),
          
    atRuleExit = proc(n: Node) = 
      n.params = replaceWithHashedClasses(n.params, classTable),
  )
