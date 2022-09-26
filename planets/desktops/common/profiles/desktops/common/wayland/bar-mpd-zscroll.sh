#!/usr/bin/env bash

zscroll -p " === " -l 50 -b "  Stopped" -d 0.2 -u t "mpc current" -M "mpc status" -m "playing" "-s1 -b '  '" -m "paused" "-s0 -b '  '"
