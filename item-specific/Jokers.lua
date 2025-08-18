Mu_f.items.Jokers = {}
MuExporter.items.Jokers = {}
local log = Mu_f.log
local simple_ev = Mu_f.simple_ev

-- ============

local rarity_indices = {
	localize('k_common'),
	localize('k_uncommon'),
	localize('k_rare'),
	localize('k_legendary')
}
local rarity_format = "{{rarity|%s%s}}"

-- ============
-- DATA PARSING
-- ============

---@class Mu.JokerInfo
---@field name string
---@field nakedname string
---@field internalid string
---@field mod string
---@field image string
---@field buyprice number
---@field copyable boolean
---@field perishable boolean
---@field eternal boolean
---@field rarity string
---@field parsed_effect table<integer, table<integer, string>>
---@field parsed_unlock table<integer, table<integer, string>>
local j_info_tbl = {}

-- Prepares various descriptions and values associated with the Joker.
---@param key string
---@return Mu.JokerInfo
function Mu_f.items.Jokers.prepare_values(key)
	if MuExporter.items.Jokers[key] then return MuExporter.items.Jokers[key] end

	local joker = Mu_f.set_contained_card(key)
	local j_center = joker.config.center

	local loc_vars = j_center.loc_vars and j_center:loc_vars({}, joker) or {vars = {}}
	local locked_loc_vars = j_center.locked_loc_vars and j_center:locked_loc_vars({}, joker) or {vars = {}}
	local joker_localization = G.localization.descriptions.Joker[key]

	loc_vars.vars = loc_vars.vars or {}
	locked_loc_vars.vars = locked_loc_vars.vars or {}

	local unparsed_effect = joker_localization.text and (
		type(joker_localization.text[1]) == "table"
		and joker_localization.text
		or {joker_localization.text}
	) or {}
	local unparsed_unlock = joker_localization.unlock and (
		type(joker_localization.unlock[1]) == "table"
		and joker_localization.unlock
		or {joker_localization.unlock}
	) or {}

	local joker_info      = {}
	joker_info.name       = Mu_f.transcribe_desc_line(joker_localization.name)
	joker_info.nakedname  = joker_localization.name:gsub("{.*}", "")
	joker_info.internalid = key
	joker_info.mod        = j_center.mod.name
	joker_info.image      = Mu_f.format_image_name(joker_info.nakedname, joker_info.mod, "png")
	joker_info.buyprice   = j_center.cost
	joker_info.copyable   = j_center.blueprint_compat
	joker_info.perishable = j_center.perishable_compat
	joker_info.eternal    = j_center.eternal_compat

	-- parse rarity
	local j_rarity = j_center.rarity
	if type(j_rarity) == "number" then -- Vanilla rarities
		joker_info.rarity = rarity_format:format(rarity_indices[j_rarity], "")
	else
		joker_info.rarity = rarity_format:format(localize('k_' .. j_rarity), "|" .. SMODS.Rarities[j_rarity].mod.name)
	end

	-- parse effect
	Mu_f.set_loc_vars(loc_vars.vars, unparsed_effect)
	joker_info.parsed_effect = Mu_f.transcribe_description(unparsed_effect)

	-- parse unlock
	Mu_f.set_loc_vars(locked_loc_vars.vars, unparsed_unlock)
	joker_info.parsed_unlock = Mu_f.transcribe_description(unparsed_unlock)

	MuExporter.items.Jokers[key] = joker_info
	return joker_info
end

-- ============

-- Generates a JokerInfobox template.
---@param args Mu.JokerInfo
---@return string
Mu_f.infoboxes.Jokers = function(args)
	local params = {}

	params.name       = args.name
	params.internalid = args.internalid
	params.mod        = args.mod
	params.image      = args.image
	params.rarity     = ("%s"):format(args.rarity)
	params.buyprice   = args.buyprice
	params.copyable   = args.copyable
	params.perishable = args.perishable
	params.eternal    = args.eternal

	if #args.parsed_unlock > 0 then params.unlock = table.concat(args.parsed_unlock[1], "<br>") end

	if #args.parsed_effect == 1 then
		params.effect = table.concat(args.parsed_effect[1], "<br>")
	elseif #args.parsed_effect > 1 then
		for i,box in ipairs(args.parsed_effect) do
			params["effect" .. i] = table.concat(box, "<br>")
		end
	end

	return Mu_f.infobox_string("JokerInfobox", params, {
		"name",
		"internalid",
		"mod",
		"image",
		"effect", "effect1", "effect2", "effect3", "effect4", "effect5", "effect6",
		"rarity",
		"unlock",
		"buyprice",
		"copyable",
		"perishable",
		"eternal"
	})
end

-- ============
-- INDIVIDUAL ELEMENT EXPORTS
-- ============

-- Exports the sprite of a Joker and properly names it.\
-- Returns true if export succeeded, else false.
---@param key string
---@return boolean
function Mu_f.items.Jokers.export_sprite(key)
	if key:sub(1,2) ~= "j_" then
		return false
	end

	local joker = G.P_CENTERS[key]
	if not (joker and joker.mod) then
		return false
	end

	----

	local mod_name = joker.mod.name
	local joker_loc_entry_name = G.localization.descriptions.Joker[key].name
	local joker_name = type(joker_loc_entry_name) == "table" and joker_loc_entry_name[1] or joker_loc_entry_name
	joker_name = joker_name:gsub("{.*}", "")

	local pos = joker.pos
	local soul_pos = joker.soul_pos
	local atlas = joker.atlas
	if not SMODS.Atlases[atlas] then return false end

	----
    local dir = MuExporter.filedirs.mod_imgs(mod_name, "Jokers")
    local file_name = ("%s (%s).png"):format(joker_name, mod_name)

	local joker_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y) --sets base
	if soul_pos and soul_pos.x and soul_pos.y then
		joker_sprite:overlay_layer(atlas, soul_pos.x, soul_pos.y)
	end
	joker_sprite:export_sprite(dir, file_name)

	return true
end

-- ============

-- Generates the starting page contents of a Joker.\
-- Returns true if generation succeeded, else false.
---@param key string
---@return boolean
function Mu_f.items.Jokers.generate_page(key)
	if key:sub(1,2) ~= "j_" then
		return false
	end

	local joker = G.P_CENTERS[key]
	if not (joker and joker.mod) then
		return false
	end

	----

	local joker_data = Mu_f.items.Jokers.prepare_values(key)
	
	local infobox = Mu_f.infoboxes.Jokers(joker_data)
	local page_format = [[{{modsubpage}}
{{auto generated|MuExporter}}
%s
]]
	local page = page_format:format(infobox)
	----
	local dir = MuExporter.filedirs.mod_pages(joker_data.mod, "Jokers")
	local file_name = joker_data.nakedname .. ".txt"

	love.filesystem.createDirectory(dir)
	dir = Mu_f.set_dir_slash(dir)
	local did_succeed, err = love.filesystem.write(dir .. file_name, page)
	if not did_succeed then
		print(err)
		return false
	end

	return true
end

-- ============
-- GROUP EXPORTS
-- ============

-- Generates the page for the mod's list of Jokers.\
-- Returns true if generation succeeded, else false.\
-- item_order must be a list of Joker keys.
---@param mod_name string
---@param item_order table<integer, string>
---@return boolean
function Mu_f.items.Jokers.generate_list_page(mod_name, item_order)
	local page_format = [[{{modsubpage}}
{{auto generated|MuExporter}}
%s adds %s Jokers.

== List of Jokers ==
{| class="wikitable sortable"
! Joker !! Effect !! Cost !! Rarity !! Type
%s
|}
]]
	local table_concat_table = {}
	local table_row_format = [[|-
| {{captimg||%s}}
|
%s
| {{ct|cash|$%s}}
| %s
| TBD]]
	for _,joker_key in ipairs(item_order) do
		local joker_info = Mu_f.items.Jokers.prepare_values(joker_key)
		local joker_name = joker_info.nakedname
		local buyprice   = joker_info.buyprice
		local rarity     = joker_info.rarity

		local effect_concat_table = {}
		for _,box in ipairs(joker_info.parsed_effect) do
			table.insert(effect_concat_table, table.concat(box, "\n<br>"))
		end
		local effect = table.concat(effect_concat_table, "\n----\n")

		local table_row = table_row_format:format(joker_name, effect, buyprice, rarity)
		table.insert(table_concat_table, table_row)
	end

	local table_contents = table.concat(table_concat_table, "\n")
	local page = page_format:format(mod_name, #item_order, table_contents)

	----
	local dir = MuExporter.filedirs.mod(mod_name)
	local file_name = "List of Jokers.txt"

	love.filesystem.createDirectory(dir)
	dir = Mu_f.set_dir_slash(dir)
	local did_succeed, err = love.filesystem.write(dir .. file_name, page)
	if not did_succeed then
		print(err)
		return false
	end
	return true
end

-- ============
-- MASS-EXPORT
-- ============

-- Exports Joker images and data of a given mod.
function Mu_f.items.Jokers.mass_export(mod_id)
	local mod_object = SMODS.Mods[mod_id]
	local mod_name = mod_object.name or "unspecified_mod"

	local jokers_in_collection_order = G.P_CENTER_POOLS["Joker"]
	local mod_jokers_in_collection_order = {}
	for _,joker in ipairs(jokers_in_collection_order) do
		if joker.original_mod == mod_object then
			table.insert(mod_jokers_in_collection_order, joker.key)
		end
	end

	log("Exporting " .. mod_name .. " Jokers...")

	for _,joker_key in ipairs(mod_jokers_in_collection_order) do
		simple_ev(function()
			Mu_f.items.Jokers.export_sprite(joker_key)
			delay(0.1)
		end)
	end
	for _,joker_key in ipairs(mod_jokers_in_collection_order) do
		simple_ev(function()
			Mu_f.items.Jokers.generate_page(joker_key)
			delay(0.1)
		end)
	end
	simple_ev(function()
		Mu_f.items.Jokers.generate_list_page(mod_name, mod_jokers_in_collection_order)
	end)

	log("Export of " .. mod_name .. " Jokers DONE")

end