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

  DialogueBuilder* = ref object
    lines*: seq[Line]
    labels*: LabelTable
    variables*: VariableTable
    procedures*: ProcedureTable

func replaceInfo(self: Line, dialogue: Dialogue): string =
  ## Helper function for replacing the line info.
  self.replaceInfo(dialogue.variables)

func replaceContent(self: Line, dialogue: Dialogue): string =
  ## Helper function for replacing the line content.
  self.replaceContent(dialogue.variables)

func getName(self: Line, dialogue: Dialogue): string =
  ## Helper function to get the name of a line.
  if self.info.len > 0:
    self.replaceinfo(dialogue)
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
    if line.info in self.labels:
      self.setIndexAndRefresh(self.labels[line.info])
    else:
      self.setIndexAndRefresh(self.index + 1)
  of Variable:
    let name = line.getName(self)
    if name in self.variables:
      self.variables[name] = line.replaceContent(self)
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

func simpleLine(self: Dialogue): Line =
  ## Returns just the current line.
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

proc reset*(self: Dialogue) =
  ## Resets the dialogue to its original state.
  self.setIndexAndRefresh(0)

proc jump*(self: Dialogue, label: string) =
  ## Changes the current line by using a label.
  self.setIndexAndRefresh(self.labels[label])

proc jumpTo*(self: Dialogue, index: int) =
  ## Changes the current line to a specific line.
  self.setIndexAndRefresh(index)

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

func `$`*(self: Dialogue): string =
  ## Returns a string from a dialogue.
  result = ""
  for i, line in self.lines:
    result.add($line)
    if i != self.lines.len - 1:
      result.add('\n')

#

func newDialogueBuilder*(): DialogueBuilder =
  ## Creates a new dialogue builder.
  DialogueBuilder()

func addLine*(self: DialogueBuilder, line: Line): DialogueBuilder =
  ## Adds a line.
  self.lines.add(line)
  self

func addLines*(self: DialogueBuilder, lines: varargs[Line]): DialogueBuilder =
  ## Adds one line or more lines.
  self.lines.add(lines)
  self

func addVariable*(self: DialogueBuilder, name, value: string): DialogueBuilder =
  ## Adds a variable.
  self.variables[name] = value
  self

func addProcedure*(
    self: DialogueBuilder,
    name: string,
    value: DialogueProcedure
    ): DialogueBuilder =
  ## Adds a procedure.
  self.procedures[name] = value
  self

func reset*(self: DialogueBuilder): DialogueBuilder =
  ## Resets the builder.
  self.lines = seq[Line].default()
  self.labels = LabelTable.default()
  self.variables = VariableTable.default()
  self.procedures = ProcedureTable.default()
  self

proc build*(self: DialogueBuilder): Dialogue =
  ## Creates a new dialogue.
  result = newDialogue(self.lines)
  result.variables = self.variables
  result.procedures = self.procedures
  result.refresh()
