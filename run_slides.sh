#!/usr/bin/env sh
find ./slides/ -type f | sort | grep -v \\.terraform | xargs /usr/local/bin/emacsclient -nw -a ''
