
--[=[
	[INFO]
	author: @halosviel
	created: 2026 June 14

	[DESCRIPTION]

]=]

--[[
	"Cats" is short for categories (variables).
	See: https://wiki.hypr.land/Configuring/Basics/Variables/#syntax
]]

--# ───────────────────────────
--# variables
--# ───────────────────────────

hl.config({
	general = {
  	resize_on_border = true,
  	gaps_out = { top = 9, left = 16, right = 16, bottom = 16 },
		gaps_workspaces = -16,
		locale = "en_US",
		allow_tearing = true
	},

	decoration = {
  	rounding = 8,
		active_opacity = 1,
		inactive_opacity = 0.9,
	},

	input = {
		repeat_delay = 200,
  	repeat_rate = 40,

  	natural_scroll = true,
  	scroll_factor = 0.8,
  	mouse_refocus = false
	},

	misc = {
		disable_splash_rendering = true,
		vrr = 0,
		middle_click_paste = false,
	},
})


--# ───────────────────────────
--# animations
--# ───────────────────────────

--# still counting these as variables (they used to be).

hl.curve("workspaceAnims", { type = "spring", mass = 2.2, stiffness = 80, dampening = 25 })
hl.curve("windowAnims", { type = "spring", mass = 3, stiffness = 100, dampening = 25 })

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 6,
	spring = "workspaceAnims"
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 6,
	spring = "windowAnims"
})
