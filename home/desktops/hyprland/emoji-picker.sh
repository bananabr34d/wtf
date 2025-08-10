#!/usr/bin/env bash

# Select emoji from emojis.txt using fuzzel and copy to clipboard
emoji=$(cat ~/.config/emojis.txt | grep -v '^#' | fuzzel -d | awk '{print $2}')
if [ -n "$emoji" ]; then
  echo -n "$emoji" | wl-copy
  notify-send "Emoji copied to clipboard: $emoji"
fi
