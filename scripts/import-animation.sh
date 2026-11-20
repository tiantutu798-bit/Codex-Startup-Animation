#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  printf '用法 / Usage: %s /path/to/custom-animation.mp4\n' "$0" >&2
  exit 1
fi

src_video="$1"
if [[ ! -f "$src_video" ]]; then
  printf '找不到视频文件：%s\n' "$src_video" >&2
  exit 1
fi

support_dir="$HOME/Library/Application Support/DragonCodexBoot"
media_dir="$support_dir/media"
config_file="$support_dir/launcher.json"
filename="$(basename "$src_video")"
target_video="$media_dir/$filename"

mkdir -p "$media_dir"
cp "$src_video" "$target_video"
cmp -s "$src_video" "$target_video"

if [[ -f "$config_file" ]]; then
  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup_file="$support_dir/launcher.before-$timestamp.json"
  cp "$config_file" "$backup_file"
  printf '已备份现有配置：%s\n' "$backup_file"
fi

printf '已导入并校验视频：%s\n' "$target_video"
printf '请编辑 %s，将 "Video" 更新为 "media/%s"，并按新视频时长调整 HoldAt / TransitionStart / TransitionEnd。\n' "$config_file" "$filename"
