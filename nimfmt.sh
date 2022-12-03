#!/bin/env sh

name=lalia

[ -d src ] && nimpretty src/*.nim
[ -d examples ] && nimpretty examples/*.nim
[ -d tests ] && nimpretty tests/*.nim
[ -d src/$name ] && nimpretty src/$name/*.nim
