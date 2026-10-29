# 贡献与维护

感谢共同打磨青山入墨。设计目标是长期阅读代码时的清晰与安静：低饱和青绿背景、可辨的注释与语法层级、少量古金与朱砂。色彩调整应同时检查普通代码、文档注释、诊断、选区和 diff。

## 环境

- Neovim 0.10+；CI 覆盖 0.10.4、stable、nightly。
- Python 3.10+：配色导出与原生主题测试，无第三方 Python 依赖。
- StyLua、Ruff：Lua 与 Python 格式检查。
- 可选 `uv`：为截图脚本安装隔离依赖。

## 色板与导出

1. 在 `lua/qingshan/palette.lua` 修改命名颜色，在 `lua/qingshan/theme.lua` 修改角色与链接。默认高亮与用户配置 API 分别由 `theme.lua` 和 `init.lua` 管理。
2. 修改跨工具映射时编辑 `scripts/export.py`，运行 `python3 scripts/export.py`。`extras/` 下的主题文件与 `palette.json` 随源码一同提交，便于单独导入。README 色块由同一命令生成到 `assets/swatches/`，随色板更新。
3. 执行下方检查，再用 `nvim -u scripts/preview.lua` 观察实际效果。运行 `uv run scripts/screenshot.py` 更新 `assets/qingshan.png`，查看图片确认没有文字裁切、错误高亮或色板漂移。
4. 更新 README 中的颜色、语义映射和 CHANGELOG；`python3 scripts/export.py --check` 应无差异。

注释使用暖灰以区别青绿关键字，变量使用更明亮的宣纸色。不要以降低注释可读性换取层级。`tests/run.lua` 对默认主要文字执行相对亮度对比度检查，这只是配色约束，不代表完整无障碍认证。

原生语法未必识别参数；Treesitter/LSP 识别时将其链接到 `QingShanParameter`。bat 按 `variable.parameter` scope 处理；slides 的 Chroma token 不提供独立参数角色时使用普通变量色。保持各工具在其能力范围内语义一致。

Alfred 的 UUID 根据固定 seed 生成。seed 中的旧小写仓库名属于已安装主题的持久身份，改名不会改变该 seed。`QingShan Dark Large` 是 Alfred 的显示名与原生文件名，Neovim、WezTerm、bat 的名称继续使用原约定。

## 验证

从仓库根目录执行；`python3` 必须为 3.10+，系统版本较旧时替换为实际新版命令。

```sh
nvim --headless -u NONE -l tests/run.lua
nvim --headless -u scripts/preview.lua -c 'luafile tests/preview.lua'
python3 scripts/export.py --check
python3 -m unittest discover -s tests -p 'test_*.py' -v
stylua --check lua colors tests scripts examples
ruff check scripts/export.py tests/test_exports.py
ruff format --check scripts/export.py tests/test_exports.py
```

Lua 检查覆盖解析、加载、重载、链接、选项隔离和文字对比度。Python 测试验证原生文件与色板一致、注释与语法层级可辨、终端选区独立以及各端背景一致；检查只读取仓库和临时数据。

修改原生格式后，可按改动范围验证 bat 主题解析、delta 配色和 Alfred 原生外观。导入步骤见 `extras/README.md`。报告实际运行过的验证，不将高亮定义检查描述为完整的应用端到端测试。

## 项目边界

主题仓库只分发高亮、配色数据与相关开发工具。个人账户的切换函数、安装器、应用自动化、tmux 交互选择器及其测试在各自配置目录维护。原生导出仅写入仓库 `extras/`；主题加载不修改个人 shell 或应用配置。

## 发布检查

- 完整检查通过，实际截图与默认色板一致，生成文件无漂移。
- 安装示例填写真实仓库地址；检查大小写敏感文件系统上的路径和 Lua 加载。
- 将 `CHANGELOG.md` 的待发布项整理成真实版本与日期，确认 MIT 许可完整。
- 人工确认实际插件与工具的显示效果；当前自动测试不宣称完整的插件端到端覆盖。
- 版本标签、推送或公开发布由维护者明确决定；准备文件不会自动发布。

## 截图

`uv run scripts/screenshot.py` 捕获 Neovim 的真实 UI 网格并生成 `assets/qingshan.png`。预览中的诊断与 Git 标记为演示数据。脚本自动寻找常见等宽与中文字体，也可指定：

```sh
uv run scripts/screenshot.py --font /path/to/monospace.ttf --cjk-font /path/to/chinese.ttc
```
