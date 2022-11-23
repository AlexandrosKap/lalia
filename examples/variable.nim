import lalia

# A dialogue with variables.

var dialogue = newDialogue(
  text "Math time!",
  # Saves "1 + 1" to a variable called "_".
  variable "1 + 1",
  text "1 + 1 = $_",
  # Saves the value of "_" to a cool variable.
  variable("myCoolVar", "$_"),
  text "I love the number $myCoolVar!",
)

while not dialogue.hasStop:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue.variables
