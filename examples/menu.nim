import lalia, strutils

var dialogue = newDialogue(
  textLine "What should I do?",
  # Jump to the label "COFFE" or "TEA".
  menuLine "Drink coffee.|Drink tea.",

  labelLine "COFFEE",
  textLine "I drink coffee.",
  # Jump to the next anonymous label.
  jumpLine "",

  labelLine "TEA",
  textLine "I drink tea.",
  # Jump to the next anonymous label.
  jumpLine "",

  # An anonymous label.
  labelLine "",
  textLine "The end.",
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
