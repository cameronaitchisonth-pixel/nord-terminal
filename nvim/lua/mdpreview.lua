-- Markdown browser preview and HTML export, built with pandoc (no plugin, nothing downloaded).
--
-- Preview: renders the buffer to an HTML page that reloads itself every second, re-rendered as you
-- type (no need to save). The page follows the system light/dark mode. With the Firefox snap it
-- lives under ~/snap/firefox/common, because the snap can't read hidden folders like ~/.cache.
-- Export: a standalone light HTML file next to the .md (print it to PDF from the browser).
local M = {}

local pandoc = vim.fn.exepath "pandoc" ~= "" and vim.fn.exepath "pandoc" or "pandoc"
local dir = vim.fn.stdpath "config" .. "/export"
local preview_dir = vim.fn.isdirectory(vim.env.HOME .. "/snap/firefox/common") == 1
    and vim.env.HOME .. "/snap/firefox/common/md-preview"
  or vim.fn.stdpath "cache" .. "/md-preview"

local function render(buf, out, extra, on_done)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t:r")
  local args = {
    pandoc, "-f", "gfm+tex_math_dollars", "-t", "html5", "-o", out .. ".part", "--standalone", "--embed-resources",
    "--css", dir .. "/markdown.css", "--metadata", "pagetitle=" .. (name ~= "" and name or "preview"),
    "--highlight-style", "tango",
    -- relative image links resolve from the .md file's folder
    "--resource-path", vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:h"),
  }
  vim.list_extend(args, extra or {})
  vim.system(args, { stdin = table.concat(lines, "\n"), text = true }, vim.schedule_wrap(function(r)
    if r.code ~= 0 then
      os.remove(out .. ".part")
      vim.notify("pandoc failed:\n" .. r.stderr, vim.log.levels.ERROR)
      return
    end
    -- swap in whole, so the self-reloading preview never sees a half-written page
    os.rename(out .. ".part", out)
    if on_done then
      on_done(out)
    end
  end))
end

-- buf -> { out = path, timer = uv timer }
local previews = {}

function M.toggle()
  local buf = vim.api.nvim_get_current_buf()
  if previews[buf] then
    M.stop(buf)
    vim.notify "Markdown preview stopped"
    return
  end
  vim.fn.mkdir(preview_dir, "p")
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t:r")
  local out = ("%s/%s-%d.html"):format(preview_dir, name ~= "" and name or "untitled", buf)
  local state = { out = out, timer = vim.uv.new_timer() }
  previews[buf] = state
  local extra = { "--include-in-header", dir .. "/preview-head.html" }

  render(buf, out, extra, function(path)
    vim.ui.open(path)
    vim.notify("Markdown preview: " .. path)
  end)

  -- Re-render 300 ms after the last edit
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
    buffer = buf,
    group = vim.api.nvim_create_augroup("mdpreview_" .. buf, { clear = true }),
    callback = function()
      state.timer:stop()
      state.timer:start(300, 0, vim.schedule_wrap(function()
        if previews[buf] then
          render(buf, out, extra)
        end
      end))
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    group = "mdpreview_" .. buf,
    callback = function()
      M.stop(buf)
    end,
  })
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for buf in pairs(previews) do
      M.stop(buf)
    end
  end,
})

function M.stop(buf)
  local state = previews[buf]
  if not state then
    return
  end
  previews[buf] = nil
  state.timer:stop()
  state.timer:close()
  pcall(vim.api.nvim_del_augroup_by_name, "mdpreview_" .. buf)
  os.remove(state.out)
end

function M.export()
  local buf = vim.api.nvim_get_current_buf()
  local src = vim.api.nvim_buf_get_name(buf)
  if src == "" then
    vim.notify("Save the file first", vim.log.levels.WARN)
    return
  end
  render(buf, vim.fn.fnamemodify(src, ":p:r") .. ".html", nil, function(out)
    vim.notify("Exported " .. out)
    vim.ui.open(out)
  end)
end

return M
