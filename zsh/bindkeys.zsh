#!/usr/bin/env zsh
#

# Fix for vi mode ESC double key
noop () { }
zle -N noop
bindkey -M vicmd '\e' noop

# vi history search fix
autoload vi-search-fix
zle -N vi-search-fix
bindkey -M viins '\e/' vi-search-fix


# other vi key fixes
bindkey "^?" backward-delete-char
bindkey "^W" backward-kill-word
# Control-h also deletes the previous char
bindkey "^H" backward-delete-char
bindkey "^U" backward-kill-line 
