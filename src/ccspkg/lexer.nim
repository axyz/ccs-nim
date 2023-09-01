import strutils, lexbase, streams

type
  TokenKind* = enum
    tkEof,
    tkComment,
    tkWord,
    tkBlockStart,
    tkBlockEnd,
    tkColon,
    tkSemicolon,
    tkAt

  LexerError* = enum
    errEofExpected,
    errNone,
    errInvalidToken,
    errEndOfCommentExpected

  LexerState* = enum
    stateStart,
    stateRunning,
    stateError,
    stateEnd

  Lexer* = object of BaseLexer
    a: string
    kind: TokenKind
    state: LexerState
    err: LexerError
    filename: string

#------------------------------------------------------------------------------#

const
  errorMessages*: array[LexerError, string] = [
    "EOF expected",
    "no error",
    "invalid token",
    "End of comment expected"
  ]

  WordChars* = AllChars - Whitespace - {'{', ';', ':', '\0', '@', '}'}

#------------------------------------------------------------------------------#

proc open*(self: var Lexer, input: Stream, filename: string) =
  lexbase.open(self, input)
  self.filename = filename
  self.kind = tkEof
  self.state = stateStart
  self.a = ""

proc close*(self: var Lexer) {.inline.} =
  ## closes the parser `self` and its associated input stream.
  lexbase.close(self)

func str*(self: Lexer): string {.inline.} =
  ## returns the character data for the events
  self.a

func kind*(self: Lexer): TokenKind {.inline.} =
  ## returns the current event type for the  parser
  self.kind

func getColumn*(self: Lexer): int {.inline.} =
  ## get the current column the parser has arrived at.
  result = getColNumber(self, self.bufpos)

func getLine*(self: Lexer): int {.inline.} =
  ## get the current line the parser has arrived at.
  result = self.lineNumber

func getFilename*(self: Lexer): string {.inline.} =
  ## get the filename of the file that the parser processes.
  result = self.filename

func errorMsg*(self: Lexer): string =
  ## returns a helpful error message for the event `stateError`
  assert(self.state == stateError)
  result = "$1($2, $3) Error: $4" % [
    self.filename, $self.getLine, $self.getColumn, errorMessages[self.err]]

func step(self: var Lexer, count: range[1..high(int)] = 1) {.inline.} =
  for _ in 1..count:
    inc(self.bufpos)

func peek*(self: Lexer, offset: range[0..high(int)] = 0): char {.inline.} =
  if self.buf.len > self.bufpos + offset:
    self.buf[self.bufpos + offset]
  else:
    '\0'

func skip*(self: var Lexer, s: set[char]) {.inline.} =
  while self.peek in s:
    self.step

func eat(self: var Lexer, kind: TokenKind) {.inline.} =
  add(self.a, self.peek)
  self.kind = kind
  self.step

func parseWord(self: var Lexer) =
  while self.peek in WordChars:
    self.eat(tkWord)
  self.a = self.a.strip

func parseComment(self: var Lexer) =
  self.step(len("/*"))
  while true:
    case self.peek
    of '*':
      if self.peek(1) == '/':
        self.step(len("*/"))
        self.kind = tkComment
        break
    of '\0':
      self.err = errEndOfCommentExpected
      break
    else:
      self.eat(tkComment)

func next*(self: var Lexer): TokenKind =
  setLen(self.a, 0)
  self.skip(Whitespace)
  case self.peek
  of '{':
    self.eat(tkBlockStart)
  of '}':
    self.eat(tkBlockEnd)
  of '@':
    self.eat(tkAt)
  of ':':
    self.eat(tkColon)
  of ';':
    self.eat(tkSemicolon)
  of '/':
    case self.peek(1)
    of '*':
      self.parseComment
    else: self.parseWord
  of '\0':
    self.kind = tkEof
    self.state = stateEnd
  of WordChars - {'/'}:
    self.parseWord
  else:
    self.kind = tkEof
    self.state = stateEnd
  return self.kind

