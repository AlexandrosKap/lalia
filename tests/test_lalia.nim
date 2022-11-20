import unittest
import lalia

test "calc1":
  check calc("") == 0
  check calc("+") == 0
  check calc("*") == 0
  check calc("1") == 1
  check calc("-1") == -1
  check calc("1 + 2") == 3
  check calc("1 - 2") == -1
  check calc("1 * 2") == 2
  check calc("5 / 2") == 2
  check calc("2 < 5") == 1
  check calc("5 > 2") == 1
  check calc("5 = 5") == 1
  check calc("5 ! 2") == 1
  try: discard calc("a")
  except: check true
  try: discard calc("woof")
  except: check true

test "calc2":
  check calc("1 + 2 * 3  + 3 * 2 + 1") == 14
  check calc("()") == 0
  check calc("(1)") == 1
  check calc("(((1)))") == 1
  check calc("(1) + (1)") == 2
  check calc("(3 + 3) * (2 * 2 + 2) + 1") == 37
  check calc("3 > 2 + 1") == 2
  check calc("3 > (2 + 1)") == 0
