#!/bin/sh

TARGET="x64"

MAKE="make"

$MAKE iso DEPS=$MAKE_DEPS TARGET=$TARGET || \
{ echo "Make failed"; exit 1; }