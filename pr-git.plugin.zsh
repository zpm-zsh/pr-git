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

typeset -g pr_git

function _git_info() {
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
    GIT_STATUS="%{${c[red]}${c[dim]}%}$GIT_STATUS_SYMBOL%{${c[reset]}%}"
  else
    GIT_STATUS="%{${c[green]}${c[dim]}%}$GIT_STATUS_SYMBOL%{${c[reset]}%}"
  fi

  GIT_BRANCH=" %{$c[yellow]${c[bold]}%}${GIT_BRANCH}%{${c[reset]}%}"

  if [ "${GIT_AHEAD}" -eq '0' ]; then
    GIT_AHEAD=''
  else
    GIT_AHEAD=" %{${c[blue]}${c[dim]}${c[bold]}%}${GIT_STATUS_AHEAD}%{${c[reset]}${c[blue]}${c[bold]}%}${GIT_AHEAD}%{${c[reset]}%}"
  fi

  if [ "${GIT_BEHIND}" -eq '0' ]; then
    GIT_BEHIND=''
  else
    GIT_BEHIND=" %{${c[blue]}${c[dim]}${c[bold]}%}${GIT_STATUS_BEHIND}%{${c[reset]}${c[blue]}${c[bold]}%}${GIT_BEHIND}%{${c[reset]}%}"
  fi

  if [ "${GIT_STAGED}" -eq '0' ]; then
    GIT_STAGED=''
  else
    GIT_STAGED=" %{${c[cyan]}${c[dim]}${c[bold]}%}${GIT_STATUS_STAGED}%{${c[reset]}${c[cyan]}${c[bold]}%}${GIT_STAGED}%{${c[reset]}%}"
  fi

  if [ "${GIT_CONFLICTS}" -eq '0' ]; then
    GIT_CONFLICTS=''
  else
    GIT_CONFLICTS=" %{${c[red]}${c[dim]}${c[bold]}%}${GIT_STATUS_CONFLICTS}%{${c[reset]}${c[red]}${c[bold]}%}${GIT_STAGED}%{${c[reset]}%}"
  fi

  if [ "${GIT_CHANGED}"  -eq '0' ]; then
    GIT_CHANGED=''
  else
    GIT_CHANGED=" %{${c[magenta]}${c[dim]}${c[bold]}%}${GIT_STATUS_CHANGED}%{${c[reset]}${c[magenta]}${c[bold]}%}${GIT_CHANGED}%{${c[reset]}%}"
  fi

  if [ "${GIT_UNTRACKED}" -eq '0' ]; then
    GIT_UNTRACKED=''
  else
    GIT_UNTRACKED=" %{${c[blue]}${c[dim]}${c[bold]}%}${GIT_STATUS_UNTRACKED}%{${c[reset]}${c[blue]}${c[bold]}%}${GIT_UNTRACKED}%{${c[reset]}%}"
  fi

  echo "${GIT_STATUS}${GIT_BRANCH}${GIT_CHANGED}${GIT_UNTRACKED}${GIT_CONFLICTS}${GIT_STAGED}${GIT_AHEAD}${GIT_BEHIND}"
}

function _git_prompt() {
  if is-recursive-exist .git; then
    pr_git="$GIT_STATUS_PREFIX$(_git_info 2>/dev/null)$GIT_STATUS_SUFIX"
  else
    pr_git=""
  fi
}

if (( ! $+commands[git-status] )); then
  echo Please, install git-status from https://gitlab.com/cosurgi/zsh-git-cal-status-cpp
else
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _git_prompt
  _git_prompt
fi
