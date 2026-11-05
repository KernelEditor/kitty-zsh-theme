# meow: Catppuccin Mocha pill prompt with a cat that reacts to what is going on
[[ "$COLORTERM" == (truecolor|24bit) ]] || zmodload zsh/nearcolor 2>/dev/null
zmodload zsh/datetime
autoload -Uz add-zsh-hook
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Terminal.app has no Nerd Font set up, so pills there stay square and icon-free.
if [[ "$TERM_PROGRAM" == Apple_Terminal ]]; then
  _MEOW_L="" _MEOW_R="" _MEOW_BRANCH=""
else
  _MEOW_L=$'' _MEOW_R=$'' _MEOW_BRANCH=$' '
fi

_meow_pill() {
  print -rn -- "%F{$1}${_MEOW_L}%f%K{$1}%F{#1e1e2e}$2%f%k%F{$1}${_MEOW_R}%f"
}

_meow_git() {
  local out; out=$(git status --porcelain=v1 -b 2>/dev/null) || return 1
  local -a lines=("${(@f)out}")
  local head=${lines[1]#\#\# } branch ahead behind
  branch=${head%%...*}
  branch=${branch%% \[*}
  branch=${branch#No commits yet on }
  [[ "$branch" == "HEAD (no branch)" ]] && branch=$(git rev-parse --short HEAD 2>/dev/null)
  [[ "$head" =~ 'ahead ([0-9]+)' ]] && ahead=$match[1]
  [[ "$head" =~ 'behind ([0-9]+)' ]] && behind=$match[1]
  local changed=$(( $#lines - 1 )) info="${_MEOW_BRANCH}${branch//\%/%%}"
  if (( changed )); then info+=" ●$changed"; _MEOW_DIRTY=1; else info+=" ✓"; fi
  [[ -n "$ahead" ]] && info+=" ↑$ahead"
  [[ -n "$behind" ]] && info+=" ↓$behind"
  _MEOW_GIT=$info
}

_meow_preexec() { _MEOW_START=$EPOCHSECONDS }

_meow_precmd() {
  local code=$? hour=${MEOW_HOUR:-${(%):-"%D{%H}"}} pills
  _MEOW_DIRTY=0

  _MEOW_TOOK=""
  if [[ -n "$_MEOW_START" ]]; then
    local s=$(( EPOCHSECONDS - _MEOW_START ))
    local took
    if (( s >= 3600 )); then took="$(( s / 3600 ))h $(( s % 3600 / 60 ))m"
    elif (( s >= 60 )); then took="$(( s / 60 ))m $(( s % 60 ))s"
    elif (( s >= 3 )); then took="${s}s"
    fi
    [[ -n "$took" ]] && _MEOW_TOOK="%F{#f9e2af}⏱ $took %f"
    unset _MEOW_START
  fi

  pills=$(_meow_pill "#cba6f7" ' %(4~|…/%3~|%~) ')
  _MEOW_GIT=""
  _meow_git
  [[ -n "$_MEOW_GIT" ]] && pills+=" $(_meow_pill '#f5c2e7' " $_MEOW_GIT ")"
  [[ -n "$VIRTUAL_ENV" ]] && pills+=" $(_meow_pill '#fab387' " 🐍 ${VIRTUAL_ENV:t} ")"

  local face="😺"
  if (( code )); then face="🙀"
  elif (( 10#$hour < 6 )); then face="😴"
  elif (( _MEOW_DIRTY )); then face="😼"
  fi
  _MEOW_LINE="$face $pills"
}

add-zsh-hook preexec _meow_preexec
(( ${precmd_functions[(I)_meow_precmd]} )) || precmd_functions=(_meow_precmd $precmd_functions)

PROMPT=$'\n''${_MEOW_LINE}'$'\n''🐾 %(?.%F{#a6e3a1}.%F{#f38ba8})❯%f '
RPROMPT='%(?..%F{#f38ba8}✘ %? %f)${_MEOW_TOOK}%F{#6c7086}%*%f'
