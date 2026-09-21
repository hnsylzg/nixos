#!/usr/bin/env bash
# NixOS 清理脚本
#
# 用法：
#   bash cleanup.sh              # 默认保留最近 3 个 generation（可回滚）
#   bash cleanup.sh --keep 5     # 保留最近 5 个
#   bash cleanup.sh --all        # 除当前外全删，回收最多，但之后无法回滚
#   bash cleanup.sh --dry-run    # 只看能回收多少，不动手
#
# 流程：删旧 generation → GC → 硬链接去重 → 清缓存/日志 → 重建引导项
set -uo pipefail

KEEP=3
DRY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)     KEEP=0; shift ;;
    --keep)    KEEP="${2:?--keep 需要一个数字}"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "未知参数: $1（用 --help 看用法）"; exit 1 ;;
  esac
done

# nix-env 的 generation 选择器：+N = 保留最近 N 个；old = 只留当前
SPEC="+${KEEP}"
[[ "$KEEP" == "0" ]] && SPEC="old"

store_size() { du -sh /nix/store 2>/dev/null | cut -f1; }
dead_count() { nix-store --gc --print-dead 2>/dev/null | wc -l | tr -d ' '; }

echo "清理前 /nix/store = $(store_size)"
echo "可回收的 store 路径 = $(dead_count) 个"
echo "保留策略           = ${SPEC}"

if [[ "$DRY" == "1" ]]; then
  echo "(dry-run，未做任何改动)"
  exit 0
fi

if [[ "$KEEP" == "0" ]]; then
  read -r -p "将删除除当前外的全部 generation，之后无法回滚。确认？[y/N] " ans
  [[ "$ans" != "y" && "$ans" != "Y" ]] && { echo "已取消"; exit 1; }
fi

echo "==> 删除旧 generation"
# home-manager（在用户目录下，root 的 GC 看不到，必须自己先删）
HM_PROFILE="$HOME/.local/state/nix/profiles/home-manager"
[[ -e "$HM_PROFILE" ]] && nix-env -p "$HM_PROFILE" --delete-generations "$SPEC"
nix-env --delete-generations "$SPEC" 2>/dev/null
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations "$SPEC"
sudo nix-env --delete-generations "$SPEC" 2>/dev/null

echo "==> 垃圾回收"
# 上面已按策略删过 generation；--all 时再用 -d 兜底删掉其它 profile 的旧 generation
if [[ "$KEEP" == "0" ]]; then
  sudo nix-collect-garbage -d
else
  sudo nix-collect-garbage
fi

echo "==> 清缓存与构建临时目录"
sudo rm -rf /root/.cache/nix "$HOME/.cache/nix" /tmp/nix-build-* 2>/dev/null

echo "==> 硬链接去重（optimise）"
sudo nix-store --optimise

echo "==> 日志只留 7 天"
sudo journalctl --vacuum-time=7d

echo "==> 重建引导项"
sudo /run/current-system/bin/switch-to-configuration boot

echo
echo "清理后 /nix/store = $(store_size)"
df -h / | tail -1
