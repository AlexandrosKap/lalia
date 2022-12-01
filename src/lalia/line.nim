import tables, strutils, strformat
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
    info*: string
    content*: string
    kind*: LineKind

func newLineError*(line: Line): ref LineError =
  ## Creates a new line error.
  newException(LineError, fmt"The line is incorrect: {line}")

func pauseLine*(): Line =
  ## Creates a new pause line.
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

func calculationLine*(info, content: string): Line =
  ## Creates a new calculation line.
  Line(info: info, content: content, kind: Calculation)

func calculationLine*(content: string): Line =
  ## Creates a new calculation line with no info.
  Line(info: emptyString, content: content, kind: Calculation)

func procedureLine*(info, content: string): Line =
  ## Creates a new procedure line.
  Line(info: info, content: content, kind: Procedure)

func procedureLine*(content: string): Line =
  ## Creates a new procedure line with no info.
  Line(info: emptyString, content: content, kind: Procedure)

func checkLine*(info: string): Line =
  ## Creates a new check line.
  Line(info: info, content: emptyString, kind: Check)

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
