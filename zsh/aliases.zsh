#!/usr/bin/env zsh
#

alias-exists() {
  type $1 | grep -q 'aliased'
}

function unalias-safe {
  alias-exists $1 && unalias $1
}

# -------------------------------------------------------------------
# Mac only
# -------------------------------------------------------------------
if [[ $IS_MAC -eq 1 ]]; then
  unalias-safe gls
  . /usr/local/Cellar/coreutils/8.24/bin
  alias ls='gls --color=auto'
  alias lsd='ls -pgo --group-directories-first'
  alias sed='gsed'
  alias tr='gtr'
  alias rm='grm'
  alias ql='qlmanage -p 2>/dev/null' # OS X Quick Look
  alias oo='open .' # open current directory in OS X Finder
  alias 'today=calendar -A 0 -f /usr/share/calendar/calendar.mark | sort'
  alias 'mailsize=du -hs ~/Library/mail'
  alias 'smart=diskutil info disk0 | grep SMART' # display SMART status of hard drive
  # Hall of the Mountain King
  alias cello='say -v cellos "di di di di di di di di di di di di di di di di di di di di di di di di di di"'
  # alias to show all Mac App store apps
  alias apps='mdfind "kMDItemAppStoreHasReceipt=1"'
  # reset Address Book permissions in Mountain Lion (and later presumably)
  alias resetaddressbook='tccutil reset AddressBook'
  # refresh brew by upgrading all outdated casks
  alias refreshbrew='brew outdated | while read cask; do brew upgrade $cask; done'
  # rebuild Launch Services to remove duplicate entries on Open With menu
  alias rebuildopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.fram ework/Support/lsregister -kill -r -domain local -domain system -domain user'
  alias -g clip='pbcopy'
fi
if [[ $IS_WIN -eq 1 ]]; then
  # unalias-safe ls
  export LS_IGNORE='-I "NTUSER*" -I "ntuser*"'
  alias ls='ls --color $LS_IGNORE'
  alias lsd='ls -pgo --group-directories-first $LS_IGNORE'
fi

# -------------------------------------------------------------------
# use nocorrect alias to prevent auto correct from "fixing" these
# -------------------------------------------------------------------
#alias foobar='nocorrect foobar'
alias g8='nocorrect g8'

# -------------------------------------------------------------------
# directory movement
# -------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias 'bk=cd $OLDPWD'

# -------------------------------------------------------------------
# directory information
# -------------------------------------------------------------------
alias ll='ls -GFhl' # Same as above, but in long listing format
alias l='ls -al'
alias la='ls -lAFh'   #long list,show almost all,show type,human readable
alias lr='ls -tRFh'   #sorted by date,recursive,show type,human readable
alias lS='ls -1FSsh'
alias lt='ls -ltFh'   #long list,sorted by date,show type,human readable
alias lh='ls -d .*' # show hidden files/directories only
alias ldot='ls -ld .*'
alias lsd='ls -aFhlG'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias 'dus=du -sckx * | sort -nr' #directories sorted by size

alias 'wordy=wc -w * | sort | tail -n10' # sort files in current directory by the number of words they contain
alias 'filecount=find . -type f | wc -l' # number of files (not directories)

# -------------------------------------------------------------------
# grep
# -------------------------------------------------------------------
alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '

# -------------------------------------------------------------------
# curl
# -------------------------------------------------------------------
alias curlp='curl -sLN'

curls() {
  sanitize "$(curlp "$1")"
}

# -------------------------------------------------------------------
# editors
# -------------------------------------------------------------------
alias edit="$EDITOR"
# alias hack="$EDITOR_ATOM"
# alias webstorm="$EDITOR_WEBSTORM"

alias zshrc='vim "$ZSHRC_PATH"'
alias zshenv='vim "$ZSHENV_PATH"'
alias npmrc='vim "$NPMRC_PATH"'
alias vimrc='vim "$VIMRC_PATH"'
alias exports='vim "$ZSCRIPTDIR/exports.zsh"'
alias aliases='vim "$ZSCRIPTDIR/aliases.zsh"'
alias fns='vim "$ZSCRIPTDIR/functions.zsh"'
alias color='vim "$ZSCRIPTDIR/colors.zsh"'
alias paradox='vim "$ZPREZTODIR/modules/prompt/functions/prompt_paradox_setup"'
alias zdotdir='cd "$ZDOTDIR"'

alias hackzsh='hack "$ZSHRC_PATH"'
alias hackgist='hack "$USR_SRC_GIST_ROOT"'
alias hacknpm='hackjs "$NPM_SRC_ROOT"'

if [[ $IS_WIN -eq 1 ]]; then
  alias visualstudio='"$EDITOR_VS"'
  alias hosts='edit "/c/windows/system32/drivers/etc/hosts"'

  win_resolve() {
    local file_path="$1"
    if [[ -z "$file_path" ]] || [[ "$file_path" == "." ]]; then
      local file_path="$PWD"
    fi
    cygpath -w "$file_path"
  }

  hacknet() {
    visualstudio "$(win_resolve "$@")" & disown
  }
fi

hackjs() {
  if [[ $IS_WIN -eq 1 ]]; then
    webstorm "$(win_resolve "$@")" & disown
  else
    webstorm "$@" & disown
  fi
}

# -------------------------------------------------------------------
# remote machines
# -------------------------------------------------------------------
alias 'beast=ssh beast@local.devdis.co'

# -------------------------------------------------------------------
# Git
# -------------------------------------------------------------------
alias ga='git add'
alias gp='git push'
alias gl='git log'
alias gpl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gs='git status'
alias gd='git diff'
alias gm='git commit -m'
alias gma='git commit -am'
alias gb='git branch'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gra='git remote add'
alias grr='git remote rm'
alias gpu='git pull'
alias gcl='git clone'
alias gta='git tag -a -m'
alias gf='git reflog'
alias gv='git log --pretty=format:'%s' | cut -d " " -f 1 | sort | uniq -c | sort -nr'

# leverage aliases from ~/.gitconfig
alias gh='git hist'
alias gt='git today'

# curiosities
# gsh shows the number of commits for the current repos for all developers
alias gsh="git shortlog | grep -E '^[ ]+\w+' | wc -l"

# gu shows a list of all developers and the number of commits they've made
alias gu="git shortlog | grep -E '^[^ ]'"


# Force tmux to use 256 colors
alias tmux='TERM=screen-256color-bce tmux'

# alias to cat this file to display
alias acat='< ~/.zsh/aliases.zsh'
alias fcat='< ~/.zsh/functions.zsh'

# -------------------------------------------------------------------
# Source: http://aur.archlinux.org/packages/lolbash/lolbash/lolbash.sh
# -------------------------------------------------------------------
alias wtf='dmesg'
alias onoz='cat /var/log/errors.log'
alias rtfm='man'
alias visible='echo'
alias invisible='cat'
alias moar='more'
alias icanhas='mkdir'
alias donotwant='rm'
alias dowant='cp'
alias gtfo='mv'
alias hai='cd'
alias plz='pwd'
alias inur='locate'
alias nomz='ps aux | less'
alias nomnom='killall'
alias cya='reboot'
alias kthxbai='halt'
