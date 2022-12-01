import lalia, strutils

# TODO: bugubuguub

func uwu(text: string): string =
  ## Returns uwu.
  ## If str is a number n, then uwu it repeated n times.
  try:
    "UwU ".repeat(text.parseInt).strip
  except:
    "UwU"

var dialogue = newDialogueBuilder()
  .addLines(
    textLine "I will now say \"UwU\" three times.",
    variableLine "uwu",
    textLine "$_",
    textLine "Thank you."
  )
  .addProcedure("uwu", uwu)
  .build()

while not dialogue.hasPause:
  echo dialogue.line.content
  dialogue.update()
