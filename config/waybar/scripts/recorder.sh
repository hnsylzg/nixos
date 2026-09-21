#!/usr/bin/env sh
set -x

pgrep wf-recorder
status=$?

countdown() {
  notify "Recording in 3 seconds" -t 1000
  sleep 1
  notify "Recording in 2 seconds" -t 1000
  sleep 1
  notify "Recording in 1 seconds" -t 1000
  sleep 1
}

notify() {
  line=$1
  shift
  # NixOS 没有 /usr/share/icons，图标只能按名字查找（找不到就退化成无图标，不影响发送）
  notify-send "Recording" "${line}" -i camera-video $*
}

if [ $status != 0 ]; then
  target_path=$(xdg-user-dir VIDEOS)
  # 目录不存在时 wf-recorder 会打不开输出文件直接退出，这里兜底并建好
  [ -z "$target_path" ] && target_path="$HOME/Videos"
  mkdir -p "$target_path"
  timestamp=$(date +'recording_%Y%m%d-%H%M%S')

  notify "Select a region to record" -t 1000
  # area=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp)
  area=$(hyprctl clients -j | jq -r '.[] | select(.mapped == true) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp)

  countdown
  (sleep 0.5 && pkill -x -SIGRTMIN+8 waybar) &

  if [ "$1" = "-a" ]; then
    file="$target_path/$timestamp.mp4"
    wf-recorder --audio -g "$area" --file="$file"
  else
    file="$target_path/$timestamp.webm"
    wf-recorder -g "$area" -c libvpx --codec-param="qmin=0" --codec-param="qmax=25" --codec-param="crf=4" --codec-param="b:v=1M" --file="$file"
  fi

  pkill -x -SIGRTMIN+8 waybar && notify "Finished recording ${file}"
else
  pkill -x --signal SIGINT wf-recorder
  pkill -x -SIGRTMIN+8 waybar
fi
