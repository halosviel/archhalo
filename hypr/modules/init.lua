--[=[
	[INFO]
	author: @halosviel
	created: 2026 June 14

	[DESCRIPTION]
	Starts up programs. Search priority.lua if you cannot find the
	desired program here.
]=]

hl.on("hyprland.start", function()

	--# ───────────────────────────
	--# apps
	--# ───────────────────────────

	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("elephant")
	hl.exec_cmd("walker --gapplication-service")
	hl.exec_cmd("firefox", { workspace = 6 })
	hl.exec_cmd("vesktop")

	hl.exec_cmd("bash -c 'rm -rf ~/.var/app/com.obsproject.Studio/config/obs-studio/.sentinel && flatpak run com.obsproject.Studio --startreplaybuffer'", { workspace = 8 })
	hl.exec_cmd("kitty --title init_btop btop")


	--# ───────────────────────────
	--# daemons
	--# ───────────────────────────

	hl.exec_cmd("bash ~/.config/hypr/daemons/bluetooth_ntf.sh")
	hl.exec_cmd("bash ~/.config/hypr/daemons/cpu_temp_ntf.sh")
	hl.exec_cmd("bash ~/.config/hypr/daemons/memory_ntf.sh")
	hl.exec_cmd("bash ~/.config/hypr/daemons/network_ntf.sh")
	hl.exec_cmd("bash ~/.config/hypr/daemons/seeding_ntf.sh")
	hl.exec_cmd("bash ~/.config/hypr/daemons/qbit_seanime.sh")


	--# ───────────────────────────
	--# other
	--# ───────────────────────────

	-- hl.exec_cmd("wl-clip-persist --clipboard regular")
end)
