# 🐣 Lalia

A super simple dialogue system for Nim.

The library provides the essential tools needed to create a dialogue for a game,
allowing you to focus on the specific needs of your project.
It is simple by default, but can easily be extended to something powerful when needed.

## Features

* Easy
* Labels
* Menus
* Variables
* Procedures
* Conditional statements
* Mathematical operations
* Supports csv, md and ink files (TODO)
* Syntax inspired by Assembly

## Examples

A hello-world example.
More examples can be found in the examples directory.

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

## Documentation

There is no documentation.
Read the CHEATSHEET.md file in the repo for now.

## Installation

Copy and paste the following commands into a terminal.

```sh
nimble install -y https://github.com/AlexandrosKap/lalia
```

Add Lalia to your .nimble file.

```
requires "https://github.com/AlexandrosKap/lalia"
```

## License

The project is released under the terms of the MIT License.
Please refer to the LICENSE file.
