
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
  	gaps_out = { top = 10, left = 16, right = 16, bottom = 16 },
		gaps_workspaces = -16,
		locale = "en_US"
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
  	exit_window_retains_fullscreen = true
	},
})


--# ───────────────────────────
--# animations
--# ───────────────────────────

--# still counting these as variables (they used to be).

hl.curve("custom", { type = "spring", mass = 1, stiffness = 100, dampening = 30 })

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 6,
	spring = "custom"
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 3,
	spring = "custom"
})
