--[[
    hyprland.lua
    author: @halosviel
    created: 2026 June 14
--]]

local EXPECTED_VERSION = "0.55.4"

if hl.version() ~= EXPECTED_VERSION then
  hl.notification.create({
    text = "Hyprland version mismatch! Running " .. hl.version() .. ", expected " .. EXPECTED_VERSION,
    timeout = 17000
  })
end

require("modules.system")
require("modules.priority")
require("modules.binds")
require("modules.rules")
require("modules.init")
require("modules.cats")
