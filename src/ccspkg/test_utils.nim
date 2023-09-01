import parser, ast
import std/streams

template testParse*(input: string, output: Node) =
  let res = parse(newStringStream(input), "test")
  assert res == output


