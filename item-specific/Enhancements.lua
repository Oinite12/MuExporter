local section_format =
[[== List of Jokers ==
{{auto generated|MuExporter}}
{| class="wikitable sortable"
! Enhancement !! Name !! Effect
%s
|}
]]

local table_row_format =
[=[|-
! [[%s|142px]]
| %s
|
%s]=]

MuExporter.obj.CenterExporter {
	key = 'Enhancements',
	vanilla_item_type_name = 'Enhanced',

	prepare_values = function(self, item_key)
		if self.item_list[item_key] then return self.item_list[item_key] end

		local loc_info = self:get_localization_text(item_key)

		local item_info = {}
		item_info.name          = Mu_f.transcribe_desc_line(loc_info.name)
		item_info.nakedname     = loc_info.name:gsub("{.*}", "")
		item_info.internalid    = item_key
		item_info.mod           = loc_info.center.mod.name
		item_info.image         = Mu_f.format_image_name(item_info.nakedname, item_info.mod, "png")
		item_info.parsed_effect = Mu_f.transcribe_description(loc_info.unparsed_effect)
		item_info.has_ranksuit  = not (loc_info.center.replace_base_card or false)

		self.item_list[item_key] = item_info
		return item_info
	end,

	export_sprite = function(self, item_key)
		local item = G.P_CENTERS[item_key]
		if not (item and item.mod) then return false end
		if not SMODS.Atlases[item.atlas] then return false end

		local mod_name = Mu_f.filename_strip(item.mod.name)
		local item_name = Mu_f.filename_strip(self:prepare_values(item_key).nakedname)

		local pos = item.pos
		local atlas = item.atlas

		local item_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y)
		if self:prepare_values(item_key).has_ranksuit then
			-- Ace of Spades
			item_sprite:overlay_layer("cards_1", 12, 3, G.ASSET_ATLAS)
		end

		local dir = MuExporter.filedirs.mod_imgs(mod_name, self.item_type_name)
		local file_name = ("%s (%s).png"):format(item_name, mod_name)
		item_sprite:export_sprite(dir, file_name)

		return true
	end,

	generate_list_section = function(self, mod_name, item_order)
		local table_concat_table = {}
		for _, item_key in ipairs(item_order) do
			local item_info = self:prepare_values(item_key)
			local image_name = item_info.image
			local item_name  = item_info.name

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
	end
}