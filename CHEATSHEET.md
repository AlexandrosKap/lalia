# Cheatsheet

* [lalia](#lalia)

## lalia

Procedures

```nim
func stop*(): Line
func text*(info, content: string): Line
func text*(content: string): Line
func label*(info: string): Line
func jump*(info: string): Line
func menu*(info, content: string): Line
func variable*(info, content: string): Line
func check*(info: string): Line
func comment*(info: string): Line
func splitInfo*(self: Line): seq[string]
func splitContent*(self: Line): seq[string]
func `$`*(self: Line): string

func newDialogue*(lines: seq[Line]): Dialogue
func newDialogue*(lines: varargs[Line]): Dialogue
func line*(self: Dialogue): Line
func update*(self: Dialogue)
func reset*(self: Dialogue)
func jump*(self: Dialogue, index: int)
func jump*(self: Dialogue, label: string)
func hasStop*(self: Dialogue): bool
func hasMenu*(self: Dialogue): bool
func choices*(self: Dialogue): seq[string]
func choose*(self: Dialogue, choice: int)
func `$`*(self: Dialogue): string
```
