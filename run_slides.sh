#!/usr/bin/env sh
find ./slides/ -type f | sort | xargs /usr/local/bin/emacsclient -nw -a ''
