import tables, strutils, strformat
export tables

const splitChar = '|'
const variableChar = '$'
const emptyString = ""
const amoonguss = "_"

type
  ExpressionError* = object of CatchableError
  LineError* = object of CatchableError

  LineKind* = enum
    Pause,
    Comment,
    Text,
    Label,
    Jump,
    Menu,
    Variable,
    Calculation,
    Procedure,
    Check,

  Line* = object
    info*: string
    content*: string
    kind*: LineKind

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

func newExpressionError*(expression: string): ref ExpressionError =
  newException(ExpressionError, fmt"The expression is incorrect: {expression}")

func newLineError*(line: Line): ref ExpressionError =
  newException(ExpressionError, fmt"The line is incorrect: {line}")

#

func isValidNameChar*(c: char): bool =
  ## Returns true if the character is a valid variable name character.
  c.isAlphaAscii or c == variableChar

func replace*(text: string, token: char, table: Table[string, string]): string =
  ## Returns a string with certain words replaced with words from a table.
  ## Word characters can be alphabetical or an underscore.
  result = ""
  var buffer = ""
  var canAddToResult = true
  if text.len == 0:
    return ""
  for i, c in text:
    if c == token:
      canAddToResult = false
    elif canAddToResult:
      result.add(c)
    elif not c.isValidNameChar:
      if table.hasKey(buffer):
        result.add(table[buffer])
      result.add(c)
      buffer.setLen(0)
      canAddToResult = true
    else:
      buffer.add(c)
  if buffer.len > 0 or text[^1] == token:
    if table.hasKey(buffer):
      result.add(table[buffer])

func expression(a: int, op: char, b: int): int =
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
  else: raise newExpressionError(fmt"{a}{op}{b}")

func calculate*(text: string): int =
  ## Returns an int by evaluating an expression from a string.
  result = 0
  let args = text.replace(" ", "") & "+0"
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
          n = calculate(args[i + 1 ..< j])
          i = j + 1
          rop = args[i]
        # Calculate expression.
        case lop
        of '+': stack.add(n)
        of '-': stack.add(-n)
        else: stack[^1] = expression(stack[^1], lop, n)
        buffer.setLen(0)
      except:
        raise newExpressionError(text)
    i += 1
  for item in stack: result += item

#

func pauseLine*(): Line =
  ## Creates a new stop line.
  Line(info: emptyString, content: emptyString, kind: Pause)

func commentLine*(info: string): Line =
  ## Creates a new comment line.
  Line(info: info, content: emptyString, kind: Comment)

func textLine*(info, content: string): Line =
  ## Creates a new text line.
  Line(info: info, content: content, kind: Text)

func textLine*(content: string): Line =
  ## Creates a new text line with no info.
  Line(info: emptyString, content: content, kind: Text)

func labelLine*(info: string): Line =
  ## Creates a new label line.
  Line(info: info, content: emptyString, kind: Label)

func jumpLine*(info: string): Line =
  ## Creates a new jump line.
  Line(info: info, content: emptyString, kind: Jump)

func menuLine*(info, content: string): Line =
  ## Creates a new menu line.
  Line(info: info, content: content, kind: Menu)

func variableLine*(info, content: string): Line =
  ## Creates a new variable line.
  Line(info: info, content: content, kind: Variable)

func variableLine*(content: string): Line =
  ## Creates a new variable line with no info.
  Line(info: emptyString, content: content, kind: Variable)

func checkLine*(info: string): Line =
  ## Creates a new check line.
  Line(info: info, content: emptyString, kind: Check)

func splitInfo*(self: Line): seq[string] =
  self.info.split(splitChar)

func splitContent*(self: Line): seq[string] =
  self.content.split(splitChar)

func replaceInfo*(self: Line, table: Table[string, string]): string =
  self.info.replace(variableChar, table)

func replaceContent*(self: Line, table: Table[string, string]): string =
  self.content.replace(variableChar, table)

func `$`*(self: Line): string =
  ## Returns a string from a line.
  &"{self.kind},\"{self.info}\",\"{self.content}\""

#

func setIndex(self: Dialogue, value: int) =
  ## Sets the index to a new value.
  if value >= self.lines.len: self.index = self.lines.len - 1
  elif value < 0: self.index = 0
  else: self.index = value

proc reload(self: Dialogue) =
  ## Reloads the current line until a next valid line is found.
  let line = self.lines[self.index]
  case line.kind:
  of Comment, Label:
    self.setIndex(self.index + 1)
    self.reload()
  of Jump:
    self.setIndex(self.labels[line.info.replace(variableChar, self.variables)])
    self.reload()
  of Variable:
    let value = line.content.replace(variableChar, self.variables)
    let name =
      if line.info.len > 0:
        line.info.replace(variableChar, self.variables)
      else:
        amoonguss
    self.variables[name] = value
    self.setIndex(self.index + 1)
    self.reload()
  of Check:
    var step = 2
    try:
      if line.info.replace(variableChar, self.variables).calculate != 0:
        step = 1
    except:
      discard
    self.setIndex(self.index + step)
    self.reload()
  of Procedure:
    discard # TODO
  of Calculation:
    discard # TODO
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
  result.reload()

proc index*(self: Dialogue): int =
  self.index

proc lines*(self: Dialogue): seq[Line] =
  self.lines

proc labels*(self: Dialogue): LabelTable =
  self.labels

proc simpleLine(self: Dialogue): Line =
  self.lines[self.index]

proc line*(self: Dialogue): Line =
  ## Returns the current line.
  let line = self.simpleLine
  Line(
    info: line.replaceInfo(self.variables),
    content: line.replaceContent(self.variables),
    kind: line.kind,
  )

proc update*(self: Dialogue) =
  ## Updates the dialogue.
  self.setIndex(self.index + 1)
  self.reload()

proc reset*(self: Dialogue) =
  ## Resets the dialogue to its original state.
  self.setIndex(0)
  self.reload()

proc jump*(self: Dialogue, index: int) =
  ## Changes the current line.
  self.setIndex(index)
  self.reload()

proc jump*(self: Dialogue, label: string) =
  ## Changes the current line by using a label.
  self.setIndex(self.labels[label])
  self.reload()

func hasPause*(self: Dialogue): bool =
  ## Returns true if the current line is a stop line.
  self.simpleLine.kind == Pause

func hasMenu*(self: Dialogue): bool =
  ## Returns true if the current line is a menu line.
  self.simpleLine.kind == Menu

proc choices*(self: Dialogue): seq[string] =
  ## Returns the current choices.
  self.line.splitContent()

proc choose*(self: Dialogue, choice: int) =
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
  DialogueBuilder()

func addLine*(self: DialogueBuilder, line: Line): DialogueBuilder =
  self.lines.add(line)
  self

func addLines*(self: DialogueBuilder, lines: varargs[Line]): DialogueBuilder =
  self.lines.add(lines)
  self

func addVariable*(self: DialogueBuilder, name, value: string): DialogueBuilder =
  self.variables[name] = value
  self

func addProcedure*(
    self: DialogueBuilder,
    name: string,
    value: DialogueProcedure
    ): DialogueBuilder =
  self.procedures[name] = value
  self

func reset*(self: DialogueBuilder): DialogueBuilder =
  self.lines = seq[Line].default()
  self.labels = LabelTable.default()
  self.variables = VariableTable.default()
  self.procedures = ProcedureTable.default()
  self

proc build*(self: DialogueBuilder): Dialogue =
  result = newDialogue(self.lines)
  result.variables = self.variables
  result.procedures = self.procedures
  result.reload()
