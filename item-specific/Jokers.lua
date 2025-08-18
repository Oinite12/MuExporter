Mu_f.items.Jokers = {}
MuExporter.items.Jokers = {}

local log = Mu_f.log
local simple_ev = Mu_f.simple_ev
local item_F = Mu_f.items.Jokers
local item_List = MuExporter.items.Jokers

-- ============

local rarity_indices = {
	localize('k_common'),
	localize('k_uncommon'),
	localize('k_rare'),
	localize('k_legendary')
}
local rarity_format = "{{rarity|%s%s}}"

---@param card Card
local function get_rarity(card)
	local j_rarity = card.config.center.rarity
	if type(j_rarity) == "number" then -- Vanilla rarities
		return rarity_format:format(rarity_indices[j_rarity], "")
	else
		return rarity_format:format(localize('k_' .. j_rarity), "|" .. SMODS.Rarities[j_rarity].mod.name)
	end
end

-- ============
-- DATA PARSING
-- ============

-- Gets a list of Jokers in the order seen in the Collection.
---@param mod_object Mod
---@return table<integer, string>
function item_F.get_items_in_collection_order(mod_object)
	return Mu_f.items.Centers.get_centers_in_collection_order(mod_object, "Joker")
end

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
---@field parsed_effect Mu.BoxList
---@field parsed_unlock Mu.BoxList
local j_info_tbl = {}

-- Prepares various descriptions and values associated with the Joker.
---@param key string
---@return Mu.JokerInfo
function item_F.prepare_values(key)
	if item_List[key] then return item_List[key] end

	local item = Mu_f.set_contained_card(key)
	local center = item.config.center
	local loc_info = Mu_f.items.Centers.get_localization_text("Joker", key)

	local item_info         = {}
	item_info.name          = Mu_f.transcribe_desc_line(loc_info.name)
	item_info.nakedname     = loc_info.name:gsub("{.*}", "")
	item_info.internalid    = key
	item_info.mod           = center.mod.name
	item_info.image         = Mu_f.format_image_name(item_info.nakedname, item_info.mod, "png")
	item_info.rarity        = get_rarity(item)
	item_info.buyprice      = center.cost
	item_info.copyable      = center.blueprint_compat
	item_info.perishable    = center.perishable_compat
	item_info.eternal       = center.eternal_compat
	item_info.parsed_effect = Mu_f.transcribe_description(loc_info.unparsed_effect)
	item_info.parsed_unlock = Mu_f.transcribe_description(loc_info.unparsed_unlock)

	item_List[key] = item_info
	return item_info
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
	params.rarity     = args.rarity
	params.buyprice   = args.buyprice
	params.copyable   = args.copyable
	params.perishable = args.perishable
	params.eternal    = args.eternal
    Mu_f.items.Centers.wikitext_unlock(params, args.parsed_unlock)
    Mu_f.items.Centers.wikitext_effect(params, args.parsed_effect)

	return Mu_f.block_template_string("JokerInfobox", params, {
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
function item_F.export_sprite(key)
    return Mu_f.items.Centers.export_sprite(key, "Jokers", "Joker")
end

-- ============

-- Generates the starting page contents of a Joker.\
-- Returns true if generation succeeded, else false.
---@param joker_data Mu.JokerInfo
---@return boolean
function item_F.generate_page(joker_data)
	return Mu_f.items.Centers.generate_page("Jokers", joker_data)
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
function item_F.generate_list_page(mod_name, item_order)
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
		local joker_info = item_F.prepare_values(joker_key)
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
---@param mod_id string
---@return nil
function item_F.mass_export(mod_id)
	Mu_f.items.Centers.mass_export("Jokers", "Joker", mod_id)
end