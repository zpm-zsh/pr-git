#!/usr/bin/env zsh

: ${GIT_STATUS_PREFIX:=' '}
: ${GIT_STATUS_SUFIX:=''}

: ${GIT_STATUS_SYMBOL:=''}
: ${GIT_STATUS_STAGED:='→'}
: ${GIT_STATUS_CONFLICTS:='≠'}
: ${GIT_STATUS_CHANGED:='±'}
: ${GIT_STATUS_BEHIND:='↓'}
: ${GIT_STATUS_AHEAD:='↑'}
: ${GIT_STATUS_UNTRACKED:='+'}

typeset -g pr_git_old
typeset -g pr_git

function _git_info() {
  if (( ! $+commands[git-status] )); then
    echo Please, install git-status from https://gitlab.com/cosurgi/zsh-git-cal-status-cpp
    return
  fi

  command git-status --whoami $USER --pwd-dir . --refresh-sec 3 2> /dev/null | read -A __CURRENT_GIT_STATUS

  GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
  GIT_AHEAD=$__CURRENT_GIT_STATUS[2]
  GIT_BEHIND=$__CURRENT_GIT_STATUS[3]
  GIT_STAGED=$__CURRENT_GIT_STATUS[4]
  GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
  GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
  GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
  GIT_SECONDS_OR_ERROR=$__CURRENT_GIT_STATUS[8]


  if [[ $(( $GIT_UNTRACKED + $GIT_CHANGED + $GIT_CONFLICTS + $GIT_STAGED )) != '0' ]]; then
    GIT_STATUS="%{$c[red]$c_dim%}$GIT_STATUS_SYMBOL%{$c_reset%}"
  else
    GIT_STATUS="%{$c[green]$c_dim%}$GIT_STATUS_SYMBOL%{$c_reset%}"
  fi

  GIT_BRANCH=" %{$c[yellow]$c_bold%}${GIT_BRANCH}%{$c_reset%}"

  if [ "${GIT_AHEAD}" -eq '0' ]; then
    GIT_AHEAD=''
  else
    GIT_AHEAD=" %{$c[blue]$c_dim$c_bold%}${GIT_STATUS_AHEAD}%{$c_reset$c[blue]$c_bold%}${GIT_AHEAD}%{$c_reset%}"
  fi

  if [ "${GIT_BEHIND}" -eq '0' ]; then
    GIT_BEHIND=''
  else
    GIT_BEHIND=" %{$c[blue]$c_dim$c_bold%}${GIT_STATUS_BEHIND}%{$c_reset$c[blue]$c_bold%}${GIT_BEHIND}%{$c_reset%}"
  fi

  if [ "${GIT_STAGED}" -eq '0' ]; then
    GIT_STAGED=''
  else
    GIT_STAGED=" %{$c[cyan]$c_dim$c_bold%}${GIT_STATUS_STAGED}%{$c_reset$c[cyan]$c_bold%}${GIT_STAGED}%{$c_reset%}"
  fi

  if [ "${GIT_CONFLICTS}" -eq '0' ]; then
    GIT_CONFLICTS=''
  else
    GIT_CONFLICTS=" %{$c[red]$c_dim$c_bold%}${GIT_STATUS_CONFLICTS}%{$c_reset$c[red]$c_bold%}${GIT_STAGED}%{$c_reset%}"
  fi

  if [ "${GIT_CHANGED}"  -eq '0' ]; then
    GIT_CHANGED=''
  else
    GIT_CHANGED=" %{$c[magenta]$c_dim$c_bold%}${GIT_STATUS_CHANGED}%{$c_reset$c[magenta]$c_bold%}${GIT_CHANGED}%{$c_reset%}"
  fi

  if [ "${GIT_UNTRACKED}" -eq '0' ]; then
    GIT_UNTRACKED=''
  else
    GIT_UNTRACKED=" %{$c[blue]$c_dim$c_bold%}${GIT_STATUS_UNTRACKED}%{$c_reset$c[blue]$c_bold%}${GIT_UNTRACKED}%{$c_reset%}"
  fi


  echo "${GIT_STATUS}${GIT_BRANCH}${GIT_CHANGED}${GIT_UNTRACKED}${GIT_CONFLICTS}${GIT_STAGED}${GIT_AHEAD}${GIT_BEHIND}"
}

function _git_prompt() {
  if is-recursive-exist .git; then
    pr_git_old="$pr_git"

    pr_git="$GIT_STATUS_PREFIX$(_git_info 2>/dev/null)$GIT_STATUS_SUFIX"

    if [[ "$pr_git_old" != "$pr_git" ]]; then
      zle && zle reset-prompt
    fi
  else
    pr_git=""
  fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _git_prompt
_git_prompt
