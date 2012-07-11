#!/bin/sh

IN=src/code/
OUT=public/js/

set -e -x

coffee --watch --output $OUT $IN
