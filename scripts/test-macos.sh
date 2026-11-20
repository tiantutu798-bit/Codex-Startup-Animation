#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
app_bundle="$repo_root/build/DragonCodexBoot.app"
video_rel="media/welcome-glass-4k-12s.mp4"

"$repo_root/scripts/build-macos.sh"
"$app_bundle/Contents/MacOS/DragonCodexBootMac" --self-test
plutil -lint "$app_bundle/Contents/Info.plist"
codesign --verify --deep --strict "$app_bundle"
cmp "$repo_root/$video_rel" "$app_bundle/Contents/Resources/$video_rel"
cmp "$repo_root/media/MEDIA_NOTICE.md" "$app_bundle/Contents/Resources/MEDIA_NOTICE.md"
file "$app_bundle/Contents/MacOS/DragonCodexBootMac"
