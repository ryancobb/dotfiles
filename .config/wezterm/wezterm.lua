local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local arrow_keys = {
	LeftArrow = "Left",
	DownArrow = "Down",
	UpArrow = "Up",
	RightArrow = "Right",
}

local vim_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { arrow_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = vim_keys[key] }, pane)
				end
			end
		end),
	}
end

wezterm.on("gui-startup", function()
	mux.spawn_window({
		workspace = "gitlab",
		cwd = wezterm.home_dir .. "/Projects/gdk/gitlab",
		args = {},
	})

	mux.spawn_window({
		workspace = "cdot",
		cwd = wezterm.home_dir .. "/Projects/customers-gitlab-com",
	})

	mux.spawn_window({
		worspace = "default",
		cwd = wezterm.home_dir,
		args = {},
	})
end)

wezterm.on("update-right-status", function(window)
	window:set_right_status(window:active_workspace())
end)

local config = {
	force_reverse_video_cursor = true,
	scrollback_lines = 10000,
	font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" }),
	font_size = 12.0,

	window_decorations = "RESIZE",
	window_padding = {
		left = "0.3cell",
		right = "0.3cell",
		top = "0.2cell",
		bottom = "0.2cell",
	},

	inactive_pane_hsb = {
		saturation = 0.9,
		brightness = 0.65,
	},
}

config.hyperlink_rules = {
	{
		regex = [[/Users/.*(?:\.png|\.html)]],
		format = "$0",
	},
	-- Linkify things that look like URLs and the host has a TLD name.
	{
		regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
		format = "$0",
	},
	-- match the URL with a PORT
	-- such 'http://localhost:3000/index.html'
	{
		regex = "\\b\\w+://(?:[\\w.-]+):\\d+\\S*\\b",
		format = "$0",
	},
	-- file:// URI
	{
		regex = [[\bfile://\S*\b]],
		format = "$0",
	},
	-- Linkify things that look like URLs with numeric addresses as hosts.
	-- E.g. http://127.0.0.1:8000 for a local development server,
	-- or http://192.168.1.1 for the web interface of many routers
	{
		regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
		format = "$0",
	},
}

config.keys = {
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	split_nav("resize", "LeftArrow"),
	split_nav("resize", "RightArrow"),
	split_nav("resize", "UpArrow"),
	split_nav("resize", "DownArrow"),
	{ key = "0", mods = "CTRL", action = act.PaneSelect({ mode = "SwapWithActive" }) },
	{ key = "l", mods = "ALT", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "K", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
	{ key = "Z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
	{ key = "{", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
	{ key = "}", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
	{ key = "S", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Down", size = { Percent = 20 } }) },
	{ key = "V", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Right" }) },
}

config.mouse_bindings = {
	-- Disable the default click behavior
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
	-- Disable the Cmd-click down event to stop programs from seeing it when a URL is clicked
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = wezterm.action.Nop,
	},
}

-- nightfox
config.window_frame = {
	active_titlebar_bg = "#232831",
	inactive_titlebar_bg = "#232831",
}

config.colors = {
	foreground = "#cdcecf",
	background = "#2e3440",
	cursor_bg = "#cdcecf",
	cursor_border = "#cdcecf",
	cursor_fg = "#2e3440",
	compose_cursor = "#c9826b",
	selection_bg = "#3e4a5b",
	selection_fg = "#cdcecf",
	scrollbar_thumb = "#7e8188",
	split = "#232831",
	visual_bell = "#cdcecf",
	ansi = { "#3b4252", "#bf616a", "#a3be8c", "#ebcb8b", "#81a1c1", "#b48ead", "#88c0d0", "#e5e9f0" },
	brights = { "#465780", "#d06f79", "#b1d196", "#f0d399", "#8cafd2", "#c895bf", "#93ccdc", "#e7ecf4" },
	indexed = {
		[16] = "#bf88bc",
		[17] = "#c9826b",
	},
	tab_bar = {
		background = "#232831",
		inactive_tab_edge = "#232831",
		inactive_tab_edge_hover = "#39404f",
		active_tab = {
			bg_color = "#444c5e",
			fg_color = "#cdcecf",
		},
		inactive_tab = {
			bg_color = "#232831",
			fg_color = "#7e8188",
		},
		inactive_tab_hover = {
			bg_color = "#444c5e",
			fg_color = "#cdcecf",
		},
		new_tab = {
			bg_color = "#2e3440",
			fg_color = "#abb1bb",
		},
		new_tab_hover = {
			bg_color = "#444c5e",
			fg_color = "#cdcecf",
		},
	},
}

return config
