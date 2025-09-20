local page_format =
[[{{modsubpage}}
{{auto generated|MuExporter}}
%s adds %s Decks.

== List of Decks ==
{| class="wikitable sortable"
! Deck !! Name !! Description
%s
|}
]]

local table_row_format =
[=[|-
| [[File:%s|142px]]
| %s
|
%s]=]

MuExporter.obj.CenterExporter {
	key = 'Decks',
	vanilla_item_type_name = 'Back',

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
        item_info.parsed_unlock = Mu_f.transcribe_description(loc_info.unparsed_unlock)

		self.item_list[item_key] = item_info
		return item_info
	end,

	infobox_template = function(self, args)
        local params = {}

        params.name       = args.name
        params.internalid = args.internalid
        params.mod        = args.mod
        params.image      = args.image
        self.wikitext_unlock(params, args.parsed_unlock)
        self.wikitext_effect(params, args.parsed_effect)

        return Mu_f.block_template_string("DeckInfobox", params, {
            "name",
            "internalid",
            "mod",
            "image",
            "effect", "effect1", "effect2", "effect3", "effect4", "effect5", "effect6",
            "unlock",
        })
	end,

	generate_list_page = function(self, mod_name, item_order)
		local table_concat_table = {}
		for _, item_key in ipairs(item_order) do
			local item_info = self:prepare_values(item_key)
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
		local page = page_format:format(mod_name, #item_order, table_contents)

		----
		local dir = MuExporter.filedirs.mod(mod_name)
		local file_name = "List of " .. self.item_type_name .. ".txt"

		love.filesystem.createDirectory(dir)
		dir = Mu_f.set_dir_slash(dir)
		local did_succeed, err = love.filesystem.write(dir .. file_name, page)
		if not did_succeed then
			print(err)
			return false
		end
		return true
	end
}