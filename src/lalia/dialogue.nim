import tables
import consts, utils, line

type
  DialogueProcedure* = proc(text: string): string
  LabelTable* = Table[string, int]
  VariableTable* = Table[string, string]
  ProcedureTable* = Table[string, DialogueProcedure]

  Dialogue* = ref object
    index: int
    lines: seq[Line]
    labels: LabelTable
    variables: VariableTable
    procedures: ProcedureTable

func replaceInfo(self: Line, dialogue: Dialogue): string =
  ## Helper function for replacing the line info.
  self.replaceInfo(dialogue.variables)

func replaceContent(self: Line, dialogue: Dialogue): string =
  ## Helper function for replacing the line content.
  self.replaceContent(dialogue.variables)

func getName(self: Line, dialogue: Dialogue): string =
  ## Helper function to get the name of a variable from a line.
  if self.info.len > 0:
    self.replaceInfo(dialogue)
  else:
    amoonguss

func setIndex(self: Dialogue, value: int)
proc refresh(self: Dialogue)

template setIndexAndRefresh(self: Dialogue, value: int): untyped =
  ## Helper template to avoid typing the same thing again and again.
  self.setIndex(value)
  self.refresh()

func setIndex(self: Dialogue, value: int) =
  ## Sets the index to a new value.
  if value >= self.lines.len: self.index = self.lines.len - 1
  elif value < 0: self.index = 0
  else: self.index = value

proc refresh(self: Dialogue) =
  ## Reloads the current line until a valid line is found.
  let line = self.lines[self.index]
  case line.kind:
  of Comment, Label:
    self.setIndexAndRefresh(self.index + 1)
  of Jump:
    let label = line.replaceInfo(self)
    if label in self.labels:
      self.setIndexAndRefresh(self.labels[label])
    else:
      self.setIndexAndRefresh(self.index + 1)
  of Variable:
    self.variables[line.getName(self)] = line.replaceContent(self)
    self.setIndexAndRefresh(self.index + 1)
  of Check:
    try:
      if line.replaceInfo(self).calculate != 0:
        self.setIndexAndRefresh(self.index + 1)
      else:
        self.setIndexAndRefresh(self.index + 2)
    except:
      self.setIndexAndRefresh(self.index + 2)
  of Calculation:
    let name = line.getName(self)
    if name in self.variables:
      self.variables[name] = line.replaceContent(self).calculateAndConvert
    self.setIndexAndRefresh(self.index + 1)
  of Procedure:
    let name = line.getName(self)
    let content = line.replaceContent(self)
    let start = content.find(' ')
    if name in self.variables and start > 0 and start < content.len - 1:
      let procedureName = content[0 ..< start]
      let procedureText = content[start + 1 .. ^1]
      if procedureName in self.procedures:
        self.variables[name] = self.procedures[procedureName](procedureText)
    self.setIndexAndRefresh(self.index + 1)
  of Pause, Text, Menu:
    discard

proc newDialogue*(lines: varargs[Line]): Dialogue =
  ## Creates a new dialogue.
  result = Dialogue(variables: {amoonguss: "0"}.toTable)
  for i, line in lines:
    result.lines.add(line)
    if line.kind == Label:
      result.labels[line.info] = i
  result.lines.add(pauseLine())
  result.refresh()

func index*(self: Dialogue): int =
  ## Returns the index.
  self.index

func simpleLine*(self: Dialogue): Line =
  ## Returns the current line as it is with the variable names.
  self.lines[self.index]

func line*(self: Dialogue): Line =
  ## Returns the current line.
  let line = self.simpleLine
  Line(
    info: line.replaceInfo(self),
    content: line.replaceContent(self),
    kind: line.kind,
  )

func lines*(self: Dialogue): seq[Line] =
  ## Returns the lines.
  self.lines

func labels*(self: Dialogue): LabelTable =
  ## Returns the labels.
  self.labels

func variables*(self: Dialogue): VariableTable =
  ## Returns the variables.
  self.variables

func procedures*(self: Dialogue): ProcedureTable =
  ## Returns the procedures.
  self.procedures

proc update*(self: Dialogue) =
  ## Updates the dialogue.
  self.setIndexAndRefresh(self.index + 1)

proc jump*(self: Dialogue, label: string) =
  ## Changes the current line by using a label.
  self.setIndexAndRefresh(self.labels[label])

proc jumpTo*(self: Dialogue, index: int) =
  ## Changes the current line to a specific line.
  self.setIndexAndRefresh(index)

proc jumpToStart*(self: Dialogue) =
  ## Changes the current line to the starting line.
  self.jumpTo(0)

func hasPause*(self: Dialogue): bool =
  ## Returns true if the current line is a stop line.
  self.simpleLine.kind == Pause

func hasMenu*(self: Dialogue): bool =
  ## Returns true if the current line is a menu line.
  self.simpleLine.kind == Menu

func choices*(self: Dialogue): seq[string] =
  ## Returns the current choices.
  if self.simpleLine.kind == Menu:
    self.line.splitContent()
  else:
    @[]

proc choose*(self: Dialogue, choice: int) =
  ## Selects an choice from the current choices.
  let choices = self.simpleLine.splitInfo()
  if self.simpleLine.kind == Menu and choice < choices.len:
    self.jump(choices[choice])

proc reset*(self: Dialogue) =
  ## Resets the dialogue to its original state.
  self.variables.clear()
  self.jumpToStart()

func `$`*(self: Dialogue): string =
  ## Returns a string from a dialogue.
  result = ""
  for i, line in self.lines:
    result.add($line)
    if i != self.lines.len - 1:
      result.add('\n')
