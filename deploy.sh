#!/usr/bin/env bash
# 安全部署脚本：把本仓库（26.05 + dotfiles 声明式接管 + nvidia 580 + fish 登录 shell）
# 应用到当前 NixOS 机器。会先备份并校验硬件 UUID，防止写错磁盘导致开不了机。
#
# 用法（在 nixos 仓库根目录）：  bash deploy.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HW="$REPO_ROOT/nixos/hardware-configuration.nix"
BACKUP="$HOME/hw-backup-$(date +%F-%H%M%S).conf"

echo "==> [1/7] 备份当前机器的 hardware-configuration.nix"
cp -f "$HW" "$BACKUP"
echo "        已备份到 $BACKUP"

echo "==> [2/7] 拉取并硬对齐 GitHub 的 origin/main"
git -C "$REPO_ROOT" fetch origin
git -C "$REPO_ROOT" reset --hard origin/main

echo "==> [3/7] 校验硬件 UUID 是否对应本机真实磁盘"
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
  echo "        硬件 UUID 与本机不符，恢复机器自己的 hardware-configuration.nix"
  cp -f "$BACKUP" "$HW"
  # 恢复后工作树会变脏，同样会触发 "Git tree is dirty" 警告，这里一起提交掉
  git -C "$REPO_ROOT" add nixos/hardware-configuration.nix
  git -C "$REPO_ROOT" commit -q -m "chore: use this machine's hardware-configuration.nix"
fi

echo "==> [4/7] 更新并提交 flake.lock（消除 Git tree is dirty 警告）"
# 说明：flake.lock 与 flake.nix 不一致时，nixos-rebuild 会自己改写 flake.lock，
# 工作树因此变脏 → 之后每次构建都刷 "warning: Git tree ... is dirty"。
# 这里先显式更新并提交，构建阶段 lock 已是最新、不会被改写，警告随之消失。
# 想彻底消除（避免每次重新解析）：把这次生成的 flake.lock push 回仓库，
# 以后 reset --hard 拿到的最新 lock 与 flake.nix 一致，本步自动变成空操作。
( cd "$REPO_ROOT" && nix flake update )
if ! git -C "$REPO_ROOT" diff --quiet -- flake.lock; then
  git -C "$REPO_ROOT" add flake.lock
  git -C "$REPO_ROOT" commit -q -m "chore: update flake.lock ($(date +%F))"
  echo "        已本地提交 flake.lock"
fi

echo "==> [5/7] 构建并切换系统配置"
sudo nixos-rebuild switch --flake "$REPO_ROOT#nixos"

echo "==> [6/7] 应用 home 配置"
home-manager switch --flake "$REPO_ROOT#lzg@nixos"

echo "==> [7/7] 完成"
echo "        请重新登录使 fish 默认 shell 生效；若有问题用 sudo nixos-rebuild --rollback 回退。"
