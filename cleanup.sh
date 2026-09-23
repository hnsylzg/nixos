#!/usr/bin/env bash
# NixOS 清理脚本（默认路径都是快的；慢的步骤默认跳过并给了开关）
#
# 用法：
#   bash cleanup.sh               # 保留最近 3 个 generation（可回滚）
#   bash cleanup.sh --keep 5      # 保留最近 5 个
#   bash cleanup.sh --all         # 除当前外全删，回收最多（会问确认；非交互加 -y）
#   bash cleanup.sh --dry-run     # 只看能回收多少，不动手
#   bash cleanup.sh --optimise    # 附带做硬链接去重（最慢，可能十几分钟）
#
# 每次都会顺手清掉 ~/.config 下指向 /nix/store 的悬空符号链接（旧代残留的坏链），
# 免得它们挡住 home-manager 重建同名目录。
#   bash cleanup.sh --help
#
# 慢操作说明（避免看起来像卡死）：
#   - 每个步骤前都会打时间戳
#   - du / nix-store --gc --print-dead 都加了 timeout，超时就跳过不再干等
#   - 需要确认时若不是交互终端就直接跳过确认，不会挂住
set -uo pipefail

KEEP=3
DRY=0
YES=0
DO_OPT=0

usage() { sed -n '2,15p' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)      KEEP=0; shift ;;
    --keep)     KEEP="${2:?--keep 需要一个数字}"; shift 2 ;;
    --dry-run)  DRY=1; shift ;;
    --optimise) DO_OPT=1; shift ;;
    -y|--yes)   YES=1; shift ;;
    -h|--help)  usage; exit 0 ;;
    *) echo "未知参数: $1（用 --help 看用法）"; exit 1 ;;
  esac
done

SPEC="+${KEEP}"
[[ "$KEEP" == "0" ]] && SPEC="old"

step() { echo; echo "[$(date +%H:%M:%S)] ==> $*"; }

# 清理 ~/.config 下悬空的 home-manager 符号链接。
# 成因：把 xdg.configFile."<目录>" 改成 "<目录>/<文件>" 后，旧的整目录符号链接不再
# 被新代管理 → 指向的 store 路径失活 → 变成坏链（Thunar 里红叉，程序读不到配置），
# 而且会挡住 home-manager 重建同名目录（mkdir 撞 EEXIST，报完错还是坏的）。
# 只删「已断链」且「目标在 /nix/store 下」的，普通用户文件不可能误伤。
prune_dangling_links() {
  local n f
  n=$(find "$HOME/.config" -xtype l -lname '/nix/store/*' 2>/dev/null | wc -l | tr -d ' ')
  if [ "${n:-0}" -eq 0 ]; then
    echo "        无悬空符号链接"
    return
  fi
  echo "        发现 $n 个："
  find "$HOME/.config" -xtype l -lname '/nix/store/*' -print 2>/dev/null | while IFS= read -r f; do
    echo "        删除 $f"
    rm -f "$f"
  done
}
# 带超时，避免在大 store 上长时间无输出，看起来像卡死
store_size() { timeout 15 du -sh /nix/store 2>/dev/null | cut -f1 || echo "(du 超时，跳过)"; }
free_space() { df -h / | awk 'NR==2 {print $4}'; }

echo "开始时间        : $(date +%H:%M:%S)"
echo "可用空间        : $(free_space)"
echo "/nix/store 大小 : $(store_size)"
echo "保留策略        : ${SPEC}（最近 ${KEEP} 个；0 = 只留当前）"

if [[ "$DRY" == "1" ]]; then
  step "dry-run：统计可回收空间（最多等 90 秒）"
  echo "可回收 store 路径: $(timeout 90 nix-store --gc --print-dead 2>/dev/null | wc -l | tr -d ' ') 个"
  echo "悬空符号链接    : $(find "$HOME/.config" -xtype l -lname '/nix/store/*' 2>/dev/null | wc -l | tr -d ' ') 个（~/.config 下指向 /nix/store 的断链）"
  step "dry-run 结束，未做任何改动"
  exit 0
fi

# 先把 sudo 凭据缓存起来，避免跑到一半才弹密码框
step "获取 sudo 凭据"
sudo -v

if [[ "$KEEP" == "0" && "$YES" != "1" ]]; then
  if [[ -t 0 ]]; then
    read -r -p "将删除除当前外的全部 generation，之后无法回滚。确认？[y/N] " ans
    [[ "$ans" != "y" && "$ans" != "Y" ]] && { echo "已取消"; exit 1; }
  else
    echo "非交互环境，跳过确认（要强制删除请加 -y）"
    exit 1
  fi
fi

step "1/7 删除旧 generation"
HM_PROFILE="$HOME/.local/state/nix/profiles/home-manager"
[[ -e "$HM_PROFILE" ]] && nix-env -p "$HM_PROFILE" --delete-generations "$SPEC"
nix-env --delete-generations "$SPEC" 2>/dev/null
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations "$SPEC"
sudo nix-env --delete-generations "$SPEC" 2>/dev/null

step "2/7 垃圾回收（这一步可能要 1~3 分钟）"
if [[ "$KEEP" == "0" ]]; then
  sudo nix-collect-garbage -d
else
  sudo nix-collect-garbage
fi

step "3/7 清悬空的 home-manager 符号链接"
prune_dangling_links

step "4/7 清缓存与构建临时目录"
sudo rm -rf /root/.cache/nix "$HOME/.cache/nix" /tmp/nix-build-* 2>/dev/null

if [[ "$DO_OPT" == "1" ]]; then
  step "5/7 硬链接去重 --optimise（最慢，可能十几分钟）"
  sudo nix-store --optimise
else
  echo
  echo "[$(date +%H:%M:%S)] ==> 5/7 跳过 optimise（默认关闭；需要时加 --optimise）"
fi

step "6/7 日志只留 7 天"
sudo journalctl --vacuum-time=7d

step "7/7 重建引导项"
sudo /run/current-system/bin/switch-to-configuration boot

echo
echo "完成时间        : $(date +%H:%M:%S)"
echo "可用空间        : $(free_space)"
echo "/nix/store 大小 : $(store_size)"
