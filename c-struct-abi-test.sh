#!/bin/sh

clang -c c-struct-abi-test-clang.c || exit 1
crystal build c-struct-abi-test-crystal.cr || exit 1
./c-struct-abi-test-crystal
