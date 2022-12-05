import tables
import consts, utils, line

type
  DialogueProcedure* = proc(text: string): string

  DialogueTable*[T] = Table[string, T]
  LabelTable* = DialogueTable[int]
  VariableTable* = DialogueTable[string]
  ProcedureTable* = DialogueTable[DialogueProcedure]

  Dialogue* = ref object
    index: int
    lines: seq[Line]
    labels: LabelTable
    variables*: VariableTable
    procedures*: ProcedureTable

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

template setIndexAndRefresh(self: Dialogue, value: int) =
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
    if start > 0 and start < content.len - 1:
      let procedureName = content[0 ..< start]
      let procedureText = content[start + 1 .. ^1]
      if name in self.variables and procedureName in self.procedures:
        self.variables[name] = self.procedures[procedureName](procedureText)
    elif name in self.variables and content in self.procedures:
      self.variables[name] = self.procedures[content]("")
    self.setIndexAndRefresh(self.index + 1)
  of Pause, Text, Menu:
    discard

func defaultVariables(): VariableTable =
  ## Creates the default variables value.
  result = VariableTable()
  result[amoonguss] = "0"

proc newDialogue*(lines: varargs[Line]): Dialogue =
  ## Creates a new dialogue.
  result = Dialogue(variables: defaultVariables())
  for i, line in lines:
    result.lines.add(line)
    if line.kind == Label:
      result.labels[line.info] = i
  if lines.len > 0 and lines[^1].kind != Pause:
    result.lines.add(pauseLine())
  result.refresh()

proc newDialogueFromCsv*(path: string): Dialogue =
  ## Creates a new dialogue from a csv file.
  result = Dialogue(
    lines: linesFromCsv(path),
    variables: defaultVariables(),
  )
  for i, line in result.lines:
    if line.kind == Label:
      result.labels[line.info] = i
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

proc update*(self: Dialogue) =
  ## Updates the dialogue.
  self.setIndexAndRefresh(self.index + 1)

proc jump*(self: Dialogue, label: string) =
  ## Changes the current line by using a label.
  if label in self.labels:
    self.setIndexAndRefresh(self.labels[label])

proc jumpTo*(self: Dialogue, index: int) =
  ## Changes the current line to a specific line.
  self.setIndexAndRefresh(index)

proc jumpToStart*(self: Dialogue) =
  ## Changes the current line to the starting line.
  self.jumpTo(0)

proc jumpToEnd*(self: Dialogue) =
  ## Changes the current line to the ending line.
  self.jumpTo(self.lines.len - 1)

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
  let line = self.line
  if line.info.len == 0:
    var labelCount = 0
    var i = self.index + 1
    while true:
      if i >= self.lines.len:
        self.jumpToEnd()
        break
      if self.lines[i].kind == Label:
        labelCount += 1
        if labelCount == choice + 1:
          self.jump(self.lines[i].replaceInfo(self))
          break
      i += 1
  else:
    let choices = line.splitInfo()
    if line.kind == Menu and choice < choices.len:
      self.jump(choices[choice])

proc reset*(self: Dialogue) =
  ## Resets the dialogue to its original state.
  ## All variables will be deleted and the index is set to the first valid line.
  self.variables = defaultVariables()
  self.jumpToStart()

proc changeLines*(self: Dialogue, lines: varargs[Line]) =
  ## Changes the lines of the dialogue.
  self.labels.clear()
  self.lines.setLen(0)
  for i, line in lines:
    self.lines.add(line)
    if line.kind == Label:
      self.labels[line.info] = i
  if lines.len > 0 and lines[^1].kind != Pause:
    self.lines.add(pauseLine())
  self.jumpToStart()

proc changeLinesFromCsv*(self: Dialogue, path: string) =
  ## Changes the lines of the dialogue with lines from a csv file.
  self.labels.clear()
  self.lines = linesFromCsv(path)
  for i, line in self.lines:
    if line.kind == Label:
      self.labels[line.info] = i
  if self.lines.len > 0 and self.lines[^1].kind != Pause:
    self.lines.add(pauseLine())
  self.jumpToStart()

template addThing[T](self: Dialogue, table, property: DialogueTable[T]) =
  ## Helper template to add new things to the dialogue property.
  for key, value in table:
    if not property.hasKey(key):
      property[key] = value

template deleteThing[T](
    self: Dialogue,
    keys: varargs[string],
    property: DialogueTable[T]
  ) =
  ## Helper template to delete things from the dialogue property.
  for key in keys:
    if property.hasKey(key):
      property.del(key)

func addVariables*(self: Dialogue, table: VariableTable) =
  ## Adds new variables to the dialogue.
  self.addThing(table, self.variables)

func deleteVariables*(self: Dialogue, names: varargs[string]) =
  ## Deletes variables from the dialogue.
  self.deleteThing(names, self.variables)

func addProcedures*(self: Dialogue, table: ProcedureTable) =
  ## Adds new procedures to the dialogue.
  self.addThing(table, self.procedures)

func deleteProcedures*(self: Dialogue, names: varargs[string]) =
  ## Deletes procedures from the dialogue.
  self.deleteThing(names, self.procedures)

func `$`*(self: Dialogue): string =
  ## Returns a string from a dialogue.
  result = ""
  for i, line in self.lines:
    result.add($line)
    if i != self.lines.len - 1:
      result.add('\n')
