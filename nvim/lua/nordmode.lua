-- Keeps the NvChad theme in sync with the system light/dark mode.
-- `nord-term` (~/.local/bin) sends SIGUSR1 to running nvim instances when the mode changes.
local M = {}

M.themes = { dark = "nord", light = "onenord_light" }

local marker = vim.fn.stdpath "data" .. "/base46/.nordmode-theme"

-- Ask nord-term (it knows GNOME, macOS and its own state file); dark if it isn't installed.
function M.mode()
  local cmd = vim.fn.exepath "nord-term"
  if cmd == "" then
    cmd = vim.fn.expand "~/.local/bin/nord-term"
  end
  if vim.fn.executable(cmd) ~= 1 then
    return "dark"
  end
  local out = vim.fn.system { cmd, "status" }
  if vim.v.shell_error ~= 0 then
    return "dark"
  end
  return out:find "light" and "light" or "dark"
end

function M.theme()
  return M.themes[M.mode()]
end

local function read_marker()
  local f = io.open(marker, "r")
  if not f then
    return nil
  end
  local s = f:read "*l"
  f:close()
  return s
end

local function write_marker(theme)
  local f = io.open(marker, "w")
  if f then
    f:write(theme)
    f:close()
  end
end

-- Called at startup, before the base46 cache is loaded: recompile if the mode changed while nvim was closed.
function M.ensure_cache()
  local theme = require("nvconfig").base46.theme
  if read_marker() ~= theme or not vim.uv.fs_stat(vim.g.base46_cache .. "defaults") then
    require("base46").compile()
    write_marker(theme)
  end
end

-- Switch a running editor to the current system mode.
function M.apply()
  local theme = M.theme()
  local cfg = require("nvconfig").base46
  if cfg.theme == theme then
    return
  end
  cfg.theme = theme
  require("base46").load_all_highlights()
  write_marker(theme)
end

return M
