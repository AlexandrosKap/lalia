import strformat, strutils
import lalia

proc echoBlock(title: string, dialogue: Dialogue) =
  echo &"# {title}\n\n```\n{dialogue}\n```"

let assets = currentSourcePath[0 .. currentSourcePath.rfind("/")] & "../assets/"

echoBlock "CSV", newDialogueFromCsv(assets & "hello.csv")
