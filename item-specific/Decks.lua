Mu_f.items.Decks = {}
MuExporter.items.Decks = {}
local log = Mu_f.log
local simple_ev = Mu_f.simple_ev

-- ============
-- DATA PARSING
-- ============

---@class Mu.DeckInfo
---@field name string
---@field nakedname string
---@field internalid string
---@field mod string
---@field image string
---@field parsed_effect table<integer, table<integer, string>>
---@field parsed_unlock table<integer, table<integer, string>>
local b_info_tbl = {}

-- Prepares various descriptions and values associated with the Deck.
---@param key string
---@return Mu.DeckInfo
function Mu_f.items.Decks.prepare_values(key)
	if MuExporter.items.Decks[key] then return MuExporter.items.Decks[key] end

	local deck = Mu_f.set_contained_card(key)
	local b_center = deck.config.center

	local loc_vars = b_center.loc_vars and b_center:loc_vars({}, deck) or {vars = {}}
	local locked_loc_vars = b_center.locked_loc_vars and b_center:locked_loc_vars({}, deck) or {vars = {}}
	local deck_localization = G.localization.descriptions.Back[key]

	loc_vars.vars = loc_vars.vars or {}
	locked_loc_vars.vars = locked_loc_vars.vars or {}

	local unparsed_effect = deck_localization.text and (
		type(deck_localization.text[1]) == "table"
		and deck_localization.text
		or {deck_localization.text}
	) or {}
	local unparsed_unlock = deck_localization.unlock and (
		type(deck_localization.unlock[1]) == "table"
		and deck_localization.unlock
		or {deck_localization.unlock}
	) or {}

	local deck_info      = {}
	deck_info.name       = Mu_f.transcribe_desc_line(deck_localization.name)
	deck_info.nakedname  = deck_localization.name:gsub("{.*}", "")
	deck_info.internalid = key
	deck_info.mod        = b_center.mod.name
	deck_info.image      = Mu_f.format_image_name(deck_info.nakedname, deck_info.mod, "png")

	-- parse effect
	Mu_f.set_loc_vars(loc_vars.vars, unparsed_effect)
	deck_info.parsed_effect = Mu_f.transcribe_description(unparsed_effect)

	-- parse unlock
	Mu_f.set_loc_vars(locked_loc_vars.vars, unparsed_unlock)
	deck_info.parsed_unlock = Mu_f.transcribe_description(unparsed_unlock)

	MuExporter.items.Decks[key] = deck_info
	return deck_info
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

	if #args.parsed_unlock > 0 then params.unlock = table.concat(args.parsed_unlock[1], "<br>") end

	if #args.parsed_effect == 1 then
		params.effect = table.concat(args.parsed_effect[1], "<br>")
	elseif #args.parsed_effect > 1 then
		for i,box in ipairs(args.parsed_effect) do
			params["effect" .. i] = table.concat(box, "<br>")
		end
	end

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
function Mu_f.items.Decks.export_sprite(key)
	if key:sub(1,2) ~= "b_" then
		return false
	end

	local deck = G.P_CENTERS[key]
	if not (deck and deck.mod) then
		return false
	end

	----

	local mod_name = deck.mod.name
	local deck_loc_entry_name = G.localization.descriptions.Back[key].name
	local deck_name = type(deck_loc_entry_name) == "table" and deck_loc_entry_name[1] or deck_loc_entry_name
	deck_name = deck_name:gsub("{.*}", "")

	local pos = deck.pos
	local soul_pos = deck.soul_pos
	local atlas = deck.atlas
	if not SMODS.Atlases[atlas] then return false end

	----
    local dir = MuExporter.filedirs.mod_imgs(mod_name, "Decks")
    local file_name = ("%s (%s).png"):format(deck_name, mod_name)

	local deck_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y) --sets base
	if soul_pos and soul_pos.x and soul_pos.y then
		deck_sprite:overlay_layer(atlas, soul_pos.x, soul_pos.y)
	end
	deck_sprite:export_sprite(dir, file_name)

	return true
end

-- ============

-- Generates the starting page contents of a Deck.\
-- Returns true if generation succeeded, else false.
---@param key string
---@return boolean
function Mu_f.items.Decks.generate_page(key)
	if key:sub(1,2) ~= "b_" then
		return false
	end

	local deck = G.P_CENTERS[key]
	if not (deck and deck.mod) then
		return false
	end

	----

	local deck_data = Mu_f.items.Decks.prepare_values(key)
	
	local infobox = Mu_f.infoboxes.Decks(deck_data)
	local page_format = [[{{modsubpage}}
{{auto generated|MuExporter}}
%s
]]
	local page = page_format:format(infobox)
	----
	local dir = MuExporter.filedirs.mod_pages(deck_data.mod, "Decks")
	local file_name = deck_data.nakedname .. ".txt"

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

-- Generates the page for the mod's list of Decks.\
-- Returns true if generation succeeded, else false.\
-- item_order must be a list of Deck keys.
---@param mod_name string
---@param item_order table<integer, string>
---@return boolean
function Mu_f.items.Decks.generate_list_page(mod_name, item_order)
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
		local deck_info  = Mu_f.items.Decks.prepare_values(deck_key)
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
function Mu_f.items.Decks.mass_export(mod_id)
	local mod_object = SMODS.Mods[mod_id]
	local mod_name = mod_object.name or "unspecified_mod"

	local decks_in_collection_order = G.P_CENTER_POOLS["Back"]
	local mod_decks_in_collection_order = {}
	for _,deck in ipairs(decks_in_collection_order) do
		if deck.original_mod == mod_object then
			table.insert(mod_decks_in_collection_order, deck.key)
		end
	end

	log("Exporting " .. mod_name .. " Decks...")

	for _,deck_key in ipairs(mod_decks_in_collection_order) do
		simple_ev(function()
			Mu_f.items.Decks.export_sprite(deck_key)
			delay(0.1)
		end)
	end
	for _,deck_key in ipairs(mod_decks_in_collection_order) do
		simple_ev(function()
			Mu_f.items.Decks.generate_page(deck_key)
			delay(0.1)
		end)
	end
	simple_ev(function()
		Mu_f.items.Decks.generate_list_page(mod_name, mod_decks_in_collection_order)
	end)

	log("Export of " .. mod_name .. " Decks DONE")
end