import lalia, strutils

var dialogue = newDialogue(
  textLine "What should I do?",
  # Jump to the label "COFFE" or "TEA".
    # The order of the labels in the dialogue is important.
  menuLine "Drink coffee.|Drink tea.",
  # Or: menuLine("COFFEE|TEA", "Drink coffee.|Drink tea."),

  labelLine "COFFEE",
  textLine "I drink coffee.",
  jumpLine "END",

  labelLine "TEA",
  textLine "I drink tea.",
  jumpLine "END",

  labelLine "END",
  textLine "The end.",
)

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
