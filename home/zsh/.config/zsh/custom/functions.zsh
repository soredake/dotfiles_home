# shellcheck disable=2034,2148

# play all in mpv
mpa() { if [[ -d "${PWD}/VIDEO_TS" ]]; then
    mpv "${PWD}"
  else
    files=( $(ls -b ${PWD}/*.{mp4,mkv,webm,avi,wmv} 2>/dev/null) )
    mpv "${PWD}"/"${1:-${files[@]}}" "$2"
  fi
}

# Create a new directory and enter it.
# In oh-my-zsh take function is identical to this
mkd() {
  mkdir -p "$@" && cd "$_" || exit 1;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Convert currencies; cconv {amount} {from} {to}
#cconv() {
#  curl --socks5-hostname 127.0.0.1:9250 -s "https://finance.google.com/finance/converter?a=$1&from=$2&to=$3&hl=es" | sed '/res/!d;s/<[^>]*>//g';
#}

# Convert currencies; cconv {amount} {from} {to}
# https://stackoverflow.com/questions/13242469/how-to-use-sed-grep-to-extract-text-between-two-words
cconv() {
  #| grep '&#8372;</strong>'
  result="$(curl -s "https://exchangerate.guru/$2/$3/$1/" | grep --color=never -o -P '(?<=<input data-role="secondary-input" type="text" class="form-control" value=").*(?=" required>)')"
  echo "$1 $2 = $result $3"
}

# Upload to transfer.sh
transfer() { if [ $# -eq 0 ]; then echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
             tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> "$tmpfile"; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> "$tmpfile" ; fi; cat "$tmpfile"; rm -f "$tmpfile"; }

# Background with log
# https://github.com/mpv-player/mpv/issues/1377#issuecomment-90370504
bkg() {
  logfile=$(mktemp -t "$(basename $1)"-"$(date +%d.%m.%G-%T)"-XXX.log)
  nohup "$@" &>"$logfile" &
}

wttr() {
  # moon or city name
  curl -A curl -k https://wttr.in/"${1}"?lang=ru
}

# Calculate actual size of {HD,SS}D; actualsize {size} {gb}[optional, use gigabytes instead of terabytes]
# http://www.sevenforums.com/hardware-devices/23890-hdds-advertized-size-vs-actual-size.html
actualsize() {
  if [[ "$2" == gb ]]; then a="0.9313226"; else a="0.9094947"; fi
  echo 'Actual size is:' "$(bc -l <<< "$1 * $a")"
}

# Calculate ppi; ppicalc {widght} {height} {display size[eg 27]}
# http://isthisretina.com/
# https://en.wikipedia.org/wiki/Pixel_density#Calculation_of_monitor_PPI
ppicalc() {
  echo 'DPI/PPI is:' "$(bc <<< "sqrt($1^2+$2^2)/$3")"
}

# 5gb max
# stores for 24 hours
cockfile() {
   if [[ "$1" =~ ^https?://.*$ ]]; then local prefix="curl --fail -L --progress-bar ${1} || exit 1"; else local suffix="${1}"; fi
   # eval or sh -c
   eval "${prefix:-true}" | curl --fail -L --progress-bar -F name="${2:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | grep -i '[a-zA-Z0-9]').${1##*.}}" -F file=@"${suffix:--}" https://cockfile.com/api.php?d=upload-tool
}

# Validate tar archives
tarval() {
  tar -tJf "$@" >/dev/null
}

# Automatically cd to the directory you were in when quitting ranger if you haven't already:
ranger() {
    tempfile="$(mktemp -t ranger-tmp.XXXXXX)"
    /usr/bin/ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n "$(pwd)")" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

px() {
  # https://stackoverflow.com/questions/23258413/expand-aliases-in-non-interactive-shells/23259088#23259088
  setopt aliases
  _command="$(which "$1" | sed 's/.*: aliased to //g' )"
  # http://wiki.bash-hackers.org/syntax/pe#substring_expansion
  eval proxychains -q "$_command" ${@:2}
}

j() {
case "$1" in
  g) cd "$HOME/git" ;;
  s) cd "$HOME/sync" ;;
  t) cd /media/disk0/torrents ;;
  d) cd "$HOME/sync/main/Documents" ;;
  b) cd "$HOME/sync/system-data" ;;
  m) cd "$HOME/media" ;;
  *) echo "No folder defined for this alias." ;;
esac
}

random() {
  shuf -i "${1}-${2}" -n "${3:-1}"
}

linuxsteamgames() {
  _url="https://store.steampowered.com/search/?category1=998&os="
  for os in win linux mac; do
    local ${os}games="$(curl --http2 -s "${_url}${os}" | grep -o "showing 1 - 25 of [0-9]*" | sed "s/showing 1 - 25 of //")"
  done
  echo "Windows steam games: ${wingames}"
  echo "Mac steam games: ${macgames}"
  echo "Linux steam games: ${linuxgames}"
  # https://stackoverflow.com/a/41265735
  echo "Percentage of linux games compared to windows:" $(echo "scale = 2; ($linuxgames / $wingames)" | bc -l | awk -F '.' '{print $2}')%
  echo "Percentage of linux games compared to macOS:" $(echo "scale = 2; ($linuxgames / $macgames)" | bc -l | awk -F '.' '{print $2}')%
}

# https://stackoverflow.com/a/10060342
# https://stackoverflow.com/a/10060342
# 512mb max
# stores for 30+ days
0x0() {
  if [[ "$1" =~ ^http?[s]://.*$ ]]; then local prefix="url="; else local prefix="file=@"; fi
  curl -F"${prefix}${1}" https://0x0.st
}

# https://github.com/chrippa/livestreamer/issues/550#issuecomment-222061982
streamnodown() {
  streamlink --loglevel debug --player-external-http --player-no-close --player-external-http-port "5555" --retry-streams 1 --retry-open 100 --stream-segment-attempts 20 --stream-timeout 180 --ringbuffer-size 64M --rtmp-timeout 240 "$1" "${2}"
}

# rclone alias
# https://stackoverflow.com/questions/45601589/zsh-not-recognizing-alias-from-within-function
# https://stackoverflow.com/questions/25532050/newly-defined-alias-not-working-inside-a-function-zsh
# TODO remove when https://github.com/rclone/rclone/issues/2697 is done
alias -g upload="rclone sync --transfers 8 --delete-excluded --fast-list -P --delete-before"

# backup
backup() {
  # local
  cps -L "$HOME/sync" /media/disk0/backup
  cps "$HOME/sync/main/Documents/keepass/NewDatabase.kdbx" "/media/disk2/Users/User/Desktop/"
  cps "$HOME/sync/main/Documents/keepass/NewDatabase.kdbx" "$HOME/sync/share/"
  # fix errors like `some-file.jpg: Duplicate object found in destination - ignoring` https://github.com/rclone/rclone/issues/2131#issuecomment-372459713
  rclone dedupe --dedupe-mode newest mega_nz:/
  rclone dedupe --dedupe-mode newest 50gbmega:/
  # dropbox
  # 2gb
  # TODO: https://plati.ru/search/DROPBOX
  echo -e "\e[1;31m Uploading to Dropbox \033[0m"
  upload "$HOME/sync/main/Documents" dropbox:/Documents
  upload "$HOME/sync/main/Screens" dropbox:/Screens
  upload "$HOME/sync/system-data" dropbox:/system-data
  # opendrive
  # 5gb
  echo -e "\e[1;31m Uploading to OpenDrive \033[0m"
  upload "$HOME/sync/main/Documents" opendrive:/Documents
  upload "$HOME/sync/main/Documents/keepass/NewDatabase.kdbx" opendrive:/
  upload "$HOME/sync/main/Screens" opendrive:/Screens
  # google drive
  # 15gb
  echo -e "\e[1;31m Google Drive \033[0m"
  upload "$HOME/sync/main/Documents" google_drive:/Documents
  upload "$HOME/sync/main/Documents/keepass/NewDatabase.kdbx" google_drive:/
  upload "$HOME/sync/main/me" google_drive:/me
  upload "$HOME/sync/main/Media" google_drive:/Media
  upload "$HOME/sync/main/Screens" google_drive:/Screens
  upload "$HOME/sync/system-data" google_drive:/system-data
  # mega.nz
  # 50gb
  echo -e "\e[1;31m Uploading to MEGA 50gb \033[0m"
  upload "$HOME/sync/main/Documents" 50gbmega:/Documents
  upload "$HOME/sync/main/Documents/keepass/NewDatabase.kdbx" 50gbmega:/
  upload "$HOME/sync/main/me" 50gbmega:/me
  upload "$HOME/sync/main/Media" 50gbmega:/Media
  upload "$HOME/sync/main/Screens" 50gbmega:/Screens
  upload "$HOME/sync/system-data" 50gbmega:/system-data
  # mega.nz
  # 15gb
  echo -e "\e[1;31m Uploading to MEGA 15gb \033[0m"
  upload "$HOME/sync/main/Documents" mega_nz:/Documents
  upload "$HOME/sync/main/Documents/keepass/NewDatabase.kdbx" mega_nz:/
  upload "$HOME/sync/main/me" mega_nz:/me
  upload "$HOME/sync/main/Media" mega_nz:/Media
  upload "$HOME/sync/main/Screens" mega_nz:/Screens
  upload "$HOME/sync/system-data" mega_nz:/system-data
  # yandex.disk
  # 10gb
  echo -e "\e[1;31m Uploading to Yandex.Disk \033[0m"
  upload "$HOME/sync/main/Documents" yandex:/Documents
  upload "$HOME/sync/main/Documents/keepass/NewDatabase.kdbx" yandex:/
  upload "$HOME/sync/main/me" yandex:/me
  upload "$HOME/sync/main/Screens" yandex:/Screens
  upload "$HOME/sync/system-data" yandex:/system-data
}

update-grub() {
  # mount esp
  #[[ ! $(grep /boot/efi /proc/mounts) ]] && sudo mount /boot/efi
  # copy microcode
  #sudo cp /boot/amd-ucode.img /boot/efi
  # generate config
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  #sudo umount /boot/efi
}

# workaround for https://github.com/citra-emu/citra/issues/3862
yuzu-binary() {
  [[ ! -f "libsndio.so.6.1" ]] && ln -sfv /usr/lib/libsndio.so.7.0 libsndio.so.6.1
  #KDE_DEBUG=1
  LD_LIBRARY_PATH=$PWD strangle 60 gamemoderun ./yuzu
}

# https://shapeshed.com/zsh-corrupt-history-file/
# https://dev.to/rishibaldawa/fixing-corrupt-zsh-history-4nf4
fix_zsh_history() {
  cd "$XDG_DATA_HOME/zsh"
  mv history history_bad
  strings history_bad > history
  fc -R history
  rm -f history_bad
}

# https://wiki.archlinux.org/index.php/Color_output_in_console#Using_less
man() {
   LESS_TERMCAP_md=$'\e[01;31m' \
   LESS_TERMCAP_me=$'\e[0m' \
   LESS_TERMCAP_se=$'\e[0m' \
   LESS_TERMCAP_so=$'\e[01;44;33m' \
   LESS_TERMCAP_ue=$'\e[0m' \
   LESS_TERMCAP_us=$'\e[01;32m' \
   command man "$@"
}

# ukr nalogi
# https://3g2upl4pq6kufc4m.onion/?q=(400+-+165)+*+35%25&ia=calculator
ukr_nalogi() { echo Tax is: $(bc -l <<< "($1 - 165) * 0.35") USD; }

checkvk() {
  Estatus=$(proxychains -q curl --http2 -sS "https://api.vk.com/method/users.get?user_id=$1&fields=last_seen,online&v=5.8" || exit)
  case "$(jq '.response[0].last_seen.platform' <<< "$Estatus")" in
    1) platform="мобильная версия" ;;
    4) platform="приложение для Android" ;;
    7) platform="полная версия сайта" ;;
    8) platform="VK Mobile" ;;
    *) platform="Unknown"
  esac
  echo "Онлайн ли сейчас: $(jq '.response[0].online' <<< "$Estatus")"
  echo "Последний раз в сети: $(date -d @$(jq '.response[0].last_seen.time' <<< "$Estatus"))"
  echo "Платформа: $platform"
}

speedfox() {
  array=( $(pgrep -f plugin-container) )
  array+=( $(pgrep -f ^firefox) )
  for pid in "${array[@]}"; do
    sudo renice -n -20 -p "$pid"
    sudo ionice -c realtime -p "$pid" && echo "Changed io priority to realtime for pid $pid"
  done
}
