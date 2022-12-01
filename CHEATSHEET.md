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
```

## line

Procedures

```nim
func newLineError*(line: Line): ref LineError
func pauseLine*(): Line
func commentLine*(info: string): Line
func textLine*(info, content: string): Line
func textLine*(content: string): Line
func labelLine*(info: string): Line
func jumpLine*(info: string): Line
func menuLine*(info, content: string): Line
func variableLine*(info, content: string): Line
func calculationLine*(info, content: string): Line
func procedureLine*(info, content: string): Line
func checkLine*(info: string): Line
func splitInfo*(self: Line): seq[string]
func splitContent*(self: Line): seq[string]
func replaceInfo*(self: Line, table: Table[string, string]): string
func replaceContent*(self: Line, table: Table[string, string]): string
func `$`*(self: Line): string
```

## dialogue

Procedures

```nim
func newDialogue*(lines: varargs[Line]): Dialogue
func index*(self: Dialogue): int
func line*(self: Dialogue): Line
func lines*(self: Dialogue): seq[Line]
func labels*(self: Dialogue): LabelTable
func variables*(self: Dialogue): VariableTable
func procedures*(self: Dialogue): ProcedureTable
func update*(self: Dialogue)
func reset*(self: Dialogue)
func jump*(self: Dialogue, label: string)
func jumpTo*(self: Dialogue, index: int)
func hasPause*(self: Dialogue): bool
func hasMenu*(self: Dialogue): bool
func choices*(self: Dialogue): seq[string]
func choose*(self: Dialogue, choice: int)
func `$`*(self: Dialogue): string

func newDialogueBuilder*(): DialogueBuilder
func addLine*(self: DialogueBuilder, line: Line): DialogueBuilder
func addLines*(self: DialogueBuilder, lines: varargs[Line]): DialogueBuilder
func addVariable*(self: DialogueBuilder, name, value: string): DialogueBuilder
func addProcedure*(self: DialogueBuilder, name: string, value: DialogueProcedure ): DialogueBuilder
func reset*(self: DialogueBuilder): DialogueBuilder
func build*(self: DialogueBuilder): Dialogue
```

## consts
