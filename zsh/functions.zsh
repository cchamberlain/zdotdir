#!/usr/bin/env zsh

# -------------------------------------------------------------------
# executes a nodescript
# -------------------------------------------------------------------
ns() {
  hash nodescript 2>/dev/null || {
    pushd "$ZNODEDIR" 2>/dev/null
      printf -- "linking nodescript..."
      npm link
    popd 2>/dev/null
  }
  hash bunyan 2>/dev/null || npm install -g bunyan
  nodescript "$@" | bunyan
}

alias clone="ns clone"
alias s3="ns s3"
alias note="ns note"

# ------------------------------------------------------------------
# prints out the environment variables related to current system
# ------------------------------------------------------------------
checks() {
  env | grep IS_
  env | grep HAS_
}

# ------------------------------------------------------------------
# namedir my_path -> names the current working directory as ~my_path
# ------------------------------------------------------------------
namedir () { $1=$PWD ;  : ~$1 }

# --------------------------------------------
# If ~/_netrc and ! ~/.netrc, symlink ~/.netrc
# --------------------------------------------
[[ -f "$HOME/_netrc" ]] && [[ ! -f "$HOME/.netrc" ]] && ln -s "$HOME/_netrc" "$HOME/.netrc"

chrome() {
  if [[ $IS_WIN -eq 1 ]]; then
    local chrome_args="//new-window $1"
  else
    local chrome_args="--new-window $1"
  fi
  "$CHROME_PATH" $chrome_args
}
# -------------------------------------------------------------------
# compressed file expander
# (from https://github.com/myfreeweb/zshuery/blob/master/zshuery.sh)
# -------------------------------------------------------------------
ex() {
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xvjf $1;;
          *.tar.gz) tar xvzf $1;;
          *.tar.xz) tar xvJf $1;;
          *.tar.lzma) tar --lzma xvf $1;;
          *.bz2) bzip2 -dk $1;;
          *.rar) unrar $1;;
          *.gz) gzip $1;;
          *.tar) tar xvf $1;;
          *.tbz2) tar xvjf $1;;
          *.tgz) tar xvzf $1;;
          *.zip) unzip $1;;
          *.Z) uncompress $1;;
          *.7z) 7z x $1;;
          *) echo "'$1' cannot be extracted via >ex<";;
    esac
    else
        echo "'$1' is not a valid file"
    fi
}

# -------------------------------------------------------------------
# extract a file that was downloaded to downloads folder
# -------------------------------------------------------------------
exdl() {
  pushd "$DOWNLOAD_ROOT"
    if [[ -f "$1" ]]; then
      ex "$1"
      ex_dir="$(ls --group-directories-first -p ${1%%.*} | grep /)"
      pushd "$ex_dir"
        $FILE_EXPLORER .
      popd
    fi
  popd
}

# -------------------------------------------------------------------
# any function from http://onethingwell.org/post/14669173541/any
# search for running processes
# -------------------------------------------------------------------
any() {
    emulate -L zsh
    unsetopt KSH_ARRAYS
    if [[ -z "$1" ]] ; then
        echo "any - grep for process(es) by keyword" >&2
        echo "Usage: any [keyword]" >&2 ; return 1
    else
        ps xauwww -Wae | grep -i --color=auto "[${1[1]}]${1[2,-1]}"
    fi
}

# -------------------------------------------------------------------
# display a neatly formatted path
# -------------------------------------------------------------------
path() {
  echo $PATH | tr ":" "\n" | \
    awk "{ sub(\"/usr\",   \"$fg_no_bold[green]/usr$reset_color\"); \
           sub(\"/bin\",   \"$fg_no_bold[blue]/bin$reset_color\"); \
           sub(\"/opt\",   \"$fg_no_bold[cyan]/opt$reset_color\"); \
           sub(\"/sbin\",  \"$fg_no_bold[magenta]/sbin$reset_color\"); \
           sub(\"/local\", \"$fg_no_bold[yellow]/local$reset_color\"); \
           print }"
}



# -------------------------------------------------------------------
# nice mount (http://catonmat.net/blog/another-ten-one-liners-from-commandlingfu-explained)
# displays mounted drive information in a nicely formatted manner
# -------------------------------------------------------------------
nicemount() { (echo "DEVICE PATH TYPE FLAGS" && mount | awk '$2="";1') | column -t ; }

# -------------------------------------------------------------------
# sanitize html into human readable compact text
# -------------------------------------------------------------------
sanitize() {
  printf -- "%s" "$1" | sed -e 's/<[^>]\+>/ /gi' -e 's/&[a-z]\+;/ /gi' -e 's/^ */\n/g' | tr -s '[:space:]' | tr \015 \012 | tr -s \012
}

# -------------------------------------------------------------------
# define a word
# -------------------------------------------------------------------
defword() { curl -sL "dict://dict.org/d:$1"; }

# -------------------------------------------------------------------
# define zsh test conditionals
# -------------------------------------------------------------------
deftest() {
  raw_conditions="$(curl -sL "http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html")"
  if [[ -n "$1" ]]; then
    sanitize "$raw_conditions" | grep -B 2 -A 8 -e"$1"
  else
    sanitize "$raw_conditions"
  fi
}

# -------------------------------------------------------------------
# search apps in usual places
# -------------------------------------------------------------------
findapp() {
  ag -lg "$1" /c/Program\ Files
  ag -lg "$1" /c/Program\ Files\(x86\)
}

# -------------------------------------------------------------------
# install everything
# -------------------------------------------------------------------
everything() {
  mkdir -p "$NPM_CONFIG_PREFIX"
  mkdir -p "$NPM_SRC_BASE"
  if [[ IS_WIN -eq 1 ]]; then
    hash node 2>/dev/null || curl -sL https://nodejs.org/dist/latest/x64/node.exe >"$USR_BIN_ROOT/node.exe"
  fi
  if [[ IS_MAC -eq 1 ]]; then
    hash node 2>/dev/null || brew install node
  fi
  hash npm 2>/dev/null || {
    pushd "$NPM_SRC_BASE" 2>/dev/null
      printf -- "\nprefix=%s\nshell=bash\n" "$NPM_CONFIG_PREFIX" >"$HOME/.npmrc"
      git clone "$NPM_GIT_SRC"
      pushd npm
        ./configure
        make link
      popd
    popd
  }
}

# -------------------------------------------------------------------
# profile startup time of app (defaults zsh)
# -------------------------------------------------------------------
startup() {
  /usr/bin/time ${1-zsh} -i -c exit
}

# -------------------------------------------------------------------
# modify npm log level
# -------------------------------------------------------------------
loglevel() {
  npm config -g set loglevel $1
}

# -------------------------------------------------------------------
# set logging to extremely verbose
# -------------------------------------------------------------------
loglevel-silly() {
  loglevel silly
  export GIT_TRACE=1
  export GIT_CURL_VERBOSE=1
  export V=1
}

# -------------------------------------------------------------------
# reset logging to defaults
# -------------------------------------------------------------------
loglevel-reset() {
  loglevel warn
  unset GIT_TRACE
  unset GIT_CURL_VERBOSE
  unset V
}


# -------------------------------------------------------------------
# configure global git settings
# -------------------------------------------------------------------
setup-git() {
  if [[ $IS_WIN -eq 1 ]]; then
    curl -sL "http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=gitcredentialstore&DownloadId=834616&FileTime=130434786227870000&Build=21028" >"/usr/local/bin/git-credential-winstore.exe"
    git-credential-winstore -s
  fi
}

# -------------------------------------------------------------------
# git add, commit, and publish to npm
# -------------------------------------------------------------------
npm-pub() {
  if [[ -n "$1" ]]; then
    local repo_root="$USR_SRC_ROOT/$1"
    local commit_msg="${2-"publishing $1"}"
  else
    local repo_root="$PWD"
    local commit_msg="publishing $(basename $PWD)"
  fi

  if [[ -d "$repo_root/.git" ]]; then
    pushd "$repo_root" 2>/dev/null
      git add -A 2>/dev/null
      git commit -am ${2-"publishing $1"} 2>/dev/null
      npm version patch
      npm publish
      git push --follow-tags
    popd 2>/dev/null
  else
    printf -- "%s is not a git repository...\n" "$repo_root"
  fi
}


npm-url() {
  printf -- "https://www.npmjs.com/package/%s" "$1"
}

npm-grep() {
  url="$(npm-url "$1")"
  [[ -n "$2" ]] && curls $url | grep "$2"
  [[ -z "$2" ]] && curls $url
}

npm-exists() {
  package="$1"
  package_root="$USR_SRC_ROOT/$package"

  if [[ -z "$(npm-grep "$1" "not found")" ]]; then
    read -q "navigate?$package exists... open? (Yn):"
    [[ $navigate = n ]] && return 0
    chrome --new-window "$(npm-url "$package")"
  else
    read -q "make_package?$package does not exist... claim? (Yn):"
    [[ $make_package = n ]] && return 0
    mkdir -p "$package_root"
    cd "$package_root"
    git init
    npm init
    npm publish
  fi
}

# -------------------------------------------------------------------
# pull latest upstream code for a git fork and rebase on top
# -------------------------------------------------------------------
update-fork() {
  [[ -d "${1-"$PWD"}/.git" ]] && git fetch upstream && git checkout master && git rebase upstream/master
}

update-npm() {
  pushd "$NPM_SRC_ROOT" 2>/dev/null
    git remote add upstream https://github.com/npm/npm
    git fetch upstream
    git checkout master
    git reset upstream/master --hard
    ./configure
    make link
  popd 2>/dev/null
}

update-zprezto() {
  pushd "$ZPREZTO_ROOT" 2>/dev/null
    git pull && git submodule update --init --recursive
  popd 2>/dev/null
}

# -------------------------------------------------------------------
# find all git repositories relative to current directory recursively
# -------------------------------------------------------------------
ls-git-recursive() {
  ls -R --directory --color=never */.git | sed 's/\/.git//'
}

# -------------------------------------------------------------------
# git pull on all directories recursively
# -------------------------------------------------------------------
pull-recursive() {
  ls-git-recursive | xargs -P10 -I{} git -C {} pull || printf -- "could not update %s" {}
}

# -------------------------------------------------------------------
# git pull on all directories recursively
# -------------------------------------------------------------------
status-recursive() {
  ls-git-recursive | xargs -P10 -I{} git -C {} status
}


# -------------------------------------------------------------------
# take a backup of path and delete it
# -------------------------------------------------------------------
backup() {
  if [[ -z "$1" ]]; then
    printf -- "Must pass something to backup...\n"
  elif [[ ! -e "$1" ]]; then
    printf -- "%s does not exist...\n" "$1"
  else
    local backup_path="$USR_BACKUP_ROOT/${1##*/}_$(date +%s)"
    printf -- "backing up %s to %s...\n" "$1" "$backup_path"
    mkdir -p "$USR_BACKUP_ROOT"
    cp -rf "$1" "$backup_path"
    rm -rf "$1"
  fi
}



# -------------------------------------------------------------------
# force copy a directory or path and backup dest if it exists
# -------------------------------------------------------------------
cprf() {
  if [[ $# -lt 2 ]]; then
    printf -- "Must specify source and destination...\n"
    return 1
  fi
  if [[ -e "$2" ]]; then
    backup "$2"
  fi
  cp -rf "$1" "$2"
}

# -------------------------------------------------------------------
# update a gist in user gist directory and file system from github
# -------------------------------------------------------------------
update-gist() {
  if [[ $# -lt 2 ]]; then
    printf -- "usage: update-gist gist_id file_path\n"
    return 1
  fi
  local gist_id="$1"
  local file_path="$2"
  local file_name="${2##*/}"

  local gist_url="$GIST_BASE_URL/$gist_id"
  local gist_root="$USR_SRC_GIST_ROOT/$gist_id"
  local gist_path="$gist_root/$file_name"

  if [[ -d "$gist_root" ]]; then
    pushd "$gist_root" 2>/dev/null
      printf -- "updating %s source...\n" "$file_name"
      git pull
    popd 2>/dev/null
  else
    mkdir -p "$USR_SRC_GIST_ROOT"
    pushd "$USR_SRC_GIST_ROOT" 2>/dev/null
      printf -- "cloning %s source...\n" "$file_name"
      git clone "$gist_url"
    popd 2>/dev/null
  fi

  printf -- "force copying %s to %s...\n" "$gist_path" "$file_path"
  cprf "$gist_path" "$file_path"
}

# -------------------------------------------------------------------
# clone or pull a git repo from github to your machine
# -------------------------------------------------------------------
update-git() {
  if [[ $# -lt 1 ]]; then
    printf -- "usage: update-git repo_path [repo_url]\n"
    return 1
  fi

  local repo_path="$1"
  local root_path="${1%/*}"
  local repo_name="${1##*/}"
  local git_url="${2-"$GIT_USER_URL/$repo_name"}"

  if [[ -d "$repo_path" ]]; then
    pushd "$repo_path" 2>/dev/null
      printf -- "updating %s source...\n" "$repo_path"
      git pull
    popd 2>/dev/null
  else
    mkdir -p "$root_path"
    pushd "$root_path" 2>/dev/null
      printf -- "cloning %s to %s/%s...\n" "$git_url" "$root_path" "$repo_name"
      git clone "$git_url" "$repo_name"
    popd 2>/dev/null
  fi
}

# -------------------------------------------------------------------
# when git merge happens and you want theirs for a file
# -------------------------------------------------------------------
backup-merge-use-their-file() {
  if [[ -e "$1" ]]; then
    backup "$1"
    git checkout --theirs -- "$1"
    git add "$1"
  fi
}

# -------------------------------------------------------------------
# when git merge happens and you want ours for a file
# -------------------------------------------------------------------
backup-merge-use-our-file() {
  if [[ -e "$1" ]]; then
    backup "$1"
    git checkout --ours -- "$1"
    git add "$1"
  fi
}

# -------------------------------------------------------------------
# get basic status of files in git repo filtered by a grep
# -------------------------------------------------------------------
git-status-filter() {
  git status --porcelain | grep $1 | sed 's/[A-Z]* //g'
}

# -------------------------------------------------------------------
# takes backup and overwrites all merge conflicts with their files
# -------------------------------------------------------------------
backup-merge-use-their-files() {
  git-status-filter AA | while read file
  do
    backup-merge-use-their-file "$file"
  done
}

# -------------------------------------------------------------------
# takes backup and overwrites all merge conflicts with our files
# -------------------------------------------------------------------
backup-merge-use-our-files() {
  git-status-filter AA | while read file
  do
    backup-merge-use-our-file "$file"
  done
}

# -------------------------------------------------------------------
# git add, commit and push to github
# -------------------------------------------------------------------
save-git() {
  if [[ $# -lt 1 ]]; then
    printf -- "usage: save-git repo_root\n"
    return 1
  fi
  local repo_root="$1"
  if [[ ! -d "$repo_root/.git" ]]; then
    printf -- "%s does not exist or is not a git repository...\n" "$repo_root"
    return 1
  fi
  pushd "$repo_root" 2>/dev/null
    git add -A 2>/dev/null && git commit -am "${2-"updating $(basename $1)"}" 2>/dev/null && git push
  popd 2>/dev/null
}

# -------------------------------------------------------------------
# save gist to github
# -------------------------------------------------------------------
save-gist() {
  if [[ $# -lt 1 ]]; then
    printf -- "usage: save-gist gist_id\n"
    return 1
  fi
  local gist_root="$USR_SRC_GIST_ROOT/$1"
  printf -- "saving gist...\n"
  save-git "$gist_root"
}

# -------------------------------------------------------------------
# save local $ZDOTDIR/.zshrc to github
# -------------------------------------------------------------------
save-zshrc() {
  cprf "$DOT_ZSHRC_PATH" "$USR_SRC_GIST_ROOT/$GIST_ZSHRC_ID/.zshrc"
  save-gist "$GIST_ZSHRC_ID"
}

# -------------------------------------------------------------------
# save local ~/.zshenv to github
# -------------------------------------------------------------------
save-zshenv() {
  cprf "$DOT_ZSHENV_PATH" "$USR_SRC_GIST_ROOT/$GIST_ZSHENV_ID/.zshenv"
  save-gist "$GIST_ZSHENV_ID"
}

# -------------------------------------------------------------------
# save local ~/.vimrc to github
# -------------------------------------------------------------------
save-vimrc() {
  cprf "$DOT_VIMRC_PATH" "$USR_SRC_GIST_ROOT/$GIST_VIMRC_ID/.vimrc"
  save-gist "$GIST_VIMRC_ID"
}

# -------------------------------------------------------------------
# save $ZDOTDIR to github
# -------------------------------------------------------------------
save-zdotdir() {
  save-git "$ZDOTDIR"
}


# -------------------------------------------------------------------
# update $ZDOTDIR/.zshrc from github
# -------------------------------------------------------------------
update-zshrc() {
  update-gist "$GIST_ZSHRC_ID" "$DOT_ZSHRC_PATH"
}

# -------------------------------------------------------------------
# update ~/.zshenv from github
# -------------------------------------------------------------------
update-zshenv() {
  update-gist "$GIST_ZSHENV_ID" "$DOT_ZSHENV_PATH"
}

# -------------------------------------------------------------------
# update ~/.vimrc from github
# -------------------------------------------------------------------
update-vimrc() {
  update-gist "$GIST_VIMRC_ID" "$DOT_VIMRC_PATH"
}

# -------------------------------------------------------------------
# update $ZDOTDIR from github
# -------------------------------------------------------------------
update-zdotdir() {
  update-git "$ZDOTDIR" "$GIT_URL_ZDOTDIR"
}

clone-tixinc() {
  mkdir -p "$HOME/tixinc"
  pushd "$HOME/tixinc" 2>/dev/null
    git clone https://$GIT_USERNAME@github.com/tixinc/config
    git clone https://$GIT_USERNAME@github.com/tixinc/ext
    git clone https://$GIT_USERNAME@github.com/tixinc/automation
    git clone https://$GIT_USERNAME@github.com/tixinc/tix-cli
    git clone https://$GIT_USERNAME@github.com/tixinc/tixinc-js
    git clone https://$GIT_USERNAME@github.com/tixinc/tixinc-net
  popd 2>/dev/null
}

# -------------------------------------------------------------------
# update all dotfiles to latest version from github
# -------------------------------------------------------------------
update-dotfiles() {
  update-zshenv
  update-vimrc
  update-zdotdir
}

# -------------------------------------------------------------------
# save local dotfiles to github
# -------------------------------------------------------------------
save-dotfiles() {
  save-zshenv
  save-zshrc
  save-vimrc
  save-zdotdir
}

update-system() {
  update-dotfiles
  update-npm
}

save-system() {
  save-dotfiles
}