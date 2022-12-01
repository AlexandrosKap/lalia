import lalia

var dialogue = newDialogue(
  textLine "Hi!",
  jumpLine "END",
  textLine "Please don't look at me.",
  labelLine "END",
  textLine "The end.",
)

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue
