local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

local mod = {}
mod.SUPER = "CMD"
mod.SUPER_REV = "CMD|CTRL"

-- GENERAL
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font("IosevkaTerm Nerd Font")
config.font_size = 20.0
config.color_scheme = "Gruber (base16)"
config.tab_bar_at_bottom = true
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.98
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.2,
}
config.default_cwd = "/Users/danielsusman"
config.enable_scroll_bar = true
config.switch_to_last_active_tab_when_closing_tab = true
config.leader = { key = "x", mods = mod.SUPER_REV }

-- KEYBINDS
config.keys = {
	-- movement
	{ key = "k", mods = mod.SUPER_REV, action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = mod.SUPER_REV, action = act.ActivatePaneDirection("Down") },
	{ key = "h", mods = mod.SUPER_REV, action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = mod.SUPER_REV, action = act.ActivatePaneDirection("Right") },
	-- splits
	{
		key = "p",
		mods = mod.SUPER_REV,
		action = act.PaneSelect({ alphabet = "1234567890", mode = "SwapWithActiveKeepFocus" }),
	},
	{
		key = "b",
		mods = mod.SUPER,
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "b",
		mods = mod.SUPER_REV,
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- windows
	{ key = "w",  mods = "CMD",  action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	-- debug/help
	{ key = "F1", mods = "NONE", action = "ActivateCopyMode" },
	{ key = "F2", mods = "NONE", action = act.ActivateCommandPalette },
	{ key = "F3", mods = "NONE", action = act.ShowLauncher },
	{ key = "F4", mods = "NONE", action = act.ShowLauncherArgs({ flags = "FUZZY|TABS" }) },
	{
		key = "F5",
		mods = "NONE",
		action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	},
	-- resizing (see `key_tables' below)
	{
		key = "f",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_font",
			one_shot = false,
			timemout_miliseconds = 1000,
		}),
	},
	{
		key = "p",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
			timemout_miliseconds = 1000,
		}),
	},
}

-- resizing panes and font
local key_tables = {
	resize_font = {
		{ key = "k",      action = act.IncreaseFontSize },
		{ key = "j",      action = act.DecreaseFontSize },
		{ key = "r",      action = act.ResetFontSize },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q",      action = "PopKeyTable" },
	},
	resize_pane = {
		{ key = "k",      action = act.AdjustPaneSize({ "Up", 3 }) },
		{ key = "j",      action = act.AdjustPaneSize({ "Down", 3 }) },
		{ key = "h",      action = act.AdjustPaneSize({ "Left", 3 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "q",      action = "PopKeyTable" },
	},
}

config.key_tables = key_tables

-- and finally, return the configuration to wezterm
return config
