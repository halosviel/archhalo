--[[
    hyprland.lua
    author: @halosviel
    created: 2026 June 14
--]]

--# Version Check

local EXPECTED_VERSION = "0.55.4"
local NTF_FAIL_LIFETIME = 6000

local function iconSad()
	local handle = io.popen("ls /home/halosviel/Local/Rice/Icons/Sad/*.png | shuf -n 1")
	local icon = handle:read("*l")
	handle:close()
	return icon
end

if hl.version() ~= EXPECTED_VERSION then
	local exclamations = string.rep("!", math.random(1, 3))
	hl.dispatch(hl.dsp.exec_cmd(
		string.format(
			"notify-send 'Outdated version%s' 'You are running an outdated version of Hyprland! Check the Wiki for the latest version.' -i '%s' -t %d",
			exclamations,
			iconSad(),
			NTF_FAIL_LIFETIME
		)
	))
end

--# Requires

require("modules.system")
require("modules.priority")
require("modules.binds")
require("modules.rules")
require("modules.init")
require("modules.cats")
