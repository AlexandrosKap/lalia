import tables, strformat, strutils, math
export tables

#[
-- Idea --

Procedures can only be used in variable lines.
And only one procedure can be used per variable line.
This makes it more safe to use procedures.

variable "a", "str"
variable "b", "1 + 1"
variable "c", "foo str"
variable "foo str"
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
    variables*: Table[string, string]
    procedures*: Table[string, DialogueProc]

func expr(a: int, op: char, b: int): int =
  ## The base of the calc procedure.
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

func calc*(str: string): int =
  ## Returns an int by evaluating an expression from a string.
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

proc replace*(str: string, replaceChar: char, table: Table[string,
    string]): string =
  ## Returns a string with certain words replaced with words from a table.
  ## Word chars can be alphabetical or underscore.
  result = ""
  var
    buffer = ""
    canAddToResult = true
  if str.len == 0: return ""
  for i, c in str:
    if c == replaceChar:
      canAddToResult = false
    elif canAddToResult:
      result.add(c)
    elif not (c.isAlphaAscii or c == '_'):
      if table.hasKey(buffer): result.add(table[buffer])
      result.add(c)
      buffer.setLen(0)
      canAddToResult = true
    else:
      buffer.add(c)
  if buffer.len > 0 or str[^1] == replaceChar:
    if table.hasKey(buffer): result.add(table[buffer])

func stop*(): Line =
  ## Creates a new stop line.
  Line(kind: Stop, info: nostr, content: nostr)

func comment*(info: string): Line =
  ## Creates a new comment line.
  Line(kind: Comment, info: info, content: nostr)

func text*(info, content: string): Line =
  ## Creates a new text line.
  Line(kind: Text, info: info, content: content)

func text*(content: string): Line =
  ## Creates a new text line with no info.
  Line(kind: Text, info: nostr, content: content)

func label*(info: string): Line =
  ## Creates a new label line.
  Line(kind: Label, info: info, content: nostr)

func jump*(info: string): Line =
  ## Creates a new jump line.
  Line(kind: Jump, info: info, content: nostr)

func menu*(info, content: string): Line =
  ## Creates a new menu line.
  Line(kind: Menu, info: info, content: content)

func variable*(info, content: string): Line =
  ## Creates a new variable line.
  Line(kind: Variable, info: info, content: content)

func variable*(content: string): Line =
  ## Creates a new variable line with no info.
  Line(kind: Variable, info: nostr, content: content)

func check*(info: string): Line =
  ## Creates a new check line.
  Line(kind: Menu, info: info, content: nostr)

func splitInfo*(self: Line): seq[string] =
  ## Splits the line info.
  self.info.split(splitChar)

func splitContent*(self: Line): seq[string] =
  ## Splits the line content.
  self.content.split(splitChar)

func `$`*(self: Line): string =
  ## Returns a string from a line.
  &"{self.kind},\"{self.info}\",\"{self.content}\""

#

proc setIndex(self: Dialogue, val: int)
proc reload(self: Dialogue)

template setIndexAndReload(self: Dialogue, val: int): untyped =
  self.setIndex(val)
  self.reload()

proc setIndex(self: Dialogue, val: int) =
  if val >= self.lines.len: self.index = self.lines.len - 1
  elif val < 0: self.index = 0
  else: self.index = val

proc reload(self: Dialogue) =
  let line = self.lines[self.index]
  case line.kind:
  of Label:
    self.setIndexAndReload(self.index + 1)
  of Jump:
    self.setIndexAndReload(self.labels[line.info.replace(varChar,
        self.variables)])
  of Variable:
    let
      name =
        if line.info.len > 0: line.info.replace(varChar, self.variables)
        else: "_"
      val = line.content.replace(varChar, self.variables)
    for c in name:
      if not (c.isAlphaAscii or c == '_'):
        raise newException(LineError, &"The variable name \"{name}\" is not valid.")
    try:
      self.variables[name] = val.calc.intToStr
    except:
      let i = val.find(' ')
      if i > 0 and self.procedures.hasKey(val[0 ..^ i]):
        self.variables[name] = self.procedures[val[0 ..^ i]](val[i .. ^1])
      else:
        self.variables[name] = val
    self.setIndexAndReload(self.index + 1)
  of Check:
    var step = 2
    try:
      if line.info.replace(varChar, self.variables).calc != 0: step = 1
    except:
      discard
    self.setIndexAndReload(self.index + step)
  of Stop, Comment, Text, Menu:
    discard

proc newDialogue*(lines: varargs[Line]): Dialogue =
  ## Creates a new dialogue.
  result = Dialogue()
  for i, line in lines:
    result.lines.add(line)
    if line.kind == Label: result.labels[line.info] = i
  result.lines.add(stop())
  result.reload()

proc line*(self: Dialogue): Line =
  ## Returns the current dialogue line.
  let line = self.lines[self.index]
  Line(
    kind: line.kind,
    info: line.info.replace(varChar, self.variables),
    content: line.content.replace(varChar, self.variables)
  )

proc update*(self: Dialogue) =
  ## Updates the dialogue.
  self.setIndexAndReload(self.index + 1)

proc reset*(self: Dialogue) =
  self.setIndexAndReload(0)

proc jump*(self: Dialogue, index: int) =
  self.setIndexAndReload(index)

proc jump*(self: Dialogue, label: string) =
  self.setIndexAndReload(self.labels[label])

func hasStop*(self: Dialogue): bool =
  self.lines[self.index].kind == Stop

func hasMenu*(self: Dialogue): bool =
  self.lines[self.index].kind == Menu

proc choices*(self: Dialogue): seq[string] =
  if self.lines[self.index].kind != Menu:
    raise newException(LineError, "The current line is not a menu line.")
  self.line.splitContent

proc choose*(self: Dialogue, choice: int) =
  if self.lines[self.index].kind != Menu:
    raise newException(LineError, "The current line is not a menu line.")
  self.jump(self.lines[self.index].splitInfo[choice])

func `$`*(self: Dialogue): string =
  result = ""
  for i, line in self.lines:
    result.add($line)
    if i != self.lines.len - 1: result.add('\n')
