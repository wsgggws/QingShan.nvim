-- 青山入墨: mountain teal, warm paper, and restrained mineral pigments.
local M = {}

local colors = {
  bg = "#203237",
  bg_dark = "#1A292D",
  bg_float = "#26383E",
  bg_highlight = "#293D42",
  bg_visual = "#3C5962",
  bg_search = "#4A6260",
  fg = "#DEE7DF",
  fg_dim = "#AFBFBA",
  -- Nearly neutral stone gray separates prose from colored syntax.
  comment = "#A7A6A3",
  line_nr = "#6B8387",
  border = "#56767C",
  keyword = "#96C3A2",
  bamboo = "#AAC39A",
  jade = "#94C9CF",
  string = "#C8D5A4",
  gold = "#CCB17E",
  sand = "#D9BF9C",
  red = "#D29580",
  orange = "#C6A080",
  yellow = "#D1B77F",
  blue = "#9DBCCE",
  hint = "#9CB28E",
  diff_add = "#2C4031",
  diff_change = "#2C3F47",
  diff_delete = "#432F2B",
  diff_text = "#3B5864",
  diagnostic_error = "#382F2A",
  diagnostic_warn = "#38392C",
  diagnostic_info = "#28383F",
  diagnostic_hint = "#303C32",
  none = "NONE",
}

---Return an independent palette; customization never changes module defaults.
---@param overrides? table<string, string>
---@return table<string, string>
function M.get(overrides)
  local result = vim.deepcopy(colors)
  for name, value in pairs(overrides or {}) do
    if colors[name] == nil then
      error("qingshan: unknown palette color: " .. tostring(name))
    end
    if type(value) ~= "string" or not value:match("^#%x%x%x%x%x%x$") then
      error("qingshan: palette." .. name .. " must be a #RRGGBB color")
    end
    if name == "none" then
      error("qingshan: palette.none cannot be overridden")
    end
    result[name] = value
  end
  return result
end

---The shared ANSI order used by Neovim and exported terminal themes.
---@param p? table<string, string>
---@return string[]
function M.terminal(p)
  p = p or M.get()
  return {
    p.bg_dark,
    p.red,
    p.bamboo,
    p.gold,
    p.blue,
    p.sand,
    p.jade,
    p.fg_dim,
    p.line_nr,
    p.red,
    p.string,
    p.yellow,
    p.blue,
    p.sand,
    p.jade,
    p.fg,
  }
end

return M
