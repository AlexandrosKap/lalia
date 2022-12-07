import tables, strutils
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

func defaultVariables(): VariableTable =
  ## Creates the default variables value.
  result = VariableTable()
  result[amoonguss] = "0"

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
  let simpleLine = self.lines[self.index]
  let line = Line(
    kind: simpleLine.kind,
    info: simpleLine.replaceInfo(self.variables),
    content: simpleLine.replaceContent(self.variables),
  )
  case line.kind:
  of Comment, Label:
    self.setIndexAndRefresh(self.index + 1)
  of Jump:
    if line.info.len == 0:
      var i = self.index + 1
      while true:
        if i >= self.lines.len:
          self.setIndexAndRefresh(self.lines.len - 1)
          break
        elif self.lines[i].kind == Label:
          let label = self.lines[i].info
          if label.startsWith(amoonguss) and label in self.labels:
            self.setIndexAndRefresh(self.labels[label])
            break
        i += 1
    elif line.info in self.labels:
      self.setIndexAndRefresh(self.labels[line.info])
    else:
      self.setIndexAndRefresh(self.index + 1)
  of Variable:
    let name = if line.info.len != 0: line.info else: amoonguss
    self.variables[name] = line.content
    self.setIndexAndRefresh(self.index + 1)
  of Check:
    try:
      if line.info.calculate != 0:
        self.setIndexAndRefresh(self.index + 1)
      else:
        self.setIndexAndRefresh(self.index + 2)
    except:
      self.setIndexAndRefresh(self.index + 2)
  of Calculation:
    let name = if line.info.len != 0: line.info else: amoonguss
    if name in self.variables:
      self.variables[name] = line.content.calculateAndConvert()
    self.setIndexAndRefresh(self.index + 1)
  of Procedure:
    let name = if line.info.len != 0: line.info else: amoonguss
    let start = line.content.find(' ')
    if start > 0 and start < line.content.len - 1:
      let procedureName = line.content[0 ..< start]
      let procedureText = line.content[start + 1 .. ^1]
      if name in self.variables and procedureName in self.procedures:
        self.variables[name] = self.procedures[procedureName](procedureText)
    elif name in self.variables and line.content in self.procedures:
      self.variables[name] = self.procedures[line.content]("")
    self.setIndexAndRefresh(self.index + 1)
  of Pause, Text, Menu:
    discard

proc newDialogue*(lines: varargs[Line]): Dialogue =
  ## Creates a new dialogue.
  result = Dialogue(variables: defaultVariables())
  for i, line in lines:
    result.lines.add(line)
    if line.kind == Label:
      if line.info.len == 0:
        result.labels[amoonguss & intToStr(i)] = i
      else:
        result.labels[line.info] = i
  if lines.len > 0 and lines[^1].kind != Pause:
    result.lines.add(pauseLine())
  result.refresh()

proc newDialogueFromCsv*(path: string): Dialogue =
  ## Creates a new dialogue from a csv file.
  newDialogue(linesFromCsv(path))

func index*(self: Dialogue): int =
  ## Returns the index.
  self.index

func line*(self: Dialogue): Line =
  ## Returns the current line.
  let line = self.lines[self.index]
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
  let line = self.line
  if line.info.len == 0:
    # TODO: Fix bug with anonymous labels.
    var labelCount = 0
    var i = self.index + 1
    while true:
      if i >= self.lines.len:
        self.jumpToEnd()
        break
      elif self.lines[i].kind == Label:
        labelCount += 1
        if labelCount == choice + 1:
          self.jump(self.lines[i].info)
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
      if line.info.len == 0:
        self.labels[amoonguss & intToStr(i)] = i
      else:
        self.labels[line.info] = i
  if lines.len > 0 and lines[^1].kind != Pause:
    self.lines.add(pauseLine())
  self.jumpToStart()

proc changeLinesFromCsv*(self: Dialogue, path: string) =
  ## Changes the lines of the dialogue with lines from a csv file.
  self.changeLines(linesFromCsv(path))

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
