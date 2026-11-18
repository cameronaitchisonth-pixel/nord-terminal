-- Markdown: comfortable writing and reading
local opt = vim.opt_local
opt.wrap = true -- soft-wrap long lines at word boundaries, indented under their bullet
opt.linebreak = true
opt.breakindent = true
opt.spell = true -- z= suggests fixes, zg adds a word to the dictionary
opt.spelllang = "en_us"
opt.textwidth = 0

local map = function(lhs, rhs, desc, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = true, desc = desc })
end

-- Move by screen line on wrapped text (counts like 5j still jump real lines)
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { buffer = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { buffer = true, expr = true })

map("<leader>mr", "<cmd>RenderMarkdown toggle<cr>", "markdown toggle rendering")
map("<leader>mp", function() require("mdpreview").toggle() end, "markdown browser preview")

-- Toggle a task checkbox: "- [ ]" <-> "- [x]"; turns a plain list item into a task
map("<leader>mx", function()
  local line = vim.api.nvim_get_current_line()
  local new
  if line:match "%[ %]" then
    new = line:gsub("%[ %]", "[x]", 1)
  elseif line:match "%[[xX]%]" then
    new = line:gsub("%[[xX]%]", "[ ]", 1)
  else
    new = line:gsub("^(%s*[-*+] )", "%1[ ] ", 1)
  end
  vim.api.nvim_set_current_line(new)
end, "markdown toggle checkbox")

-- Browser preview (live, follows light/dark) and HTML export; see lua/mdpreview.lua
map("<leader>me", function() require("mdpreview").export() end, "markdown export to HTML")
