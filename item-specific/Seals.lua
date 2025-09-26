local section_format =
[[== Seals ==
{{auto generated|MuExporter}}
{| class="wikitable sortable"
! Seal !! Name !! Effect
%s
|}
]]

local table_row_format =
[=[|-
! [[%s|142px]]
| %s
|
%s]=]

MuExporter.obj.Exporter {
	key = 'Seals',
	vanilla_item_type_name = 'Seal',

	get_localization_text = function (self, item_key)
		local card_with_seal = Mu_f.set_contained_center('c_base') --[[@as Card]]
		card_with_seal:set_seal(item_key, true, true)
		local localization = G.localization.descriptions.Other[item_key:lower().."_seal"]
		local name = localization.name
		local prototype = SMODS.Seals[item_key]

		local loc_vars = prototype.loc_vars and prototype:loc_vars({}, card_with_seal) or {vars = {}}
		card_with_seal:set_seal(nil, true, true)

		local unparsed_effect = localization.text and (
			type(localization.text[1]) == "table"
			and localization.text
			or {localization.text}
		) or {}

		Mu_f.set_loc_vars(loc_vars.vars, unparsed_effect)

		return {
			name = name,
			unparsed_effect = unparsed_effect
		}
	end,

	prepare_values = function (self, item_key)
		if self.item_list[item_key] then return self.item_list[item_key] end

		local loc_info = self:get_localization_text(item_key)

		local item_info = {}
		item_info.name          = Mu_f.transcribe_desc_line(loc_info.name)
		item_info.nakedname     = loc_info.name:gsub("{.*}", "")
		item_info.internalid    = item_key
		item_info.mod           = SMODS.Seals[item_key].mod.name
		item_info.image         = Mu_f.format_image_name(item_info.nakedname, item_info.mod, "png")
		item_info.parsed_effect = Mu_f.transcribe_description(loc_info.unparsed_effect)

		self.item_list[item_key] = item_info
		return item_info
	end,

	generate_ordered_mod_item_list = function (self, mod_object)
		local order = {}
		for _,item in pairs(G.P_CENTER_POOLS['Seal']) do
			if item.mod == mod_object then
				table.insert(order, item.key)
			end
		end
		return order
	end,

	export_sprite = function (self, item_key)
		local item = SMODS.Seals[item_key]
		if not (item and item.mod) then return false end
		if not SMODS.Atlases[item.atlas] then return false end

		local mod_name = item.mod.name
		local item_name = self:prepare_values(item_key).nakedname

		local pos = item.pos --[[@as {x: number, y: number}]]
		local atlas = item.atlas --[[@as string]]

		-- Ace of Spades
		local item_sprite = Mu_f.get_atlas_sprite("cards_1", 12, 3, G.ASSET_ATLAS)
		item_sprite:overlay_layer(atlas, pos.x, pos.y)

		local dir = MuExporter.filedirs.mod_imgs(mod_name, self.item_type_name)
		local file_name = ("%s (%s).png"):format(item_name, mod_name)
		item_sprite:export_sprite(dir, file_name)

		return true
	end,

	generate_list_section = function (self, mod_name, item_order)
		local table_concat_table = {}
		for _, item_key in ipairs(item_order) do
			local item_info = self:prepare_values(item_key)
			local image_name = item_info.image
			local item_name = item_info.name

			local effect_concat_table = {}
			for _, box in ipairs(item_info.parsed_effect) do
				table.insert(effect_concat_table, table.concat(box, "\n<br>"))
			end
			local effect = table.concat(effect_concat_table, "\n----\n")

			local table_row = table_row_format:format(image_name, item_name, effect)
			table.insert(table_concat_table, table_row)
		end

		local table_contents = table.concat(table_concat_table, "\n")
		local section = section_format:format(table_contents)

		----
		local dir = MuExporter.filedirs.mod(mod_name)
		local file_name = "List of " .. self.item_type_name .. " section.txt"

		love.filesystem.createDirectory(dir)
		dir = Mu_f.set_dir_slash(dir)
		local did_succeed, err = love.filesystem.write(dir .. file_name, section)
		if not did_succeed then
			print(err)
			return false
		end
		return true
	end,
}