import lalia

var story = newDialogue(
  label "START",
  text "Hello world.",
  jump "END",
  text "This is a test.",
  text "Pls don't look at me.",
  label "END",
  text "The end.",
)

while not story.hasStop:
  echo story.line.content
  story.update()
echo "\n", story
