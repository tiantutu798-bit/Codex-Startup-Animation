# 贡献指南

欢迎参与改进本项目的 macOS 启动动画、播放稳定性、窗口定位与文档体验。

## 开发与提交流程

1. Fork 本仓库并从 `main` 分支切出特性或修复分支。
2. 修改 macOS 启动器源码、配置校验或安装脚本后，请在本地 macOS 环境运行完整检查：
   - 脚本语法检查：`bash -n scripts/*.sh`
   - Swift Package 单元测试：`swift test --package-path macos`
   - 应用构建、自检、签名与内嵌视频校验：`./scripts/test-macos.sh`
3. 若改动涉及 `LaunchAgent` 登录监视器、窗口边界贴合、连续圆角或焦点交接，请参考 [测试指南](docs/TESTING.md) 在安装了 Codex 的 macOS 桌面上完成一次真实冷启动验收，并在 PR 中注明触发条件、实际表现与验证环境（macOS 版本与芯片架构）。

## 安全与合规要求

- 提交代码适用本仓库的 [MIT License](LICENSE)。
- 请勿在 PR 中提交本机绝对路径、个人配置文件（`launcher.json`）、日志文件、构建缓存（`build/`）、官方提取图标、未获分发的第三方音视频素材或任何个人凭据。
- 对配置校验逻辑或淡出曲线的修改，请同步补充或更新 `macos/Tests/DragonCodexBootCoreTests/LauncherConfigurationTests.swift` 测试用例。
