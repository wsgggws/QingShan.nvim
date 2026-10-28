# 青山 · QingShan

> 青山不改，绿水长流。

> 青山依旧在，几度夕阳红。

远山敛黛，竹影落纸。以低饱和黛青、温玉与宣纸色，呈现安静清晰的 Neovim 深色主题。

![青山预览](assets/qingshan.png)

需要 **Neovim 0.10+** 与支持真彩色的终端，无插件依赖。

- 注释暖灰斜体，变量明亮，关键字竹青加粗。
- 支持 Treesitter、LSP 语义高亮、诊断、diff 与终端色。
- 适配 Telescope、nvim-cmp、blink.cmp、Neo-tree、nvim-tree、which-key、gitsigns 等插件。
- 支持透明背景、非活动窗口变暗与高亮覆盖。

## 安装

使用 lazy.nvim：

```lua
{
  "wsgggws/QingShan.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("qingshan")
  end,
}
```

使用 LazyVim 时，注册主题插件，并设置：

```lua
return {
  { "wsgggws/QingShan.nvim", lazy = true },
  { "LazyVim/LazyVim", opts = { colorscheme = "qingshan" } },
}
```

本地安装可将仓库名替换为 `dir = vim.fn.expand("~/github/QingShan.nvim")`。
安装后也可执行 `:colorscheme qingshan`。主题会自动启用 `termguicolors`。

## 配置

`setup()` 可省略；自定义时在加载主题之前调用：

```lua
require("qingshan").setup({
  transparent = false,
  dim_inactive = false,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { bold = true },
  },
  palette = {},
  highlights = {},
})
vim.cmd.colorscheme("qingshan")
```

例如关闭注释斜体、覆盖高亮：

```lua
require("qingshan").setup({
  styles = { comments = { italic = false } },
  highlights = function(p)
    return { CursorLineNr = { fg = p.jade, bold = true } }
  end,
})
```

修改配置后重新执行 `:colorscheme qingshan`。完整选项见 `:help qingshan`。

## 色彩

| 角色          | 色值                  |
| ------------- | --------------------- |
| 背景 / 正文   | `#1D3229` / `#DCE8D5` |
| 注释 / 关键字 | `#ADA594` / `#89C79B` |
| 函数 / 参数   | `#99CEBE` / `#D7C5A0` |
| 字符串 / 数字 | `#C6D8A3` / `#C5AD78` |

松绿背景与竹青关键字强化青绿气息；明亮变量、暖灰注释、冷玉函数与浅沙参数拉开层级，字体样式作为辅助。完整色板见 [palette.lua](lua/qingshan/palette.lua)。

## 其他配色

[extras/](extras/README.md) 提供 WezTerm、tmux、fzf、bat、Git diff（delta）、Alfred 与 slides 的同色板主题文件，随色板同步更新。导入与重载方法见各工具说明；个人安装与统一切换命令在各自配置目录维护。

## 预览

```sh
nvim -u scripts/preview.lua
```

开发与截图方法见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可

[MIT](LICENSE)
