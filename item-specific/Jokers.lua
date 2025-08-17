Mu_f.items.Jokers = {}
local log = Mu_f.log

-- ============

-- Exports the sprite of a Joker and properly names it.
-- Returns true if export succeeded, else false.
---@param key string
---@return boolean
function Mu_f.items.Jokers.export_sprite(key)
	log("EXTRACTING SPRITE OF JOKER " .. key .. ":")

	if key:sub(1,2) ~= "j_" then
		print(key .. " NOT JOKER, skipping... (what are you doing???)")
		return false
	end

	local joker = G.P_CENTERS[key]
	if not joker then
		print(key .. " NOT FOUND, skipping...")
		return false
	end

	if not joker.mod then
		print(key .. " IS VANILLA (No support for vanilla content yet), skipping...")
		return false
	end

	----

	local joker_name = joker.config.name
	local mod_name = joker.mod.name

	local pos = joker.pos
	local soul_pos = joker.soul_pos
	local atlas = joker.atlas

	----
    local dir = MuExporter.filedirs.mod_imgs(mod_name, "Jokers")
    local file_name = ("%s (%s).png"):format(joker_name, mod_name)

	local joker_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y) --sets base
	if soul_pos and soul_pos.x and soul_pos.y then
		joker_sprite:overlay_layer(atlas, soul_pos.x, soul_pos.y)
	end
	joker_sprite:export_sprite(dir, file_name)
	log("JOKER " .. key .. " SPRITE EXTRACT SUCCESS ")

	return true
end

-- ============

local rarity_indices = {
	localize('k_common'),
	localize('k_uncommon'),
	localize('k_rare'),
	localize('k_legendary')
}
local rarity_format = "{{Rarity|%s%s}}"

-- Prepares various descriptions and values associated with the Joker.
---@param key string
---@return {name: string, internalid: string, mod: string, image: string, buyprice: number, copyable: boolean, perishable: boolean, eternal: boolean, rarity: string, parsed_effect: table, parsed_unlock: table }
function Mu_f.items.Jokers.prepare_values(key)
	local area = G.export_zone.CenterContainer
	if area.cards[1] then
		local thing = area.cards[1]
		area:remove_card(thing)
		thing:remove()
	end
	SMODS.add_card{
		key = key,
		area = area
	}
	local joker = area.cards[1]
	local j_center = joker.config.center
	local loc_vars = j_center.loc_vars and j_center:loc_vars({}, joker) or {vars = {}}
	loc_vars.vars = loc_vars.vars or {}
	local locked_loc_vars = j_center.locked_loc_vars and j_center:locked_loc_vars({}, joker) or {vars = {}}
	locked_loc_vars.vars = locked_loc_vars.vars or {}
	local joker_localization = G.localization.descriptions.Joker[key]

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

	local joker_info = {}
	joker_info.name = joker_localization.name
	joker_info.internalid = key
	joker_info.mod = j_center.mod.name
	joker_info.image = Mu_f.filename_strip(joker_info.name) .. (" (%s).png"):format(joker_info.mod)
	joker_info.buyprice = j_center.cost
	joker_info.copyable = j_center.blueprint_compat
	joker_info.perishable = j_center.perishable_compat
	joker_info.eternal = j_center.eternal_compat

	-- parse rarity
	local j_rarity = j_center.rarity
	if type(j_rarity) == "number" then -- Vanilla rarities
		joker_info.rarity = rarity_format:format(rarity_indices[j_rarity], "")
	else
		joker_info.rarity = rarity_format:format(localize('k_' .. j_rarity), "|" .. j_rarity.mod.name)
	end

	-- parse effect
	for i,value in ipairs(loc_vars.vars) do
		for _,box in ipairs(unparsed_effect) do
			for row,text in ipairs(box) do
				box[row] = text:gsub("#" .. i .. "#", value)
			end
		end
	end
	joker_info.parsed_effect = Mu_f.transcribe_description(unparsed_effect)

	-- parse unlock
	for i,value in ipairs(locked_loc_vars.vars) do
		for _,box in ipairs(unparsed_unlock) do
			for row,text in ipairs(box) do
				box[row] = text:gsub("#" .. i .. "#", value)
			end
		end
	end
	joker_info.parsed_unlock = Mu_f.transcribe_description(unparsed_unlock)

	return joker_info
end