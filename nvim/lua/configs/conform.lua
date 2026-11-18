local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_organize_imports", "ruff_format" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    markdown = { "prettier" },
  },

  -- Format on save for code. Markdown is left alone (format it on purpose with <leader>fm).
  -- :FormatToggle turns it off/on for the session; :FormatToggle! for just this buffer.
  format_on_save = function(buf)
    if vim.g.disable_autoformat or vim.b[buf].disable_autoformat or vim.bo[buf].filetype == "markdown" then
      return
    end
    return { timeout_ms = 1000, lsp_format = "fallback" }
  end,
}

vim.api.nvim_create_user_command("FormatToggle", function(args)
  if args.bang then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    vim.notify("Format on save (this buffer): " .. (vim.b.disable_autoformat and "off" or "on"))
  else
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    vim.notify("Format on save: " .. (vim.g.disable_autoformat and "off" or "on"))
  end
end, { bang = true, desc = "Toggle format on save" })

return options
