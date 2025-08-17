local export_zone_stylesheet = assert(SMODS.load_file("modules/extra/export zone jtmlss.lua"))()
local page_size_limit = 6

-- Generates the JTML syntax for a list item.
---@param args { label?: string, callback?: string, ref_table?: table, ref_value?: string }
---@return table
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
			ref_value = args.ref_value,
			scale = 0.75
		},
		{"column", class="item-label-container", {
			{"text", class="item-label", text=args.label}
		}}
	}}
end

local generate_list_contents_jtml = {}

-- Generates the JTML syntax for the mod list.
---@param args { page?: integer }
---@return table
function generate_list_contents_jtml.mod_list(args)
	args = args or {}
	args.page = args.page or 1

	local returntable = {}
	local ref_table = G.export_zone.mod_list
	local start_index = page_size_limit*(args.page - 1) + 1
	local end_index = page_size_limit*args.page

	for i = start_index, end_index do
		local mod = ref_table[i]
		if not mod then break end
		table.insert(returntable, generate_list_item_jtml{
			label = mod[2],
			ref_table = G.export_zone.mod_is_selected,
			ref_value = mod[1]
		})
	end
	return returntable
end

-- Generates the JTML syntax for the item list.
---@param args { page?: integer }
---@return table
function generate_list_contents_jtml.item_list(args)
	args = args or {}
	args.page = args.page or 1

	local returntable = {}
	local ref_table = G.export_zone.item_list
	local start_index = page_size_limit*(args.page - 1) + 1
	local end_index = page_size_limit*args.page

	for i = start_index, end_index do
		local item = ref_table[i]
		if not item then break end
		table.insert(returntable, generate_list_item_jtml{
			label = item,
			ref_table = G.export_zone.item_is_selected,
			ref_value = item
		})
	end
	return returntable
end

-- Generates the JTML syntax for a list-containing box.
---@param args { id: string, label: string }
---@return table
local function generate_box(args)
	args = args or {}
	args.id = args.id or "list"
	args.label = args.label or "List"

	local page_format = localize('k_page') .. " %s/%s"
	local pages = {}
	local page_count = math.ceil(#G.export_zone[args.id]/page_size_limit)
	for i = 1, page_count do
		table.insert(pages, page_format:format(i, page_count))
	end

	return
	{"row", class="list-container", {
		{"column", class="list", {
			{"row", class="list-title-container", {
				{"text", class="general-text list-title", text=args.label}
			}},
			{"row", class="list-contents", {
				{"object", id=args.id .. "_contents", object=Moveable()},
			}},
			create_option_cycle{
				id = args.id .. "_cycle",
				scale = 0.9,
				h = 0.3,
				w = 2.5,
				options = pages,
				cycle_shoulders = true,
				opt_callback = "change_list_contents_" .. args.id,
				current_option = 1,
				colour = G.C.RED,
				no_pips = true,
				focus_args = {snap_to = true}
			}
		}}
	}}
end

-- Generates the JTML syntax for an export zone log line.
---@param i integer
---@return table
local function quick_log_line(i)
	return
	{"row", class="log-line-container", {
		{"object", id = "log_line_" .. i, object=DynaText{
			string = {{
				ref_table = G.export_zone.log_lines,
				ref_value = i
			}},
			colours = {G.C.UI.TEXT_LIGHT},
			font = G.LANGUAGES['en-us'].font,
			scale = 0.4
		}}
	}}
end

-- Generates a list of export zone log lines.
local function log_lines()
	local returntable = {}
	for i = 1, MuExporter.log_size do
		table.insert(returntable, quick_log_line(i))
	end
	return returntable
end

-- ============
-- MAIN FUNCTION
-- ============

-- Generates the UIBox definition for the export zone stage.
---@return table
Mu_f.create_UIBox_export_zone = function()
	local ez_mod_list = generate_box{
		id="mod_list",
		label=localize('b_muexp_mod_list') or "Mod list"
	}
	local ez_item_list = generate_box{
		id="item_list",
		label=localize('b_muexp_item_list') or "Mod list"
	}

	local export_zone_jtml =
	{"root", class="root", {
		{"row", class="body", {
			-- Lists on the left side of the screen
			{"column", class="body-col left-col", {
				{"row", class="left-row", style={align="bottom-left"}, {ez_mod_list}},
				{"row", class="left-row", style={align="top-left"}, {ez_item_list}},
			}},
			{"column", class="body-col right-col", {
				-- Card areas
				{"row", class="right-row cardarea-list", style={align="center-right"}, {
					{"column", {
						{"row", {
							{"text", class="cardarea-label", text=localize('b_muexp_centercontainer')}
						}},
						{"row", class="cardarea-container", {
							{"object", object=G.export_zone.CenterContainer}
						}}
					}}
				}},
				-- Log screen
				{"row", class="right-row", {
					{"column", class="log-container", log_lines()},
				}},
				-- Export button
				{"row", class="right-row export-button-container", {
					{"column", class="export-button", {
						{"text", class="general-text", text=localize('b_muexp_export')}
					}}
				}},
				-- Tip text
				{"row", class="right-row tip", {
					{"text", class="tip-text", text=localize('b_muexp_tip')}
				}}
			}}
		}}
	}}

	return Mu_f.jtml_to_uibox(export_zone_jtml, export_zone_stylesheet)
end

-- ============
-- BUTTON CALLBACKS
-- ============

-- The function that runs when moving to a new page in the mod list.
---@param args { cycle_config: { current_option: integer } }
---@return nil
function G.FUNCS.change_list_contents_mod_list(args)
	if not G.HUD or not args or not args.cycle_config then return end
	local mod_list = G.HUD:get_UIE_by_ID('mod_list_contents')
	if not mod_list then return end

	if mod_list.config.object then mod_list.config.object:remove() end
	local list_contents = generate_list_contents_jtml.mod_list{page = args.cycle_config.current_option}
	local new_mod_list_jtml =
	{"root", style={fillColour=G.C.CLEAR}, {
		{"row", class="list-contents", list_contents}
	}}

	mod_list.config.object = UIBox{
		definition = Mu_f.jtml_to_uibox(new_mod_list_jtml, export_zone_stylesheet),
		config = {offset = {x=0,y=0}, align = 'cm', parent = mod_list}
	}
end

-- The function that runs when moving to a new page in the item list.
---@param args { cycle_config: { current_option: integer } }
---@return nil
function G.FUNCS.change_list_contents_item_list(args)
	if not G.HUD or not args or not args.cycle_config then return end
	local item_list = G.HUD:get_UIE_by_ID('item_list_contents')
	if not item_list then return end

	if item_list.config.object then item_list.config.object:remove() end
	local list_contents = generate_list_contents_jtml.item_list{page = args.cycle_config.current_option}
	local new_item_list_jtml =
	{"root", style={fillColour=G.C.CLEAR}, {
		{"row", class="list-contents", list_contents}
	}}

	item_list.config.object = UIBox{
		definition = Mu_f.jtml_to_uibox(new_item_list_jtml, export_zone_stylesheet),
		config = {offset = {x=0,y=0}, align = 'cm', parent = item_list}
	}
end
