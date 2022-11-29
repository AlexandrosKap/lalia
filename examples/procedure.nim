import lalia, strutils

# TODO: has bug with no arg line.

func uwu(str: string): string =
  ## Returns uwu.
  ## If str is a number n, then uwu it repeated n times.
  try:
    "UwU ".repeat(str.parseInt).strip()
  except:
    "UwU"

var dialogue = newDialogueBuilder()
  .add(
    text "I will now say \"UwU\" three times.",
    variable "uwu 3",
    text "$_",
    text "Thank you."
  )
  .add("uwu", uwu)
  .build()

while not dialogue.hasStop:
  echo dialogue.line.content
  dialogue.update()
