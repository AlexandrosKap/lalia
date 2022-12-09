# Cheatsheet

* [lalia](#lalia)
* [lalia/utils](#lalia/utils)
* [lalia/line](#lalia/line)
* [lalia/dialogue](#lalia/dialogue)
* [lalia/consts](#lalia/consts)

## lalia

## lalia/utils

Procedures

```nim
func newExpressionError*(expression: string): ref ExpressionError
func isValidNameChar*(c: char): bool
func replace*(text: string, token: char, table: Table[string, string]): string
func calculate*(text: string): int
func calculateAndConvert*(text: string): string
```

## lalia/line

Procedures

```nim
func lineKind*(str: string): LineKind
func newLine*(kind: LineKind, content: string): Line
func newLine*(data: openArray[string]): Line
proc newLinesFromCsv*(path: string): seq[Line]
func pause*(): Line
func comment*(content: string): Line
func text*(content: string): Line
func label*(content: string): Line
func jump*(content: string): Line
func menu*(content: string): Line
func variable*(content: string): Line
func calculation*(content: string): Line
func procedure*(content: string): Line
func check*(content: string): Line
func len*(self: Line): int
func splitContent*(self: Line): seq[string]
func replaceContent*(self: Line, table: Table[string, string]): string
func `$`*(self: Line): string
```

## lalia/dialogue

Procedures

```nim
proc newDialogue*(lines: varargs[Line]): Dialogue
proc newDialogueFromCsv*(path: string): Dialogue
func index*(self: Dialogue): int
func line*(self: Dialogue): Line
func lines*(self: Dialogue): seq[Line]
func labels*(self: Dialogue): DialogueTable[int]
proc update*(self: Dialogue)
proc jump*(self: Dialogue, label: string)
proc jumpTo*(self: Dialogue, index: int)
proc jumpToStart*(self: Dialogue)
proc jumpToEnd*(self: Dialogue)
func hasPause*(self: Dialogue): bool
func hasMenu*(self: Dialogue): bool
func choices*(self: Dialogue): seq[string]
proc choose*(self: Dialogue, choice: int)
proc reset*(self: Dialogue)
proc changeLines*(self: Dialogue, lines: varargs[Line])
proc changeLinesFromCsv*(self: Dialogue, path: string)
func `$`*(self: Dialogue): string
```

## lalia/consts
