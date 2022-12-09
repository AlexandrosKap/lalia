import lalia, strutils

var dialogue = newDialogue(
  text "What should I do?",
  # Jump to the label "COFFE" or "TEA".
  menu "Drink coffee.|Drink tea.",

  label "COFFEE",
  text "I drink coffee.",
  # Jump to the next anonymous label.
  jump "",

  label "TEA",
  text "I drink tea.",
  # Jump to the next anonymous label.
  jump "",

  # An anonymous label.
  label "",
  text "The end.",
)

echo dialogue.labels
while not dialogue.hasPause:
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
