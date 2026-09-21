#!/usr/bin/env bash
# 安全部署脚本：把本仓库（25.11 + dotfiles 声明式接管 + nvidia 580 + fish 登录 shell）
# 应用到当前 NixOS 机器。会先备份并校验硬件 UUID，防止写错磁盘导致开不了机。
#
# 用法（在 nixos 仓库根目录）：  bash deploy.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HW="$REPO_ROOT/nixos/hardware-configuration.nix"
BACKUP="$HOME/hw-backup-$(date +%F-%H%M%S).conf"

echo "==> [1/6] 备份当前机器的 hardware-configuration.nix"
cp -f "$HW" "$BACKUP"
echo "        已备份到 $BACKUP"

echo "==> [2/6] 拉取并硬对齐 GitHub 的 25.11 (origin/main)"
git -C "$REPO_ROOT" fetch origin
git -C "$REPO_ROOT" reset --hard origin/main

echo "==> [3/6] 校验硬件 UUID 是否对应本机真实磁盘"
mapfile -t UUIDS < <(grep -oE 'by-uuid/[0-9A-Fa-f-]+' "$HW" | sed 's#by-uuid/##')
ALL_OK=1
for u in "${UUIDS[@]}"; do
  if [ -e "/dev/disk/by-uuid/$u" ]; then
    echo "        [OK] $u 存在"
  else
    echo "        [!!] $u 不在本机磁盘上"
    ALL_OK=0
  fi
done

if [ "$ALL_OK" -ne 1 ]; then
  echo "==> 硬件 UUID 与本机不符，恢复机器自己的 hardware-configuration.nix 后继续"
  cp -f "$BACKUP" "$HW"
  echo "        已恢复为 $BACKUP（即本机真实硬件配置）"
fi

echo "==> [4/6] 构建并切换系统配置"
sudo nixos-rebuild switch --flake "$REPO_ROOT#nixos"

echo "==> [5/6] 应用 home 配置"
home-manager switch --flake "$REPO_ROOT#lzg@nixos"

echo "==> [6/6] 完成"
echo "        请重新登录使 fish 默认 shell 生效；若有问题用 sudo nixos-rebuild --rollback 回退。"
