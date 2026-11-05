# Cat greeting: interactive terminals only, so scripts and pipes stay clean.
# Set MEOW_QUIET=1 to turn it off. MEOW_HOUR=3 previews a given hour.
if [[ -o interactive && -t 1 && -z "$MEOW_QUIET" ]]; then
  () {
    [[ "$COLORTERM" == (truecolor|24bit) ]] || zmodload zsh/nearcolor 2>/dev/null

    local hour=${MEOW_HOUR:-${(%):-"%D{%H}"}}
    hour=$(( 10#$hour ))

    local art hello
    local -a phrases
    if (( hour < 6 )); then
      IFS= read -r -d '' art <<'CAT'
      |\      _,,,---,,_
ZZZzz /,`.-'`'    -.  ;-;;,_
     |,4-  ) )-,_. ,\ (  `'-'
    '---''(_/--'  `-'\_)
CAT
      hello="тссс, кот спит"
      phrases=("завтра докодишь" "ночной коммит, смелый ход" "спать тоже полезно" "не буди, он устал")
    else
      IFS= read -r -d '' art <<'CAT'
   |\__/,|   (`\
   |_ _  |.--.) )
   ( T   )     /
  (((^_(((/(((_/
CAT
      if (( hour < 12 )); then hello="доброе утро"
      elif (( hour < 18 )); then hello="добрый день"
      else hello="добрый вечер"
      fi
      phrases=("погнали кодить" "покорми кота" "мяу?" "сегодня без багов" "коммить почаще"
               "мур-мур" "тесты сами себя не напишут" "кот верит в тебя" "не забудь попить воды")
    fi

    local -a rows=("${(@f)art}")
    local -a colors=("#f5c2e7" "#cba6f7" "#b4befe" "#89b4fa")
    local -a texts=(
      ""
      "%B%F{#f5c2e7}${hello}%f%b"
      "%F{#cba6f7}${phrases[RANDOM % $#phrases + 1]}%f"
      "%F{#6c7086}%D{%A, %f %B}%f"
    )

    local width=0 i
    for i in {1..4}; do (( $#rows[i] > width )) && width=$#rows[i]; done

    print
    for i in {1..4}; do
      # The art goes through print -r: -P would expand its backticks and slashes.
      print -nP "%F{$colors[i]}"
      print -rn -- "${(r:width+3:: :)rows[i]}"
      print -nP "%f"
      print -P -- "$texts[i]"
    done
  }
fi
