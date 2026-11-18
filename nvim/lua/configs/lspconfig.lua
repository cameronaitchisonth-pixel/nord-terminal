require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "pyright",
  "ruff",
  "bashls",
  "jsonls",
  "yamlls",
  "ts_ls",
  "marksman", -- markdown: links, headings, [[wiki links]], table of contents
}
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
