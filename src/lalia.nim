import tables, strformat, strutils, math

#[
-- Idea --

Procedures can only be used in variable lines.
This makes it more safe to use procedures.

variable "a", "1 + 1"
variable "b", "str"
variable "c", "foo(str)"
variable "foo(str)"
check "$c > 2"
]#

const splitChar = '|'
const varChar = '$'
const nostr = ""

type
  ExprError* = object of CatchableError
  LineError* = object of CatchableError
  LineKind* = enum
    Stop, Comment, Text, Label, Jump, Menu, Variable, Check
  Line* = object
    kind*: LineKind
    info*: string
    content*: string
  DialogueProc* = proc(str: string): string
  Dialogue* = ref object
    index: int
    lines: seq[Line]
    labels: Table[string, int]
    variables: Table[string, string]
    procedures: Table[string, DialogueProc]

func expr(a: int, op: char, b: int): int =
  case op:
  of '+': a + b
  of '-': a - b
  of '*': a * b
  of '/': a div b
  of '%': a mod b
  of '<': int(a < b)
  of '>': int(a > b)
  of '=': int(a == b)
  of '!': int(a != b)
  else: raise newException(ExprError, &"The expression \"{a} {op} {b}\" is not valid.")

proc calc*(str: string): int =
  let args = str.replace(" ", "") & "+0"
  var
    stack = @[0]
    buffer = ""
    lop = ' '
    rop = '+'
    i = 0
  while i < args.len:
    if args[i].isDigit:
      buffer.add(args[i])
    else:
      try:
        lop = rop
        rop = args[i]
        var n = 0
        if buffer.len > 0:
          n = buffer.parseInt
        elif rop == '(' and i + 1 < args.len:
          # Find the position of ')'.
          var pcount = 1
          var j = i + 1
          while j < args.len:
            if args[j] == '(': pcount += 1
            elif args[j] == ')': pcount -= 1
            if pcount == 0: break
            j += 1
          # Skip the characters in parentheses.
          n = calc(args[i + 1 ..< j])
          i = j + 1
          rop = args[i]
        # Calculate expression.
        case lop
        of '+': stack.add(n)
        of '-': stack.add(-n)
        else: stack[^1] = expr(stack[^1], lop, n)
        buffer.setLen(0)
      except: raise newException(ExprError,
          &"The expression \"{str}\" is not valid.")
    i += 1
  stack.sum

func replace*(self: string, table: TableRef[string, string]): string =
  # TODO: Make it later...
  result = ""
  var canAdd = true
  for i, c in self:
    if c == varChar: canAdd = false
    if canAdd: result.add(c)

func stop*(): Line =
  Line(kind: Stop, info: nostr, content: nostr)

func comment*(info: string): Line =
  Line(kind: Comment, info: info, content: nostr)

func text*(info, content: string): Line =
  Line(kind: Text, info: info, content: content)

func text*(content: string): Line =
  Line(kind: Text, info: nostr, content: content)

func label*(info: string): Line =
  Line(kind: Label, info: info, content: nostr)

func jump*(info: string): Line =
  Line(kind: Jump, info: info, content: nostr)

func menu*(info, content: string): Line =
  Line(kind: Menu, info: info, content: content)

func variable*(info, content: string): Line =
  Line(kind: Variable, info: info, content: content)

func check*(info: string): Line =
  Line(kind: Menu, info: info, content: nostr)

func splitInfo*(self: Line): seq[string] =
  self.info.split(splitChar)

func splitContent*(self: Line): seq[string] =
  self.content.split(splitChar)

func `$`*(self: Line): string =
  &"{self.kind},\"{self.info}\",\"{self.content}\""

#

func setIndex(self: Dialogue, val: int)
func reload(self: Dialogue)

template setIndexAndReload(self: Dialogue, val: int): untyped =
  self.setIndex(val)
  self.reload()

func setIndex(self: Dialogue, val: int) =
  if val >= self.lines.len: self.index = self.lines.len - 1
  elif val < 0: self.index = 0
  else: self.index = val

func reload(self: Dialogue) =
  let line = self.lines[self.index]
  case line.kind:
  of Label:
    self.setIndexAndReload(self.index + 1)
  of Jump:
    self.setIndexAndReload(self.labels[line.info])
  of Variable:
    self.variables[line.info] = line.content # TODO: Add proc support.
    self.setIndexAndReload(self.index + 1)
  of Check:
    discard
  of Stop, Comment, Text, Menu:
    discard

template newDialogueTemplate[T: seq[Line] | varargs[Line]](lines: T): untyped =
  result = Dialogue()
  for i, line in lines:
    result.lines.add(line)
    if line.kind == Label: result.labels[line.info] = i
  result.lines.add(stop())
  result.reload()

func newDialogue*(lines: seq[Line]): Dialogue =
  newDialogueTemplate(lines)

func newDialogue*(lines: varargs[Line]): Dialogue =
  newDialogueTemplate(lines)

func newDialogue*[N](lines: array[N, Line]): Dialogue =
  newDialogueTemplate(lines)

func line*(self: Dialogue): Line =
  self.lines[self.index]

func update*(self: Dialogue) =
  self.setIndexAndReload(self.index + 1)

func reset*(self: Dialogue) =
  self.setIndexAndReload(0)

func jump*(self: Dialogue, index: int) =
  self.setIndexAndReload(index)

func jump*(self: Dialogue, label: string) =
  self.setIndexAndReload(self.labels[label])

func hasStop*(self: Dialogue): bool =
  self.lines[self.index].kind == Stop

func hasMenu*(self: Dialogue): bool =
  self.lines[self.index].kind == Menu

func choices*(self: Dialogue): seq[string] =
  if self.lines[self.index].kind != Menu:
    raise newException(LineError, "The current line is not a menu line.")
  self.line.splitContent

func choose*(self: Dialogue, choice: int) =
  if self.lines[self.index].kind != Menu:
    raise newException(LineError, "The current line is not a menu line.")
  self.jump(self.lines[self.index].splitInfo[choice])

func `$`*(self: Dialogue): string =
  result = ""
  for i, line in self.lines:
    result.add($line)
    if i != self.lines.len - 1: result.add('\n')
