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

func line*(kind: LineKind, info, content: string): Line =
  ## Creates a new line.
  Line(kind: kind, info: info, content: content)

func lineWithNoInfo*(kind: LineKind, content: string): Line =
  ## Creates a new line with no info.
  Line(kind: kind, content: content)

func lineWithNoContent*(kind: LineKind, info: string): Line =
  ## Creates a new line with no content.
  Line(kind: kind, info: info)

func lineWithNothing*(kind: LineKind): Line =
  ## Creates an empty line.
  Line(kind: kind)

func lineFromArray*(data: openArray[string]): Line =
  ## Creates a new line from an array.
  if data.len != 3:
    return Line(kind: Pause)
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
    result.add(lineFromArray(parser.row))
  if result.len > 0 and result[^1].kind != Pause:
    result.add(lineWithNothing(Pause))
  parser.close()

func pauseLine*(): Line = lineWithNothing(Pause)
func commentLine*(info: string): Line = lineWithNoContent(Comment, info)
func textLine*(info, content: string): Line = line(Text, info, content)
func textLine*(content: string): Line = lineWithNoInfo(Text, content)
func labelLine*(info: string): Line = lineWithNoContent(Label, info)
func jumpLine*(info: string): Line = lineWithNoContent(Jump, info)
func menuLine*(info, content: string): Line = line(Menu, info, content)
func menuLine*(content: string): Line = lineWithNoInfo(Menu, content)
func variableLine*(info, content: string): Line = line(Variable, info, content)
func variableLine*(content: string): Line = lineWithNoInfo(Variable, content)
func calculationLine*(info, content: string): Line = line(Calculation, info, content)
func calculationLine*(content: string): Line = lineWithNoInfo(Calculation, content)
func procedureLine*(info, content: string): Line = line(Procedure, info, content)
func procedureLine*(content: string): Line = lineWithNoInfo(Procedure, content)
func checkLine*(info: string): Line = lineWithNoContent(Check, info)

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
