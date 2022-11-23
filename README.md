# ⛄ Lalia

A dialogue system for Nim.

## Example

A hello-world example.

```nim
import lalia

# A simple dialogue.

var dialogue = newDialogue(
  label "START",
  text "Hello world.",
  jump "END",
  text "Pls don't look at me.",
  label "END",
  text "The end.",
)

while not dialogue.hasStop:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue
```

An example that uses variables.

```nim
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
```

More examples can be found in the examples directory.

## Installation

Copy and paste the following commands into your terminal.

```sh
nimble install https://github.com/AlexandrosKap/lalia
```

## Documentation

Information on how to use the library can be found in the CHEATSHEET.md file.

## License

The project is released under the terms of the MIT License.
Please refer to the LICENSE file.
