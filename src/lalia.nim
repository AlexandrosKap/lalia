import tables, strformat

const nostr = ""

type
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
  Line(kind: Stop, info: nostr, content: nostr)

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

func comment*(info: string): Line =
  Line(kind: Comment, info: info, content: nostr)

func `$`*(self: Line): string =
  &"{self.kind},\"{self.info}\",\"{self.content}\""

#

func setIndex(self: Dialogue, val: int) =
  if val >= self.lines.len: self.index = self.lines.len - 1
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

func newDialogue*(lines: seq[Line]): Dialogue =
  result = Dialogue(lines: lines)
  for i, line in lines:
    if line.kind == Label: result.labels[line.info] = i
  result.lines.add(stop())
  result.reload()

func newDialogue*(lines: varargs[Line]): Dialogue =
  result = Dialogue()
  for i, line in lines:
    result.lines.add(line)
    if line.kind == Label: result.labels[line.info] = i
  result.lines.add(stop())
  result.reload()

func line*(self: Dialogue): Line =
  self.lines[self.index]

func update*(self: Dialogue) =
  self.setIndex(self.index + 1)
  self.reload()

func reset*(self: Dialogue) =
  self.setIndex(0)
  self.reload()

func hasStop*(self: Dialogue): bool =
  self.lines[self.index].kind == Stop

func `$`*(self: Dialogue): string =
  result = ""
  for i, line in self.lines:
    result.add($line)
    if i != self.lines.len - 1: result.add('\n')
