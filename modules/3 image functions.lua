---@type table<string, Mu.ImageDataHolder|nil>
MuExporter.image_data_holders = {}

---@class Mu.ImageDataHolder
---@field w integer
---@field h integer
---@field id string
---@field image_data love.ImageData
MuExporter.ImageDataHolder = Object:extend()
function MuExporter.ImageDataHolder:init(w,h)
	self.w = w
	self.h = h
	if not (self.w and self.h) then
		error("[MU] ImageDataHolder not given width or height")
	end

	self.id = w .. "*" .. h
	self.image_data = love.image.newImageData(w,h,"rgba8")

	if getmetatable(self) == MuExporter.ImageDataHolder then
		MuExporter.image_data_holders[self.id] = self
	end
end

-- Adds a layer over an image data holder given an atlas and atlas position.
---@param atlas_name string
---@param pos_x integer
---@param pos_y integer
---@return nil
function MuExporter.ImageDataHolder:overlay_layer(atlas_name, pos_x, pos_y)
	local atlas = SMODS.Atlases[atlas_name]
	local granularity = G.SETTINGS.GRAPHICS.texture_scaling
	local full_px = atlas.px*granularity
	local full_py = atlas.py*granularity

	local function over(x, y, r, g, b, a)
		-- "a over b"
		-- based on formulae in https://en.wikipedia.org/wiki/Alpha_compositing#Description

		-- over channels
		local over_r,over_g,over_b,over_a = atlas.image_data:getPixel(pos_x*full_px + x, pos_y*full_py + y)
		if over_a == 0 then
			return r, g, b, a
		elseif over_a == 1 then
			return over_r, over_g, over_b, over_a
		end

		-- return channels
		local return_a = over_a + a*(1 - over_a)
		local return_r = (over_r*over_a + r*a*(1 - over_a))/return_a
		local return_g = (over_g*over_a + g*a*(1 - over_a))/return_a
		local return_b = (over_b*over_a + b*a*(1 - over_a))/return_a

		return return_r, return_g, return_b, return_a
	end

	self.image_data:mapPixel(over)
end

-- Exports the image in the image data holder.
---@param dir string
---@param file_name string
---@return nil
function MuExporter.ImageDataHolder:export_sprite(dir, file_name)
	love.filesystem.createDirectory(dir)
	dir = Mu_f.set_dir_slash(dir)
	self.image_data:encode("png", (dir .. file_name))
end

-- ============

-- Retrieve an image data holder with some width and height.
---@param w integer
---@param h integer
---@return Mu.ImageDataHolder
function Mu_f.get_image_data_holder(w, h)
	-- We do it this way so we're not unnecessarily creating image data objects

	local image_data_holder = MuExporter.image_data_holders[w .. "*" .. h]
	if image_data_holder == nil then
		image_data_holder = MuExporter.ImageDataHolder(w, h)
	end
	return image_data_holder
end

-- ============

-- Extracts a single sprite from an atlas places it\
-- on an image data holder.
---@param atlas_name string
---@param x integer
---@param y integer
---@return Mu.ImageDataHolder
function Mu_f.get_atlas_sprite(atlas_name, x, y)
	local atlas = SMODS.Atlases[atlas_name]
	local granularity = G.SETTINGS.GRAPHICS.texture_scaling
	local full_px = atlas.px*granularity
	local full_py = atlas.py*granularity
	local image_data_holder = Mu_f.get_image_data_holder(full_px, full_py)

	image_data_holder.image_data:paste(
		atlas.image_data,
		0, 0,
		x*full_px, y*full_py,
		full_px, full_py
	)
	return image_data_holder
end