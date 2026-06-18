--[=[
	[INFO]
	author: @halosviel
	created: 2026 June 14

	[DESCRIPTION]
	Contains essential system definitions.
]=]

--# ───────────────────────────
--# monitors
--# ───────────────────────────

hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@144",
  position = "0x0",
  scale = 1,
})

hl.monitor({
	output = "DP-1",
	disabled = true
})


--# ───────────────────────────
--# environment
--# ───────────────────────────

--# for descriptions, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

--# hyprland
--hl.env("HYPRLAND_TRACE", "1")

--# xdg
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

--# qt
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

--# nvidia
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct") --# see https://wiki.hypr.land/Nvidia/
