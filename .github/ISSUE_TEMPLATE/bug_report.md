---
name: Bug report
about: 反馈 macOS 启动动画播放、窗口定位或焦点交接问题
title: ''
labels: bug
assignees: ''
---

**发生了什么 / What happened**

**重现步骤 / Reproduction**

1. 
2. 

**预期效果 / Expected behavior**

**运行环境 / Environment**

- macOS 版本与芯片架构（如 macOS 15 / Apple Silicon）：
- 显示器分辨率与缩放比例：
- 触发方式（从 Dock 原图标冷启动 / 直接打开 DragonCodexBoot.app）：
- 使用的视频（内置 12s welcome-glass-4k-12s.mp4 / 自定义 MP4）：
- 客户端此前是否已经在运行：

**自检与日志 / Checks & logs**

- `swift test --package-path macos` 结果：
- `./scripts/test-macos.sh` 结果：
- Console 日志片段（`process == "DragonCodexBootMac"`，注意脱敏）：

> 注意：请勿上传包含账户信息、API Key、聊天正文或私人窗口截屏的内容。
