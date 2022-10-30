#!/bin/bash

if [ "$(pacman -Qe | awk '/gits/ {print }'|wc -l)" -ge 1 ]; then
  echo "yes"
else
  exit 0
fi

echo "hmmm..."
