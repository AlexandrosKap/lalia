import lalia, strutils

var dialogue = newDialogue(
  textLine "What should I do?",
  menuLine("COFFEE|TEA", "Drink coffee.|Drink tea."),

  # Jump to the label "COFFE" or "TEA".
  labelLine "COFFEE",
  textLine "I drink coffee.",
  jumpLine "END",
  labelLine "TEA",
  textLine "I drink tea.",

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
