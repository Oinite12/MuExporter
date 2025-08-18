-- This is a "placeholder" item type for generic Centers;
-- Functions here are intended to be used by other items.
-- This item type is explicitly hidden from the item list.
Mu_f.items.Centers = {}
MuExporter.items.Centers = {}

local log = Mu_f.log
local simple_ev = Mu_f.simple_ev
local item_F = Mu_f.items.Centers
local item_List = MuExporter.items.Centers

-- ============

-- Refers to multi-box descriptions
---@alias Mu.BoxList table<integer, table<integer, string>>

---@class Mu.Localization
---@field name string
---@field unparsed_effect Mu.BoxList
---@field unparsed_unlock Mu.BoxList
local loc_info_tbl = {}

---@class Mu.CenterInfo
---@field name string
---@field nakedname string
---@field internalid string
---@field mod string
---@field image string
---@field parsed_effect Mu.BoxList
---@field parsed_unlock Mu.BoxList
local info_tbl = {}

-- ============

-- Prepares the item's localization.
---@param desc_entry string
---@param key string
---@return Mu.Localization
function item_F.get_localization_text(desc_entry, key)
    if not G.localization.descriptions[desc_entry] then return {
		name = "",
		unparsed_effect = {},
		unparsed_unlock = {}
	} end
    local item = Mu_f.set_contained_card(key)
	local center = item.config.center

	local loc_vars = center.loc_vars and center:loc_vars({}, item) or {vars = {}}
	local locked_loc_vars = center.locked_loc_vars and center:locked_loc_vars({}, item) or {vars = {}}
	local localization = G.localization.descriptions[desc_entry][key]
	local name = localization.name

	loc_vars.vars = loc_vars.vars or {}
	locked_loc_vars.vars = locked_loc_vars.vars or {}

	local unparsed_effect = localization.text and (
		type(localization.text[1]) == "table"
		and localization.text
		or {localization.text}
	) or {}
	local unparsed_unlock = localization.unlock and (
		type(localization.unlock[1]) == "table"
		and localization.unlock
		or {localization.unlock}
	) or {}

	Mu_f.set_loc_vars(loc_vars.vars, unparsed_effect)
	Mu_f.set_loc_vars(locked_loc_vars.vars, unparsed_unlock)

    return {
		name = name,
		unparsed_effect = unparsed_effect,
		unparsed_unlock = unparsed_unlock
	}
end

-- ============

-- Prepares the unlock description for wiki use.
---@param params_table table
---@param parsed_unlock Mu.BoxList
function item_F.wikitext_unlock(params_table, parsed_unlock)
	if #parsed_unlock > 0 then
		params_table.unlock = table.concat(parsed_unlock[1], "<br>")
	end
end

-- ============

-- Prepares the effect description for wiki use.
---@param params_table table
---@param parsed_effect Mu.BoxList
function item_F.wikitext_effect(params_table, parsed_effect)
	if #parsed_effect == 1 then
		params_table.effect = table.concat(parsed_effect[1], "<br>")
	elseif #parsed_effect > 1 then
		for i,box in ipairs(parsed_effect) do
			params_table["effect" .. i] = table.concat(box, "<br>")
		end
	end
end

-- ============

-- Exports the sprite of some Center and properly names it.\
-- Returns true if export succeeded, else false.
---@param key string
---@param item_type string
---@param item_type_loc_desc_entry string
---@return boolean
function item_F.export_sprite(key, item_type, item_type_loc_desc_entry)
	local item = G.P_CENTERS[key]
	if not (item and item.mod) then
		return false
	end

	----

	local mod_name = item.mod.name
	local item_loc_entry_name = G.localization.descriptions[item_type_loc_desc_entry][key].name
	local item_name = type(item_loc_entry_name) == "table" and item_loc_entry_name[1] or item_loc_entry_name
	item_name = item_name:gsub("{.*}", "")

	local pos = item.pos
	local soul_pos = item.soul_pos
	local atlas = item.atlas
	if not SMODS.Atlases[atlas] then return false end

	----
    local dir = MuExporter.filedirs.mod_imgs(mod_name, item_type)
    local file_name = ("%s (%s).png"):format(item_name, mod_name)

	local item_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y) --sets base
	if soul_pos and soul_pos.x and soul_pos.y then
		item_sprite:overlay_layer(atlas, soul_pos.x, soul_pos.y)
	end
	item_sprite:export_sprite(dir, file_name)

	return true
end

-- ============

-- Generates the starting page contents of some Center.\
-- Returns true if generation succeeded, else false.
---@param item_type string
---@param item_data Mu.CenterInfo
function item_F.generate_page(item_type, item_data)
	local infobox_text = Mu_f.infoboxes[item_type](item_data)
	local page_format = [[{{modsubpage}}
{{auto generated|MuExporter}}
%s
]]
	local page = page_format:format(infobox_text)
	----
	local dir = MuExporter.filedirs.mod_pages(item_data.mod, item_type)
	local file_name = item_data.nakedname .. ".txt"

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

-- Of a given mod, exports the images and data of the items under a specific item type.
---@param item_type string
---@param item_type_loc_desc_entry string
---@param mod_id string
---@return nil
function item_F.mass_export(item_type, item_type_loc_desc_entry, mod_id)
	local mod_object = SMODS.Mods[mod_id]
	local mod_name = mod_object.name or "unspecified_mod"

	local items_in_collection_order = G.P_CENTER_POOLS[item_type_loc_desc_entry]
	local mod_items_in_collection_order = {}
	for _,item in ipairs(items_in_collection_order) do
		if item.original_mod == mod_object then
			table.insert(mod_items_in_collection_order, item.key)
		end
	end

	log(("Exporting %s %s..."):format(mod_name, item_type))

	for _,item_key in ipairs(mod_items_in_collection_order) do
		simple_ev(function()
			Mu_f.items[item_type].export_sprite(item_key)
			delay(0.1)
		end)
	end
	for _,item_key in ipairs(mod_items_in_collection_order) do
		simple_ev(function()
			local item_info = Mu_f.items[item_type].prepare_values(item_key)
			Mu_f.items[item_type].generate_page(item_info)
			delay(0.1)
		end)
	end
	simple_ev(function()
		Mu_f.items[item_type].generate_list_page(mod_name, mod_items_in_collection_order)
	end)

	log(("Export of %s %s DONE"):format(mod_name, item_type))
end