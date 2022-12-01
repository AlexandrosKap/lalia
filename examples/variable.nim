import lalia

# TODO: bugubuguub

var dialogue = newDialogue(
  textLine "Math time!",
  # Saves "1 + 1" to a variable called "_".
  variableLine "1 + 1",
  textLine "1 + 1 = $_",
  # Saves the value of "_" to a cool variable.
  variableLine("myCoolVar", "$_"),
  textLine "I love the number $myCoolVar!",
)

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue.variables
