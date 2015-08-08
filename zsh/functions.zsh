#usr/bin/env zsh
#

# -------------------------------------------------------------------
# apply changes
# -------------------------------------------------------------------
function rezsh {
  . "$USR_ZSHENV_PATH"
  . "$ZSHENV_PATH"
  . "$ZSHRC_PATH"
}

# ------------------------------------------------------------------
# print usage with checking to see if min args were passed
# ------------------------------------------------------------------
function printuse {
  local usage=$1
  local min_args=$2
  local arg_count=$3
  local first_arg=$4
  if [[ $# -lt 3 ]]; then
    printerr "%busage: %bprintuse \"<usage>\" <min_args> <arg_count> <first_arg> %b|| return 1%b\n\tminimum args: 3\n\tprovided: %b%s%b\n" "$fg[blue]" "$fg[green]" "$reset_color" "$fg[magenta]" "$fg[red]" "$#" "$reset_color"
    return 2
  elif [[ $arg_count -lt $min_args ]] || [[ "$first_arg" == "-h" ]] || [[ "$first_arg" == "--help" ]]; then
    printerr "%busage: %b%s%b\n\tminimum args: %s\n\tprovided: %b%s%b\n" "$fg[blue]" "$fg[green]" "$usage" "$fg[magenta]" "$min_args" "$fg[red]" "$arg_count" "$reset_color"
    return 1
  else
    return 0
  fi
}

export ZCONTEXT="$GIT_USERNAME"

function ctx {
  printuse "ctx [context]" 0 $# $1 || return 1
  [[ -n "$1" ]] && export ZCONTEXT="$1"
  printout "%s" "$ZCONTEXT"
}

function noctx {
  printuse "noctx" 0 $# $1 || return 1
  ctx "$GIT_USERNAME"
}

function makecert {
  $PF86/Windows\ Kits/8.0/bin/x64/makecert.exe "$@"
}

function appcmd {
  $PF86/IIS\ Express/appcmd.exe "$@"
}

function makecert-ssl {
  printuse "makecert-ssl <host>" 1 $# $1 || return 1
  local host="$1"
  makecert -r -pe -n "CN=$host" -b 01/01/2000 -e 01/01/2036 -eku 1.3.6.1.5.5.7.3.1 -ss my -sr localMachine -sky exchange -sp "Microsoft RSA SChannel Cryptographic Provider" -sy 12
}

function addcert-ssl {
  printuse "addcert-ssl <port> <cert_hash>" 2 $# $1 || return 1

  #6f98570eaaf1d21b0fc6f1b1d77f73976b843b9b
  #elevate privs
  #netsh
  #http add sslcert ipport=0.0.0.0:7002 appid={214124cd-d05b-4309-9af9-9caa44b2b74a} certhash=6f98570eaaf1d21b0fc6f1b1d77f73976b843b9b

  local port="$1"
  local cert_hash="$2"
  netsh http add sslcert ipport=0.0.0.0:"$port" appid={214124cd-d05b-4309-9af9-9caa44b2b74a} certhash="$cert_hash"
}

function addacl {
  printuse "addacl <url>" 1 $# $1 || return 1
  netsh http add urlacl url="$1" user=everyone
}

function openport {
  printuse "openport <TCP/UDP> <port>" 2 $# $1 || return 1
  local port_type="$1"
  local port="$2"
  netsh firewall add portopening "$port_type" "$port" IISExpressWeb enable ALL
}

function addapphost {
  printuse "addapphost <site_name> <scheme> <port> <host>" 4 $# $1 || return 1
  local site_name="$1"
  local scheme="$2"
  local port="$3"
  local host="$4"
  appcmd set site /site.name:"$site_name" /+bindings.[protocol="$scheme",bindingInformation="*:$port:$host"]
}

function fn-exists {
  type $1 | grep -q 'shell function'
}

function storm-merge {
  printuse "storm-merge <path1> <path2> <path3> <output_path>" 4 $# $1 || return 1
  "$EDITOR_WEBSTORM" merge "$@"
}

function storm-diff {
  printuse "storm-diff <path1> <path2>" 2 $# $1 || return 1
  "$EDITOR_WEBSTORM" diff "$@"
}

function pyhack {
  printuse "pyhack [python_scipt]" 0 $# $1 || return 1
  local python_script="$1"
  if [[ -n "$python_script" ]]; then
    local script_path="$ZPYTHONDIR/$python_script"
    [[ -f "$script_path.py" ]] && vim "$script_path.py" && return 0
    vim "$script_path"
    return 0
  fi
  atom "$ZPYTHONDIR"
}

function hack {
  printuse "hack [[basename/]repo]" 0 $# $1 || return 1
  update $1
  atom .
}

function vimhack {
  printuse "hack [[basename/]repo]" 0 $# $1 || return 1
  update $1
  vim .
}

function stormhack {
  printuse "wshack [[basename/]repo]" 0 $# $1 || return 1
  update $1
  "$EDITOR_WEBSTORM" "$PWD"
}


# -------------------------------------------------------------------
# replace something recursively
# -------------------------------------------------------------------
function replace-recursive {
  printuse "replace-recursive <find_str> <replace_str>" 2 $# $1 || return 1
  hash gsed 2>/dev/null && local SED_CMD="gsed" || SED_CMD="sed"
  find . -type f -name "*.*" -not -path "*/.git/*" -print0 | xargs -0 $SED_CMD -i "s/$1/$2/g"
}

# -------------------------------------------------------------------
# replace windows line endings recursively
# -------------------------------------------------------------------
function fix-line-endings {
  replace-recursive "\r" ""
}

# -------------------------------------------------------------------
# vi history fix
# -------------------------------------------------------------------
function vi-search-fix {
  zle vi-cmd-mode
  zle .vi-history-search-backward
}

# -------------------------------------------------------------------
# executes a nodescript
# -------------------------------------------------------------------
function ns {
  hash nodescript 2>/dev/null || {
    pushd "$ZNODEDIR" 2>/dev/null
      printf -- "linking nodescript...\n"
      npm link
    popd 2>/dev/null
  }
  hash bunyan 2>/dev/null || npm install -g bunyan
  nodescript "$@" | bunyan
}

function agz {
  printuse "agz <pattern>" 1 $# $1 || return 1
  agi "$@" "$ZDOTDIR"
}

# -------------------------------------------------------------------
# search in program directories
# -------------------------------------------------------------------
function agp {
  printuse "agp <pattern>" 1 $# $1 || return 1
  if [[ $IS_WIN -eq 1 ]]; then
    agi --silent -g "$1" "$PF86"
    agi --silent -g "$1" "$PF"
  elif [[ $IS_MAC -eq 1 ]]; then
    agi --silent -g "$1" /Applications
  fi
}

# ------------------------------------------------------------------
# prints out the environment variables related to current system
# ------------------------------------------------------------------
function checks {
  env | grep IS_
  env | grep HAS_
  env | grep '^Z'
}


# ------------------------------------------------------------------
# namedir my_path -> names the current working directory as ~my_path
# ------------------------------------------------------------------
function namedir { $1=$PWD ;  : ~$1 }

function mergedir { 
  printuse "mergedir <dir_one> [<dir_two>] <dir_dest>" 2 $# $1 || return 1
  local dir_one="$1"
  local dir_two="$2"
  local dir_dest="${3-:./}"
  mkdirp "$dir_dest"
  mv $dir_one/* "$dir_dest" && [ "$dir_one" -ef "$dir_dest" ] || rmdir "$dir_one"
  mv $dir_two/* "$dir_dest" && [ "$dir_two" -ef "$dir_dest" ] || rmdir "$dir_two"
  printout "%bfinished merging dirs to %s!%b" "$fg[green]" "$dir_dest" "$reset_color"
}

function add-alias {
  printuse "add-alias <name> <alias>" 2 $# $1 || return 1
  local alias_command="alias $1='$2'"
  printout "\n%s\n" $alias_command >>"$ZSCRIPTDIR/aliases.zsh"
  printout "alias -> %s <- added\n" "$alias_command"
}

function help-expansion {
  printuse "help-expansion <alias>" 2 $# $1 || return 1
  local expansion_help="$ZHELPDIR/expansion"
  mkdirp "$$ZHELPDIR"
  [[ ! -f "$expansion_help" ]] && curl -L http://webcache.googleusercontent.com/search?q=cache:4ChUelyDvkoJ:zsh.sourceforge.net/Doc/Release/Expansion.html | sanitize >"$expansion_help"
  vim "$expansion_help"
}

# ------------------------------------------------------------------
# If ~/_netrc and ! ~/.netrc, symlink ~/.netrc
# ------------------------------------------------------------------
[[ -f "$HOME/_netrc" ]] && [[ ! -f "$HOME/.netrc" ]] && ln -s "$HOME/_netrc" "$HOME/.netrc"

function vlcp {
  local vlc_path="${1-:./}"
  vlc "$vlc_path" & disown
  printout "playing %s..." "$vlc_path"
}

function chrome {
  if [[ $IS_WIN -eq 1 ]]; then
    local chrome_args="//new-window $1"
  else
    local chrome_args="--new-window $1"
  fi
  "$CHROME_PATH" $chrome_args
}

# -------------------------------------------------------------------
# compressed file expander
# -------------------------------------------------------------------
function ex {
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
function exdl {
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
function any {
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
function path {
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
function nicemount { (echo "DEVICE PATH TYPE FLAGS" && mount | awk '$2="";1') | column -t ; }

# -------------------------------------------------------------------
# sanitize html into human readable compact text
# -------------------------------------------------------------------
function sanitize {
  printf -- "%s" "$1" | sed -e 's/<[^>]\+>/ /gi' -e 's/&[a-z]\+;/ /gi' -e 's/^ */\n/g' | tr -s '[:space:]' | tr \015 \012 | tr -s \012
}

# -------------------------------------------------------------------
# define a word
# -------------------------------------------------------------------
function defword {
  curl -sL "dict://dict.org/d:$1"
}

# -------------------------------------------------------------------
# define zsh test conditionals
# -------------------------------------------------------------------
function deftest {
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
function findapp {
  ag -lg "$1" /c/Program\ Files
  ag -lg "$1" /c/Program\ Files\(x86\)
}

# -------------------------------------------------------------------
# install everything
# -------------------------------------------------------------------
function everything {
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
function startup {
  /usr/bin/time ${1-zsh} -i -c exit
}

# -------------------------------------------------------------------
# modify npm log level
# -------------------------------------------------------------------
function loglevel {
  npm config -g set loglevel $1
}

# -------------------------------------------------------------------
# set logging to extremely verbose
# -------------------------------------------------------------------
function loglevel-silly {
  loglevel silly
  export GIT_TRACE=1
  export GIT_CURL_VERBOSE=1
  export V=1
}

# -------------------------------------------------------------------
# reset logging to defaults
# -------------------------------------------------------------------
function loglevel-reset {
  loglevel warn
  unset GIT_TRACE
  unset GIT_CURL_VERBOSE
  unset V
}


# -------------------------------------------------------------------
# configure global git settings
# -------------------------------------------------------------------
function setup-git {
  if [[ $IS_WIN -eq 1 ]]; then
    curl -sL "http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=gitcredentialstore&DownloadId=834616&FileTime=130434786227870000&Build=21028" >"/usr/local/bin/git-credential-winstore.exe"
    git-credential-winstore -s
  fi
}

# -------------------------------------------------------------------
# git add, commit, and publish to npm
# -------------------------------------------------------------------
function publish-npm {
  printuse "publish-npm [package] [commit_message]" 0 $# $1 || return 1
  if [[ -n "$1" ]]; then
    local repo_root="$USR_SRC_ROOT/$GIT_USERNAME/$1"
  else
    local repo_root="$PWD"
  fi
  local repo_name="${repo_root##*/}"
  local commit_message="${2-:"publishing $repo_name"}"

  [[ -d "$repo_root/.git" ]] || printerr "%s is not a git repository...\n" "$repo_root" && return 2
  pushd "$repo_root" 2>/dev/null
    git add -A 2>/dev/null
    git commit -am "$commit_message" 2>/dev/null
    npm version patch
    npm publish
    git push --follow-tags
  popd 2>/dev/null
}

# -------------------------------------------------------------------
# parse image urls from a page
# -------------------------------------------------------------------
function get-image-urls {
  printuse "get-image-urls <url>" 1 $# $1 || return 1
  curl -sL "$1" |& perl -e '{use HTML::TokeParser; 
    $parser = HTML::TokeParser->new(\*STDIN); 
    $img = $parser->get_tag('img') ; 
    print "$img->[1]->{src}\n"; 
  }'
}

# -------------------------------------------------------------------
# download images from a page to $ZDOWNLOADDIR/image
# -------------------------------------------------------------------
function get-images {
  printuse "get-images <url>" 1 $# $1 || return 1
  local image_root="$ZDOWNLOADDIR/image"
  mkdirp "$image_root"
  pushd "$image_root"
    get-image-urls "$1" | xargs I{} curl -sL {} >"$ZDOWNLOADDIR"
  popd
}

# -------------------------------------------------------------------
# get url for an npm package
# -------------------------------------------------------------------
function npm-url {
  printuse "npm-url <package>" 1 $# $1 || return 1
  printf -- "https://www.npmjs.com/package/%s" "$1"
}

# -------------------------------------------------------------------
# grep an npm package page
# -------------------------------------------------------------------
function npm-grep {
  printuse "npm-grep <filter>" 1 $# $1 || return 1
  local url="$(npm-url "$1")"
  [[ -n "$2" ]] && curls $url | grep "$2"
  [[ -z "$2" ]] && curls $url
}

# -------------------------------------------------------------------
# check if npm package exists, and optionally reserve if it doesn't
# -------------------------------------------------------------------
function npm-exists {
  printuse "npm-exists <package>" 1 $# $1 || return 1
  local package="$1"
  local package_root="$USR_SRC_ROOT/$GIT_USERNAME/$package"

  if [[ -z "$(npm-grep "$1" "not found")" ]]; then
    read -q "navigate?$package exists... open? (Yn):"
    [[ $navigate = n ]] && return 0
    chrome --new-window "$(npm-url "$package")"
  else
    read -q "make_package?$package does not exist... claim? (Yn):"
    [[ $make_package = n ]] && return 0
    mkdirp "$USR_SRC_ROOT/$package_root"
    cd "$package_root"
    git init
    npm init
    npm publish
  fi
}

# -------------------------------------------------------------------
# validate if a directory (or CWD) is a git repo
# -------------------------------------------------------------------
function is-git {
  printuse "is-git [repo_path] || return 1" 0 $# $1 || return 1
  local repo_path="${1-"$PWD"}"
  local git_path="$repo_path/.git"
  if [[ -d "$git_path" ]]; then
    return 0
  else
    printerr "$repo_path is not a git path..."
    return 1
  fi
}

# -------------------------------------------------------------------
# check if a git remote exists
# -------------------------------------------------------------------
function git-remote-exists {
  printuse "git-remote-exists <remote> || git remote add..." 1 $# $1 || return 1
  is-git || return 1
  if git remote | grep $1 >/dev/null; then
    return 0
  else
    return 1
  fi
}

# -------------------------------------------------------------------
# safe add remote to a git repo (repo optional if in repo)
# -------------------------------------------------------------------
function git-remote-add {
  printuse "git-remote-add <remote> repo_base[/repo_name]" 2 $# $1 || return 1
  local remote="$1"
  local repo_base="${2%/*}"
  local repo_name="${2#*/}"
  [[ -z "$repo_name" ]] && local repo_name="${PWD##*/}"
  local remote_url="https://github.com/$repo_base/$repo_name"
  git-remote-exists upstream || git remote add upstream "$remote_url"
}

# -------------------------------------------------------------------
# pull latest upstream code for a git fork
# -------------------------------------------------------------------
function update-fork {
  printuse "update-fork [repo_base[/repo_name]]" 0 $# $1 || return 1
  [[ -d "$PWD/.git" ]] || (printerr "directory is not a git repo...\n" && return 2)
  if [[ -n "$1" ]]; then
    git-remote-add upstream "$1"
  fi
  git fetch --all
  git checkout master
}


# -------------------------------------------------------------------
# pull latest upstream code for a git fork and rebase on top
# -------------------------------------------------------------------
function update-fork-rebase {
  printuse "update-fork-rebase [repo_base[/repo_name]]" 0 $# $1 || return 1
  update-fork "$@"
  git rebase upstream/master
}

# -------------------------------------------------------------------
# pull latest upstream code for a git fork and overwrite
# -------------------------------------------------------------------
function update-fork-reset {
  printuse "update-fork-reset [repo_base[/repo_name]]" 0 $# $1 || return 1
  update-fork "$@"
  git reset --hard upstream/master
}

function exec-ps {
  printuse "exec-ps <powershell_args>" 1 $# $1 || return 1
  printout "executing [powershell %s]...\n" "$*"
  echo $* | PowerShell -NoLogo -ExecutionPolicy unrestricted -NoProfile -Command -
}

function winpath {
  cygpath -w $1 | sed 's/\\/\\\\/g'
}

# -------------------------------------------------------------------
# run an iso from disk
# -------------------------------------------------------------------
function exec-iso {
  printuse "runiso <iso_path>" 1 $# $1 || return 1
  local iso_path="$1"
  if [[ ! -f "$iso_path" ]]; then
    printerr "no iso located at $iso_path...\n"
    return 2
  fi
  local iso_win_path="$(winpath "$iso_path")"

  exec-ps "Mount-DiskImage -ImagePath \"$iso_win_path\""
  printout "The ISO has been mounted as a local drive. Install manually from here...\n"
  #local drive_letter=$(exec-ps "(Get-DiskImage \"$iso_win_path\" | Get-Disk | Get-Partition | Get-Volume).DriveLetter")
  #echo $drive_letter
}

# -------------------------------------------------------------------
# test if string 1 contains string 2
# -------------------------------------------------------------------
function contains {
  printuse "contains <string> <substring> || ..." 2 $# $1 || return 1
  local string="$1"
  local substring="$2"
  if [[ "${string#*$substring}" != "$string" ]]; then
    return 0
  else
    return 1
  fi
}

# -------------------------------------------------------------------
# download / install the latest visual studio and configure node msvs
# -------------------------------------------------------------------
function update-vs {
  local network_iso_path="/s/microsoft/vs/vs2015.iso"
  local local_iso_path="$ZDOWNLOADDIR/vs2015.iso"
  local local_install_root="$PF86/vs/"
  if [[ -d "$local_install_root" ]]; then
    printout "VS2015 is already installed.\n"
    return 0
  fi
  mkdirp "$ZDOWNLOADDIR"
  if [[ ! -f "$local_iso_path" ]]; then
    if [[ -f "$network_iso_path" ]]; then
      printout "copying VS2015 from %s for offline install...\n" "$network_iso_path"
      cp "$network_iso_path" "$local_iso_path"
    else
      printout "downloading VS2015 from Microsoft for offline install...\n"
      curl -L "http://download.microsoft.com/download/0/B/C/0BC321A4-013F-479C-84E6-4A2F90B11269/vs2015.com_enu.iso" -H "Accept-Encoding: gzip, deflate, sdch" -H "Accept-Language: en-US,en;q=0.8" --compressed >"$local_iso_path"
    fi
  fi
  printout "running iso...\n"
  exec-iso "$local_iso_path"
}

# -------------------------------------------------------------------
# pull latest upstream msys2 packages and reset
# -------------------------------------------------------------------
function update-msys2-packages {
  update "$GIT_MSYS2_PACKAGES_ID"
  pushd "$MSYS2_PACKAGES_ROOT" 2>/dev/null
    update-fork-reset alexpux/msys2-packages
  popd 2>/dev/null
}

# -------------------------------------------------------------------
# pull latest npm and reset
# -------------------------------------------------------------------
function update-npm {
  printuse "update-npm" 0 $# $1 || return 1
  update "$GIT_NPM_ID"
  pushd "$NPM_SRC_ROOT" 2>/dev/null
    update-fork-reset npm/npm
    ./configure
    make link
  popd 2>/dev/null
  rezsh
  npm install -g rimraf
  npm install -g mkdirp
}

# -------------------------------------------------------------------
# pushes the latest npm code to github
# -------------------------------------------------------------------
function save-npm {
  save-git "$NPM_SRC_ROOT"
}

# -------------------------------------------------------------------
# pull latest prezto and rebase
# -------------------------------------------------------------------
function update-prezto {
  printuse "update-prezto" 0 $# $1 || return 1
  pushd "$ZPREZTODIR" 2>/dev/null
    update-fork-rebase sorin-ionescu/prezto
    git pull 2>/dev/null && git submodule update --init --recursive 2>/dev/null
  popd 2>/dev/null
}

# -------------------------------------------------------------------
# describe a function
# -------------------------------------------------------------------
function descfn {
  cat "$ZSCRIPTDIR/functions.zsh" | grep -B 3 -C 0 $1
}

# -------------------------------------------------------------------
# find all git repositories relative to current directory recursively
# -------------------------------------------------------------------
function ls-git-recursive {
  ls -R --directory --color=never */.git | sed 's/\/.git//'
}

# -------------------------------------------------------------------
# git pull on all directories recursively
# -------------------------------------------------------------------
function pull-recursive {
  ls-git-recursive | xargs -P10 -I{} git -C {} pull || printf -- "could not update %s" {}
}

# -------------------------------------------------------------------
# git pull on all directories recursively
# -------------------------------------------------------------------
function status-recursive {
  ls-git-recursive | xargs -P10 -I{} git -C {} status
}

function get-random {
  printuse "get-random count" 1 $# $1 || return 1
  rand="$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | fold -w "$1" | head -n 1)"
  printout "%s" "$rand"
}

# -------------------------------------------------------------------
# take a backup of path and delete it
# -------------------------------------------------------------------
function backup {
  printuse "backup <path>" 1 $# $1 || return 1
  local src_path="$1"
  [[ ! -e "$1" ]] && printerr "%s does not exist...\n" "$src_path" && return 2
  local backup_path="$USR_BACKUP_ROOT/${src_path##*/}_$(date +%s)_$(get-random 3)"
  printout "backing up %s to %s...\n" "$src_path" "$backup_path"
  mkdirp "$USR_BACKUP_ROOT"
  cp -rf "$src_path" "$backup_path"
}


# -------------------------------------------------------------------
# force copy a directory or path and backup dest if it exists
# -------------------------------------------------------------------
function cprf {
  printuse "cprf <src_path> <dest_path>" 2 $# $1 || return 1
  local src_path="$1"
  local dest_path="$2"
  if [[ -e "$dest_path" ]]; then
    backup "$dest_path"
    rimraf "$dest_path"
  fi
  cp -rf "$src_path" "$dest_path"
}

# -------------------------------------------------------------------
# update a gist in user gist directory and file system from github
# -------------------------------------------------------------------
function update-gist {
  printuse "update-gist <gist_id> <file_path> [skip_sync]" 2 $# $1 || return 1
  local gist_id="$1"
  local file_path="$2"
  local file_name="${2##*/}"

  local gist_url="$GIST_BASE_URL/$gist_id"
  local gist_root="$USR_SRC_GIST_ROOT/$gist_id"
  local gist_path="$gist_root/$file_name"

  if [[ -d "$gist_root" ]]; then
    pushd "$gist_root" 2>/dev/null
      printout "updating %s source...\n" "$file_name"
      git pull
    popd 2>/dev/null
  else
    mkdirp "$USR_SRC_GIST_ROOT"
    pushd "$USR_SRC_GIST_ROOT" 2>/dev/null
      printout "cloning %s source...\n" "$file_name"
      git clone "$gist_url"
    popd 2>/dev/null
  fi

  if [[ -z $skip_sync ]]; then
    printout "force copying %s to %s...\n" "$gist_path" "$file_path"
    cprf "$gist_path" "$file_path"
  fi
}

# -------------------------------------------------------------------
# clone or pull a git repo from github to your machine
# -------------------------------------------------------------------
function update-git {
  printuse "update-git <repo_id> <repo_root>" 2 $# $1 || return 1
  local repo_id="$1"
  local repo_root="$2"
  local base_root="${repo_root%/*}"
  local repo_name="${repo_root##*/}"
  local repo_base="${base_root##*/}"
  local git_url="$GIT_BASE_URL/$repo_id"

  if [[ -d "$repo_root" ]]; then
    pushd "$repo_root" 2>/dev/null
      printout "updating %s source...\n" "$repo_root"
      git pull 2>/dev/null
      git pull --tags 2>/dev/null
    popd 2>/dev/null
  else
    mkdirp "$base_root"
    pushd "$base_root" 2>/dev/null
      printout "cloning %s to %s...\n" "$git_url" "$repo_root"
      git clone "$git_url" "$repo_name" 2>/dev/null
    popd 2>/dev/null
  fi
}

# -------------------------------------------------------------------
# resolve a git repo base from a dirty repo id
# -------------------------------------------------------------------
function resolve-repo-base {
  printuse "resolve-repo-base [repo_base/]repo_name" 1 $# $1 || return 1
  local repo_base="${1%/*}"
  [[ "$repo_base" == "$1" ]] && local repo_base="$ZCONTEXT"
  printout "%s" "$repo_base"
}

# -------------------------------------------------------------------
# resolve a git repo name from a dirty repo id
# -------------------------------------------------------------------
function resolve-repo-name {
  printuse "resolve-repo-name [repo_base/]repo_name" 1 $# $1 || return 1
  printout "%s" "${1#*/}"
}

# -------------------------------------------------------------------
# resolve a git repo id -> (base_name ?? GIT_USERNAME)/repo_name
# -------------------------------------------------------------------
function resolve-repo-id {
  printuse "resolve-repo-id [repo_base/]repo_name" 0 $# $1 || return 1
  local raw_repo_id="${1-${PWD##*/*/}}"
  local repo_base="$(resolve-repo-base $raw_repo_id)"
  local repo_name="$(resolve-repo-name $raw_repo_id)"
  printout "%s/%s" "$repo_base" "$repo_name"
}

# -------------------------------------------------------------------
# shorthand to jump to a standard location or CWD
# -------------------------------------------------------------------
function go {
  printuse "go [[repo_base/]repo_name]" 0 $# $1 || return 1
  local repo_id="$(resolve-repo-id $1)"
  local repo_root="$USR_SRC_ROOT/$repo_id"
  cd "$repo_root"
}

# -------------------------------------------------------------------
# shorthand to update-git a repo to standard location or CWD
# -------------------------------------------------------------------
function update {
  printuse "update [[repo_base/]repo_name]" 0 $# $1 || return 1
  local repo_id="$(resolve-repo-id $1)"
  local repo_root="$USR_SRC_ROOT/$repo_id"
  update-git "$repo_id" "$repo_root"
  cd "$repo_root"
}

# -------------------------------------------------------------------
# shorthand to save-git a repo in standard location or CWD
# -------------------------------------------------------------------
function save {
  printuse "save [.|[repo_base/]repo_name]" 0 $# $1 || return 1
  [[ $1 = "." ]] && save-git && return 0
  local repo_id="$(resolve-repo-id $1)"
  local repo_root="$USR_SRC_ROOT/$repo_id"
  save-git "$repo_root"
}

# -------------------------------------------------------------------
# shorthand to save-git and npm publish a repo in standard or CWD
# -------------------------------------------------------------------
function publish {
  printuse "publish [[repo_base/]repo_name]" 0 $# $1 || return 1
  save "$@"
  npm publish
}

# -------------------------------------------------------------------
# when git merge happens and you want theirs for a file
# -------------------------------------------------------------------
function backup-merge-use-their-file {
  printuse "backup-merge-use-their-file <file_path>" 1 $# $1 || return 1
  local file_path="$1"
  if [[ -e "$file_path" ]]; then
    backup "$file_path"
    git checkout --theirs -- "$file_path"
    git add "$file_path"
  fi
}

# -------------------------------------------------------------------
# when git merge happens and you want ours for a file
# -------------------------------------------------------------------
function backup-merge-use-our-file {
  printuse "backup-merge-use-our-file <file_path>" 1 $# $1 || return 1
  local file_path="$1"
  if [[ -e "$file_path" ]]; then
    backup "$file_path"
    git checkout --ours -- "$file_path"
    git add "$file_path"
  fi
}

# -------------------------------------------------------------------
# get basic status of files in git repo filtered by a grep
# -------------------------------------------------------------------
function git-status-filter {
  printuse "git-status-filter <filter>" 1 $# $1 || return 1
  git status --porcelain | grep $1 | sed 's/[A-Z]* //g'
}

# -------------------------------------------------------------------
# takes backup and overwrites all merge conflicts with their files
# -------------------------------------------------------------------
function backup-merge-use-their-files {
  git-status-filter AA | while read file
  do
    backup-merge-use-their-file "$file"
  done
}

# -------------------------------------------------------------------
# takes backup and overwrites all merge conflicts with our files
# -------------------------------------------------------------------
function backup-merge-use-our-files {
  git-status-filter AA | while read file
  do
    backup-merge-use-our-file "$file"
  done
}

function create-github-repo {
  printuse "create-github-repo <repo_name> [repo_description]" 1 $# $1 || return 1
  local repo_name="$1"
  local repo_description="${2-"GitHub repo for $repo_name"}"
  json_body="$(printout '{"name":"%s","description":"%s"}' "$repo_name" "$repo_description")"
  curl -u "$GIT_USERNAME" https://api.github.com/user/repos -d "$json_body"
}

# -------------------------------------------------------------------
# git add, commit and push to github
# -------------------------------------------------------------------
function save-git {
  printuse "save-git [repo_root] [commit_msg]" 0 $# $1 || return 1
  local repo_root="${1-"$PWD"}"
  local repo_name="${repo_root##*/}"
  local init_msg="${2-"initializing $repo_name..."}"
  local commit_msg="${2-"updating $repo_name"}"

  if [[ ! -d "$repo_root/.git" ]]; then
    printerr "%s does not exist, creating...\n" "$repo_root"
    mkdirp "$repo_root"
    pushd "$repo_root" 2>/dev/null
      create-github-repo "$repo_name" || (printerr "error creating github repo %s" "$repo_name" && return 2)
      git init
      git add .
      git commit -m "$init_msg"
      local remote_url="https://github.com/$GIT_USERNAME/$repo_name"
      git remote add origin "$remote_url"
      git push origin master
    popd 2>/dev/null
  else
    pushd "$repo_root" 2>/dev/null
      git add -A 2>/dev/null
      git commit -am "$commit_msg" 2>/dev/null
      [[ -f "$repo_root/package.json" ]] && npm version patch
      git push --follow-tags
    popd 2>/dev/null
  fi
}

# -------------------------------------------------------------------
# save gist to github
# -------------------------------------------------------------------
function save-gist {
  printuse "save-gist <gist_id> <file_path>" 2 $# $1 || return 1
  local gist_id="$1"
  local gist_root="$USR_SRC_GIST_ROOT/$gist_id"
  local file_path="$2"
  local file_name="${file_path##*/}"
  local gist_path="$gist_root/${file_path##*/}"
  if [[ ! -d "$gist_root" ]]; then
    printout "updating gist first...\n"
    update-gist "$gist_id" "$file_path" 1
  fi
  printout "copying gist...\n"
  cprf "$file_path" "$gist_path"
  printout "saving gist...\n"
  save-git "$gist_root"
}


# -------------------------------------------------------------------
# save local $ZDOTDIR/.zshrc to github
# -------------------------------------------------------------------
function save-zshrc {
  save-gist "$GIST_ZSHRC_ID" "$ZSHRC_PATH"
}

# -------------------------------------------------------------------
# save local ~/.zshenv to github
# -------------------------------------------------------------------
function save-uzshenv {
  save-gist "$GIST_USR_ZSHENV_ID" "$USR_ZSHENV_PATH"
}

# -------------------------------------------------------------------
# save local $ZDOTDIR/.zshenv to github
# -------------------------------------------------------------------
function save-zshenv {
  save-gist "$GIST_ZSHENV_ID" "$ZSHENV_PATH"
}

# -------------------------------------------------------------------
# save local ~/.vimrc to github
# -------------------------------------------------------------------
function save-vimrc {
  save-gist "$GIST_VIMRC_ID" "$VIMRC_PATH"
}

# -------------------------------------------------------------------
# save $ZPREZTODIR to github
# -------------------------------------------------------------------
function save-prezto {
  save-git "$ZPREZTODIR"
}

# -------------------------------------------------------------------
# save $ZDOTDIR to github
# -------------------------------------------------------------------
function save-zdotdir {
  save-git "$ZDOTDIR"
}


# -------------------------------------------------------------------
# update $ZDOTDIR/.zshrc from github
# -------------------------------------------------------------------
function update-zshrc {
  update-gist "$GIST_ZSHRC_ID" "$ZSHRC_PATH"
}

# -------------------------------------------------------------------
# update ~/.zshenv from github
# -------------------------------------------------------------------
function update-uzshenv {
  update-gist "$GIST_USR_ZSHENV_ID" "$USR_ZSHENV_PATH"
}

# -------------------------------------------------------------------
# update $ZDOTDIR/.zshenv from github
# -------------------------------------------------------------------
function update-zshenv {
  update-gist "$GIST_ZSHENV_ID" "$ZSHENV_PATH"
}

# -------------------------------------------------------------------
# update ~/.vimrc from github
# -------------------------------------------------------------------
function update-vimrc {
  update-gist "$GIST_VIMRC_ID" "$VIMRC_PATH"
}

# -------------------------------------------------------------------
# update $ZDOTDIR from github
# -------------------------------------------------------------------
function update-zdotdir {
  update-git "$GIT_ZDOTDIR_ID" "$ZDOTDIR"
}


function update-conemu {
  cprf "$ZETCDIR/ConEmu.xml" "$HOME/local/conemu/ConEmu.xml"
}

function save-conemu {
  cprf "$HOME/local/conemu/ConEmu.xml" "$ZETCDIR/ConEmu.xml"
}


function update-tixinc {
  local tixinc_root="$HOME/tixinc"
  mkdirp "$tixinc_root"
  update-git tixinc/config "$tixinc_root/config"
  update-git tixinc/ext "$tixinc_root/ext"
  update-git tixinc/automation "$tixinc_root/automation"
  update-git tixinc/tix-cli "$tixinc_root/tix-cli"
  update-git tixinc/tixinc-js "$tixinc_root/tixinc-js"
  update-git tixinc/tixinc-net "$tixinc_root/tixinc-net"
  printout "npm linking tixinc repos...\n"
  link-tixinc
  printout "npm installing tixinc repos...\n"
  install-tixinc
  printout "successfully updated all tixinc repos\n"
}

function link-tixinc {
  local tixinc_root="$HOME/tixinc"
  pushd "$tixinc_root/tix-cli" 2>/dev/null
    npm link
  popd 2>/dev/null
  pushd "$tixinc_root/ext" 2>/dev/null
    npm link ../config
  popd 2>/dev/null
  pushd "$tixinc_root/tixinc-js" 2>/dev/null
    npm link ../config
    npm link ../ext
  popd 2>/dev/null
}

function install-tixinc {
  local tixinc_root="$HOME/tixinc"
  pushd "$tixinc_root/tix-cli" 2>/dev/null
    npm install
  popd 2>/dev/null
  pushd "$tixinc_root/config" 2>/dev/null
    npm install
  popd 2>/dev/null
  pushd "$tixinc_root/ext" 2>/dev/null
    npm install
  popd 2>/dev/null
  pushd "$tixinc_root/tixinc-js" 2>/dev/null
    npm install
  popd 2>/dev/null
}


# -------------------------------------------------------------------
# update all dotfiles to latest version from github
# -------------------------------------------------------------------
function update-dotfiles {
  update-uzshenv
  update-zdotdir
  update-vimrc
  update-prezto
  rezsh
}


# -------------------------------------------------------------------
# save local dotfiles to github
# -------------------------------------------------------------------
function save-dotfiles {
  save-uzshenv
  save-zshenv
  save-zshrc
  save-vimrc
  save-zdotdir
  save-prezto 
}

# -------------------------------------------------------------------
# downloads the latest packages and upgrades
# -------------------------------------------------------------------
function update-pacman {
  pacman -Sy
  pacman -Su
}

# -------------------------------------------------------------------
# update everything
# -------------------------------------------------------------------
function update-system {
  update-dotfiles
  rezsh
  update-npm
  [[ $IS_WIN -eq 1 ]] && update-conemu
}

# -------------------------------------------------------------------
# save everything
# -------------------------------------------------------------------
function save-system {
  [[ $IS_WIN -eq 1 ]] && save-conemu
  save-dotfiles
  save-npm
}
