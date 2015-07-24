#!/usr/bin/env zsh
#

# Fix for vi mode ESC double key
noop () { }
zle -N noop
bindkey -M vicmd '\e' noop
