# Cheatsheet

* [lalia](#lalia)

## lalia

Procedures

```nim
func isValidNameChar*(c: char): bool
func replace*(str: string, token: char, table: Table[string, string]): string
func calc*(str: string): int

func stop*(): Line
func comment*(info: string): Line
func text*(info, content: string): Line
func text*(content: string): Line
func label*(info: string): Line
func jump*(info: string): Line
func menu*(info, content: string): Line
func variable*(info, content: string): Line
func variable*(content: string): Line
func check*(info: string): Line
func `$`*(self: Line): string

proc newDialogue*(lines: varargs[Line]): Dialogue
proc index*(self: Dialogue): int
proc lines*(self: Dialogue): LineSeq
proc labels*(self: Dialogue): LabelTable
proc line*(self: Dialogue): Line
proc update*(self: Dialogue)
proc reset*(self: Dialogue)
proc jump*(self: Dialogue, index: int)
proc jump*(self: Dialogue, label: string)
func hasStop*(self: Dialogue): bool
func hasMenu*(self: Dialogue): bool
proc choices*(self: Dialogue): seq[string]
proc choose*(self: Dialogue, choice: int)
func `$`*(self: Dialogue): string

func newDialogueBuilder*(): DialogueBuilder
func add*(self: DialogueBuilder, line: Line): DialogueBuilder
func add*(self: DialogueBuilder, lines: varargs[Line]): DialogueBuilder
func add*(self: DialogueBuilder, name, value: string): DialogueBuilder
func add*(self: DialogueBuilder, name: string,value: DialogueProcedure): DialogueBuilder
func reset*(self: DialogueBuilder): DialogueBuilder
proc build*(self: DialogueBuilder): Dialogue
```
