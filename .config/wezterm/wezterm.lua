local wezterm = require("wezterm")
local act = wezterm.action

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_map = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
	LeftArrow = "Left",
	RightArrow = "Right",
	DownArrow = "Down",
	UpArrow = "Up",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				win:perform_action({
					SendKey = { key = key, mods = "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_map[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_map[key] }, pane)
				end
			end
		end),
	}
end

return {
	scrollback_lines = 10000,
	color_scheme = "Kanagawa (Gogh)",
	font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" }),
	-- harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	font_size = 12.0,

	window_decorations = "RESIZE",
	window_padding = {
		left = "0.4cell",
		right = "0.4cell",
		top = "0.2cell",
		bottom = "0.2cell",
	},

	hyperlink_rules = {
		{
			regex = [[/Users/.*(?:\.png|\.html)]],
			format = "$0",
		},
		-- Linkify things that look like URLs and the host has a TLD name.
		{
			regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
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
	},

	inactive_pane_hsb = {
		saturation = 0.9,
		brightness = 0.65,
	},
	keys = {
		{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },
		-- { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Left', 5 }, },
		-- { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Right', 5 }, },
		-- { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Up', 5 }, },
		-- { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.AdjustPaneSize { 'Down', 5 }, },
		{ key = "0", mods = "CTRL|SHIFT", action = act.PaneSelect({ mode = "SwapWithActive" }) },
		{ key = "K", mods = "CTRL|SHIFT", action = act.ClearScrollback("ScrollbackAndViewport") },
		{ key = "Z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
		{ key = "B", mods = "CTRL|SHIFT", action = act.RotatePanes("CounterClockwise") },
		{ key = "N", mods = "CTRL|SHIFT", action = act.RotatePanes("Clockwise") },
		{ key = "S", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Down", size = { Percent = 20 } }) },
		{ key = "V", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Right" }) },
		split_nav("move", "h"),
		split_nav("move", "j"),
		split_nav("move", "k"),
		split_nav("move", "l"),
		split_nav("resize", "LeftArrow"),
		split_nav("resize", "RightArrow"),
		split_nav("resize", "UpArrow"),
		split_nav("resize", "DownArrow"),
	},
}
