local simple_ev = Mu_f.simple_ev
G.STAGES.muexp_EXPORTZONE = "muexp_1"
G.STATES.muexp_EXPORTZONE = "muexp_1"
G.STAGE_OBJECTS[G.STAGES.muexp_EXPORTZONE] = {}

-- Generates the export zone.\
-- (similar to a run starting)\
-- For proper functionality, please use G.FUNCS.start_export_zone.
---@return nil
function Game:generate_export_zone()
	local list_width = 5
	local export_zone_stylesheet = {
		[".root"] = {
			fillColour = G.C.UI.TRANSPARENT_DARK,
			align = "center-middle",
		},
		[".body"] = {
			align = "center-middle",
			padding = 0.05,
			minWidth = 21.5,
			minHeight = 15.75,
		},
		[".body-col"] = {
			align = "center-middle",
			minHeight = 15.75,
			noFill = true,
		},
		[".left-row"] = {
			minHeight = 7.875,
			noFill = true,
			padding = 0.15
		},
		[".list-container"] = {
			fillColour = lighten(G.C.JOKER_GREY, 0.5),
			roundness = 1,
			emboss = 0.2,
		},
		[".list"] = {
			fillColour = G.C.GREY,
			padding = 0.1,
			minHeight = 6.875,
			roundness = 1,
			outlineColour = lighten(G.C.JOKER_GREY, 0.5),
			outlineWidth = 1.5,
		},
		[".list-title-container"] = {
			align = "center-middle",
			minWidth = list_width,
			minHeight = 0.4,
		},
		[".list-title"] = {
			colour = G.C.UI.TEXT_LIGHT,
			scale = 0.75
		},
		[".list-contents"] = {
			minWidth = list_width,
			minHeight = 5.475
		},
		[".list-page-buttons"] = {
			align = "center-middle",
			padding = 0.2,
			minWidth = list_width,
			minHeight = 0.4,
		},
		[".item-label-container"] = {
			padding = 0.1,
		},
		[".item-label"] = {
			colour = G.C.UI.TEXT_LIGHT,
			scale = 0.5
		}
	}

	G.exportzone = {}

	G.exportzone.item_list = {}
	G.exportzone.item_is_selected = {}
	G.exportzone.item_list_page = 1
	for item_name in pairs(Mu_f.items) do
		table.insert(G.exportzone.item_list, item_name)
		G.exportzone.item_is_selected[item_name] = false
	end
	table.sort(G.exportzone.item_list)

	G.exportzone.mod_list = {}
	G.exportzone.mod_is_selected = {}
	G.exportzone.mod_list_page = 1
	local mod_blacklist = {
		DebugPlus = true,
		muexporter = true
	}
	for _,mod in pairs(SMODS.mod_list) do
		if not mod.disabled and not mod_blacklist[mod.id] then
			table.insert(G.exportzone.mod_list, {mod.id, mod.name})
			G.exportzone.mod_is_selected[mod.id] = false
		end
	end
	table.sort(G.exportzone.mod_list, function(a,b) return a[1] < b[1] end)

	local function generate_list_item_jtml(args)
		args = args or {}
		args.label = args.label or "Test"

		return
		{"row", class="list-item", {
			create_toggle{
				col = true,
				hide_label = true,
				callback = args.callback,
				ref_table = args.ref_table,
				ref_value = args.ref_value
			},
			{"column", class="item-label-container", {
				{"text", class="item-label", text=args.label}
			}}
		}}
	end

	local function generate_mod_list_contents_jtml()
		local returntable = {}
		for _,mod in ipairs(G.exportzone.mod_list) do
			table.insert(returntable, generate_list_item_jtml{
				label = mod[2],
				ref_table = G.exportzone.mod_is_selected,
				ref_value = mod[1]
			})
		end
		return returntable
	end

	local function generate_item_list_contents_jtml()
		local returntable = {}
		for _,item in ipairs(G.exportzone.item_list) do
			table.insert(returntable, generate_list_item_jtml{
				label = item,
				ref_table = G.exportzone.item_is_selected,
				ref_value = item
			})
		end
		return returntable
	end

	local function generate_box(args)
		args = args or {}
		args.id = args.id or "list"
		args.label = args.label or "List"

		return
		{"row", class="list-container", {
			{"column", class="list", {
				{"row", class="list-title-container", {
					{"text", class="list-title", text=args.label}
				}},
				{"row", id=args.id .. "_contents", class="list-contents", args.gen_func()},
				{"row", class="list-page-buttons", {

				}},
			}}
		}}
	end

	local ez_mod_list = generate_box({id="mod_list", label=localize('b_muexp_mod_list'), gen_func = generate_mod_list_contents_jtml})
	local ez_item_list = generate_box({id="item_list", label=localize('b_muexp_item_list'), gen_func = generate_item_list_contents_jtml})

	local export_zone_jtml =
	{"root", class="root", {
		{"row", class="body", {
			{"column", class="body-col", {
				{"row", class="left-row", style={align="bottom-left"}, {ez_mod_list}},
				{"row", class="left-row", style={align="top-left"}, {ez_item_list}},
			}},
			{"column", class="body-col", style={minWidth = 15}, {

			}}
		}}
	}}

	-- bc tfym ts nil atp???
	self.CONTROLLER = {locks = {}}
	self.SETTINGS = {}

	self:prep_stage(G.STAGES.muexp_EXPORTZONE, G.STATES.muexp_EXPORTZONE)
	G.STAGE = G.STAGES.muexp_EXPORTZONE
    set_screen_positions()

	G.SPLASH_BACK = Sprite(-30, -6, G.ROOM.T.w+60, G.ROOM.T.h+12, G.ASSET_ATLAS["ui_1"], {x = 2, y = 0})
	G.SPLASH_BACK:set_alignment({
		major = G.play,
		type = 'cm',
		bond = 'Strong',
		offset = {x=0,y=0}
	})

	G.ARGS.spin = {
		amount = 0,
		real = 0,
		eased = 0
	}

	G.SPLASH_BACK:define_draw_steps({{
		shader = 'background',
		send = {
			{name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
			{name = 'spin_time', ref_table = G.TIMERS, ref_value = 'BACKGROUND'},
			{name = 'colour_1', ref_table = G.C.BACKGROUND, ref_value = 'C'},
			{name = 'colour_2', ref_table = G.C.BACKGROUND, ref_value = 'L'},
			{name = 'colour_3', ref_table = G.C.BACKGROUND, ref_value = 'D'},
			{name = 'contrast', ref_table = G.C.BACKGROUND, ref_value = 'contrast'},
			{name = 'spin_amount', ref_table = G.ARGS.spin, ref_value = 'amount'}
		}
	}})

	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		blocking = false,
		blockable = false,
		func = (function()
			local _dt = G.ARGS.spin.amount > G.ARGS.spin.eased and G.real_dt*2. or 0.3*G.real_dt
			local delta = G.ARGS.spin.real - G.ARGS.spin.eased
			if math.abs(delta) > _dt then delta = delta*_dt/math.abs(delta) end
			G.ARGS.spin.eased = G.ARGS.spin.eased + delta
			G.ARGS.spin.amount = _dt*(G.ARGS.spin.eased) + (1 - _dt)*G.ARGS.spin.amount
			G.TIMERS.BACKGROUND = G.TIMERS.BACKGROUND - 60*(G.ARGS.spin.eased - G.ARGS.spin.amount)*_dt
		end)
	}))

	self.HUD = UIBox {
		definition = Mu_f.jtml_to_uibox(export_zone_jtml, export_zone_stylesheet),
		config = {
			align = "cli",
			offset = {x=-0.7, y=0},
			major = G.ROOM_ATTACH
		}
	}
end

-- Switches the game stage to the export zone.\
-- To be used as a button function.
---@return nil
G.FUNCS.start_export_zone = function()
	G.E_MANAGER:clear_queue()
	G.FUNCS.wipe_on()

	G.E_MANAGER:add_event(Event({
		no_delete = true,
		func = function()
			G:delete_run()
			return true
		end
	}))

	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		no_delete = true,
		func = function()
			Game:generate_export_zone()
			return true
		end
	}))

	G.FUNCS.wipe_off()
end

--[[

G.FUNCS.start_export_zone()

]]
