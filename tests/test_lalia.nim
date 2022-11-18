import unittest
import lalia

test "calc1":
  check calc("") == 0
  check calc("+") == 0
  check calc("woof") == 0
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
