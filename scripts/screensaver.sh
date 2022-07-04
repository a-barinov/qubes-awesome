#!/bin/sh

SAVER=$(xscreensaver-command -time 2>/dev/null)
LOCKED="screen locked"

test "${SAVER#*$LOCKED}" != "${SAVER}" && ( echo "set_language(widgets.language.languages[1])" | awesome-client )
