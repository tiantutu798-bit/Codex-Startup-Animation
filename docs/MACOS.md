# macOS 启动机制与功能边界

本项目 macOS 版由 `macos/` 下的原生 Swift 代码构建，最低要求 **macOS 13 (Ventura)** 与 **Swift 5.9** 以上，无需额外第三方运行时依赖。

## 两种启动方式

### 1. 通过登录监视器从原 Codex 图标自动触发（推荐）

在仓库根目录执行安装脚本：

```zsh
./scripts/install-codex-integration.sh
```

安装流程会：
1. 调用 `./scripts/build-macos.sh` 编译并 ad-hoc 签名 `build/DragonCodexBoot.app`；
2. 将应用复制到 `~/Applications/DragonCodexBoot.app`；
3. 运行 `DragonCodexBootMac --install-integration`，在 `~/Library/LaunchAgents/community.dragoncodexboot.codex-watcher.plist` 注册后台监视进程（`--watch`）并通过 `launchctl bootstrap` 立即加载。

**冷启动触发原理**：
- 监视器通过 `NSWorkspace.shared.notificationCenter` 监听 `didLaunchApplicationNotification`，仅匹配配置中指定的 `AppBundleIdentifier`（默认 `com.openai.codex`）。
- 检测到新进程启动后，每 `0.2` 秒通过 `CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)` 查询该 PID 的普通层级主窗口（`layer == 0`、宽高不小于 `350 × 250`）。
- 当连续两次读取到稳定的主窗口几何矩形后，启动器以 `.screenSaver` 置顶层级弹出无边框播放窗口，位置与尺寸完全对齐 Codex 主窗口，并启用 `12 pt` 连续圆角（`.continuous`）。
- 在 `HoldAt`（默认 `6.2s`）处若目标应用仍未 `isFinishedLaunching`，视频会暂停并显示「Codex 正在启动… Esc 跳过」；就绪后继续播放，并在 `TransitionStart`（`10.6s`）至 `TransitionEnd`（`12.0s`）之间通过平滑 S 曲线降低窗口透明度，最后交还键盘焦点给 Codex。
- **不会重复打扰**：已经在运行的 Codex 被再次切回前台时不会重播动画。

### 2. 直接双击启动器播放

直接运行 `~/Applications/DragonCodexBoot.app` 时：
- 根据配置中的 `Fullscreen`（默认 `true`）或 `PlayerWidth` / `PlayerHeight` 在主屏幕居中显示播放窗口；
- 后台调用 `NSWorkspace.shared.openApplication` 拉起目标客户端（若已在运行则复用现有实例）；
- 同样遵守 `HoldAt` 等待节点与 `TransitionStart`–`TransitionEnd` 淡出交接逻辑。

## 可选：铺满桌面可用区域（`FillDesktop`）

若在 `launcher.json` 中显式加入 `"FillDesktop": true`：
- 播放窗口将铺满主屏幕的 `visibleFrame`（保留菜单栏与 Dock 可用区），并以 `.floating` 层级播放；
- 若同时已向启动器授予 **辅助功能（Accessibility）** 权限，启动器会尝试通过 `AXUIElement` 将底层 Codex 窗口尺寸也同步调整至填满桌面区域。
- 若未开启 `FillDesktop`（默认行为），启动器**完全不请求**辅助功能权限。

可使用以下命令主动触发系统辅助功能授权弹窗（仅开启 `FillDesktop` 时需要）：

```zsh
~/Applications/DragonCodexBoot.app/Contents/MacOS/DragonCodexBootMac --request-window-access
```

## 隐私、安全与功能边界

- **无侵入性**：不修改、不替换 `/Applications/Codex.app` 内部文件或签名，不修改 Dock 数据库或 Launch Services 默认关联。
- **最小权限原则**：默认不需要屏幕录制、辅助功能或管理员权限。`CGWindowListCopyWindowInfo` 仅读取窗口几何矩形，不读取屏幕像素或窗口标题内容。
- **干净卸载**：执行 `./scripts/uninstall-codex-integration.sh` 即可注销并删除 `LaunchAgent` 与 `~/Applications/DragonCodexBoot.app`（`~/Library/Application Support/DragonCodexBoot/` 中的用户配置与自定义视频默认保留）。
- **日志位置**：运行与调试日志输出至 macOS 统一日志系统（可通过「控制台 / Console.app」或 `log show --predicate 'process == "DragonCodexBootMac"'` 查看），不记录聊天内容或键盘输入。
