#!/bin/bash
stty_orig=`stty -g`
tput civis -- invisible
stty -echo
lua5.3 "./main.lua" "$@"
tput cnorm -- normal
stty $stty_orig
