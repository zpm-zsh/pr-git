# Standarized ZSH polyfills, following:
# https://github.com/zdharma/Zsh-100-Commits-Club/blob/master/Zsh-Plugin-Standard.adoc
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if [[ $PMSPEC != *f* ]] {
  fpath+=( "${0:h}/functions" )
}

: ${PR_GIT_STATUS_STAGED:='→'}
: ${PR_GIT_STATUS_CONFLICTS:='≠'}
: ${PR_GIT_STATUS_CHANGED:='±'}
: ${PR_GIT_STATUS_BEHIND:='↓'}
: ${PR_GIT_STATUS_AHEAD:='↑'}
: ${PR_GIT_STATUS_UNTRACKED:='+'}

autoload -Uz git-prompt

typeset -g pr_git=''

function _git_prompt() {
  if is-recursive-exist .git; then
    pr_git=" $(git-prompt 2>/dev/null)"
  else
    pr_git=""
  fi
}

if (( $+commands[git-status] )); then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _git_prompt
  _git_prompt
fi
