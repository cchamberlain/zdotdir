#!/usr/bin/env zsh

export UNIX_NAME="$(uname -s)"

case "$UNIX_NAME" in
  Linux) export IS_LINUX=1;;
  Darwin) export IS_MAC=1;;
  *Cygwin*|*MSYS*|*MINGW*) export IS_WIN=1;;
  *) export IS_UNKNOWN=1;;
esac

hash npm 2>/dev/null && export HAS_NPM=1
hash node 2>/dev/null && export HAS_NODE=1
hash brew 2>/dev/null && export HAS_BREW=1
hash apt-get 2>/dev/null && export HAS_APT=1
hash yum 2>/dev/null && export HAS_YUM=1
hash chocolatey 2>/dev/null && export HAS_CHOC=1