local section_format =
[[== Editions ==
{{auto generated|MuExporter}}
{| class="wikitable sortable"
! Edition !! Name !! Effect
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
	key = 'Editions',
	vanilla_item_type_name = 'Edition',

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

		self.item_list[item_key] = item_info
		return item_info
	end,

	export_sprite = function(self, item_key)
		local item = G.P_CENTERS[item_key]
		if not (item and item.mod) then return false end

		local mod_name = Mu_f.filename_strip(item.mod.name)
		local item_name = Mu_f.filename_strip(self:prepare_values(item_key).nakedname)

		local granularity = G.SETTINGS.GRAPHICS.texture_scaling
		local dummy_card = Mu_f.set_contained_center('j_joker') --[[@as table|Card]]
		dummy_card:set_edition(item_key, true, true)
		local dummy_sprite = dummy_card.children.center
		local dummy_sprite_w = dummy_sprite.scale.x*granularity
		local dummy_sprite_h = dummy_sprite.scale.y*granularity

        local shader_key = item.shader or 'dissolve'
		local shader = G.SHADERS[shader_key]
		local shader_file_name = SMODS.Shaders[shader_key] and SMODS.Shaders[shader_key].original_key or shader_key
		-- This is manually set for full replicability
		shader:send( 'mouse_screen_pos' , {0, 0}                              )
		shader:send( 'screen_scale'     , G.TILESCALE*G.TILESIZE*G.CANV_SCALE )
		shader:send( 'hovering'         , 0                                   )
		shader:send( 'dissolve'         , 0                                   )
		shader:send( 'time'             , 0                                   )
		shader:send( 'texture_details'  , dummy_sprite:get_pos_pixel()        )
		shader:send( 'image_details'    , dummy_sprite:get_image_dims()       )
		shader:send( 'burn_colour_1'    , G.C.CLEAR                           )
		shader:send( 'burn_colour_2'    , G.C.CLEAR                           )
		shader:send( 'shadow'           , false                               )
		shader:send( shader_file_name   , {0, 0}                              )

		-- Massive credits to CardExporter for the procedure on how to export shader results
		local canvas = love.graphics.newCanvas(dummy_sprite_w, dummy_sprite_h, {type = '2d', readable = true})
		-- Creating a new canvas instance per edition is fine since editions aren't all too common
		local previous_canvas = love.graphics.getCanvas()
		love.graphics.push()
		love.graphics.setCanvas(canvas)
		love.graphics.clear{0, 0, 0, 0}
		love.graphics.setColor{1, 1, 1, 1}
		love.graphics.setShader(shader)
		love.graphics.draw(
			dummy_sprite.atlas.image,
			-- This is a Quad, whatever that means, but it can input for x and y
			dummy_sprite.sprite,
			0, 0, 0, 2, 2
		)
		love.graphics.setShader()
		love.graphics.setCanvas(previous_canvas)
		love.graphics.pop()

		local dir = MuExporter.filedirs.mod_imgs(mod_name, self.item_type_name)
		local file_name = ("%s (%s).png"):format(item_name, mod_name)
		-- ====
		love.filesystem.createDirectory(dir)
		dir = Mu_f.set_dir_slash(dir)
		canvas:newImageData():encode("png", (dir .. file_name))
		canvas:release() -- Remove instance of canvas to prevent build-up
		dummy_card:set_edition(nil, true, true)

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