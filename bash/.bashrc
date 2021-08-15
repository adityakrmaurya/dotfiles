# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
# case "$TERM" in
# xterm*|rxvt*)
#     PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#     ;;
# *)
    #     ;;
    # esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto -lat'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# TerminalForLife
# ANSI color escape sequences. Useful else, not just the prompt.
C_Red='\e[2;31m';       C_BRed='\e[1;31m';      C_Green='\e[2;32m';
C_BGreen='\e[1;32m';    C_Yellow='\e[2;33m';    C_BYellow='\e[1;33m';
C_Grey='\e[2;37m';      C_Reset='\e[0m';        C_BPink='\e[1;35m';
C_Italic='\e[3m';       C_Blue='\e[2;34m';      C_BBlue='\e[1;34m';
C_Pink='\e[2;35m';      C_Cyan='\e[2;36m';      C_BCyan='\e[1;36m'

PROMPT_PARSER(){
    X=$1
    (( $X == 0 )) && X=

    if git rev-parse --is-inside-work-tree &> /dev/null; then
        GI=(
            '≎' # Clean
            '≍' # Uncommitted changes
            '≭' # Unstaged changes
            '≺' # New file(s)
            '⊀' # Removed file(s)
            '≔' # Initial commit
            '∾' # Branch is ahead
            '⮂' # Fix conflicts
            '!' # Unknown (ERROR)
            '-' # Removed file(s)
        )

        Status=`git status 2> /dev/null`
        Top=`git rev-parse --show-toplevel`

        local GitDir=`git rev-parse --git-dir`
        if [ "$GitDir" == '.' ] || [ "$GitDir" == "${PWD%%/.git/*}/.git" ]; then
            Desc="${C_BRed}∷  ${C_Grey}Looking under the hood..."
        else
            if [ -n "$Top" ]; then
                # Get the current branch name.
                IFS='/' read -a A < "$Top/.git/HEAD"
                local GB=${A[${#A[@]}-1]}
            fi

                # The following is in a very specific order of priority.
                if [ -z "$(git rev-parse --branches)" ]; then
                    Desc="${C_BCyan}${GI[5]}  ${C_Grey}Branch '${GB:-?}' awaits its initial commit."
                else
                    while read -ra Line; do
                        if [ "${Line[0]}${Line[1]}${Line[2]}" == '(fixconflictsand' ]; then
                            Desc="${C_BCyan}${GI[7]}  ${C_Grey}Branch '${GB:-?}' has conflict(s)."
                            break
                        elif [ "${Line[0]}${Line[1]}" == 'Untrackedfiles:' ]; then
                            NFTTL=0
                            while read -a Line; do
                                [ "${Line[0]}" == '??' ] && let NFTTL++
                            done <<< "$(git status --short)"
                            printf -v NFTTL "%'d" $NFTTL

                            Desc="${C_BCyan}${GI[3]}  ${C_Grey}Branch '${GB:-?}' has $NFTTL new file(s)."
                            break
                        elif [ "${Line[0]}" == 'deleted:' ]; then
                            Desc="${C_BCyan}${GI[9]}  ${C_Grey}Branch '${GB:-?}' detects removed file(s)."
                            break
                        elif [ "${Line[0]}" == 'modified:' ]; then
                            readarray Buffer <<< "$(git --no-pager diff --name-only)"
                            printf -v ModifiedFiles "%'d" ${#Buffer[@]}
                            Desc="${C_BCyan}${GI[2]}  ${C_Grey}Branch '${GB:-?}' has $ModifiedFiles modified file(s)."
                            break
                        elif [ "${Line[0]}${Line[1]}${Line[2]}${Line[3]}" == 'Changestobecommitted:' ]; then
                            Desc="${C_BCyan}${GI[1]}  ${C_Grey}Branch '${GB:-?}' has changes to commit."
                            break
                        elif [ "${Line[0]}${Line[1]}${Line[3]}" == 'Yourbranchahead' ]; then
                            printf -v TTLCommits "%'d" "${Line[7]}"
                            Desc="${C_BCyan}${GI[6]}  ${C_Grey}Branch '${GB:-?}' leads by $TTLCommits commit(s)."
                            break
                        elif [ "${Line[0]}${Line[1]}${Line[2]}" == 'nothingtocommit,' ]; then
                            printf -v TTLCommits "%'d" "$(git rev-list --count HEAD)"

                            Desc="${C_BCyan}${GI[0]}  ${C_Grey}Branch '${GB:-?}' is $TTLCommits commit(s) clean."
                            break
                        fi
                    done <<< "$Status"
                fi
        fi
    fi
    PS1="\[${C_Reset}\]╭──╼${X}╾──☉  ${Desc}\[${C_Reset}\]\n╰─☉  "
    unset Z Line Desc GI Status Top X GB CWD\
        Buffer ModifiedFiles TTLCommits NFTTL
}
PROMPT_COMMAND='PROMPT_PARSER $?'
source "$HOME/.vim/bundle/gruvbox/gruvbox_256palette.sh"

