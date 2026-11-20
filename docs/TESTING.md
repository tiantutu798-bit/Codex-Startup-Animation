# 测试与验收指南

## 1. 自动化验证（不改动当前系统安装状态）

在仓库根目录执行以下检查：

### Shell 脚本语法检查

```zsh
bash -n scripts/*.sh
```

### Swift Package 单元测试

运行配置解码、边界校验、路径解析以及平滑淡出曲线测试（[LauncherConfigurationTests.swift](../macos/Tests/DragonCodexBootCoreTests/LauncherConfigurationTests.swift)）：

```zsh
swift test --package-path macos
```

### 应用打包、自检与签名校验

运行完整 macOS 构建校验脚本（[scripts/test-macos.sh](../scripts/test-macos.sh)）：

```zsh
./scripts/test-macos.sh
```

该脚本依次验证：
1. `swiftc` 离线编译生成 `build/DragonCodexBoot.app`（支持本机 arm64/x86_64，模块缓存写入系统临时目录，不污染仓库）；
2. 执行 `DragonCodexBootMac --self-test`，校验模板配置 `config/launcher.macos.example.json` 解码、S 曲线透明度检查（`10.6 -> 1.0`、`11.3 -> 0.5`、`12.0 -> 0.0`）以及 `LaunchAgent` plist 生成逻辑；
3. `plutil -lint` 检查 `Info.plist` 格式合规；
4. `codesign --verify --deep --strict` 验证 ad-hoc 代码签名完整；
5. `cmp` 逐字节对比源仓库 `media/welcome-glass-4k-12s.mp4` 和 `media/MEDIA_NOTICE.md` 与 App 包内副本完全一致。

---

## 2. 桌面实机手动验收清单

自动化测试不注册后台 `LaunchAgent`，也不真正拉起或退出你的 Codex 桌面端。安装并部署后，建议在真实桌面环境核对以下 5 项：

1. **安装态核对**：
   - 运行 `./scripts/install-codex-integration.sh` 后，执行 `launchctl list | grep dragoncodexboot`，确认输出中有 `community.dragoncodexboot.codex-watcher`。
2. **冷启动自动触发与圆角贴合**：
   - 按 `⌘Q` 完全退出 Codex，然后点击 Dock 中的原 Codex 图标；
   - 确认主窗口弹出后，12 秒 `welcome` 动画立即按 Codex 窗口边界与 `12 pt` 连续圆角贴合播放。
3. **淡出交接与键盘焦点**：
   - 观察至 `10.6s ~ 12.0s`，确认画面平滑叠化淡出并露出底下的 Codex 窗口，且无需再次点击即可直接在输入框键入文字。
4. **Esc 跳过响应**：
   - 再次冷启动 Codex，在动画播放到前几秒时按下 `Esc` 或点击右上角「跳过 Esc」，确认覆盖窗立即消失并把焦点交还给 Codex。
5. **已运行状态下不误触发**：
   - 当 Codex 已在后台运行时点击 Dock 图标将其切回前台，确认不会重复播放启动动画。
