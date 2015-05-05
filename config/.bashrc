# base-files version 3.9-3

# To pick up the latest recommended .bashrc content,
# look in /etc/defaults/etc/skel/.bashrc

# Modifying /etc/skel/.bashrc directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benificial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .bashrc file

# Environment Variables
# #####################

# TMP and TEMP are defined in the Windows environment.  Leaving
# them set to the default Windows temporary directory can have
# unexpected consequences.
unset TMP
unset TEMP

# Alternatively, set them to the Cygwin temporary directory
# or to any other tmp directory of your choice
# export TMP=/tmp
# export TEMP=/tmp

# Or use TMPDIR instead
# export TMPDIR=/tmp

# Shell Options
# #############

# See man bash for more options...

# Don't wait for job termination notification
# set -o notify

# Don't use ^D to exit
# set -o ignoreeof

# Use case-insensitive filename globbing
# shopt -s nocaseglob

# Make bash append rather than overwrite the history on disk
# shopt -s histappend

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell


# Completion options
# ##################

# These completion tuning parameters change the default behavior of bash_completion:

# Define to access remotely checked-out files over passwordless ssh for CVS
# COMP_CVS_REMOTE=1

# Define to avoid stripping description in --option=description of './configure --help'
# COMP_CONFIGURE_HINTS=1

# Define to avoid flattening internal contents of tar files
# COMP_TAR_INTERNAL_PATHS=1

# If this shell is interactive, turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
# case $- in
#   *i*) [[ -f /etc/bash_completion ]] && . /etc/bash_completion ;;
# esac


# History Options
# ###############

# Don't put duplicate lines in the history.
# export HISTCONTROL="ignoredups"

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well

# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"


# Aliases
# #######

# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.

# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# Default to human readable figures
# alias df='df -h'
# alias du='du -h'

# Misc :)
# alias less='less -r'                          # raw control characters
# alias whence='type -a'                        # where, of a sort
alias grep='grep --color'                     # show differences in colour
PATH='~/bin/':$PATH
TTCN3_LICENSE_FILE=C:\cygwin\home\ehuufei\ttcn3-1.8.pl6\license\license.dat

# Some shortcuts for different directory listings
alias ls='ls -hF --color=tty'                 # classify files in colour
# alias dir='ls --color=auto --format=vertical'
# alias vdir='ls --color=auto --format=long'
alias ll='ls -l'                              # long list
# alias la='ls -A'                              # all but . and ..
# alias l='ls -CF'                              #
alias rbin='cd ~/script/ruby/'
alias cbin='cd ~/c'
alias jbin='cd ~/java'
alias rabin='cd /cygdrive/c/InstantRails-2.0-win/'
alias sshg='ssh -T git@github.com'

# Functions
# #########

# Some example functions
# function settitle() { echo -ne "\e]2;$@\a\e]1;$@\a"; }

export TTCN3_LICENSE_FILE

#start gdb
export CYGWIN="$CYGWIN error_start=gdb -nw %1 %2"
# generate core dump
#export CYGWIN="$CYGWIN error_start=dumper.exe -d %1 %2"

# Shared Memory
export CYGWIN="$CYGWIN sever X"

# Display remote, so we can invoke graphic app in shell
export DISPLAY=:0.0

alias vi='gvim'

# Support Chinese Chars
#export LC_CTYPE=zh_CN.gbk
#export CHARSET=GBK
alias ls='/bin/ls --color --show-control-chars'

#Go Env
export GOROOT=/cygdrive/c/Go/
export GOPATH=/cygdrive/c/Go/
PATH=$GOROOT/bin:$PATH

# For QT
#QTDIR=/usr/lib/qt4
#export PATH=$PATH':/usr/lib/qt4/bin'

# For dmalloc
function dmalloc { eval `command dmalloc -b $*`; }

# For quick cd
# Quick CD(c) to :
#   q - app
#   z - platform
export ANW_GITREPO_ROOT=/cygdrive/c/git/
export ANW_APP_Q=$ANW_GITREPO_ROOT/app/app
export ANW_APP_Z=$ANW_GITREPO_ROOT/app/platform
export ANW_APP_U=$ANW_GITREPO_ROOT/ui
export ANW_APP_C=$ANW_GITREPO_ROOT/occ
export DESKTOP=/cygdrive/c/Users/I311384.GLOBAL/Desktop

alias ca="cd $DESKTOP"
alias cc="cd $ANW_APP_C"
alias cq="cd $ANW_APP_Q"
alias cz="cd $ANW_APP_Z"
alias cu="cd $ANW_APP_U"

# Common dir
alias cqgb="cd $ANW_APP_Q/app-ns/src/main/resources/globalization"
alias cqns="cd $ANW_APP_Q/app-ns/src/main/java/com/sap/sbo/app/ns"
alias cqmt="cd $ANW_APP_Q/metadata-repository/src/main/resources/META-INF/"
alias czgb="cd $ANW_APP_Z/service-layer/src/main/resources/globalization"
alias cujs="cd $ANW_APP_U/sfa-anw/src/main/webapp/js"
alias ccjs="cd $ANW_APP_C/server/sfa-anw/src/main/webapp/js"
alias dsrc='cd /cygdrive/c/B1_Dev/Design/BUSMB_B1/SBO/9.01_DEV/Source'
alias nsrc='cd /cygdrive/c/B1_Dev/Design/BUSMB_B1/SBO_TEMP_PRJ/INNOVATION_WORK/NewHireTrainingForB1/Source/Client'

# Nodejs
source /cygdrive/c/git/nvm/nvm.sh
export NVM_NODEJS_ORG_MIRROR=http://dist.u.qiniudn.com

# Git (sources is oncely loaded in bash_profile)
export GIT_PS1_SHOWCOLORHINTS=true
#export PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$'
#export PS1='\[\e]0;\w\a\]\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n$(__git_ps1 " (%s)")\$ '
export PROMPT_COMMAND='__git_ps1 "\[\e]0;\w\a\]\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n" "\\\$"'


