
--[=[
	[INFO]
	author: @halosviel
	created: 2026 June 14

	[DESCRIPTION]
	A general place that aims to centralise all unique Hyprland
	things.

	Runs after system.lua.
]=]


hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start ags.service")
end)
