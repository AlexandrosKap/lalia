import lalia

# A simple dialogue.

var dialogue = newDialogue(
  label "START",
  text "Hello world.",
  jump "END",
  text "Pls don't look at me.",
  label "END",
  text "The end.",
)

while not dialogue.hasStop:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue
