import lalia, strutils

# A dialogue with checks.

var dialogue = newDialogue(
  label "START",
  text "Say yes!",
  menu("NO|YES", "No.|Yes."),

  label "YES",
  variable "$_ + 1",
  jump "START",
  label "NO", 
  text "...",

  check "$_ = 0",
  text "Ok.",
  check "$_ = 1",
  text "You said yes 1 time.",
  check "$_ > 1",
  text "You said yes $_ times.",
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
