import tables, strutils, strformat

type
  ExpressionError* = object of CatchableError

func newExpressionError*(expression: string): ref ExpressionError =
  ## Creates a new expression error.
  newException(ExpressionError, &"The expression is incorrect: {expression}")

func isValidNameChar*(c: char): bool =
  ## Returns true if the character is a valid variable name character.
  c.isAlphaAscii or c == '_'

func replace*(text: string, token: char, table: Table[string, string]): string =
  ## Returns a string with certain words replaced with words from a table.
  ## Word characters can be alphabetical or an underscore.
  result = ""
  var buffer = ""
  var canAddToResult = true
  if text.len == 0:
    return ""
  for i, c in text:
    if c == token:
      canAddToResult = false
    elif canAddToResult:
      result.add(c)
    elif not c.isValidNameChar:
      if table.hasKey(buffer):
        result.add(table[buffer])
      result.add(c)
      buffer.setLen(0)
      canAddToResult = true
    else:
      buffer.add(c)
  if buffer.len > 0 or text[^1] == token:
    if table.hasKey(buffer):
      result.add(table[buffer])

func expression(a: int, op: char, b: int): int =
  ## The base of the calculate procedure.
  case op:
  of '+': a + b
  of '-': a - b
  of '*': a * b
  of '/': a div b
  of '%': a mod b
  of '<': int(a < b)
  of '>': int(a > b)
  of '=': int(a == b)
  of '!': int(a != b)
  else: raise newExpressionError(&"{a}{op}{b}")

func calculate*(text: string): int =
  ## Returns an int by evaluating an expression from a string.
  result = 0
  let args = text.replace(" ", "") & "+0"
  var
    stack = @[0]
    buffer = ""
    lop = ' '
    rop = '+'
    i = 0
  while i < args.len:
    if args[i].isDigit:
      buffer.add(args[i])
    else:
      try:
        lop = rop
        rop = args[i]
        var n = 0
        if buffer.len > 0:
          n = buffer.parseInt
        elif rop == '(' and i + 1 < args.len:
          # Find the position of ')'.
          var pcount = 1
          var j = i + 1
          while j < args.len:
            if args[j] == '(': pcount += 1
            elif args[j] == ')': pcount -= 1
            if pcount == 0: break
            j += 1
          # Skip the characters in parentheses.
          n = calculate(args[i + 1 ..< j])
          i = j + 1
          rop = args[i]
        # Calculate expression.
        case lop
        of '+': stack.add(n)
        of '-': stack.add(-n)
        else: stack[^1] = expression(stack[^1], lop, n)
        buffer.setLen(0)
      except:
        raise newExpressionError(text)
    i += 1
  for item in stack: result += item

func calculateAndConvert*(text: string): string =
  ## Calculates and converts the result to a string.
  ## An empty string is returned if the expression is incorrect.
  try:
    text.calculate.intToStr
  except:
    ""
