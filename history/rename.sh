#!/bin/sh
mkdir -p img

ls *.png | awk -F "[^0-9]*" '{printf "spread%s.png ./img/spread%04d.png\n", $2, $2 -2}' | xargs -t -n 2 cp

