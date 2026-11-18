return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- format on save (see configs/conform.lua; :FormatToggle turns it off)
    opts = require "configs.conform",
  },

  -- Markdown, rendered right in the buffer: headings, tables, code blocks, checkboxes, links.
  -- Raw text comes back on the line under the cursor and in insert mode. <leader>mr toggles.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      completions = { lsp = { enabled = true } },
      heading = { sign = false, width = "block", left_pad = 1, right_pad = 2 },
      code = { sign = false, width = "block", left_pad = 2, right_pad = 2, border = "thick" },
      pipe_table = { preset = "round" },
      checkbox = { custom = { todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" } } },
    },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Seamless Ctrl+h/j/k/l between nvim splits and tmux panes (pairs with the tmux plugin)
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "luadoc", "vimdoc", "printf",
        "python", "bash", "json", "yaml", "toml",
        "markdown", "markdown_inline",
        "html", "css", "javascript", "typescript", "tsx",
        "sql", "dockerfile", "gitignore", "regex",
        "diff", "gitcommit", "git_rebase", "make", "csv", "xml", "latex",
      },
    },
  },
}
