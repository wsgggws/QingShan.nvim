-- 青山入墨: mineral greens, warm paper, and restrained mineral pigments.
local M = {}

local colors = {
  bg = "#1D3229",
  bg_dark = "#182A22",
  bg_float = "#243B2E",
  bg_highlight = "#293F30",
  bg_visual = "#41634A",
  bg_search = "#536C43",
  fg = "#DCE8D5",
  fg_dim = "#AEC0AB",
  -- Warm stone separates prose from green syntax without sacrificing contrast.
  comment = "#ADA594",
  line_nr = "#6C866E",
  border = "#56785D",
  keyword = "#89C79B",
  bamboo = "#A8C38B",
  jade = "#99CEBE",
  string = "#C6D8A3",
  gold = "#C5AD78",
  sand = "#D7C5A0",
  red = "#D29580",
  orange = "#C6A080",
  yellow = "#D1B77F",
  blue = "#9BBDB5",
  hint = "#A2BC8E",
  diff_add = "#294630",
  diff_change = "#2C423B",
  diff_delete = "#432F2B",
  diff_text = "#3A5B46",
  diagnostic_error = "#382F2A",
  diagnostic_warn = "#38392C",
  diagnostic_info = "#253D32",
  diagnostic_hint = "#2C402D",
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
