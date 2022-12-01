# Cheatsheet

* [lalia](#lalia)

## lalia

Procedures

```nim
func newExpressionError*(expression: string): ref ExpressionError
func newLineError*(line: Line): ref ExpressionError

func isValidNameChar*(c: char): bool
func replace*(text: string, token: char, table: Table[string, string]): string
func calculate*(text: string): int

func pauseLine*(): Line
func commentLine*(info: string): Line
func textLine*(info, content: string): Line
func textLine*(content: string): Line
func labelLine*(info: string): Line
func jumpLine*(info: string): Line
func menuLine*(info, content: string): Line
func variableLine*(info, content: string): Line
func variableLine*(content: string): Line
func checkLine*(info: string): Line
func splitInfo*(self: Line): seq[string]
func splitContent*(self: Line): seq[string]
func replaceInfo*(self: Line, table: Table[string, string]): string
func replaceContent*(self: Line, table: Table[string, string]): string
func `$`*(self: Line): string

proc newDialogue*(lines: varargs[Line]): Dialogue
proc index*(self: Dialogue): int
proc lines*(self: Dialogue): seq[Line]
proc labels*(self: Dialogue): LabelTable
proc line*(self: Dialogue): Line
proc update*(self: Dialogue)
proc reset*(self: Dialogue)
proc jump*(self: Dialogue, index: int)
proc jump*(self: Dialogue, label: string)
func hasPause*(self: Dialogue): bool
func hasMenu*(self: Dialogue): bool
proc choices*(self: Dialogue): seq[string]
proc choose*(self: Dialogue, choice: int)
func `$`*(self: Dialogue): string

func newDialogueBuilder*(): DialogueBuilder
func addLine*(self: DialogueBuilder, line: Line): DialogueBuilder
func addLines*(self: DialogueBuilder, lines: varargs[Line]): DialogueBuilder
func addVariable*(self: DialogueBuilder, name, value: string): DialogueBuilder
func addProcedure*(self: DialogueBuilder, name: string, value: DialogueProcedure ): DialogueBuilder
func reset*(self: DialogueBuilder): DialogueBuilder
proc build*(self: DialogueBuilder): Dialogue
```
