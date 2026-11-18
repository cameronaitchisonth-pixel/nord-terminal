require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Navigate between nvim splits and tmux panes (vim-tmux-navigator)
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "window left (tmux-aware)" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "window down (tmux-aware)" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "window up (tmux-aware)" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "window right (tmux-aware)" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
