# Cheatsheet

* [lalia](#lalia)
* [utils](#utils)
* [line](#line)
* [dialogue](#dialogue)
* [consts](#consts)

## lalia

## utils

Procedures

```nim
func newExpressionError*(expression: string): ref ExpressionError
func isValidNameChar*(c: char): bool
func replace*(text: string, token: char, table: Table[string, string]): string
func calculate*(text: string): int
func calculateAndConvert*(text: string): string
```

## line

Procedures

```nim
func newLineError*(line: Line): ref LineError
func lineKind*(text: string): LineKind
func pauseLine*(): Line
func commentLine*(info: string): Line
func textLine*(info, content: string): Line
func textLine*(content: string): Line
func labelLine*(info: string): Line
func jumpLine*(info: string): Line
func menuLine*(info, content: string): Line
func variableLine*(info, content: string): Line
func variableLine*(content: string): Line
func calculationLine*(info, content: string): Line
func calculationLine*(content: string): Line
func procedureLine*(info, content: string): Line
func procedureLine*(content: string): Line
func checkLine*(info: string): Line
func line*(data: openArray[string]): Line
proc linesFromCsv*(path: string): seq[Line]
func splitInfo*(self: Line): seq[string]
func splitContent*(self: Line): seq[string]
func replaceInfo*(self: Line, table: Table[string, string]): string
func replaceContent*(self: Line, table: Table[string, string]): string
func `$`*(self: Line): string
```

## dialogue

Procedures

```nim
proc newDialogue*(lines: varargs[Line]): Dialogue
proc newDialogueFromCsv*(path: string): Dialogue
func index*(self: Dialogue): int
func simpleLine*(self: Dialogue): Line
func line*(self: Dialogue): Line
func lines*(self: Dialogue): seq[Line]
func labels*(self: Dialogue): LabelTable
proc update*(self: Dialogue)
proc jump*(self: Dialogue, label: string)
proc jumpTo*(self: Dialogue, index: int)
proc jumpToStart*(self: Dialogue)
func hasPause*(self: Dialogue): bool
func hasMenu*(self: Dialogue): bool
func choices*(self: Dialogue): seq[string]
proc choose*(self: Dialogue, choice: int)
proc reset*(self: Dialogue)
proc changeLines*(self: Dialogue, lines: varargs[Line])
proc changeLinesFromCsv*(self: Dialogue, path: string)
func addVariables*(self: Dialogue, table: VariableTable)
func deleteVariables*(self: Dialogue, names: varargs[string])
func addProcedures*(self: Dialogue, table: ProcedureTable)
func deleteProcedures*(self: Dialogue, names: varargs[string])
func `$`*(self: Dialogue): string
```

## consts
