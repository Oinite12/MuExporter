MuExporter.filedirs = {}
local filedirs = MuExporter.filedirs

filedirs.main = "MuExporter/"
filedirs.atlas_split = filedirs.main .. "atlases/"
filedirs.individual  = filedirs.main .. "individual/"
filedirs.logs        = filedirs.main .. "logs/"

---@param mod_name string
---@param item_type string
---@return string
filedirs.mod_imgs = function(mod_name, item_type)
	return filedirs.main .. "mods/" .. mod_name .. "/Images/" .. item_type
end

Mu_f.items = {}

MuExporter.log_size = 12