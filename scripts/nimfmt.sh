#!/bin/env sh

# Simple code formatting script.

name=lalia

[ -d examples ] && nimpretty examples/*.nim
[ -d tests ] && nimpretty tests/*.nim
[ -d src/$name ] && nimpretty src/$name/*.nim
[ -d src ] && nimpretty src/*.nim && exit
echo "Oops! The thing is not here!"
