import lalia, strutils

var story = newDialogue(
  text "What should I do?",
  # Jump to the label 'COFFE', 'TEA' or 'SLEEP'.
  menu("COFFEE|TEA|SLEEP", "Drink coffee.|Drink tea.|Go sleep."),
  label "COFFEE",
  text "I drink the coffee.",
  jump "END",
  label "TEA",
  text "I drink the tea.",
  jump "END",
  label "SLEEP",
  text "I drink the sleep.",
  label "END",
  text "The end.",
)

while not story.hasStop:
  while story.hasMenu:
    for i, choice in story.choices:
      echo "-> ", i, ": ", choice
    var input = -1
    while input < 0 or input >= story.choices.len:
      try: input = readLine(stdin).parseInt
      except ValueError: discard
    story.choose(input)
  echo story.line.content
  story.update()
