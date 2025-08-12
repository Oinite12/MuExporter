Mu_f.items.Jokers = {}

-- ============

-- Exports the sprite of a Joker and properly names it.
-- Returns true if export succeeded, else false.
---@param key string
---@return boolean
function Mu_f.items.Jokers.export_sprite(key)
	print("[MU] EXTRACTING JOKER " .. key)

	if key:sub(1,2) ~= "j_" then
		print("[MU] " .. key .. " NOT JOKER, skipping... (what are you doing???)")
		return false
	end

	local joker = G.P_CENTERS[key]
	if not joker then
		print("[MU] " .. key .. " NOT FOUND, skipping...")
		return false
	end

	if not joker.mod then
		print("[MU] " .. key .. " VANILLA (No support for vanilla content yet), skipping...")
		return false
	end

	----

	local joker_name = joker.config.name
	local mod_name = joker.mod.name

	local pos = joker.pos
	local soul_pos = joker.soul_pos
	local atlas = joker.atlas

	----
    local dir = MuExporter.filedirs.mod_imgs(mod_name, "Jokers")
    local file_name = ("%s (%s).png"):format(joker_name, mod_name)

	local joker_sprite = Mu_f.get_atlas_sprite(atlas, pos.x, pos.y) --sets base
	if soul_pos and soul_pos.x and soul_pos.y then
		joker_sprite:overlay_layer(atlas, soul_pos.x, soul_pos.y)
	end
	joker_sprite:export_sprite(dir, file_name)

	return true
end