-- From Oinite (author):
-- This code sucks ass
-- Because of event bullshit I have to put all these functions on a higher scope than the register
-- I really do not appreciate how this is writtem but it works and it upsets me, but better than nothing
-- Praying someone will come in and make this 1000000000% better

local section_format =
[[== %s ==
<div class="minibox-gallery">
%s
</div>]]

local page_format =
[[{{modsubpage}}
{{auto generated|MuExporter}}
%s adds %s %s.

== List of %s ==
{| class="wikitable sortable"
! %s !! Name !! Description
%s
|}
]]

local table_row_format =
[=[|-
| [[File:%s|142px]]
| %s
|
%s]=]

local c_generate_ordered_mod_item_list = function (poopshit, mod_object)
	local order = {}
	for _,item in ipairs(poopshit.ordered_consumable_list) do
		if item.original_mod == mod_object then
			table.insert(order, item.key)
		end
	end
	return order
end

local c_get_localization_text = function(poopshit, item_key)
	local item = Mu_f.set_contained_center(item_key)
	local center = item.config.center

	local loc_vars = center.loc_vars and center:loc_vars({}, item) or {vars = {}}
	local locked_loc_vars = center.locked_loc_vars and center:locked_loc_vars({}, item) or {vars = {}}
	local localization = poopshit.consumable_loc_desc[item_key]
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
		center = center,
		name = name,
		unparsed_effect = unparsed_effect,
		unparsed_unlock = unparsed_unlock
	}
end

local c_prepare_values = function (poopshit, item_key)
	if poopshit.consumable_list[item_key] then return poopshit.consumable_list[item_key] end

	local loc_info = c_get_localization_text(poopshit, item_key)

	local item_info = {}
	item_info.name          = Mu_f.transcribe_desc_line(loc_info.name)
	item_info.nakedname     = loc_info.name:gsub("{.*}", "")
	item_info.internalid    = item_key
	item_info.mod           = loc_info.center.mod.name
	item_info.type          = poopshit.consumable_type_name
	item_info.buyprice      = loc_info.center.cost
	item_info.image         = Mu_f.format_image_name(item_info.nakedname, item_info.mod, "png")
	item_info.parsed_effect = Mu_f.transcribe_description(loc_info.unparsed_effect)
	item_info.parsed_unlock = Mu_f.transcribe_description(loc_info.unparsed_unlock)

	poopshit.consumable_list[item_key] = item_info
	return item_info
end

local c_export_sprite = function (poopshit, item_key)
	local item = G.P_CENTERS[item_key]
	if not (item and item.mod) then return false end
	if not SMODS.Atlases[item.atlas] then return false end

	local mod_name = item.mod.name
	local item_name = Mu_f.filename_strip(c_prepare_values(poopshit, item_key).nakedname)

	local pos = item.pos
	local soul_pos = item.soul_pos
	local atlas = item.atlas

	local item_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y)
	if soul_pos and soul_pos.x and soul_pos.y then
		item_sprite:overlay_layer(atlas, soul_pos.x, soul_pos.y)
	end

	local dir = MuExporter.filedirs.mod_imgs(mod_name, "Consumables", poopshit.consumable_type_name)
	local file_name = ("%s (%s).png"):format(item_name, mod_name)
	item_sprite:export_sprite(dir, file_name)

	return true
end

local c_generate_list_page = function(poopshit, mod_name, item_order)
	local table_concat_table = {}
	for _, item_key in ipairs(item_order) do
		local item_info = c_prepare_values(poopshit, item_key)
		local item_image = item_info.image
		local item_name  = item_info.nakedname

		local effect_concat_table = {}
		for _, box in ipairs(item_info.parsed_effect) do
			table.insert(effect_concat_table, table.concat(box, "\n<br>"))
		end
		local effect = table.concat(effect_concat_table, "\n----\n")

		local table_row = table_row_format:format(item_image, item_name, effect)
		table.insert(table_concat_table, table_row)
	end

	local table_contents = table.concat(table_concat_table, "\n")
	local page = page_format:format(
		mod_name,
		#item_order,
		poopshit.consumable_type_name,
		poopshit.consumable_type_name,
		poopshit.consumable_type_name,
		table_contents
	)

	----
	local dir = MuExporter.filedirs.mod(mod_name)
	local file_name = "List of " .. poopshit.consumable_type_name .. ".txt"

	love.filesystem.createDirectory(dir)
	dir = Mu_f.set_dir_slash(dir)
	local did_succeed, err = love.filesystem.write(dir .. file_name, page)
	if not did_succeed then
		print(err)
		return false
	end
	return true
end

local c_register_template = function (poopshit, args)
	local params = {}

	params.name       = args.name
	params.internalid = args.internalid
	params.mod        = args.mod
	params.buyprice   = args.buyprice
	params.type       = args.type
	if #args.parsed_unlock > 0 then
		params.unlock = table.concat(args.parsed_unlock[1], "<br>")
	end
	if #args.parsed_effect > 0 then
		params.effect = table.concat(args.parsed_effect[1], "<br>")
	end

	return Mu_f.block_template_string("VoucherInfobox", params, {
		"name",
		"internalid",
		"mod",
		"type",
		"effect",
		"unlock",
		"buyprice"
	})
end

local c_generate_registry_section = function(poopshit, mod_name, item_order)
	local register_concat_table = {}
	for _,item_key in ipairs(item_order) do
		local item_info = c_prepare_values(poopshit, item_key)
		table.insert(register_concat_table, c_register_template(poopshit, item_info))
	end

	local register_contents = table.concat(register_concat_table, "\n")
	local section = section_format:format(poopshit.consumable_type_name, register_contents)

	----

	local dir = MuExporter.filedirs.mod(mod_name)
	local file_name = poopshit.consumable_type_name .. " registry section.txt"

	love.filesystem.createDirectory(dir)
	local did_succeed, err = love.filesystem.write(dir .. file_name, section)
	if not did_succeed then
		print(err)
		return false
	end
	return true
end

MuExporter.obj.CenterExporter {
	key = 'Consumables',
	vanilla_item_type_name = 'Consumeables', --sic
	prepare_values = function (self, item_key) return {} end,

	mass_export = function (self, mod_id)
		local mod_object = SMODS.Mods[mod_id]
		local mod_name = mod_object.name or "unspecified_mod"

		Mu_f.log(("Exporting %s %s..."):format(mod_name, self.item_type_name))

		for consumable_type_key in pairs(SMODS.ConsumableTypes) do
			local poopshit = {}
			poopshit.consumable_type_name = localize('b_'..consumable_type_key:lower()..'_cards')
			MuExporter.items.Consumables[poopshit.consumable_type_name] = {}
			poopshit.consumable_list = MuExporter.items.Consumables[poopshit.consumable_type_name]
			poopshit.vanilla_consumable_type_name = localize('k_'..consumable_type_key:lower())
			poopshit.ordered_consumable_list = G.P_CENTER_POOLS[consumable_type_key]
			poopshit.consumable_loc_desc = G.localization.descriptions[consumable_type_key]

			local ordered_mod_item_list = c_generate_ordered_mod_item_list(poopshit, mod_object)

			if #ordered_mod_item_list > 0 then
				for _, item_key in ipairs(ordered_mod_item_list) do
					Mu_f.simple_ev(function ()
						c_export_sprite(poopshit, item_key)
					end)
				end

				Mu_f.simple_ev(function ()
					c_generate_list_page(poopshit, mod_name, ordered_mod_item_list)
				end)

				Mu_f.simple_ev(function ()
					c_generate_registry_section(poopshit, mod_name, ordered_mod_item_list)
				end)
			end
		end

		Mu_f.log(("Export of %s %s DONE"):format(mod_name, self.item_type_name))
	end
}