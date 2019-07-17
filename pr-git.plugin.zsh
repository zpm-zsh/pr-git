#!/usr/bin/env zsh

GIT_STATUS_PREFIX=${GIT_STATUS_PREFIX:-' '}
GIT_STATUS_SUFIX=${GIT_STATUS_SUFIX:-''}

GIT_STATUS_SYMBOL=${GIT_STATUS_SYMBOL:-''}
GIT_STATUS_MODIFIEED="${GIT_STATUS_MODIFIEED="±"}"
GIT_STATUS_ADDED="${GIT_STATUS_ADDED="+"}"
GIT_STATUS_DELETED="${GIT_STATUS_DELETED="-"}"
GIT_STATUS_STAGED="${GIT_STATUS_STAGED="→"}"
GIT_STATUS_AHEAD="${GIT_STATUS_AHEAD="⇡"}"
GIT_STATUS_BEHIND="${GIT_STATUS_BEHIND="⇣"}"


DEPENDENCES_ZSH+=( zpm-zsh/helpers zpm-zsh/background-functions zpm-zsh/colors )

if command -v zpm >/dev/null; then
  zpm zpm-zsh/helpers zpm-zsh/background-functions zpm-zsh/colors
fi

_git-info() {
  INDEX=$(command git status --porcelain -b 2> /dev/null)
  INDEX_STAGED=$(command git diff --staged --name-status 2> /dev/null)
  
  git_changes=$(echo "$INDEX" | wc -l 2>/dev/null)
  if [[ $CLICOLOR = 1 ]]; then
    if [[ "$git_changes" > "1" ]]; then
      git_status="%{$c[red]$c_dim%}$GIT_STATUS_SYMBOL%{$c_reset%}"
    else
      git_status="%{$c[green]$c_dim%}$GIT_STATUS_SYMBOL%{$c_reset%}"
    fi
  else
    if [[ "$git_changes" > "1" ]]; then
      git_status="-$GIT_STATUS_SYMBOL"
    else
      git_status="+$GIT_STATUS_SYMBOL"
    fi
  fi
  
  ref=$(command git symbolic-ref HEAD 2>/dev/null)
  if [[ $CLICOLOR = 1 ]]; then
    git_branch=" %{$c[yellow]$c_bold%}${ref#refs/heads/}%{$c_reset%}"
  else
    git_branch=" ${ref#refs/heads/}"
  fi
  
  git_modified_number=$(echo "$INDEX" | command grep -E '^[ MARC]M ' | wc -l)
  if [[ "$git_modified_number" == 0 ]]; then
    git_modified=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_modified=" %{$c[magenta]$c_dim$c_bold%}${GIT_STATUS_MODIFIEED}%{$c_reset$c[magenta]$c_bold%}${git_modified_number}%{$c_reset%}"
    else
      git_modified=" ${GIT_STATUS_MODIFIEED}${git_modified_number}"
    fi
  fi
  
  git_added_number=$(echo "$INDEX" | command grep -E '^\?\? ' | wc -l)
  if [[ "$git_added_number" == 0 ]]; then
    git_added=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_added=" %{$c[blue]$c_dim$c_bold%}${GIT_STATUS_ADDED}%{$c_reset$c[blue]$c_bold%}${git_added_number}%{$c_reset%}"
    else
      git_added=" ${GIT_STATUS_ADDED}${git_added_number}"
    fi
  fi
  
  git_deleted_number=$(echo "$INDEX" | command grep -E '^[ MARC]D ' | wc -l)
  if [[ "$git_deleted_number" == 0 ]]; then
    git_deleted=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_deleted=" %{$c[red]$c_dim$c_bold%}${GIT_STATUS_DELETED}%{$c_reset$c[red]$c_bold%}${git_deleted_number}%{$c_reset%}"
    else
      git_deleted=" ${GIT_STATUS_DELETED}${git_deleted_number}"
    fi
  fi
  
  git_staged_number=$(echo "$INDEX_STAGED" | command grep -E '^[ MARC]' | wc -l)
  if [[ "$git_staged_number" == 0 ]]; then
    git_staged=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_staged=" %{$c[cyan]$c_dim$c_bold%}${GIT_STATUS_STAGED}%{$c_reset$c[cyan]$c_bold%}${git_staged_number}%{$c_reset%}"
    else
      git_staged=" ${GIT_STATUS_STAGED}${git_staged_number}"
    fi
  fi
  
  git_ahead_number=$(echo "$INDEX" | sed -n 's/.*ahead \([\0-9]\+\).*/\1/p' 2>/dev/null)
  if [[ -z "$git_ahead_number" ]]; then
    git_ahead=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_ahead=" %{$c[blue]$c_dim$c_bold%}${GIT_STATUS_AHEAD}%{$c_reset$c[blue]$c_bold%}${git_ahead_number}%{$c_reset%}"
    else
      git_ahead=" ${GIT_STATUS_AHEAD}${git_ahead_number}"
    fi
  fi
  
  git_behind_number=$(echo "$INDEX" | sed -n 's/.*behind \([\0-9]\+\).*/\1/p' 2>/dev/null)
  if [[ -z "$git_behind_number" ]]; then
    git_behind=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_behind=" %{$c[cyan]$c_dim$c_bold%}${GIT_STATUS_BEHIND}%{$c_reset$c[cyan]$c_bold%}${git_behind_number}%{$c_reset%}"
    else
      git_behind=" ${GIT_STATUS_BEHIND}${git_behind_number}"
    fi
  fi
  
  echo "$git_status$git_branch$git_modified$git_added$git_deleted$git_staged$git_ahead$git_behind"
}

_git_prompt() {
  if [ "$(command git config --get --bool oh-my-zsh.hide-status 2>/dev/null)" != "true" ] \
  && is-recursive-exist .git > /dev/null 2>&1; then
    pr_git_old="$pr_git"
    pr_git="$GIT_STATUS_PREFIX$(_git-info 2>/dev/null)$GIT_STATUS_SUFIX"
    if [[ ! "$pr_git_old" == "$pr_git" ]]; then
      zle && zle reset-prompt
    fi
  else
    pr_git=""
  fi
}

_git_prompt
precmd_functions+=(_git_prompt)
background_functions+=(_git_prompt)
