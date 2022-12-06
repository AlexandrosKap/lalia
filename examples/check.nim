import lalia, strutils

var dialogue = newDialogue(
  labelLine "START",
  textLine "Say yes!",
  menuLine "Yes.|No.",

  labelLine "YES",
  calculationLine "$_ + 1",
  jumpLine "START",

  labelLine "NO",
  textLine "...",
  # If "_" is not 0, then skip the next line."
  checkLine "$_ = 0",
  textLine "Ok.",
  checkLine "$_ = 1",
  textLine "You said yes 1 time.",
  checkLine "$_ > 1",
  textLine "You said yes $_ times.",
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
echo dialogue.variables
