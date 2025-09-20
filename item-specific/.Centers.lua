MuExporter.exporters = {}
MuExporter.items = {}
MuExporter.obj = {}

MuExporter.obj.CenterExporter = SMODS.GameObject:extend {
	set = 'CenterExporters',
	obj_table = MuExporter.exporters,
	obj_buffer = {},
	prefix_config = { key = false },

	required_params = {
		'key',
		'prepare_values'
	},

	inject = function(self)
		self.item_type_name = self.item_type_name or self.key
		MuExporter.items[self.key] = {}
		self.item_list = self.item_list or MuExporter.items[self.key]

		self.vanilla_item_type_name = self.vanilla_item_type_name or self.key
		self.ordered_item_list = G.P_CENTER_POOLS[self.vanilla_item_type_name]
		self.loc_desc = self.loc_desc or G.localization.descriptions[self.vanilla_item_type_name]
	end,



	get_localization_text = function(self, item_key)
		local item = Mu_f.set_contained_center(item_key)
		local center = item.config.center

		local loc_vars = center.loc_vars and center:loc_vars({}, item) or {vars = {}}
		local locked_loc_vars = center.locked_loc_vars and center:locked_loc_vars({}, item) or {vars = {}}
		local localization = self.loc_desc[item_key]
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
	end,

	wikitext_unlock = function(params_table, parsed_unlock)
		if #parsed_unlock > 0 then
			params_table.unlock = table.concat(parsed_unlock[1], "<br>")
		end
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

	export_sprite = function(self, item_key)
		local item = G.P_CENTERS[item_key]
		if not (item and item.mod) then return false end
		if not SMODS.Atlases[item.atlas] then return false end

		local mod_name = item.mod.name
		local item_name = self:prepare_values(item_key).nakedname

		local pos = item.pos
		local soul_pos = item.soul_pos
		local atlas = item.atlas

		local item_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y)
		if soul_pos and soul_pos.x and soul_pos.y then
			item_sprite:overlay_layer(atlas, soul_pos.x, soul_pos.y)
		end

		local dir = MuExporter.filedirs.mod_imgs(mod_name, self.item_type_name)
		local file_name = ("%s (%s).png"):format(item_name, mod_name)
		item_sprite:export_sprite(dir, file_name)

		return true
	end,

	mass_export = function(self, mod_id)
		local mod_object = SMODS.Mods[mod_id]
		local mod_name = mod_object.name or "unspecified_mod"

		Mu_f.log(("Exporting %s %s..."):format(mod_name, self.item_type_name))
		local ordered_mod_item_list = self:generate_ordered_mod_item_list(mod_object)

		for _,item_key in ipairs(ordered_mod_item_list) do
			Mu_f.simple_ev(function()
				self:export_sprite(item_key)
			end)
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