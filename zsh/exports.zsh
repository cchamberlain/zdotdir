#!/usr/bin/env zsh

export LANG=en_US.UTF-8
export SHELL="/bin/zsh"

export EDITOR='vim'
export EDITOR_ATOM='atom'
export EDITOR_SUBLIME='subl'

export GIT_BASE_URL="https://$GIT_USERNAME@github.com"
export GIST_BASE_URL="https://$GIT_USERNAME@gist.github.com"
export NPM_GIT_SRC="$GIT_BASE_URL/$GIT_NPM_ID"
export GIT_USR_URL="$GIT_BASE_URL/$GIT_USERNAME"

export LOCAL_ROOT="$HOME/local"
export LOCAL_SRC_ROOT="$LOCAL_ROOT/src"
export USR_SRC_GIST_ROOT="$USR_SRC_ROOT/gist"
export USR_BACKUP_ROOT="$HOME/.backup"
export USR_NOTES_ROOT="$HOME/.notes"

# USR APP DIRECTORIES
export USR_PREFIX="$LOCAL_ROOT"
export USR_BIN_ROOT="$USR_PREFIX/bin"

# NPM DIRECTORIES
export NPM_SRC_BASENAME="${GIT_NPM_ID%/*}"
export NPM_SRC_BASE="$USR_SRC_ROOT/$NPM_SRC_BASENAME"
export NPM_SRC_ROOT="$NPM_SRC_BASE/npm"

# NPM SETTINGS
export NPM_CONFIG_PREFIX="$USR_PREFIX/npm"
export NPM_CONFIG_CACHE="$USR_PREFIX/npm-cache"

# MSYS2 DIRECTORIES
export MSYS2_PACKAGES_ROOT="$USR_SRC_ROOT/msys2-packages"

if [[ $IS_WIN -eq 1 ]]; then
  export CC=gcc
  export GYP_MSVS_VERSION=2015
  export PYTHON="/usr/bin/python"
  export JAVA_HOME=/c/WINDOWS/system32/java
  export PF86="/c/Program\ Files\ \(x86\)"
  export PF="/c/Program\ Files"
  export CHROME_PATH="$PF86/Google/Chrome/Application/chrome.exe"
  export EDITOR_VS="$PF86/Microsoft\ Visual\ Studio\ 12.0/Common7/IDE/devenv.exe"
  export EDITOR_WEBSTORM="$PF86/JetBrains/WebStorm\ 10.0.4/bin/WebStorm.exe"
  export PATH="/usr/local/bin:/usr/bin:/bin:/opt/bin:/mingw64/bin:$LOCAL_ROOT/bin:$LOCAL_ROOT/npm:$LOCAL_ROOT/iojs:$LOCAL_ROOT/tcc:/c/WINDOWS/system32:/c/WINDOWS:/c/WINDOWS/System32/WindowsPowerShell/v1.0:$PF86/Heroku/bin:$LOCAL_ROOT/chocolatey/bin:$HOME/AppData/Local/atom/bin"
elif [[ $IS_MAC -eq 1 ]]; then
  export TERM=xterm-256color
  export CHROME_PATH="$(which chrome)"
  export PATH="$USR_BIN_ROOT:$NPM_CONFIG_PREFIX/bin:$PATH:~/bin:/usr/local/bin:/usr/local/sbin:~/bin"
fi

# vi mode lag fix
export KEYTIMEOUT=1

# This resolves issues install the mysql, postgres, and other gems with native non universal binary extensions
export ARCHFLAGS='-arch x86_64'

export LESS='--ignore-case --raw-control-chars'
export PAGER='less'
export EDITOR='subl -w'

export NODE_PATH="$USR_NODESCRIPT_ROOT:$NODE_PATH"
#export PYTHONPATH=/usr/local/lib/python2.6/site-packages
# CTAGS Sorting in VIM/Emacs is better behaved with this in place
export LC_COLLATE=C

#export GH_ISSUE_CREATE_TOKEN=083f60c674d8eb41f98258df9fc8d94cb733218a
