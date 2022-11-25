import lalia, strutils

# TODO: has bug with no arg line.
# TODO: think about addind proc and vars to dialogue.

func uwu(str: string): string =
  ## Returns uwu.
  ## If str is a number n, then uwu it repeated n times.
  try:
    "UwU ".repeat(str.parseInt).strip
  except:
    "UwU"

var dialogue = newDialogue(
  text "I will now say the line.",
  variable "uwu 3",
  text "$_",
  text "Thank you.",
)
dialogue.procedures["uwu"] = uwu

while not dialogue.hasStop:
  echo dialogue.line.content
  dialogue.update()
