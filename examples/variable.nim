import lalia

var story = newDialogue(
  text "Math time!",
  # Saves "1 + 1" to a variable called "_".
  variable "1 + 1",
  text "1 + 1 = $_",
  # Saves the value of "_" to a cool variable.
  variable("myCoolVar", "$_"),
  text "I love the number $myCoolVar!",
)

while not story.hasStop:
  echo story.line.content
  story.update()
echo "\n", story.variables
