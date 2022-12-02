import unittest
import lalia/utils

test "calculus1":
  check calculate("") == 0
  check calculate("+") == 0
  check calculate("*") == 0
  check calculate("1") == 1
  check calculate("-1") == -1
  check calculate("1 + 2") == 3
  check calculate("1 - 2") == -1
  check calculate("1 * 2") == 2
  check calculate("5 / 2") == 2
  check calculate("2 < 5") == 1
  check calculate("5 > 2") == 1
  check calculate("5 = 5") == 1
  check calculate("5 ! 2") == 1
  check calculateAndConvert("a") == ""
  check calculateAndConvert("woof") == ""

test "calculus2":
  check calculate("1 + 2 * 3  + 3 * 2 + 1") == 14
  check calculate("()") == 0
  check calculate("(1)") == 1
  check calculate("(((1)))") == 1
  check calculate("(1) + (1)") == 2
  check calculate("(3 + 3) * (2 * 2 + 2) + 1") == 37
  check calculate("3 > 2 + 1") == 2
  check calculate("3 > (2 + 1)") == 0
