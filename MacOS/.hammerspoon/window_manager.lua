---@diagnostic disable: undefined-global

-- Move window function
function MoveWindow(xDelta, yDelta)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local f = win:frame()
	f.x = f.x + xDelta
	f.y = f.y + yDelta
	win:setFrame(f)
end

-- Resize window function: sets the window to a specific width and height.
function ResizeWindow(newWidth, newHeight)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local f = win:frame()
	-- Optionally, if you want the window to remain centered, you can adjust x and y as well.
	-- For a simple resize keeping the top-left corner fixed, just update the width and height.
	f.w = newWidth
	f.h = newHeight
	win:setFrame(f)
end

-- Function to print the size of the current selected window.
function PrintWindowSize()
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No focused window")
		return
	end

	local f = win:frame()
	hs.alert.show(f.w .. "w x " .. f.h .. "h")
end

-- Bind keys for moving window
-- NOTE: ARROW KEYS FOR FINER MOVEMENTS
local moveAmt = 15
hs.hotkey.bind({ "alt", "ctrl" }, "left", function()
	MoveWindow(-1 * moveAmt, 0)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "right", function()
	MoveWindow(moveAmt, 0)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "up", function()
	MoveWindow(0, -1 * moveAmt)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "down", function()
	MoveWindow(0, moveAmt)
end)

-- NOTE: YUIO (HJKL shifted up one row) for larger movements
local lgMoveAmt = 45
hs.hotkey.bind({ "alt", "ctrl" }, "a", function()
	MoveWindow(-1 * lgMoveAmt, 0)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "d", function()
	MoveWindow(lgMoveAmt, 0)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "w", function()
	MoveWindow(0, -1 * lgMoveAmt)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "s", function()
	MoveWindow(0, lgMoveAmt)
end)

-- Bind a key to resize the window to a specific size (w, h)
hs.hotkey.bind({ "alt", "ctrl" }, "m", function()
	ResizeWindow(1800, 1125) -- Macbook 14" Screen
end)
hs.hotkey.bind({ "alt", "ctrl" }, "r", function()
	ResizeWindow(1375, 1085)
end)

-- Bind a key to print the size of the current selected window
hs.hotkey.bind({ "alt", "ctrl" }, "p", function()
	PrintWindowSize()
end)
