# Changelog

## 0.2.0-codex-welcome — 2026-11-20

- **新增默认 12 秒 4K 玻璃字成片**：集成 `media/welcome-glass-4k-12s.mp4`（3840 × 2160，30 fps，12.0 秒），预置 `HoldAt = 6.2`、`TransitionStart = 10.6`、`TransitionEnd = 12.0` 最佳时间轴参数。
- **macOS 专项仓库精简整理**：聚焦 macOS 13+ 原生 Swift 5.9+ 启动器，移除冗余构建缓存与跨平台非相关产物。
- **补全文档与工具链**：
  - 新增 `assets/hero-preview.jpg` 与 `assets/storyboard-preview.jpg` 直观分镜预览；
  - 新增 `scripts/import-animation.sh` 支持安全导入并校验自定义 MP4 启动视频；
  - 完善 `README.md`、`docs/MACOS.md`、`docs/CONFIGURATION.md`、`docs/TESTING.md` 及 macOS GitHub Actions 工作流；
  - 更新 `LauncherConfiguration` 默认参数及 XCTest 单元测试用例以匹配 12 秒版本。

## 0.2.0（上游 Dragon Codex Boot 基础）— 2026-10-06

- 新增 Swift 原生 macOS 启动器与 Core 配置库，使用 `AVKit` 播放本地 MP4 并在结束时淡出交接焦点。
- 新增可选 `LaunchAgent` 登录监视器（`--watch`），支持从原 Codex 图标冷启动时按可见主窗口位置、尺寸与 12 pt 连续圆角贴合播放；提供一键安装与卸载脚本。
- 支持 `--self-test`、配置输入合法性校验以及平滑 S 曲线窗口淡出控制。
