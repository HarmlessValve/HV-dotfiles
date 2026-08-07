-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 8,

		border_size = 2,

		col = {
			active_border = {
				colors = {
					"rgba(8FECD5ee)",
					"rgba(8FECD5ee)",
					"rgba(8FECD5ee)",
					"rgba(8FECD5ee)",
					"rgba(8FECD5ee)",
					"rgba(0a0a0aee)",
					"rgba(0a0a0aee)",
					"rgba(0a0a0aee)",
				},
				angle = 90,
			},
			inactive_border = "rgb(272b30)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = false,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = false,

		layout = "dwindle",
	},

	group = {
		col = {
			border_active = {
				colors = {
					"rgba(8FECD5ee)",
					"rgba(8FECD5ee)",
					"rgba(8FECD5ee)",
					"rgba(8FECD5ee)",
					"rgba(8FECD5ee)",
					"rgba(0a0a0aee)",
					"rgba(0a0a0aee)",
					"rgba(0a0a0aee)",
				},
				angle = 90,
			},
			border_inactive = "rgb(272b30)",
		},
		groupbar = {
			col = {
				active = "rgba(8FECD599)",
				inactive = "rgba(48536288)",
			},
			text_color = "rgb(0a0a0a)",
			text_color_inactive = "rgba(D35F5Fff)",
		},
	},

	decoration = {
		rounding = 1,
		rounding_power = 3,

		-- Change transparency of focused and unfocused windows
		active_opacity = 0.90,
		inactive_opacity = 0.80,

		shadow = {
			enabled = true,
			range = 20,
			render_power = 6,
			color = "rgba(00000052)",
		},

		blur = {
			enabled = true,
			size = 3,
			passes = 2,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 10, bezier = "default", style = "slide bottom" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 6, bezier = "default", style = "popin 95%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "default", style = "popin" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = false, speed = 1 })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default", style = "slide smart" })
-- hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })
