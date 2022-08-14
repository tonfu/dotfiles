_isarch=false
[[ -f /etc/arch-release ]] && _isarch=true

_isxrunning=false
[[ -n "$DISPLAY" ]] && _isxrunning=true

_isroot=false
[[ $UID -eq 0 ]] && _isroot=true

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

shopt -s cdspell			        # Correct cd typos
shopt -s checkwinsize			    # Update windows size on command
shopt -s histappend			        # Append History
shopt -s extglob			        # Extended pattern
shopt -s no_empty_cmd_completion	# No empty completion
shopt -s autocd                     # Auto CD when entering just path
    # --- Completion ---
	#complete -cf sudo

    [ -r /usr/share/bash-completion/bash_completion   ] && . /usr/share/bash-completion/bash_completion

    # --- Bash History ---
    export HISTSIZE=1000            # bash history will save N commands
    export HISTFILESIZE=${HISTSIZE} # bash will remember N commands
    export HISTCONTROL=ignoreboth   # ignore duplicates and spaces
    export HISTIGNORE='&:ls:ll:la:cd:exit:clear:history'

    # --- Colored Manual Pages
    if $_isxrunning; then
      export PAGER=less
      export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
      export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
      export LESS_TERMCAP_me=$'\E[0m'           # end mode
      export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
      export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
      export LESS_TERMCAP_ue=$'\E[0m'           # end underline
      export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
    fi

# --- Dir Colors ---
eval $( dircolors -b $HOME/.dircolors )

# --- Color Codes ---
NO_COLOR="\[\033[0m\]"
LIGHT_WHITE="\[\033[1;37m\]"
WHITE="\[\033[0;37m\]"
GRAY="\[\033[1;30m\]"
BLACK="\[\033[0;30m\]"
RED="\[\033[0;31m\]"
LIGHT_RED="\[\033[1;31m\]"
GREEN="\[\033[0;32m\]"
LIGHT_GREEN="\[\033[1;32m\]"
YELLOW="\[\033[0;33m\]"
LIGHT_YELLOW="\[\033[1;33m\]"
BLUE="\[\033[0;94m\]"
LIGHT_BLUE="\[\033[1;34m\]"
MAGENTA="\[\033[0;35m\]"
LIGHT_MAGENTA="\[\033[1;35m\]"
CYAN="\[\033[0;36m\]"
LIGHT_CYAN="\[\033[1;36m\]"
# --- Extra Color Codes ---
function EXT_COLOR () { echo -ne "\[\033[38;5;$1m\]"; }
ORANGE="`EXT_COLOR 172`"
YELLOW="`EXT_COLOR 226`"
PURPLE="`EXT_COLOR 99`"


# --- Alias ---
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'
alias cpwd='pwd | xclip -selection clipboard'
alias df='df -h'
alias du='du -c -h'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias free='free -h'
alias grep='grep --color=auto'
alias l='ls --color=auto -CF'
alias la='ll -A'
alias lc='ls --group-directories-first -thora'
alias lca='ls --group-directories-first -hota'
alias lco='ls --group-directories-first -hoart'
alias ld='ls --group-directories-first -o'
alias ldo='ls --group-directories-first -lrt'
alias ll='ls --color=auto -alh'
alias lm='la | less'
alias ls='ls --color=auto'
alias mkdir='mkdir -p -v'
alias more='less'
alias mpdviza='mpdviz --viz="spectrum" --file="/tmp/mpd.fifo" --icolor=true --imode="256" --scale=2 --step=2'
alias mv='mv -i'
alias path='echo -e ${PATH//:/\\n}'
alias rmf='rm -Rf'
alias srcbash='. ~/.bashrc'

    # --- SU Access ---
    if ! $_isroot; then
        alias halt='sudo halt'
        alias root='sudo su'
        alias reboot='sudo reboot'
    fi
    # --- Pacman Alias
    if $_isarch; then
      # we're not root
      if ! $_isroot; then
        alias pacman='sudo pacman'
      fi
      alias pacupg='pacman -Syu'            # Synchronize with repositories and then upgrade packages that are out of date on the local system.
      alias pacupd='pacman -Sy'             # Refresh of all package lists after updating /etc/pacman.d/mirrorlist
      alias pacin='pacman -S'               # Install specific package(s) from the repositories
      alias pacinu='pacman -U'              # Install specific local package(s)
      alias pacre='pacman -R'               # Remove the specified package(s), retaining its configuration(s) and required dependencies
      alias pacun='pacman -Rcsn'            # Remove the specified package(s), its configuration(s) and unneeded dependencies
      alias pacinfo='pacman -Si'            # Display information about a given package in the repositories
      alias pacse='pacman -Ss'              # Search for package(s) in the repositories

      alias pacupa='pacman -Sy && sudo abs' # Update and refresh the local package and ABS databases against repositories
      alias pacind='pacman -S --asdeps'     # Install given package(s) as dependencies of another package
      alias pacclean="pacman -Sc"           # Delete all not currently installed package files
      alias pacmake="makepkg -fcsi"         # Make package from PKGBUILD file in current directory
    fi

#--- Commands ---
# Reverse filename
rfilename() {
    for i in $*; do a=$(echo $i | rev); mv $i $a.mkv; done
}

# Copy Preserve timestamp
cpt() {
    cp --preserve=timestamps $*
}

# Diretory traverse
# up <int>
up() {
    local d=""
    limit=$1
    for ((i=1 ; i <= limit ; i++)); do
        d=$d/..
    done
    d=$(echo $d | sed 's/^\///')
    if [[ -z "$d" ]]; then
        d=..
    fi
    cd $d
}

# Calculator
# usage: calc <equation>
calc() {
    if which bc &>/dev/null; then
        echo "scale=3; $*" | bc -l
    else
        awk "BEGIN { print $* }"
    fi
}

# Find files
# usage: find <string>
ff() { find . -type f -iname '*'$*'*' -ls ; }

# Calculate directory size
# usage: dirsize <string>
dirsize () {
    du -shx * .[a-zA-Z0-9_]* 2> /dev/null | egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
    egrep '^ *[0-9.]*M' /tmp/list
    egrep '^ *[0-9.]*G' /tmp/list
    rm -rf /tmp/list
}

# Remove empty directories
# usage: dirempty <string>
fared() {
    read -p "Delete all empty folders recursively [y/N]: " OPT
    [[ $OPT == y ]] && find . -type d -empty -exec rm -fr {} \; &> /dev/null
}

# Enter and list directory
function cd() { builtin cd -- "$@" && { [ "$PS1" = "" ] || ls -havo --group-directories-first --color=auto ; }; }

# move and rename files to lowercase
lowercase() {
    for file ; do
        filename=${file##*/}
        case "$filename" in
        */* ) dirname==${file%/*} ;;
        * ) dirname=.;;
        esac
        nf=$(echo $filename | tr A-Z a-z)
        newname="${dirname}/${nf}"
        if [[ "$nf" != "$filename" ]]; then
        mv "$file" "$newname"
        echo "lowercase: $file --> $newname"
        else
        echo "lowercase: $file not changed."
        fi
    done
}

PS1="${NO_COLOR}[${MAGENTA}\t${NO_COLOR}] ${LIGHT_RED}\w\n${CYAN}» ${NO_COLOR}"
color_prompt=yes
