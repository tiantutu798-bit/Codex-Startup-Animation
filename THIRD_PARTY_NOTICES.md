# 第三方名称、框架与素材声明

## 1. 程序代码与致谢

本仓库中的 macOS Swift 启动器源码、配置模板、自动化脚本与文档按根目录 [LICENSE](LICENSE) 中的 MIT 许可证分发。

macOS 启动器底层骨架基于开源社区项目 **Dragon Codex Boot**（`0.2.0`）进行精简与适配，并保留原版权声明。

## 2. 系统运行依赖

macOS 原生启动器在运行时直接调用 Apple macOS 系统框架：
- `AppKit`（窗口管理、透明/连续圆角样式与焦点交接）
- `AVKit` / `AVFoundation`（本地 MP4 硬件解码与播放控制）
- `CoreGraphics`（主窗口几何区域查询）
- `ApplicationServices`（仅在可选开启 `FillDesktop` 时检查辅助功能状态）

上述系统组件属于操作系统环境的一部分，不包含在本仓库或编译产物内，按 Apple 系统软件许可协议使用。

## 3. 产品与商标名称

文档中提及的 **OpenAI**、**Codex**、**ChatGPT**、**Apple** 与 **macOS** 仅用于说明所支持的宿主操作系统与目标桌面客户端。本项目为独立社区工具，与上述公司或官方客户端不存在隶属、赞助或授权关系。

## 4. 媒体资产边界

仓库附带的 12 秒 4K 启动动画视频 `media/welcome-glass-4k-12s.mp4` 及首页预览图说明见 [media/MEDIA_NOTICE.md](media/MEDIA_NOTICE.md)。本仓库不包含任何官方客户端提取图标、个人聊天记录或用户本地凭据。用户自行导入的视频或素材，其版权与许可由原提供方规定。
