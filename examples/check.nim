import lalia, strutils

# A dialogue with checks.
# TODO: somethin is broken uwu

var dialogue = newDialogue(
  label "START",
  text "Say yes!",
  menu("YES|NO|END", "Yes.|No.|Can I skip this?"),

  label "YES",
  variable "$_ + 1",
  jump "START",
  label "NO",
  text "...",

  label "END",
  check "$_ > 1",
  text "I love you.",
  text "I hate you.",
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
