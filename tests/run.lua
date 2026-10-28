-- Run from the repository root: nvim --headless -u NONE -l tests/run.lua
local root = vim.fn.getcwd()
vim.opt.runtimepath:prepend(root)

local count = 0
local function check(condition, message)
  assert(condition, message)
  count = count + 1
end

local function hl(name, resolve)
  return vim.api.nvim_get_hl(0, { name = name, link = not resolve })
end

local function rgb(hex)
  return tonumber(hex:sub(2), 16)
end

local function luminance(hex)
  local channels = {}
  for index = 2, 6, 2 do
    local channel = tonumber(hex:sub(index, index + 1), 16) / 255
    channels[#channels + 1] = channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * channels[1] + 0.7152 * channels[2] + 0.0722 * channels[3]
end

local function contrast(a, b)
  local x, y = luminance(a), luminance(b)
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05)
end

local function run()
  check(vim.fn.has("nvim-0.10") == 1, "Neovim 0.10+ is required")
  for _, directory in ipairs({ "lua", "colors", "tests", "scripts", "examples" }) do
    for _, file in ipairs(vim.fn.glob(root .. "/" .. directory .. "/**/*.lua", false, true)) do
      local chunk, err = loadfile(file)
      check(chunk ~= nil, file .. ": " .. tostring(err))
    end
  end

  local theme = require("qingshan")
  local palette = require("qingshan.palette")
  local p = palette.get()
  check(vim.fn.exists(":QingShan") == 0, "loading modules must not add commands")
  vim.o.background = "light"
  vim.o.termguicolors = false
  vim.cmd.colorscheme("qingshan")
  check(vim.g.colors_name == "qingshan", "standard colorscheme entry point")
  check(vim.o.background == "dark", "dark background")
  check(vim.o.termguicolors, "true colors enabled")
  check(hl("Normal").bg == rgb(p.bg), "Normal background")
  check(hl("Normal").fg == rgb(p.fg), "Normal foreground")
  check(hl("Comment").italic, "quiet italic comments")
  check(hl("Keyword", true).bold, "keyword emphasis survives links")
  check(hl("DiagnosticUnderlineError").undercurl, "diagnostic underline")
  check(hl("DiagnosticUnderlineError").sp == rgb(p.red), "diagnostic underline color")
  check(hl("DiagnosticDeprecated").strikethrough, "deprecated text has a non-color cue")
  check(hl("@lsp.mod.deprecated").fg == nil, "deprecated modifier preserves syntax color")
  check(hl("@markup.strong").bold and hl("@markup.strong").fg == nil, "markup composes with syntax")
  check(hl("Visual").fg == rgb(p.fg), "selection maintains text contrast")

  -- Resolve every highlighting layer: semantic tokens must keep the same hierarchy.
  for _, name in ipairs({ "Comment", "@comment", "@comment.documentation", "@lsp.type.comment" }) do
    local value = hl(name, true)
    check(value.fg == rgb(p.comment) and value.italic and not value.bold, "comment hierarchy: " .. name)
  end
  for _, name in ipairs({ "Identifier", "@variable", "@variable.member", "@lsp.type.variable", "@lsp.type.property" }) do
    local value = hl(name, true)
    check(value.fg == rgb(p.fg) and not value.italic and not value.bold, "variable hierarchy: " .. name)
  end
  for _, name in ipairs({ "Keyword", "@keyword", "@keyword.return", "@lsp.type.keyword" }) do
    local value = hl(name, true)
    check(value.fg == rgb(p.keyword) and value.bold and not value.italic, "keyword hierarchy: " .. name)
  end
  for _, name in ipairs({ "@parameter", "@variable.parameter", "@lsp.type.parameter" }) do
    check(hl(name, true).fg == rgb(p.sand), "parameter hierarchy: " .. name)
  end
  -- Comments stay readable and warm-neutral even when italics are unavailable.
  local function channel(color, index)
    return tonumber(color:sub(index, index + 1), 16)
  end
  check(channel(p.comment, 2) > channel(p.comment, 4), "comments use a warm neutral rather than syntax green")
  check(channel(p.keyword, 4) > channel(p.keyword, 2), "keywords retain a green accent")
  check(contrast(p.fg, p.comment) >= 1.9, "variables remain visibly brighter than comments")
  check(contrast(p.keyword, p.comment) >= 1.2, "keywords stand apart from comments without font styles")

  local groups = require("qingshan.theme").get(p, {
    transparent = false,
    dim_inactive = false,
    styles = { comments = { italic = true }, keywords = { bold = true }, functions = {}, variables = {} },
  })
  for name in pairs(groups) do
    check(next(hl(name)) ~= nil, "missing highlight: " .. name)
    local seen, cursor = {}, name
    while groups[cursor] and groups[cursor].link do
      check(not seen[cursor], "highlight link cycle: " .. cursor)
      seen[cursor] = true
      cursor = groups[cursor].link
    end
    check(groups[cursor] ~= nil, "undefined link target for " .. name .. ": " .. cursor)
  end
  for _, name in ipairs({
    "TelescopeSelection",
    "CmpItemKindFunction",
    "BlinkCmpMenuSelection",
    "NeoTreeDirectoryName",
    "NvimTreeRootFolder",
    "WhichKey",
    "GitSignsChange",
    "@lsp.type.function",
    "@function.method.call",
    "PmenuMatch",
    "LspInlayHint",
  }) do
    check(hl(name, true).fg ~= nil, "plugin/syntax group resolves: " .. name)
  end
  check(hl("@lsp.type.function", true).fg == rgb(p.jade), "LSP and syntax share function color")

  local before = vim.api.nvim_get_hl(0, {})
  vim.cmd.colorscheme("qingshan")
  check(vim.deep_equal(before, vim.api.nvim_get_hl(0, {})), "repeat load is deterministic")
  vim.cmd.colorscheme("default")
  vim.cmd.colorscheme("qingshan")
  check(hl("Normal").bg == rgb(p.bg), "switching themes restores the palette")
  vim.cmd("syntax on")
  vim.cmd.colorscheme("qingshan")
  check(hl("String", true).fg == rgb(p.string), "syntax reset preserves theme definitions")

  local terminal_roles = {
    "bg_dark",
    "red",
    "bamboo",
    "gold",
    "blue",
    "sand",
    "jade",
    "fg_dim",
    "line_nr",
    "red",
    "string",
    "yellow",
    "blue",
    "sand",
    "jade",
    "fg",
  }
  for index, role in ipairs(terminal_roles) do
    check(vim.g["terminal_color_" .. (index - 1)] == p[role], "ANSI slot " .. (index - 1))
  end
  vim.g.terminal_color_1 = "#123456"
  theme.setup({ terminal_colors = false })
  vim.cmd.colorscheme("qingshan")
  check(vim.g.terminal_color_1 == "#123456", "disabled terminal palette preserves existing globals")

  theme.setup({ transparent = true, dim_inactive = true, styles = { comments = { italic = false } } })
  vim.cmd.colorscheme("qingshan")
  for _, name in ipairs({ "Normal", "NormalNC", "SignColumn", "FoldColumn", "NeoTreeNormal", "NvimTreeNormal" }) do
    check(hl(name, true).bg == nil, "transparent surface: " .. name)
  end
  check(hl("NormalFloat").bg == rgb(p.bg_float), "transparent mode keeps popups readable")
  check(not hl("Comment").italic, "italic comments can be disabled")
  check(
    hl("@lsp.type.comment", true).fg ~= hl("@lsp.type.keyword", true).fg,
    "comments remain distinct without italics"
  )
  theme.setup({ styles = { variables = { underline = true } } })
  vim.cmd.colorscheme("qingshan")
  check(
    hl("@variable", true).underline and hl("@lsp.type.parameter", true).underline,
    "variable styles include parameters"
  )
  theme.setup({ dim_inactive = true })
  vim.cmd.colorscheme("qingshan")
  check(hl("NormalNC").bg == rgb(p.bg_dark), "inactive window dimming")

  theme.setup({
    palette = { jade = "#BBDDCB" },
    highlights = function(colors)
      check(colors.jade == "#BBDDCB", "callback receives customized palette")
      colors.bg = "#000000"
      return {
        Comment = { link = "Function" },
        Function = { fg = colors.jade, bold = true },
        QingShanUserGroup = { fg = colors.gold },
        QingShanDefaultGroup = { link = "Function", default = true },
      }
    end,
  })
  vim.cmd.colorscheme("qingshan")
  check(hl("Comment").link == "Function" and hl("Comment").italic == nil, "links replace whole definitions")
  check(hl("@lsp.type.function", true).fg == rgb("#BBDDCB"), "palette overrides propagate through links")
  check(hl("Normal").bg == rgb(p.bg), "callback palette is isolated")
  check(hl("QingShanUserGroup").fg == rgb(p.gold), "custom groups")
  check(hl("QingShanDefaultGroup").link == "Function", "default link applies to undefined groups")
  vim.api.nvim_set_hl(0, "QingShanDefaultGroup", { link = "Error", default = true })
  check(hl("QingShanDefaultGroup").link == "Function", "default links preserve existing definitions")

  local customized = palette.get({ bg = "#112233" })
  customized.string = "#000000"
  check(palette.get().bg == p.bg and palette.get().string == p.string, "palette copies are independent")
  local caller_options = { palette = { jade = "#BBDDCB" }, highlights = { Normal = { fg = "#CCDDEE" } } }
  theme.setup(caller_options)
  caller_options.highlights.Normal.fg = "#000000"
  caller_options.palette.jade = "#000000"
  vim.cmd.colorscheme("qingshan")
  check(hl("Normal").fg == rgb("#CCDDEE"), "setup copies caller highlight tables")
  check(hl("Function").fg == rgb("#BBDDCB"), "setup copies caller palette tables")

  for _, invalid in ipairs({
    false,
    "invalid",
    { transparent = "yes" },
    { palette = { typo = "#112233" } },
    { palette = { fg = "green" } },
    { styles = { comments = { italic = "yes" } } },
    { styles = { comment = {} } },
    { highlights = false },
    { unknown = true },
  }) do
    check(not pcall(theme.setup, invalid), "invalid options must be rejected")
  end
  theme.setup({
    highlights = function()
      return nil
    end,
  })
  local old_normal = hl("Normal")
  check(not pcall(theme.load), "invalid callback return must fail")
  check(vim.deep_equal(old_normal, hl("Normal")), "callback failure preserves the current theme")
  theme.setup()
  vim.cmd.colorscheme("qingshan")
  check(hl("Comment").italic and not hl("Function").bold, "setup resets previous configuration")
  check(hl("Normal").bg == rgb(p.bg), "setup restores opaque defaults")

  -- WCAG relative luminance is a useful guardrail, not a claim of full UI compliance.
  for _, role in ipairs({
    "fg",
    "fg_dim",
    "comment",
    "keyword",
    "bamboo",
    "jade",
    "string",
    "gold",
    "sand",
    "red",
    "yellow",
    "blue",
    "hint",
  }) do
    for _, surface in ipairs({ "bg", "bg_float", "bg_highlight" }) do
      check(contrast(p[role], p[surface]) >= 4.5, role .. " contrast against " .. surface)
    end
  end
  check(contrast(p.fg, p.bg_visual) >= 4.5, "selected text contrast")
  check(contrast(p.fg, p.bg_search) >= 4.5, "search text contrast")
  check(contrast(p.bg_dark, p.yellow) >= 4.5, "current search text contrast")
  check(contrast(p.bg_dark, p.jade) >= 4.5, "terminal selection text contrast")
  io.stdout:write(string.format("QingShan: %d checks passed on %s\n", count, vim.version()))
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end
