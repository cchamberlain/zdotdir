#!/usr/bin/env zsh
#
# Defines Environment Variables

# RESET ZSHENV FILE VIA ENVIRONMENT VARIABLE
export USR_ZSHENV_PATH="$HOME/.zshenv"
if [[ $USR_ZSHENV_RESET -eq 1 ]]; then
  unset USR_ZSHENV_RESET
  if [[ -z "$GIST_USR_ZSHENV_ID" ]]; then
    export GIST_USR_ZSHENV_ID="ad8ae7ce3ef2a965295d"
  fi
  printf -- "No user zshenv found at $USR_ZSHENV_PATH, using default..."
  TEMP_GIST="${TMP:-"$TEMP"}/zshenv"
  
  if [[ -d "$TEMP_GIST" ]]; then
    rm -rf "$TEMP_GIST"
  fi
  git clone https://gist.github.com/$GIST_USR_ZSHENV_ID "$TEMP_GIST"
  mv "$USR_ZSHENV_PATH" "$USR_ZSHENV_PATH.bak"
  cp "$TEMP_GIST/.zshenv" "$USR_ZSHENV_PATH"
  . "$USR_ZSHENV_PATH"
fi

# DIRECTORIES
export ZDOTDIR="${ZDOTDIR:-"$HOME/.zsh"}"
export ZNODEDIR="$ZDOTDIR/node"
export ZSCRIPTDIR="$ZDOTDIR/zsh"
export ZPYTHONDIR="$ZDOTDIR/python"
export ZETCDIR="$ZDOTDIR/etc"
export ZASSETSDIR="$ZDOTDIR/assets"
export ZDOWNLOADDIR="$ZDOTDIR/download"
export ZHELPDIR="$ZDOTDIR/help"
export ZPREZTODIR="$ZDOTDIR/.zprezto"

# DOTFILES
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

# Get Prezto
if [[ ! -d "$ZPREZTODIR" ]]; then
  git clone --recursive https://github.com/$GIT_ZPREZTO_ID "$ZPREZTODIR"
fi

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "$ZPROFILE_PATH" ]]; then
  . "$ZPROFILE_PATH"
fi
