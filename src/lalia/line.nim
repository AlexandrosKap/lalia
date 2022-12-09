import tables, strutils, strformat, streams, parsecsv
import consts, utils

type
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

  Line* = ref object
    kind*: LineKind
    content*: string

func lineKind*(str: string): LineKind =
  ## Creates a new line kind from a string.
  case str:
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

func newLine*(kind: LineKind, content: string): Line =
  ## Creates a new line.
  Line(kind: kind, content: content)

func newLine*(data: openArray[string]): Line =
  ## Creates a new line from an array.
  if data.len != 2:
    newLine(Pause, "")
  else:
    newLine(lineKind(data[0]), data[1])

proc newLinesFromCsv*(path: string): seq[Line] =
  ## Creates lines from a csv file.
  result = newSeq[Line]()
  var stream = newFileStream(path)
  var parser = CsvParser()
  parser.open(stream, path)
  parser.readHeaderRow()
  while parser.readRow():
    result.add(newLine(parser.row))
  if result.len > 0 and result[^1].kind != Pause:
    result.add(newLine(Pause, ""))
  parser.close()

func pause*(): Line = newLine(Pause, "")
func comment*(content: string): Line = newLine(Comment, content)
func text*(content: string): Line = newLine(Text, content)
func label*(content: string): Line = newLine(Label, content)
func jump*(content: string): Line = newLine(Jump, content)
func menu*(content: string): Line = newLine(Menu, content)
func variable*(content: string): Line = newLine(Variable, content)
func calculation*(content: string): Line = newLine(Calculation, content)
func procedure*(content: string): Line = newLine(Procedure, content)
func check*(content: string): Line = newLine(Check, content)

func len*(self: Line): int =
  ## Returns the length of the content.
  self.content.len

func splitContent*(self: Line): seq[string] =
  ## Returns the content split by the split character.
  self.content.split(splitChar)

func replaceContent*(self: Line, table: Table[string, string]): string =
  ## Returns the content with certain words replaced with words from a table.
  self.content.replace(variableChar, table)

func `$`*(self: Line): string =
  ## Returns a string from a line.
  &"{self.kind},\"{self.content}\""
