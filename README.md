# 🐣 Lalia

A super simple dialogue system for Nim.

The library provides the essential tools needed to create a dialogue for a game,
allowing you to focus on the specific needs of your project.
It is simple by default, but can easily be extended to something powerful when needed.

## Features

* Labels
* Menus
* Variables
* Procedures
* Conditional statements
* Mathematical operations
* CSV and Markdown support
* Syntax inspired by Assembly

## Examples

A hello-world example:

```nim
import lalia

var dialogue = newDialogue(
  textLine "Hi!",
  jumpLine "END",
  textLine "Please don't look at me.",
  labelLine "END",
  textLine "The end.",
)

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
echo "\n", dialogue
```

More examples can be found in the examples directory.

## Documentation

There is no documentation. (TODO)

## Installation

Copy and paste the following command into a terminal:

```sh
nimble install -y https://github.com/AlexandrosKap/lalia
```

Add Lalia as a dependency to a .nimble file:

```
requires "https://github.com/AlexandrosKap/lalia"
```

## License

The project is released under the terms of the MIT License.
Please refer to the LICENSE file.
