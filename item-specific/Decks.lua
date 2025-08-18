Mu_f.items.Decks = {}
MuExporter.items.Decks = {}

local log = Mu_f.log
local simple_ev = Mu_f.simple_ev
local item_F = Mu_f.items.Decks
local item_List = MuExporter.items.Decks

-- ============
-- DATA PARSING
-- ============

---@class Mu.DeckInfo
---@field name string
---@field nakedname string
---@field internalid string
---@field mod string
---@field image string
---@field parsed_effect Mu.BoxList
---@field parsed_unlock Mu.BoxList
local b_info_tbl = {}

-- Prepares various descriptions and values associated with the Deck.
---@param key string
---@return Mu.DeckInfo
function item_F.prepare_values(key)
	if item_List[key] then return item_List[key] end

	local item = Mu_f.set_contained_card(key)
	local center = item.config.center
    local loc_info = Mu_f.items.Centers.get_localization_text("Back", key)

	local item_info         = {}
	item_info.name          = Mu_f.transcribe_desc_line(loc_info.name)
	item_info.nakedname     = loc_info.name:gsub("{.*}", "")
	item_info.internalid    = key
	item_info.mod           = center.mod.name
	item_info.image         = Mu_f.format_image_name(item_info.nakedname, item_info.mod, "png")
	item_info.parsed_effect = Mu_f.transcribe_description(loc_info.unparsed_effect)
	item_info.parsed_unlock = Mu_f.transcribe_description(loc_info.unparsed_unlock)

	item_List[key] = item_info
	return item_info
end

-- ============

-- Generates a DeckInfobox template.
---@param args Mu.DeckInfo
---@return string
Mu_f.infoboxes.Decks = function(args)
	local params = {}

	params.name       = args.name
	params.internalid = args.internalid
	params.mod        = args.mod
	params.image      = args.image
    Mu_f.items.Centers.wikitext_unlock(params, args.parsed_unlock)
    Mu_f.items.Centers.wikitext_effect(params, args.parsed_effect)

	return Mu_f.infobox_string("DeckInfobox", params, {
		"name",
		"internalid",
		"mod",
		"image",
		"effect", "effect1", "effect2", "effect3", "effect4", "effect5", "effect6",
		"unlock",
	})
end

-- ============
-- INDIVIDUAL ELEMENT EXPORTS
-- ============

-- Exports the sprite of a Deck and properly names it.\
-- Returns true if export succeeded, else false.
---@param key string
---@return boolean
function item_F.export_sprite(key)
    return Mu_f.items.Centers.export_sprite(key, "Decks", "Back")
end

-- ============

-- Generates the starting page contents of a Deck.\
-- Returns true if generation succeeded, else false.
---@param deck_data Mu.DeckInfo
---@return boolean
function item_F.generate_page(deck_data)
	return Mu_f.items.Centers.generate_page("Decks", deck_data)
end

-- ============
-- GROUP EXPORTS
-- ============

-- Generates the page for the mod's list of Decks.\
-- Returns true if generation succeeded, else false.\
-- item_order must be a list of Deck keys.
---@param mod_name string
---@param item_order table<integer, string>
---@return boolean
function item_F.generate_list_page(mod_name, item_order)
	local page_format = [[{{modsubpage}}
{{auto generated|MuExporter}}
%s adds %s Decks.

== List of Decks ==
{| class="wikitable sortable"
! Deck !! Name !! Description
%s
|}
]]
	local table_concat_table = {}
	local table_row_format = [[|-
| \[\[File:%s|142px\]\]
| %s
|
%s]]
	for _,deck_key in ipairs(item_order) do
		local deck_info  = item_F.prepare_values(deck_key)
        local deck_image = deck_info.image
		local deck_name  = deck_info.nakedname

		local effect_concat_table = {}
		for _,box in ipairs(deck_info.parsed_effect) do
			table.insert(effect_concat_table, table.concat(box, "\n<br>"))
		end
		local effect = table.concat(effect_concat_table, "\n----\n")

		local table_row = table_row_format:format(deck_image, deck_name, effect)
		table.insert(table_concat_table, table_row)
	end

	local table_contents = table.concat(table_concat_table, "\n")
	local page = page_format:format(mod_name, #item_order, table_contents)

	----

	local dir = MuExporter.filedirs.mod(mod_name)
	local file_name = "List of Decks.txt"

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

-- Exports Deck images and data of a given mod.
---@param mod_id string
---@return nil
function item_F.mass_export(mod_id)
	Mu_f.items.Centers.mass_export("Decks", "Back", mod_id)
end