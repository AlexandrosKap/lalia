import lalia, strutils

# A dialogue with choices.

var dialogue = newDialogue(
  text "What should I do?",
  # Jump to the label "COFFE" or "TEA".
  menu("COFFEE|TEA", "Drink coffee.|Drink tea."),
  label "COFFEE",
  text "I drink coffee.",
  jump "END",
  label "TEA",
  text "I drink tea.",
  label "END",
  text "The end.",
)

while not dialogue.hasStop:
  while dialogue.hasMenu:
    for i, choice in dialogue.choices:
      echo "-> ", i, ": ", choice
    var input = -1
    while input < 0 or input >= dialogue.choices.len:
      try: input = readLine(stdin).parseInt
      except ValueError: discard
    dialogue.choose(input)
  echo dialogue.line.content
  dialogue.update()
