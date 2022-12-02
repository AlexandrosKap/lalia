import lalia

var dialogue = newDialogue(
  # Creates a variable called "myCoolVar" with the value "0".
  variableLine("myCoolVar", "0"),
  # Variables values can be used by using the '$' character.
  # If "myCoolVar" is a number (it is), it will add 1 to its value.
  calculationLine("myCoolVar", "$myCoolVar + 1"),
  calculationLine("myCoolVar", "$myCoolVar + 1"),
  textLine "I love the number $myCoolVar!",

  # Every dialogue by default has a variable called "_" with the value "0".
  textLine "I hate the number $_!",
  # Variable and calculation lines with no info use the variable "_".
  variableLine "665",
  calculationLine "$_ + 1",
  textLine "The number $_ is the number of love.",
)

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue.variables
