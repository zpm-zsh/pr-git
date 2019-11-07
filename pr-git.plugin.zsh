#!/usr/bin/env zsh

GIT_STATUS_PREFIX=${GIT_STATUS_PREFIX:-' '}
GIT_STATUS_SUFIX=${GIT_STATUS_SUFIX:-''}

GIT_STATUS_SYMBOL=${GIT_STATUS_SYMBOL:-''}
GIT_STATUS_MODIFIEED="${GIT_STATUS_MODIFIEED="±"}"
GIT_STATUS_ADDED="${GIT_STATUS_ADDED="+"}"
GIT_STATUS_DELETED="${GIT_STATUS_DELETED="-"}"
GIT_STATUS_STAGED="${GIT_STATUS_STAGED="→"}"
GIT_STATUS_AHEAD="${GIT_STATUS_AHEAD="↑"}"
GIT_STATUS_BEHIND="${GIT_STATUS_BEHIND="↓"}"


DEPENDENCES_ZSH+=( zpm-zsh/helpers zpm-zsh/background zpm-zsh/colors )

if command -v zpm >/dev/null; then
  zpm zpm-zsh/helpers zpm-zsh/background zpm-zsh/colors
fi

_git-info() {
  setopt extendedglob
  
  declare -a INDEX; INDEX=( ${(f)"$(command git status --porcelain -b 2> /dev/null)"} )
  local REF=$(command git symbolic-ref HEAD 2>/dev/null)
  
  if [[ "${#INDEX}" != "1" ]]; then
    git_status="%{$c[red]$c_dim%}$GIT_STATUS_SYMBOL%{$c_reset%}"
  else
    git_status="%{$c[green]$c_dim%}$GIT_STATUS_SYMBOL%{$c_reset%}"
  fi
  
  git_branch=" %{$c[yellow]$c_bold%}${REF#refs/heads/}%{$c_reset%}"
  
  declare -a git_modified_number; git_modified_number=( ${(M)INDEX:#[ MARC]M\ *} )
  if [[ "${#git_modified_number}" == 0 ]]; then
    git_modified=''
  else
    git_modified=" %{$c[magenta]$c_dim$c_bold%}${GIT_STATUS_MODIFIEED}%{$c_reset$c[magenta]$c_bold%}${#git_modified_number}%{$c_reset%}"
  fi
  
  declare -a git_added_number; git_added_number=( ${(M)INDEX:#\?\?\ *} )
  if [[ "${#git_added_number}" == 0 ]]; then
    git_added=''
  else
    git_added=" %{$c[blue]$c_dim$c_bold%}${GIT_STATUS_ADDED}%{$c_reset$c[blue]$c_bold%}${#git_added_number}%{$c_reset%}"
  fi
  
  declare -a git_deleted_number; git_deleted_number=( ${(M)INDEX:#[ MARC]D\ *} )
  if [[ "${#git_deleted_number}" == 0 ]]; then
    git_deleted=''
  else
    git_deleted=" %{$c[red]$c_dim$c_bold%}${GIT_STATUS_DELETED}%{$c_reset$c[red]$c_bold%}${#git_deleted_number}%{$c_reset%}"
  fi
  
  declare -a git_staged_number; git_staged_number=( ${(M)INDEX:#[MARC]*} )
  if [[ "${#git_staged_number}" == 0 ]]; then
    git_staged=''
  else
    git_staged=" %{$c[cyan]$c_dim$c_bold%}${GIT_STATUS_STAGED}%{$c_reset$c[cyan]$c_bold%}${#git_staged_number}%{$c_reset%}"
  fi
  
  local git_ahead_number="${${INDEX[@]##*ahead\ }%%[\,\]]*}"
  if [[ "$INDEX[@]" != *'ahead'* ]]; then
    git_ahead=''
  else
    git_ahead=" %{$c[blue]$c_dim$c_bold%}${GIT_STATUS_AHEAD}%{$c_reset$c[blue]$c_bold%}${git_ahead_number}%{$c_reset%}"
  fi
  
  local git_behind_number="${${INDEX[@]##*behind\ }%%[\,\]]*}"
  if [[ "$INDEX[@]" != *"behind"* ]]; then
    git_behind=''
  else
    git_behind=" %{$c[cyan]$c_dim$c_bold%}${GIT_STATUS_BEHIND}%{$c_reset$c[cyan]$c_bold%}${git_behind_number}%{$c_reset%}"
  fi
  
  echo "$git_status$git_branch$git_modified$git_added$git_deleted$git_staged$git_ahead$git_behind"
}

_git_prompt() {
  if is-recursive-exist .git; then
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
add-zsh-hook precmd _git_prompt
add-zsh-hook background _git_prompt
