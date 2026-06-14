--# binds.lua | 2026 June 14

--# ───────────────────────────
--# general
--# ───────────────────────────

hl.bind("SUPER + X", function()
	hl.dispatch(hl.dsp.window.close())
end)

hl.bind("SUPER + CTRL + X", function()
	hl.dispatch(hl.dsp.window.kill())
end)

hl.bind("SUPER + F", function()
	hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
end)


--# ───────────────────────────
--# apps
--# ───────────────────────────

hl.bind("SUPER + C", function()
	hl.dispatch(hl.dsp.exec_cmd("kitty"))
end)


--# ───────────────────────────
--# workspaces
--# ───────────────────────────

--# SWITCH FOCUS

for i = 1, 5 do
	hl.bind(("SUPER + %i"):format(i), function()
		hl.dispatch(hl.dsp.focus({ workspace = i, on_current_monitor = true }))
	end)
end

--# 6-8
hl.bind("SUPER + grave", function()
	hl.dispatch(hl.dsp.focus({ workspace = 6, on_current_monitor = true }))
end)

hl.bind("SUPER + Tab", function()
	hl.dispatch(hl.dsp.focus({ workspace = 7, on_current_monitor = true }))
end)


hl.bind("SUPER + Q", function()
	hl.dispatch(hl.dsp.focus({ workspace = 8, on_current_monitor = true }))
end)



--# MOVE APP TO

--# 1-5
for i = 1, 5 do
	hl.bind(("SUPER + SHIFT + %i"):format(i), function()
		hl.dispatch(hl.dsp.window.move({ workspace = i }))
	end)
end

--# 6-8
hl.bind("SUPER + SHIFT + grave", function()
	hl.dispatch(hl.dsp.window.move({ workspace = 6 }))
end)

hl.bind("SUPER + SHIFT + Tab", function()
	hl.dispatch(hl.dsp.window.move({ workspace = 7 }))
end)


hl.bind("SUPER + SHIFT + Q", function()
	hl.dispatch(hl.dsp.window.move({ workspace = 8 }))
end)
