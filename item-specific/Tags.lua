local page_format =
[[{modsubpage}}
{{auto generated|MuExporter}}
%s adds %s Tags.

== List of Tags ==
{| class="wikitable sortable"
! Tag !! Name !! Description !! Notes !! Ante
%s
|}
]]

local table_row_format =
[=[|-
! [[%s|142px]]
| %s
|
%s
|
| %s]=]

MuExporter.obj.Exporter {
	key = 'Tags',
	vanilla_item_type_name = 'Tag',

	get_localization_text = function (self, item_key)
		local item = Tag(item_key)
		local localization = self.loc_desc[item_key]
		local name = localization.name
		local prototype = SMODS.Tags[item_key]

		local loc_vars = prototype.loc_vars and prototype:loc_vars({}, item) or {vars = {}}
		item:remove_from_game()

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
		local item_proto = SMODS.Tags[item_key]

		local item_info = {}
		item_info.name          = Mu_f.transcribe_desc_line(loc_info.name)
		item_info.nakedname     = loc_info.name:gsub("{.*}", "")
		item_info.internalid    = item_key
		item_info.mod           = item_proto.mod.name
		item_info.image         = Mu_f.format_image_name(item_info.nakedname, item_info.mod, "png")
		item_info.parsed_effect = Mu_f.transcribe_description(loc_info.unparsed_effect)
		item_info.min_ante      = item_proto.min_ante or "?"

		self.item_list[item_key] = item_info
		return item_info
	end,

	generate_ordered_mod_item_list = function (self, mod_object)
		local order = {}
		local all_tags = {}
		for _,item in pairs(G.P_TAGS) do
			if item.mod == mod_object then table.insert(all_tags, item) end
		end
		table.sort(all_tags, function(a,b) return a.order < b.order end)
		for _,item in ipairs(all_tags) do
			table.insert(order, item.key)
		end
		return order
	end,

	generate_list_page = function (self, mod_name, item_order)
		local table_concat_table = {}
		for _, item_key in ipairs(item_order) do
			local item_info = self:prepare_values(item_key)
			local image_name = item_info.image
			local item_name = item_info.name
			local min_ante = item_info.min_ante

			local effect_concat_table = {}
			for _, box in ipairs(item_info.parsed_effect) do
				table.insert(effect_concat_table, table.concat(box, "\n<br>"))
			end
			local effect = table.concat(effect_concat_table, "\n----\n")

			local table_row = table_row_format:format(image_name, item_name, effect, min_ante)
			table.insert(table_concat_table, table_row)
		end

		local table_contents = table.concat(table_concat_table, "\n")
		local section = page_format:format(mod_name, #item_order, table_contents)

		----
		local dir = MuExporter.filedirs.mod(mod_name)
		local file_name = "List of " .. self.item_type_name .. ".txt"

		love.filesystem.createDirectory(dir)
		dir = Mu_f.set_dir_slash(dir)
		local did_succeed, err = love.filesystem.write(dir .. file_name, section)
		if not did_succeed then
			print(err)
			return false
		end
		return true
	end,

	export_sprite = function (self, item_key)
		local item = G.P_TAGS[item_key]
		if not (item and item.mod) then return false end
		if not SMODS.Atlases[item.atlas] then return false end

		local mod_name = item.mod.name
		local item_name = self:prepare_values(item_key).nakedname
		local pos = item.pos
		local atlas = item.atlas

		local item_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y)

		local dir = MuExporter.filedirs.mod_imgs(mod_name, self.item_type_name)
		local file_name = ("%s (%s).png"):format(item_name, mod_name)
		item_sprite:export_sprite(dir, file_name)

		return true
	end
}