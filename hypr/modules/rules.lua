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
--# system apps
--# ───────────────────────────

hl.window_rule({
  match = {
		title = "floating",
    class = "kitty",
  },
	size = { 750, 450 }
})

hl.window_rule({
  match = {
    class = "org.gnome.Nautilus"
  },
  float = true,
	center = true,
	size = { 750, 450 },
	opacity = 0.9
})

--# images
hl.window_rule({
  match = {
    class = "imv"
  },
  float = true,
	center = true,
	size = { 800, 500 }
})

--# videos
hl.window_rule({
  match = {
    class = "mpv"
  },
  float = true,
	center = true,
	size = { 1192, 671 }
})

--# file picker
hl.window_rule({
  match = {
    class = "xdg-desktop-portal-gtk"
  },
  float = true,
	center = true,
	size = { 1000, 600 }
})

--# pavucontrol
hl.window_rule({
  match = {
    class = "org.pulseaudio.pavucontrol"
  },
  float = true,
	center = true,
	size = { 1000, 700 }
})

hl.window_rule({
  match = {
    class = "com.github.tchx84.Flatseal"
  },
  float = true,
	center = true,
	size = { 1000, 60 }
})

hl.window_rule({
  match = {
    class = "nwg-look"
  },
  float = true,
	center = true,
	size = { 800, 500 }
})

--# w8 btop
hl.window_rule({
  match = {
    title = "init_btop"
  },
	workspace = 8
})


--# ───────────────────────────
--# user apps
--# ───────────────────────────

hl.window_rule({
  match = {
    class = "firefox"
  },
	opacity = 0.95
})

hl.window_rule({
  match = {
    class = "vesktop"
  },
	opacity = 0.9,
	workspace = "7 silent"
})

hl.window_rule({
  match = {
    class = "code-oss"
  },
	opacity = 0.85
})

hl.window_rule({
  match = {
    class = "robloxstudiobeta.exe"
  },
	opacity = 0.95,
	workspace = "2 silent"
})

hl.window_rule({
  match = {
    class = "com.obsproject.Studio"
  },
	opacity = 0.9,
	workspace = "8 silent"
})

hl.window_rule({
  match = {
    class = "osu!"
  },
	workspace = 2
})

hl.window_rule({
  match = {
    class = "steam"
  },
	opacity = 0.9,
	workspace = 2
})

hl.window_rule({
  match = {
		title = "nvim"
  },
	opacity = 0.9
})

hl.window_rule({
  match = {
    class = "org.vinegarhq.Sober"
  },
	workspace = 2
})

hl.window_rule({
  match = {
    class = "it.mijorus.smile"
  },
	float = true,
	move = { 800, 664 },
	size = { 320, 420 },
	center = true,
	no_initial_focus = true,
	animation = "slide bottom",
	pin = true,
	opacity = 0.8,
})


--# ───────────────────────────
--# popups
--# ───────────────────────────

--# picture-in-picture
hl.window_rule({
  match = {
    title = "Picture-in-Picture"
  },
	no_initial_focus = true,
  float = true,
	keep_aspect_ratio = true,
	pin = true,	
	border_size = 0,
	animation = "slide",
	size = { 351, 198 },
	move = { -6, 500 },		
	opaque = true,
	rounding = 12
})


--# video source picker
hl.window_rule({
  match = {
    class = "hyprland-share-picker"
  },
  float = true,
	center = true,
	size = { 500, 300 }
})

--# vinegar manage panel
hl.window_rule({
  match = {
    class = "org.vinegarhq.Vinegar"
  },
  float = true,
	center = true,
	size = { 550, 700 }
})

--# advanced wine settings
hl.window_rule({
  match = {
    class = "winecfg.exe"
  },
  float = true,
	center = true
})
