import lalia

proc ghostProc(text: string): string =
  "BoOoOoOooo"

var dialogue = newDialogue(
  textLine "Im a ghost!",
  procedureLine "ghostProc",
  textLine "$_",
)
dialogue.procedures["ghostProc"] = ghostProc

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue
