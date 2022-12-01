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

func setIndex(self: Dialogue, value: int) =
  ## Sets the index to a new value.
  if value >= self.lines.len: self.index = self.lines.len - 1
  elif value < 0: self.index = 0
  else: self.index = value

func refresh(self: Dialogue) =
  ## Reloads the current line until a next valid line is found.
  let line = self.lines[self.index]
  case line.kind:
  of Comment, Label:
    self.setIndex(self.index + 1)
    self.refresh()
  of Jump:
    self.setIndex(self.labels[line.replaceInfo(self.variables)])
    self.refresh()
  of Variable:
    let name =
      if line.info.len > 0:
        line.replaceInfo(self.variables)
      else:
        amoonguss
    if name in self.variables:
      self.variables[name] = line.replaceContent(self.variables)
    self.setIndex(self.index + 1)
    self.refresh()
  of Check:
    try:
      if line.replaceInfo(self.variables).calculate != 0:
        self.setIndex(self.index + 1)
      else:
        self.setIndex(self.index + 2)
    except:
      self.setIndex(self.index + 2)
    self.refresh()
  of Procedure:
    discard # TODO
  of Calculation:
    discard # TODO
  of Pause, Text, Menu:
    discard

func newDialogue*(lines: varargs[Line]): Dialogue =
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
    info: line.replaceInfo(self.variables),
    content: line.replaceContent(self.variables),
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

func update*(self: Dialogue) =
  ## Updates the dialogue.
  self.setIndex(self.index + 1)
  self.refresh()

func reset*(self: Dialogue) =
  ## Resets the dialogue to its original state.
  self.setIndex(0)
  self.refresh()

func jump*(self: Dialogue, label: string) =
  ## Changes the current line by using a label.
  self.setIndex(self.labels[label])
  self.refresh()

func jumpTo*(self: Dialogue, index: int) =
  ## Changes the current line to a specific line.
  self.setIndex(index)
  self.refresh()

func hasPause*(self: Dialogue): bool =
  ## Returns true if the current line is a stop line.
  self.simpleLine.kind == Pause

func hasMenu*(self: Dialogue): bool =
  ## Returns true if the current line is a menu line.
  self.simpleLine.kind == Menu

func choices*(self: Dialogue): seq[string] =
  ## Returns the current choices.
  self.line.splitContent()

func choose*(self: Dialogue, choice: int) =
  ## Selects an choice from the current choices.
  self.jump(self.simpleLine.splitInfo()[choice])

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

func build*(self: DialogueBuilder): Dialogue =
  ## Creates a new dialogue.
  result = newDialogue(self.lines)
  result.variables = self.variables
  result.procedures = self.procedures
  result.refresh()
