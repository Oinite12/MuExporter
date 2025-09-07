local section_format =
[[== Vouchers ==
<div class="minibox-gallery">
%s
</div>]]

MuExporter.obj.CenterExporter {
	key = 'Vouchers',
	vanilla_item_type_name = 'Voucher',

	prepare_values = function(self, item_key)
		if self.item_list[item_key] then return self.item_list[item_key] end

		local loc_info = self:get_localization_text(item_key)

		local item_info         = {}
		item_info.name          = Mu_f.transcribe_desc_line(loc_info.name)
		item_info.nakedname     = loc_info.name:gsub("{.*}", "")
		item_info.internalid    = item_key
		item_info.mod           = loc_info.center.mod.name
		item_info.image         = Mu_f.format_image_name(item_info.nakedname, item_info.mod, "png")
		item_info.buyprice      = loc_info.center.cost
		item_info.parsed_effect = Mu_f.transcribe_description(loc_info.unparsed_effect)
		item_info.parsed_unlock = Mu_f.transcribe_description(loc_info.unparsed_unlock)

		self.item_list[item_key] = item_info
		return item_info
	end,

	register_template = function(self, args)
		local params = {}

		params.name       = args.name
		params.internalid = args.internalid
		params.mod        = args.mod
		params.buyprice   = args.buyprice
		self.wikitext_unlock(params, args.parsed_unlock)
		if #args.parsed_effect > 0 then
			params.effect = table.concat(args.parsed_effect[1], "<br>")
		end

		return Mu_f.block_template_string("VoucherInfobox", params, {
			"name",
			"internalid",
			"mod",
			"effect",
			"unlock",
			"buyprice",
		})
	end,

	generate_registry_section = function(self, mod_name, item_order)
		local register_concat_table = {}
		for _,item_key in ipairs(item_order) do
			local item_info = self:prepare_values(item_key)
			table.insert(register_concat_table, self:register_template(item_info))
		end

		local register_contents = table.concat(register_concat_table, "\n")
		local section = section_format:format(register_contents)

		----

		local dir = MuExporter.filedirs.mod(mod_name)
		local file_name = self.item_type_name .. " registry section.txt"

		love.filesystem.createDirectory(dir)
		local did_succeed, err = love.filesystem.write(dir .. file_name, section)
		if not did_succeed then
			print(err)
			return false
		end
		return true
	end
}