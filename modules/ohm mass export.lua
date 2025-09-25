local log = Mu_f.log

function G.FUNCS.mass_export_ondraw(e)
	e.config.colour = G.C.RED
	e.config.button = 'mass_export'
end

local easter_egg_1 = false
local easter_egg_2 = false
local easter_egg_3 = false
local easter_egg_4 = false

function G.FUNCS.mass_export(e)
	local selected_mods = {}
	local selected_items = {}

	for _,mod in ipairs(G.export_zone.mod_list) do
		local mod_id = mod[1]
		local mod_name = mod[2]
		if G.export_zone.mod_is_selected[mod_id] then
			table.insert(selected_mods, mod_id)
		end
	end
	for _,item in ipairs(G.export_zone.item_list) do
		if G.export_zone.item_is_selected[item] then
			table.insert(selected_items, item)
		end
	end

	if #selected_mods == 0 and #selected_items == 0 then
		if MuExporter.enable_easter_egg then
			log("CAN'T EXPORT IF YOU DON'T SPECIFY ANYTHING, DUMBASS")
			log("(Select a mod and item to begin export!)")
		else
			log("Please select a mod and item to begin exporting!")
			easter_egg_1 = true
		end
		return
	elseif #selected_mods == 0 then
		log("Please select a mod to begin exporting!")
		easter_egg_2 = true
		return
	elseif #selected_items == 0 then
		log("Please select an item type to begin exporting!")
		easter_egg_3 = true
		return
	end
	MuExporter.enable_easter_egg = easter_egg_1 and easter_egg_2 and easter_egg_3 and easter_egg_4

	log("STARTING EXPORT - Expect freezing!!")
	for _,mod_id in ipairs(selected_mods) do
		for _,item in ipairs(selected_items) do
			MuExporter.exporters[item]:mass_export(mod_id)
		end
	end

	Mu_f.simple_ev(function()
		local undefined_ct_list = {"Text colour, background colour"}
		for _,row in pairs(MuExporter.undefined_ct_codes) do table.insert(undefined_ct_list, row) end
		love.filesystem.createDirectory(MuExporter.filedirs.bmw)
		local ct_filename = MuExporter.filedirs.bmw .. "Undefined Ct codes.txt"
		local ct_filecontent = table.concat(undefined_ct_list, "\n")
		love.filesystem.write(ct_filename, ct_filecontent)
	end)

	log("EXPORT COMPLETE - can be found in %AppData%/Balatro/MuExporter/Modded Balatro Wiki")

	Mu_f.simple_ev(function()
		if next(MuExporter.undefined_ct_codes) ~= nil then
			log("Undefined CT codes detected: Please send the 'Undefined Ct codes.txt' file to")
			log("    the BMW Discord server or the MuExporter repository.")
		end
		easter_egg_4 = true
	end)
end