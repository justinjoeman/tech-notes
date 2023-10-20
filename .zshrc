
# Edit prompt to show colours for name, path and git branch

parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

COLOR_DEF='%f'
COLOR_USR='%F{green}'
COLOR_DIR='%F{blue}'
COLOR_GIT='%F{39}'
setopt PROMPT_SUBST
export PROMPT='${COLOR_USR}%n@%M ${COLOR_DIR}%d ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}%% '


# Highlight shell scripts green, folders navy blue and symlinks light blue

export CLICOLOR=1
export LSCOLORS=ExgxCxDxcxegedabagacad

# Aliases
alias ll='ls -al'
alias tf='terraform'
