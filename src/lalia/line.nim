import tables, strutils, strformat, streams, parsecsv
import consts, utils

type
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
    kind*: LineKind
    info*: string
    content*: string

func newLineError*(line: Line): ref LineError =
  ## Creates a new line error.
  newException(LineError, fmt"The line is incorrect: {line}")

func lineKind*(text: string): LineKind =
  ## Creates a new line kind from a string.
  case text:
  of $Pause: Pause
  of $Comment: Comment
  of $Text: Text
  of $Label: Label
  of $Jump: Jump
  of $Menu: Menu
  of $Variable: Variable
  of $Calculation: Calculation
  of $Procedure: Procedure
  of $Check: Check
  else: Pause

func pauseLine*(): Line =
  ## Creates a new pause line.
  Line(kind: Pause, info: emptyString, content: emptyString)

func commentLine*(info: string): Line =
  ## Creates a new comment line.
  Line(kind: Comment, info: info, content: emptyString)

func textLine*(info, content: string): Line =
  ## Creates a new text line.
  Line(kind: Text, info: info, content: content)

func textLine*(content: string): Line =
  ## Creates a new text line with no info.
  Line(kind: Text, info: emptyString, content: content)

func labelLine*(info: string): Line =
  ## Creates a new label line.
  Line(kind: Label, info: info, content: emptyString)

func jumpLine*(info: string): Line =
  ## Creates a new jump line.
  Line(kind: Jump, info: info, content: emptyString)

func menuLine*(info, content: string): Line =
  ## Creates a new menu line.
  Line(kind: Menu, info: info, content: content)

func menuLine*(content: string): Line =
  ## Creates a new menu line with no info.
  Line(kind: Menu, info: emptyString, content: content)

func variableLine*(info, content: string): Line =
  ## Creates a new variable line.
  Line(kind: Variable, info: info, content: content)

func variableLine*(content: string): Line =
  ## Creates a new variable line with no info.
  Line(kind: Variable, info: emptyString, content: content)

func calculationLine*(info, content: string): Line =
  ## Creates a new calculation line.
  Line(kind: Calculation, info: info, content: content)

func calculationLine*(content: string): Line =
  ## Creates a new calculation line with no info.
  Line(kind: Calculation, info: emptyString, content: content)

func procedureLine*(info, content: string): Line =
  ## Creates a new procedure line.
  Line(kind: Procedure, info: info, content: content)

func procedureLine*(content: string): Line =
  ## Creates a new procedure line with no info.
  Line(kind: Procedure, info: emptyString, content: content)

func checkLine*(info: string): Line =
  ## Creates a new check line.
  Line(kind: Check, info: info, content: emptyString)

func line*(data: openArray[string]): Line =
  ## Creates a new line from an array.
  if data.len != 3:
    return pauseLine()
  Line(
    kind: data[0].lineKind,
    info: data[1],
    content: data[2],
  )

proc linesFromCsv*(path: string): seq[Line] =
  ## Creates lines from a csv file.
  result = newSeq[Line]()
  var stream = newFileStream(path)
  var parser: CsvParser
  parser.open(stream, path)
  parser.readHeaderRow()
  while parser.readRow():
    result.add(line(parser.row))
  if result.len > 0 and result[^1].kind != Pause:
    result.add(pauseLine())
  parser.close()

func splitInfo*(self: Line): seq[string] =
  ## Splits the info.
  self.info.split(splitChar)

func splitContent*(self: Line): seq[string] =
  ## Splits the content.
  self.content.split(splitChar)

func replaceInfo*(self: Line, table: Table[string, string]): string =
  ## Replaces certain words from the info with words from a table.
  self.info.replace(variableChar, table)

func replaceContent*(self: Line, table: Table[string, string]): string =
  ## Replaces certain words from the content with words from a table.
  self.content.replace(variableChar, table)

func `$`*(self: Line): string =
  ## Returns a string from a line.
  &"{self.kind},\"{self.info}\",\"{self.content}\""
