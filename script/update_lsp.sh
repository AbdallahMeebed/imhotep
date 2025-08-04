#!/usr/bin/env sh

find . -name "*.sv" -o -name "*.svh" -o -name "*.v" | sort > verible.filelist
