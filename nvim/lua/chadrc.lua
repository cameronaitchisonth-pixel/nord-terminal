-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  -- Follows the system light/dark mode (see lua/nordmode.lua). <leader>th still opens the theme picker.
  theme = require("nordmode").theme(),
  theme_toggle = { "nord", "onenord_light" },

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.nvdash = { load_on_startup = true }

M.ui = {
  tabufline = {
    lazyload = false,
  },
}

return M
