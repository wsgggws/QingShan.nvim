# 青山入墨 · 同色板主题

这些文件由 `lua/qingshan/palette.lua` 导出，与 Neovim 使用同一份色板。此目录提供配色数据，各工具独立加载。

| 工具 | 主题文件 | 建议存放位置 |
| --- | --- | --- |
| WezTerm | `wezterm/QingShan.toml` | `~/.config/wezterm/colors/QingShan.toml` |
| tmux | `tmux/qingshan.conf` | `~/.config/tmux/themes/qingshan.conf` |
| Oh my tmux! | `tmux/qingshan.oh-my-tmux.conf` | `~/.config/tmux/themes/qingshan.oh-my-tmux.conf` |
| fzf | `fzf/qingshan.sh` | `~/.config/fzf/themes/qingshan.sh` |
| bat | `bat/QingShan.tmTheme` | `~/.config/bat/themes/QingShan.tmTheme` |
| delta | `delta/qingshan.gitconfig` | `~/.config/delta/themes/qingshan.gitconfig` |
| Alfred | `alfred/QingShan Dark Large.alfredappearance` | `~/.config/alfred/themes/QingShan Dark Large.alfredappearance` |
| slides / Markdown PPT | `slides/qingshan_theme.json` | 演示文稿目录中的 `qingshan_theme.json` |

Neovim 使用 `qingshan`，WezTerm 与 bat 使用 `QingShan`，delta feature 使用 `qingshan`。仓库名保持 `QingShan.nvim` 的大小写。

## 导入文件

从仓库根目录复制需要的文件，例如：

```sh
mkdir -p ~/.config/wezterm/colors ~/.config/tmux/themes ~/.config/fzf/themes
mkdir -p ~/.config/bat/themes ~/.config/delta/themes ~/.config/alfred/themes
cp extras/wezterm/QingShan.toml ~/.config/wezterm/colors/
cp extras/tmux/qingshan*.conf ~/.config/tmux/themes/
cp extras/fzf/qingshan.sh ~/.config/fzf/themes/
cp extras/bat/QingShan.tmTheme ~/.config/bat/themes/
cp extras/delta/qingshan.gitconfig ~/.config/delta/themes/
cp 'extras/alfred/QingShan Dark Large.alfredappearance' ~/.config/alfred/themes/
```

复制前保留目标文件的已有版本。更新色板后重新复制相应文件，并按下文重载应用。`palette.json` 是完整色板的机器可读快照。

## WezTerm

在现有配置中加入或合并：

```lua
config.color_scheme_dirs = { wezterm.home_dir .. "/.config/wezterm/colors" }
config.color_scheme = "QingShan"
wezterm.add_to_config_reload_watch_list(
  wezterm.home_dir .. "/.config/wezterm/colors/QingShan.toml"
)
```

监听配色文件后，更新同名 TOML 也会触发重载。首次加入监听时保存 WezTerm 配置；亦可手动重载配置。

原生拖选使用浅玉底 `jade`、深墨字 `bg_dark`，与 Neovim 的苔绿选区分开。tmux 开启鼠标时普通拖选由其 copy mode 接管；按住 Shift 可使用 WezTerm 原生选区。

## tmux

普通 tmux 3.2+ 配置中加载：

```tmux
source-file ~/.config/tmux/themes/qingshan.conf
```

文件定义状态栏、窗口状态、边框、消息、复制模式与 popup 的颜色。使用 Oh my tmux! 时，将 `qingshan.oh-my-tmux.conf` 的变量合并到现有主题变量区。随后执行：

```sh
tmux source-file ~/.tmux.conf
```

copy mode 同样采用浅玉底、深墨字。主题文件仅提供样式，窗口选择器与快捷键由个人 tmux 配置维护。

## fzf

```sh
. "$HOME/.config/fzf/themes/qingshan.sh"
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --color=$FZF_THEME_COLOR"
```

`FZF_THEME_NAME` 为显示名称，`FZF_THEME_COLOR` 为颜色选项，`FZF_THEME_PREVIEW_CMD` 为使用 bat 的预览命令。列表使用浮层背景，预览使用正文背景；预览的滚动和内容由调用 fzf 的程序决定。

## bat

在 `~/.config/bat/config` 中设置：

```text
--theme="QingShan"
```

首次复制或更新 TextMate 文件后执行 `bat cache --build`，并用 `bat --list-themes` 确认注册。

## delta

在 Git 配置中加入：

```gitconfig
[include]
    path = ~/.config/delta/themes/qingshan.gitconfig
[delta]
    features = qingshan
```

已有 `[delta]` 中直接设置的样式可能覆盖 feature。delta 使用 bat 主题缓存；自定义缓存目录时，应让两者指向同一个 XDG 缓存位置。

## Alfred

打开 `~/.config/alfred/themes/QingShan Dark Large.alfredappearance` 导入，再在 Alfred 外观设置中选择 `QingShan Dark Large`。

不透明黛青深色配色：搜索区采用浮层青绿，选中项使用苔绿。主题 UUID 保持稳定，重新导出或更名时沿用同一身份。

`alfred/qingshan.plist` 提供浅色、深色选择均指向该 UUID 的配置数据，供个人配置工具使用；导入外观无需覆盖 Alfred 的整份偏好设置。应用自动切换脚本由个人 Alfred 配置目录维护。

## slides / Markdown PPT

`slides/qingshan_theme.json` 是 slides 使用的 Glamour JSON，包含自定义 Chroma 代码色板。复制到演示文稿目录，在文稿开头指定：

```yaml
---
theme: ./qingshan_theme.json
---
```

主题相对路径以启动 `slides` 的工作目录为准，也可使用绝对路径。JSON 定义正文、标题、引用、链接、代码与 diff；应用自身的页码、日期和作者栏可能使用内置颜色。

## 更新与检查

导出和检查需要 Python 3.10+ 与 Neovim，从仓库根目录执行：

```sh
python3 scripts/export.py
python3 scripts/export.py --check
python3 -m unittest discover -s tests -p 'test_*.py' -v
```

导出只写入本仓库的 `extras/`；检查验证生成文件、语义层级、选区反差及各端背景一致性。个人配置的安装、统一切换和窗口选择器独立维护，测试也位于对应的配置目录。
