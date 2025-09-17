#!/usr/bin/env bash

# 颜色配置
FG_COLOR="#bbbbbb"
BG_COLOR="#111111"
HLFG_COLOR="#111111"
HLBG_COLOR="#bbbbbb"
BORDER_COLOR="#222222"

if [[ $(pidof rofi) ]]; then
    pkill rofi
    exit 0
fi

# Rofi配置
ROFI_OPTIONS=(-theme ~/.config/rofi/powermenu.rasi)
# Zenity配置
ZENITY_TITLE="Power Menu"
ZENITY_TEXT="Action:"
ZENITY_OPTIONS=(--column= --hide-header)

#######################################################################
#                             配置部分                                #
#######################################################################

# 是否启用确认对话框
enable_confirmation=false

# 首选启动器
preferred_launcher="rofi"

# 锁屏命令 - 可根据您的环境自定义[4](@ref)
LOCK_CMD="swaylock -f -c 000000 --show-failed-attempts --fade-in 0.2 --grace 5 --grace-no-mouse --effect-vignette 0.5:0.5 --effect-blur 7x5 --ignore-empty-password --screenshots --clock"  # 替换为您的锁屏命令，如: "dm-tool lock", "light-locker-command -l", "xscreensaver-command -lock"

# 注销命令 - 通用方法[1,4](@ref)
if pgrep -x "niri" >/dev/null; then
  LOGOUT_CMD="niri msg action quit --skip-confirmation"
else
  LOGOUT_CMD="loginctl terminate-session $XDG_SESSION_ID"  # 或 "gnome-session-quit --logout"
fi

#######################################################################
#                             END CONFIG                              #
#######################################################################

usage="$(basename "$0") [-h] [-c] [-p name] -- 显示关机、重启、锁屏等菜单

选项:
    -h  显示帮助
    -c  启用操作确认
    -p  首选启动器 (rofi 或 zenity)

依赖:
  - systemd
  - rofi 或 zenity"

# 检查启动器是否有效
launcher_list=(rofi zenity)
function check_launcher() {
  if [[ ! "${launcher_list[@]}" =~ (^|[[:space:]])"$1"($|[[:space:]]) ]]; then
    echo "支持的启动器: ${launcher_list[*]}"
    exit 1
  else
    i=1
    launcher_list=($(for l in "$1" "${launcher_list[@]}"; do printf "%i %s\n" "$i" "$l"; let i+=1; done \
      | sort -uk2 | sort -nk1 | cut -d' ' -f2- | tr '\n' ' '))
  fi
}

# 解析参数
while getopts "hcp:" option; do
  case "${option}" in
    h) echo "${usage}"
       exit 0
       ;;
    c) enable_confirmation=true
       ;;
    p) preferred_launcher="${OPTARG}"
       check_launcher "${preferred_launcher}"
       ;;
    *) exit 1
       ;;
  esac
done

# 检查命令是否存在
function command_exists() {
  command -v "$1" &> /dev/null 2>&1
}

# 必需systemctl
if ! command_exists systemctl ; then
  exit 1
fi

# 菜单定义
typeset -A menu

# 菜单项与命令[1,4](@ref)
menu=(
  [   Shutdown]="systemctl poweroff"
  [   Reboot]="systemctl reboot"
  [   Suspend]="systemctl suspend"
  [   Hibernate]="systemctl hibernate"
  [   Lock]="$LOCK_CMD"
  [   Logout]="$LOGOUT_CMD"
  [   Cancel]=""
)

menu_nrows=${#menu[@]}

# 需要确认的操作
menu_confirm="Shutdown Reboot Hibernate Suspend Logout"

launcher_exe=""
launcher_options=""
rofi_colors=""

function prepare_launcher() {
  if [[ "$1" == "rofi" ]]; then
    rofi_colors=(-bc "${BORDER_COLOR}" -bg "${BG_COLOR}" -fg "${FG_COLOR}" \
        -hlfg "${HLFG_COLOR}" -hlbg "${HLBG_COLOR}")
    launcher_exe="rofi"
    launcher_options=(-dmenu -i -lines "${menu_nrows}" -p "电源菜单: " \
        "${rofi_colors}" "${ROFI_OPTIONS[@]}")
  elif [[ "$1" == "zenity" ]]; then
    launcher_exe="zenity"
    launcher_options=(--list --title="${ZENITY_TITLE}" --text="${ZENITY_TEXT}" \
        "${ZENITY_OPTIONS[@]}")
  fi
}

for l in "${launcher_list[@]}"; do
  if command_exists "${l}" ; then
    prepare_launcher "${l}"
    break
  fi
done

# 无可用启动器
if [[ -z "${launcher_exe}" ]]; then
  exit 1
fi

launcher=(${launcher_exe} "${launcher_options[@]}")
selection="$(printf '%s\n' "${!menu[@]}" | sort | "${launcher[@]}")"

function ask_confirmation() {
  if [ "${launcher_exe}" == "rofi" ]; then
    confirmed=$(echo -e "Yes\nNo" | rofi -dmenu -i -lines 2 -p "${selection}?" \
      "${rofi_colors}" "${ROFI_OPTIONS[@]}")
    [ "${confirmed}" == "Yes" ] && confirmed=0
  elif [ "${launcher_exe}" == "zenity" ]; then
    zenity --question --text "确定要${selection}吗?"
    confirmed=$?
  fi

  if [ "${confirmed}" == 0 ]; then
    # 直接执行命令而不是通过i3
    eval "${menu[${selection}]}" &
  fi
}

if [[ $? -eq 0 && ! -z ${selection} ]]; then
  if [[ "${enable_confirmation}" = true && \
        ${menu_confirm} =~ (^|[[:space:]])"${selection}"($|[[:space:]]) ]]; then
    ask_confirmation
  else
    # 直接执行命令而不是通过i3
    eval "${menu[${selection}]}" &
  fi
fi
