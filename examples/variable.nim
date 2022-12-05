import lalia

var dialogue = newDialogue(
  # Creates a variable called "myCoolVar" with the value "0".
  variableLine("myCoolVar", "0"),
  calculationLine("myCoolVar", "$myCoolVar + 1"),
  calculationLine("myCoolVar", "$myCoolVar + 1"),
  textLine "I love the number $myCoolVar!",

  # Every dialogue by default has a variable called "_" with the value "0".
  textLine "I hate the number $_!",
  variableLine "665",
  calculationLine "$_ + 1",
  textLine "The number $_ is the number of love.",
)

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue.variables
