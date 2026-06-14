--[=[
	[INFO]
	author: @halosviel
	created: 2026 June 14

	[DESCRIPTION]
	Contains all float rules, along with the floating class definition.
]=]

--# ───────────────────────────
--# rules
--# ───────────────────────────

hl.window_rule({
  match = {
    title = "floating"
  },
  float = true
})


--# ───────────────────────────
--# apps
--# ───────────────────────────

hl.window_rule({
  match = {
    class = "kitty"
  },
  float = true,
	center = true,
	size = { 700, 450 }
})

hl.window_rule({
  match = {
    class = "org.gnome.Nautilus"
  },
  float = true,
	center = true,
	size = { 900, 550 }
})

hl.window_rule({
  match = {
    class = "imv"
  },
  float = true,
	center = true,
	size = { 800, 500 }
})

hl.window_rule({
  match = {
    class = "mpv"
  },
  float = true,
	center = true,
	size = { 1192, 671 }
})


--# ───────────────────────────
--# popups
--# ───────────────────────────

hl.window_rule({
  match = {
    class = "hyprland-share-picker"
  },
  float = true,
	center = true,
	size = { 500, 300 }
})

