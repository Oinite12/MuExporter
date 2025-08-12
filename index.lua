MuExporter = {}
Mu_f = {}

local function simple_ev(trigger, delay, func)
	G.E_MANAGER:add_event(Event {
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end

MuExporter.data_holders = {}
function Mu_f.get_data_holder(w, h)
	local image_data_holder = MuExporter.data_holders[w .. "*" .. h]
	if image_data_holder == nil then
		image_data_holder = love.image.newImageData(w, h, "rgba8")
		MuExporter.data_holders[w .. "*" .. h] = image_data_holder
	end
	return image_data_holder
end

function Mu_f.split_atlas(atlas_name)
	print("[MU] SPLITTING " .. atlas_name)
	local atlas = SMODS.Atlases[atlas_name]
	local granularity = G.SETTINGS.GRAPHICS.texture_scaling
	local full_px = atlas.px*granularity
	local full_py = atlas.py*granularity

	local col_count = atlas.image_data:getWidth() / (full_px) - 1
	local row_count = atlas.image_data:getHeight() / (full_py) - 1

	local image_data_holder = Mu_f.get_data_holder(full_px, full_py)

	for col = 0, col_count do for row = 0, row_count do
		simple_ev(nil, nil, function()

			print("[MU] " .. atlas_name .. " SPRITE AT " .. ("%s, %s"):format(col, row))
			image_data_holder:paste(
				atlas.image_data,
				0, 0,
				col*full_px, row*full_py,
				full_px, full_py
			)

			image_data_holder:encode(
				"png",
				("MuExporter/%s %s,%s.png"):format(
					atlas_name,
					col, row
				)
			)
			delay(0.01)

		end)
	end end
end