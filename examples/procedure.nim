import lalia

proc ghostProc(text: string): string =
  "BoOoOoOooo"

var dialogue = newDialogue(
  text "Im a ghost!",
  procedure "ghostProc",
  text "$_",
)
dialogue.procedures["ghostProc"] = ghostProc

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue
