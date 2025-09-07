MuExporter = {}
Mu_f = {}

MuExporter.mod_path = tostring(SMODS.current_mod.path)

local function load_directory(folder_name)
	local mod_path = MuExporter.mod_path
	local files = NFS.getDirectoryItems(mod_path .. folder_name)
	for _, file_name in ipairs(files) do
		if file_name:match(".lua") then 
			print("[MU] Loading file " .. file_name)
			local file_format = ("%s/%s")
			local file_func, err = SMODS.load_file(file_format:format(folder_name, file_name))

			if err then error(err) end
			if file_func then file_func() end
		end
	end
end

load_directory("lib")
load_directory("modules")
load_directory("item-specific")

-- Needs to be generated as ImageData not provided by vanilla atlases
Mu_f.simple_ev(function ()
	G.ASSET_ATLAS.cards_1.image_data = love.image.newImageData("resources/textures/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/8BitDeck.png")
end)