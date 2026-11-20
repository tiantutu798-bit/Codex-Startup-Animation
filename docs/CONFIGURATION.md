# 配置指南

运行时的实际配置文件位于：

```text
~/Library/Application Support/DragonCodexBoot/launcher.json
```

首次运行启动器时，若该文件不存在，会自动从应用包内复制默认模板 [config/launcher.macos.example.json](../config/launcher.macos.example.json)，并将随附的 `media/welcome-glass-4k-12s.mp4` 一并复制到同一目录下的 `media/` 子目录。

## 字段说明

| 字段名 | 类型 | 默认值 | 说明 |
| :--- | :--- | :--- | :--- |
| `DisplayName` | `String` | `"Codex 启动动画"` | 播放窗口标题（非空） |
| `Video` | `String` | `"media/welcome-glass-4k-12s.mp4"` | 本地视频路径。相对路径以 `~/Library/Application Support/DragonCodexBoot/` 为根目录，也可填写绝对路径或 `~/...` 路径 |
| `AppBundleIdentifier` | `String` | `"com.openai.codex"` | 目标客户端 Bundle ID（`AppBundleIdentifier` 与 `AppPath` 至少填写一项） |
| `AppPath` | `String` | `""` | 目标客户端 `.app` 绝对路径（如 `"/Applications/Codex.app"`）。填写后优先按路径查找，适合不同发行渠道或重命名过的应用 |
| `HoldAt` | `Double` | `6.2` | 等待节点时间（秒）。若到达此时间客户端仍未完成启动，视频在此暂停等待 |
| `TransitionStart` | `Double` | `10.6` | 开始整窗平滑淡出的时间点（秒） |
| `TransitionEnd` | `Double` | `12.0` | 淡出完全结束并交出焦点的时间点（秒） |
| `MaxWaitSeconds` | `Double` | `60` | 等待超时上限（至少 `10` 秒）。总墙钟运行超过 `MaxWaitSeconds + 20` 秒后强制结束覆盖窗以防卡死遮挡 |
| `Volume` | `Double` | `1.0` | 播放音量，取值范围 `0.0` 到 `1.0`（当前默认 12 秒动画无音轨） |
| `Fullscreen` | `Bool` | `true` | 直接打开启动器时是否全屏显示；若为 `false`，按 `PlayerWidth` × `PlayerHeight` 居中显示。注意：从原图标经监视器触发时优先贴合目标应用主窗口尺寸 |
| `PlayerWidth` | `Int` | `1920` | 非全屏模式下的窗口宽度（合法范围 `450` – `7680`） |
| `PlayerHeight` | `Int` | `1080` | 非全屏模式下的窗口高度（合法范围 `280` – `4320`） |
| `FillDesktop` | `Bool?` | `null`（可选） | 若设为 `true`，播放窗口铺满主屏可用区域；若已授权辅助功能权限，还会把目标客户端窗口同步放大铺满 |

## 查找本机客户端标识

如果不确定你安装的 Codex / ChatGPT 客户端 Bundle ID，请在终端运行：

```zsh
mdls -name kMDItemCFBundleIdentifier -raw /Applications/Codex.app
```

如果客户端在其他位置（例如 `/Applications/ChatGPT.app`），替换对应路径即可。将查到的字符串填入 `AppBundleIdentifier`，或直接把应用绝对路径填入 `AppPath`。

## 替换为自定义动画与时间校准

1. 使用仓库自带脚本导入自己的 MP4 文件（建议 H.264 编码）：
   ```zsh
   ./scripts/import-animation.sh /path/to/my-animation.mp4
   ```
2. 编辑 `~/Library/Application Support/DragonCodexBoot/launcher.json`：
   - 修改 `"Video"` 为 `"media/my-animation.mp4"`；
   - 必须严格满足校验约束：`0 < HoldAt < TransitionStart < TransitionEnd`；
   - 建议将 `HoldAt` 设在动画中视觉自然停顿的位置，将 `TransitionStart` 与 `TransitionEnd` 设在动画结尾最后 `1 ~ 1.5` 秒。

## 淡出透明度曲线

在 `[TransitionStart, TransitionEnd]` 区间内，覆盖窗透明度采用三次 Hermite 平滑曲线（Smoothstep）：

$$p = \mathrm{clamp}\left(\frac{t - \mathrm{TransitionStart}}{\mathrm{TransitionEnd} - \mathrm{TransitionStart}},\, 0,\, 1\right), \quad \alpha(t) = 1 - (3p^2 - 2p^3)$$

- 当 `t = TransitionStart` 时，`alpha = 1.0`（完全不透明）
- 当 `t = (TransitionStart + TransitionEnd) / 2` 时，`alpha = 0.5`
- 当 `t = TransitionEnd` 时，`alpha = 0.0`（完全透明并交还焦点）
