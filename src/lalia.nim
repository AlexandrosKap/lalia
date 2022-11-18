import tables, strformat, strutils

const splitChar = '|'
const noString = ""

type
  LineError* = object of CatchableError
  LineKind* = enum
    Stop, Text, Label, Jump, Menu, Variable, Check, Comment
  Line* = object
    kind*: LineKind
    info*: string
    content*: string
  Dialogue* = ref object
    index: int
    lines: seq[Line]
    labels: Table[string, int]
    variables: Table[string, string]
    procedures: Table[string, proc(arg: string)]

func stop*(): Line =
  Line(kind: Stop, info: noString, content: noString)

func text*(info, content: string): Line =
  Line(kind: Text, info: info, content: content)

func text*(content: string): Line =
  Line(kind: Text, info: noString, content: content)

func label*(info: string): Line =
  Line(kind: Label, info: info, content: noString)

func jump*(info: string): Line =
  Line(kind: Jump, info: info, content: noString)

func menu*(info, content: string): Line =
  Line(kind: Menu, info: info, content: content)

func variable*(info, content: string): Line =
  Line(kind: Variable, info: info, content: content)

func check*(info: string): Line =
  Line(kind: Menu, info: info, content: noString)

func comment*(info: string): Line =
  Line(kind: Comment, info: info, content: noString)

func splitInfo*(self: Line): seq[string] =
  self.info.split(splitChar)

func splitContent*(self: Line): seq[string] =
  self.content.split(splitChar)

func `$`*(self: Line): string =
  &"{self.kind},\"{self.info}\",\"{self.content}\""

#

func setIndex(self: Dialogue, val: int) =
  if val >= self.lines.len: self.index = self.lines.len - 1
  elif val < 0: self.index = 0
  else: self.index = val

func reload(self: Dialogue) =
  let line = self.lines[self.index]
  case line.kind:
  of Label:
    self.setIndex(self.index + 1)
    self.reload()
  of Jump:
    self.setIndex(self.labels[line.info])
    self.reload()
  else:
    discard

template setIndexAndReload(self: Dialogue, val: int): untyped =
  self.setIndex(val)
  self.reload()

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
    raise newException(LineError, "Current line is not a menu line.")
  self.line.splitContent

func choose*(self: Dialogue, choice: int) =
  if self.lines[self.index].kind != Menu:
    raise newException(LineError, "Current line is not a menu line.")
  self.jump(self.lines[self.index].splitInfo[choice])

func `$`*(self: Dialogue): string =
  result = ""
  for i, line in self.lines:
    result.add($line)
    if i != self.lines.len - 1: result.add('\n')
