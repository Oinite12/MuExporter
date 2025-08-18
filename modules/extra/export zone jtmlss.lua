local list_width = 5
return {
	[".root"] = {
		fillColour = G.C.UI.TRANSPARENT_DARK,
		align = "center-middle",
	},
	[".body"] = {
		align = "center-middle",
		padding = 0.05,
		minWidth = 21.5,
		minHeight = 15,
	},

	[".body-col"] = {
		align = "center-middle",
		minHeight = 15,
		noFill = true,
	},
	[".left-row"] = {
		minHeight = 7.875,
		noFill = true,
		padding = 0.15
	},
	[".right-row"] = {
		minWidth = 4,
		noFill = true,
		padding = 0.15
	},

	[".list-container"] = {
		fillColour = lighten(G.C.JOKER_GREY, 0.5),
		roundness = 1,
		emboss = 0.15,
	},
	[".list"] = {
		fillColour = G.C.GREY,
		padding = 0.1,
		minHeight = 6,
		roundness = 1,
		outlineColour = lighten(G.C.JOKER_GREY, 0.5),
		outlineWidth = 1.5,
	},
	[".list-title-container"] = {
		align = "center-middle",
		minWidth = list_width,
		minHeight = 0.4,
	},
	[".general-text"] = {
		colour = G.C.UI.TEXT_LIGHT,
		scale = 0.55
	},
	[".list-contents"] = {
		noFill = true,
		minWidth = list_width,
		minHeight = 4
	},
	[".item-label-container"] = {
		padding = 0.1,
	},
	[".item-label"] = {
		colour = G.C.UI.TEXT_LIGHT,
		scale = 0.4
	},

	[".cardarea-list"] = {
		minWidth = 15,
	},
	[".cardarea-container"] = {
		fillColour = G.C.UI.TRANSPARENT_DARK,
		roundness = 0.5
	},
	[".cardarea-label"] = {
		colour = G.C.JOKER_GREY,
		scale = 0.3
	},

	[".log-container"] = {
		padding = 0.2,
		minWidth = 15,
		fillColour = G.C.UI.TRANSPARENT_DARK,
		roundness = 0.5
	},
	[".log-line-container"] = {
		minHeight = 0.4,
		height = 0.4
	},

	[".export-button"] = {
		padding = 0.3,
		emboss = 0.2,
		roundness = 1,
	},

	[".tip"] = {
		align = "center-left"
	},
	[".tip-text"] = {
		colour = G.C.JOKER_GREY,
		scale = 0.4
	}
}