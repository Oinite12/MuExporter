MuExporter.exporters = {} -- Registered exporters
MuExporter.items = {} -- prepare_values tables
MuExporter.obj = {} -- Objects that are used to register exporters

MuExporter.obj.Exporter = SMODS.GameObject:extend {
	set = 'Exporters',
	obj_table = MuExporter.exporters,
	obj_buffer = {},
	prefix_config = { key = false },

	required_params = {
		'key',
		'prepare_values',
		'get_localization_text',
		'generate_ordered_mod_item_list'
	},

	inject = function(self)
		self.item_type_name = self.item_type_name or self.key
		MuExporter.items[self.key] = {}
		self.item_list = self.item_list or MuExporter.items[self.key]

		self.vanilla_item_type_name = self.vanilla_item_type_name or self.key
		self.loc_desc = self.loc_desc or G.localization.descriptions[self.vanilla_item_type_name]
		self.extra = {}
	end,



	wikitext_effect = function(params_table, parsed_effect)
		if #parsed_effect == 1 then
			params_table.effect = table.concat(parsed_effect[1], "<br>")
		elseif #parsed_effect > 1 then
			for i, box in ipairs(parsed_effect) do
				params_table["effect" .. i] = table.concat(box, "<br>")
			end
		end
	end,

	generate_individual_page = function(self, item_key)
		local item_data = self:prepare_values(item_key)
		local infobox_text = self:infobox_template(item_data)
		local page_format = [[{{modsubpage|%s}}
{{auto generated|MuExporter}}
%s
]]
		local page = page_format:format(self.item_type_name, infobox_text)
		----
		local dir = MuExporter.filedirs.mod_pages(item_data.mod, self.item_type_name)
		local file_name = item_data.nakedname .. ".txt"

		love.filesystem.createDirectory(dir)
		dir = Mu_f.set_dir_slash(dir)
		local did_succeed, err = love.filesystem.write(dir .. file_name, page)
		if not did_succeed then
			print(err)
			return false
		end

		return true
	end,

	generate_ordered_mod_item_list = function(self, mod_object)
		local order = {}
		for _,item in ipairs(self.ordered_item_list) do
			if item.original_mod == mod_object then
				table.insert(order, item.key)
			end
		end
		return order
	end,

	mass_export = function(self, mod_id)
		local mod_object = SMODS.Mods[mod_id]
		local mod_name = mod_object.name or "unspecified_mod"

		Mu_f.log(("Exporting %s %s..."):format(mod_name, self.item_type_name))
		local ordered_mod_item_list = self:generate_ordered_mod_item_list(mod_object)

		for _,item_key in ipairs(ordered_mod_item_list) do
			if self.export_sprite then
				Mu_f.simple_ev(function()
					self:export_sprite(item_key)
				end)
			end
			if self.infobox_template then
				Mu_f.simple_ev(function()
					self:generate_individual_page(item_key)
				end)
			end
		end

		if self.generate_list_page then
			Mu_f.simple_ev(function ()
				self:generate_list_page(mod_name, ordered_mod_item_list)
			end)
		end

		if self.generate_list_section then
			Mu_f.simple_ev(function ()
				self:generate_list_section(mod_name, ordered_mod_item_list)
			end)
		end

		if self.register_template then
			Mu_f.simple_ev(function ()
				self:generate_registry_section(mod_name, ordered_mod_item_list)
			end)
		end

		Mu_f.log(("Export of %s %s DONE"):format(mod_name, self.item_type_name))
	end,
}