local simple_ev = Mu_f.simple_ev

-- ============

-- Extracts a single sprite from an atlas places it\
-- on an image data holder.
---@param atlas_name string
---@param x integer
---@param y integer
---@return love.ImageData
function Mu_f.extract_atlas_sprite(atlas_name, x, y)
	local atlas = SMODS.Atlases[atlas_name]
	local granularity = G.SETTINGS.GRAPHICS.texture_scaling
	local full_px = atlas.px*granularity
	local full_py = atlas.py*granularity
	local image_data_holder = Mu_f.get_data_holder(full_px, full_py)

	image_data_holder:paste(
		atlas.image_data,
		0, 0,
		x*full_px, y*full_py,
		full_px, full_py
	)
	return image_data_holder
end

-- ============

-- Adds a layer over an image data holder given an atlas and atlas position.
---@param image_data_holder love.ImageData
---@param atlas_name string
---@param pos_x integer
---@param pos_y integer
function Mu_f.add_sprite_layer(image_data_holder, atlas_name, pos_x, pos_y)
	local atlas = SMODS.Atlases[atlas_name]
	local granularity = G.SETTINGS.GRAPHICS.texture_scaling
	local full_px = atlas.px*granularity
	local full_py = atlas.py*granularity

	local function over(x, y, br, bg, bb, ba)
		-- "a over b"
		-- based on formulae in https://en.wikipedia.org/wiki/Alpha_compositing#Description

		-- over channels
		local ar,ag,ab,aa = atlas.image_data:getPixel(pos_x*full_px + x, pos_y*full_py + y)

		if aa == 0 then return br, bg, bb, ba end

		-- return channels
		local ra = aa + ba*(1 - aa)
		local rr = (ar*aa + br*ba*(1 - aa))/ra
		local rg = (ag*aa + bg*ba*(1 - aa))/ra
		local rb = (ab*aa + bb*ba*(1 - aa))/ra

		return rr,rg,rb,ra
	end

	image_data_holder:mapPixel(over)
end

-- ============

-- Exports the image in the image data holder.
---@param image_data_holder love.ImageData
---@param dir string
---@param file_name string
function Mu_f.export_sprite(image_data_holder, dir, file_name)
	love.filesystem.createDirectory(dir)
	dir = Mu_f.set_dir_slash(dir)
	image_data_holder:encode("png", (dir .. file_name))
end