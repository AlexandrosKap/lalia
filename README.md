# 🍱 Lalia

A dialogue system for Nim.

## Example

A hello-world example.
More examples can be found in the examples folder.

```nim
import lalia

var story = newDialogue(
  label "START",
  text "Hello world.",
  jump "END",
  text "This is a test.",
  text "Pls don't look at me.",
  label "END",
  text "The end.",
)

while not story.hasStop:
  echo story.line.content
  story.update()
echo "\n", story
```

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
