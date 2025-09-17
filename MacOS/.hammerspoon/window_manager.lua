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

-- Resize window function: sets the window to a specific width and height, expanding from center
function ResizeWindowFromCenter(newWidth, newHeight)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local f = win:frame()

	-- Calculate the center point of the current window
	local centerX = f.x + f.w / 2
	local centerY = f.y + f.h / 2

	-- Set new dimensions and position to keep the window centered
	f.x = centerX - newWidth / 2
	f.y = centerY - newHeight / 2
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

-- NOTE: Larger movements (A, D, W, S)
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
	ResizeWindowFromCenter(1800, 1125) -- Macbook 14" Screen
end)
hs.hotkey.bind({ "alt", "ctrl" }, "r", function()
	ResizeWindowFromCenter(1375, 1085)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "b", function() -- Match the height of the macbook screen but smaller
	ResizeWindowFromCenter(1492, 1125)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "f", function() -- Good finder window size (smaller than macbook screen size)
	ResizeWindowFromCenter(1114, 727)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "e", function() -- Good squarish size for mini-arc
	ResizeWindowFromCenter(1326, 1000)
end)

-- Widescreen full screen is: 3440w x 1415h
hs.hotkey.bind({ "alt", "ctrl" }, "i", function() -- Even gaps on top and bottom (15)
	ResizeWindowFromCenter(1955, 1385)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "u", function() -- Even gaps on top and bottom (15)
	ResizeWindowFromCenter(1440, 1385)
end)
hs.hotkey.bind({ "alt", "ctrl" }, "y", function() -- Even gaps on top and bottom (15) BUT wider than the preset
	ResizeWindowFromCenter(2545, 1385)
end)

-- Bind a key to print the size of the current selected window
hs.hotkey.bind({ "alt", "ctrl" }, "p", function()
	PrintWindowSize()
end)
