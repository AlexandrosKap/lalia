import tables, strutils
import consts, utils, line

type
  DialogueProc* = proc(str: string): string
  DialogueTable*[T] = Table[string, T]

  Dialogue* = ref object
    index: int
    lines: seq[Line]
    labels: DialogueTable[int]
    variables*: DialogueTable[string]
    procedures*: DialogueTable[DialogueProc]

func initVariables(): DialogueTable[string] =
  ## Creates the default variables of a dialogue.
  result = DialogueTable[string]()
  result[amoonguss] = "0"

func setIndex(self: Dialogue, value: int) =
  ## Sets the index to a new value.
  if value >= self.lines.len:
    self.index = self.lines.len - 1
  elif value < 0:
    self.index = 0
  else:
    self.index = value

proc refresh(self: Dialogue) =
  ## Reloads the current line until a valid line is found.
  let line = self.lines[self.index]
  case line.kind:
  of Comment, Label:
    self.setIndex(self.index + 1)
    self.refresh()
  of Jump:
    if line.len == 0:
      var i = self.index + 1
      while true:
        if i >= self.lines.len:
          self.setIndex(self.lines.len - 1)
          break
        elif self.lines[i].kind == Label:
          let content = self.lines[i].content
          if content.startsWith(amoonguss) and content in self.labels:
            self.setIndex(self.labels[content])
            break
        i += 1
    elif line.content in self.labels:
      self.setIndex(self.labels[line.content])
    else:
      self.setIndex(self.index + 1)
    self.refresh()
  of Variable:
    let name = if line.len == 0: amoonguss else: line.content
    self.variables[name] = line.content
    self.setIndex(self.index + 1)
    self.refresh()
  of Check:
    if calculateAndConvert(line.content) != "":
      self.setIndex(self.index + 1)
    else:
      self.setIndex(self.index + 2)
    self.refresh()
  of Calculation:
    let name = if line.len == 0: amoonguss else: line.content
    if name in self.variables:
      self.variables[name] = calculateAndConvert(line.content)
    self.setIndex(self.index + 1)
    self.refresh()
  of Procedure:
    let name = if line.len == 0: amoonguss else: line.content
    let start = line.content.find(' ')
    if start > 0 and start < line.len - 1:
      let procName = line.content[0 ..< start]
      let procText = line.content[start + 1 .. ^1]
      if name in self.variables and procName in self.procedures:
        self.variables[name] = self.procedures[procName](procText)
    elif name in self.variables and line.content in self.procedures:
      self.variables[name] = self.procedures[line.content]("")
    self.setIndex(self.index + 1)
    self.refresh()
  of Pause, Text, Menu:
    discard

proc newDialogue*(lines: varargs[Line]): Dialogue =
  ## Creates a new dialogue.
  result = Dialogue(variables: initVariables())
  for i, line in lines:
    result.lines.add(line)
    if line.kind == Label:
      if line.len == 0:
        result.labels[amoonguss & intToStr(i)] = i
      else:
        result.labels[line.content] = i
  if lines.len > 0 and lines[^1].kind != Pause:
    result.lines.add(pause())
  result.refresh()

proc newDialogueFromCsv*(path: string): Dialogue =
  ## Creates a new dialogue from a csv file.
  newDialogue(newLinesFromCsv(path))

func index*(self: Dialogue): int =
  ## Returns the index.
  self.index

func line*(self: Dialogue): Line =
  ## Returns the current line.
  let line = self.lines[self.index]
  Line(
    kind: line.kind,
    content: line.replaceContent(self.variables),
  )

func lines*(self: Dialogue): seq[Line] =
  ## Returns the lines.
  self.lines

func labels*(self: Dialogue): DialogueTable[int] =
  ## Returns the labels.
  self.labels

proc update*(self: Dialogue) =
  ## Updates the dialogue.
  self.setIndex(self.index + 1)
  self.refresh()

proc jump*(self: Dialogue, label: string) =
  ## Changes the current line by using a label.
  if label in self.labels:
    self.setIndex(self.labels[label])
    self.refresh()

proc jumpTo*(self: Dialogue, index: int) =
  ## Changes the current line to a specific line.
  self.setIndex(index)
  self.refresh()

proc jumpToStart*(self: Dialogue) =
  ## Changes the current line to the starting line.
  self.jumpTo(0)

proc jumpToEnd*(self: Dialogue) =
  ## Changes the current line to the ending line.
  self.jumpTo(self.lines.len - 1)

func hasPause*(self: Dialogue): bool =
  ## Returns true if the current line is a stop line.
  self.lines[self.index].kind == Pause

func hasMenu*(self: Dialogue): bool =
  ## Returns true if the current line is a menu line.
  self.lines[self.index].kind == Menu

func choices*(self: Dialogue): seq[string] =
  ## Returns the current choices.
  if self.lines[self.index].kind == Menu:
    self.line.splitContent()
  else:
    @[]

proc choose*(self: Dialogue, choice: int) =
  ## Selects an choice from the current choices.
  var labelCount = 0
  var i = self.index + 1
  # TODO: Fix bug with anonymous labels.
  while true:
    if i >= self.lines.len:
      self.jumpToEnd()
      break
    elif self.lines[i].kind == Label:
      labelCount += 1
      if labelCount == choice + 1:
        let label = self.lines[i].content # TODO
        self.jump(label)
        break
    i += 1

proc reset*(self: Dialogue) =
  ## Resets the dialogue to its original state.
  ## All variables will be deleted and the index is set to the first valid line.
  self.variables = initVariables()
  self.jumpToStart()

proc changeLines*(self: Dialogue, lines: varargs[Line]) =
  ## Changes the lines of the dialogue.
  self.labels.clear()
  self.lines.setLen(0)
  for i, line in lines:
    self.lines.add(line)
    if line.kind == Label:
      if line.len == 0:
        self.labels[amoonguss & intToStr(i)] = i
      else:
        self.labels[line.content] = i
  if lines.len > 0 and lines[^1].kind != Pause:
    self.lines.add(pause())
  self.jumpToStart()

proc changeLinesFromCsv*(self: Dialogue, path: string) =
  ## Changes the lines of the dialogue with lines from a csv file.
  self.changeLines(newLinesFromCsv(path))

func `$`*(self: Dialogue): string =
  ## Returns a string from a dialogue.
  result = ""
  for i, line in self.lines:
    result.add($line)
    if i != self.lines.len - 1:
      result.add('\n')
