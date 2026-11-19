-- Nord tablet buttons for Xournal++.
-- OpenTabletDriver turns tablet button 1..8 (top to bottom) into Ctrl+Alt+Shift + U I O J K L M N,
-- chosen so nothing else on the desktop uses them. Change what a button does here; rebind the
-- buttons themselves in OpenTabletDriver (otd-gui).
--
--   1-3  first three colors of the toolbar palette (1 = black on a light page, white on a dark page)
--   4    next color
--   5    undo
--   6/7  zoom in / zoom out
--   8    line tool (press again for freehand)

local current = 0   -- palette position of the last color a button picked

local function palette()
  local p = app.getColorPalette()
  if p and #p > 0 then return p end
end

-- Colors only apply to the pen, highlighter and text tools; from any other tool, switch to the pen
local function ensureColorTool()
  local ok, info = pcall(app.getToolInfo, "active")
  local t = ok and info and info.type or ""
  if t ~= "pen" and t ~= "highlighter" and t ~= "text" then
    app.activateAction("select-tool", app.C.Tool_pen)
  end
end

-- Is the current page light? (Its background color's brightness; dark if it can't be read.)
local function lightPage()
  local ok, doc = pcall(app.getDocumentStructure)
  local page = ok and doc and doc.pages and doc.pages[doc.currentPage]
  local c = page and page.backgroundColor
  if not c then return false end
  local r, g, b = (c >> 16) & 0xff, (c >> 8) & 0xff, c & 0xff
  return 0.2126 * r + 0.7152 * g + 0.0722 * b > 128
end

local NORD_BLACK, NORD_WHITE = 0x2e3440, 0xeceff4

local function pickColor(i)
  local p = palette()
  if not p then return end
  current = (i - 1) % #p + 1
  -- Color 1 is "ink": Polar Night black on a light page, Snow Storm white on a dark page
  local color = p[current].color
  if current == 1 then color = lightPage() and NORD_BLACK or NORD_WHITE end
  ensureColorTool()
  app.changeToolColor({ color = color, selection = true })
end

local lineOn = false
local function toggleLine()
  local ok, info = pcall(app.getToolInfo, "active")
  if ok and info then
    if info.type ~= "pen" and info.type ~= "highlighter" then
      app.activateAction("select-tool", app.C.Tool_pen)
      info.drawingType = nil
    end
    lineOn = info.drawingType ~= "line"
  else
    lineOn = not lineOn
  end
  app.changeActionState("tool-draw-line", lineOn)
end

local buttons = {
  { key = "u", menu = "Tablet 1: color 1",    run = function() pickColor(1) end },
  { key = "i", menu = "Tablet 2: color 2",    run = function() pickColor(2) end },
  { key = "o", menu = "Tablet 3: color 3",    run = function() pickColor(3) end },
  { key = "j", menu = "Tablet 4: next color", run = function() pickColor(current + 1) end },
  { key = "k", menu = "Tablet 5: undo",       run = function() app.activateAction("undo") end },
  { key = "l", menu = "Tablet 6: zoom in",    run = function() app.activateAction("zoom-in") end },
  { key = "m", menu = "Tablet 7: zoom out",   run = function() app.activateAction("zoom-out") end },
  { key = "n", menu = "Tablet 8: line tool",  run = toggleLine },
}

function initUi()
  for i, b in ipairs(buttons) do
    _G["tabletButton" .. i] = b.run
    app.registerUi({ menu = b.menu, callback = "tabletButton" .. i, accelerator = "<Control><Alt><Shift>" .. b.key })
  end
  -- Light/dark page: opens the page color picker, whose first two swatches are Nord Snow Storm
  -- (light) and Polar Night (dark); double-click one. Toolbar button + Ctrl+Alt+Shift+B.
  app.registerUi({ menu = "Page color (Nord light/dark)", callback = "nordPageColor",
                   accelerator = "<Control><Alt><Shift>b", toolbarId = "NORD_PAGE_COLOR",
                   iconName = "display-brightness-symbolic" })
end

function nordPageColor()
  app.activateAction("paper-background-color")
end
