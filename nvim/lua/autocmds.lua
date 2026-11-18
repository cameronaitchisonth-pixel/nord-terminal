require "nvchad.autocmds"

-- Follow the system light/dark mode: `nord-term` sends SIGUSR1 when it changes
vim.api.nvim_create_autocmd("Signal", {
  pattern = "SIGUSR1",
  callback = function()
    vim.schedule(require("nordmode").apply)
  end,
})
