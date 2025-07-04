---@diagnostic disable: undefined-global

local hyper = { "cmd", "alt", "ctrl", "shift" }

function AppSwitcher(bundleID)
	hs.application.launchOrFocusByBundleID(bundleID)
end

-- Hide app intead of switching off
function SwitchToAndFromApp(bundleID)
	local focusedWindow = hs.window.focusedWindow()
	local focusedApp = nil
	if focusedWindow then
		focusedApp = focusedWindow:application()
	end

	if not focusedWindow then
		hs.application.launchOrFocusByBundleID(bundleID)
	elseif focusedApp:bundleID() == bundleID then
		focusedApp:hide() -- Hide the currently focused application
	else
		previousApp = focusedApp
		hs.application.launchOrFocusByBundleID(bundleID)
	end
end

-- Bind the function to the hotkey in a lambda to use the enhanced switch function
hs.hotkey.bind(hyper, "A", function()
	SwitchToAndFromApp("company.thebrowser.Browser")
end) -- arc
hs.hotkey.bind(hyper, "B", function()
	SwitchToAndFromApp("com.bitwarden.desktop")
end) -- bitwarden
hs.hotkey.bind(hyper, "C", function()
	SwitchToAndFromApp("com.apple.Safari.WebApp.45DA8B15-A990-4B5A-A00C-C9DDD9CDA921")
end) -- google calendar
hs.hotkey.bind(hyper, "D", function()
	SwitchToAndFromApp("com.hnc.Discord")
end) -- discord
-- hs.hotkey.bind(hyper, "E", function()
-- 	SwitchToAndFromApp("com.apple.mail")
-- end) -- apple mail
hs.hotkey.bind(hyper, "F", function()
	SwitchToAndFromApp("com.apple.finder")
end) -- finder
hs.hotkey.bind(hyper, "G", function()
	SwitchToAndFromApp("com.mitchellh.ghostty")
end) -- ghostty
hs.hotkey.bind(hyper, "I", function()
	SwitchToAndFromApp("company.thebrowser.dia")
end) -- dia
hs.hotkey.bind(hyper, "J", function()
	SwitchToAndFromApp("com.brave.Browser")
end) -- Brave
-- hs.hotkey.bind(hyper, "K", function()
-- 	SwitchToAndFromApp("net.ankiweb.dtop")
-- end) -- anki
hs.hotkey.bind(hyper, "L", function()
	SwitchToAndFromApp("com.tinyspeck.slackmacgap")
end) -- slack
hs.hotkey.bind(hyper, "M", function()
	SwitchToAndFromApp("com.apple.MobileSMS")
end) -- messages
hs.hotkey.bind(hyper, "N", function()
	SwitchToAndFromApp("notion.id")
end) -- notion
hs.hotkey.bind(hyper, "O", function()
	SwitchToAndFromApp("md.obsidian")
end) -- obsidian
hs.hotkey.bind(hyper, "P", function()
	SwitchToAndFromApp("com.apple.iBooksX")
end) -- books
hs.hotkey.bind(hyper, "Q", function()
	SwitchToAndFromApp("com.apple.Notes")
end) -- notes
hs.hotkey.bind(hyper, "R", function()
	SwitchToAndFromApp("com.apple.reminders")
end) -- reminders
hs.hotkey.bind(hyper, "S", function()
	SwitchToAndFromApp("info.sioyek.sioyek")
end) -- sioyek
hs.hotkey.bind(hyper, "U", function()
	SwitchToAndFromApp("com.apple.Music")
end) -- apple music
-- hs.hotkey.bind(hyper, "V", function()
-- 	SwitchToAndFromApp("com.microsoft.VSCode")
-- end) -- vscode
hs.hotkey.bind(hyper, "V", function()
	SwitchToAndFromApp("com.todesktop.230313mzl4w4u92")
end) -- cursor
hs.hotkey.bind(hyper, "X", function()
	SwitchToAndFromApp("com.apple.findmy")
end) -- chat gpt
hs.hotkey.bind(hyper, "Y", function()
	SwitchToAndFromApp("com.openai.chat")
end) -- gpt
hs.hotkey.bind(hyper, "Z", function()
	SwitchToAndFromApp("org.zotero.zotero")
end) -- zotero

-- NOTE: Still have H, I, J, K, N, W available
-- freed E from mail
-- T is used for TOT

-- show the bundleid of the currently open window
hs.hotkey.bind(hyper, "`", function()
	local bundleID = hs.window.focusedWindow():application():bundleID()
	hs.alert.show(bundleID)
	hs.pasteboard.setContents(bundleID)
end)
