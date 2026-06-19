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

--# style for sign-in prompt (rules don't work)
hl.on("window.title", function(w)
  if w.class == "firefox" and w.title:match("Sign in %- Google Accounts") then
    hl.dispatch(hl.dsp.window.float({ action = "enable", window = w }))
    hl.dispatch(hl.dsp.window.resize({ x = 400, y = 500, window = w }))
    hl.dispatch(hl.dsp.window.center({ window = w }))
  end
end)
