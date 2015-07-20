#!/usr/bin/env zsh
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Cole Chamberlain <cole.chamberlain@gmail.com
#

# DIRECTORIES
export ZDOTDIR="${ZDOTDIR:-"$HOME/.zsh"}"
export ZNODEDIR="$ZDOTDIR/node"
export ZSCRIPTDIR="$ZDOTDIR/zsh"
export ZETCDIR="$ZDOTDIR/etc"
export ZASSETSDIR="$ZDOTDIR/assets"
export ZPREZTO_ROOT="$ZDOTDIR/.zprezto"

# DOTFILES
export USR_ZSHENV_PATH="$HOME/.zshenv"
export ZSHENV_PATH="$ZDOTDIR/.zshenv"
export ZSHRC_PATH="$ZDOTDIR/.zshrc"
export ZPREZTORC_PATH="$ZDOTDIR/.zpreztorc"
export ZPROFILE_PATH="$ZDOTDIR/.zprofile"
export ZLOGIN_PATH="$ZDOTDIR/.zlogin"
export ZLOGOUT_PATH="$ZDOTDIR/.zlogout"
export NPMRC_PATH="$HOME/.npmrc"
export VIMRC_PATH="$HOME/.vimrc"

# Mac OS X uses path_helper and /etc/paths.d to preload PATH, clear it out first
if [ -x /usr/libexec/path_helper ]; then
  PATH=''
  eval `/usr/libexec/path_helper -s`
fi

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "$ZPROFILE_PATH" ]]; then
  . "$ZPROFILE_PATH"
fi

# Get Dot Files
if [[ ! -f "$ZSHRC_PATH" ]]; then
  if [[ -d "$ZDOTDIR" ]]; then
    printf -- "ZDOTDIR is corrupt.  Backup and delete %s and reload..." "$ZDOTDIR"
  fi
  git clone https://github.com/cchamberlain/zdotdir "$ZDOTDIR"
fi

# Get Prezto
if [[ ! -d "$ZPREZTO_ROOT" ]]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto "$ZPREZTO_ROOT"
fi
