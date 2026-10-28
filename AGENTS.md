# QingShan.nvim 维护约定

- 仓库名为 `QingShan.nvim`，模块与 colorscheme 为 `qingshan`；兼容 Neovim 0.10+。
- 颜色只定义在 `lua/qingshan/palette.lua`，高亮与链接在 `theme.lua`，公开选项在 `init.lua`。
- 保持暖灰注释、明亮变量、竹青关键字的层级；默认正文在普通、浮层、当前行背景上的对比度至少 4.5:1。
- 基础语法、Treesitter、LSP 使用一致角色；链接有目标且无循环，加载可重复且不依赖插件。
- 修改色板或原生格式时，按 [CONTRIBUTING.md](CONTRIBUTING.md) 重新导出并检查所有工具的语义与背景一致性；`extras/` 除 README 外均为生成文件。Alfred UUID seed 保持稳定。
- 修改公开行为时同步 README 与 `doc/qingshan.txt`；导入说明位于 [extras/README.md](extras/README.md)。
- 本仓库维护主题与配色导出；个人安装、切换、缓存刷新及应用交互脚本归对应配置目录。工具导入与同名主题更新的重载方法写入 `extras/README.md`。

完成修改前运行相关加载、导出与格式检查，流程见 CONTRIBUTING。配色变更需检查实际预览并更新截图；文档修改无需重建截图。报告已执行的检查与未验证范围。
