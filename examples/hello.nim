import lalia

var dialogue = newDialogue(
  text "Hi!",
  jump "END",
  text "Please don't look at me.",
  label "END",
  text "The end.",
)

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue
