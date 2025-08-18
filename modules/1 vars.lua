MuExporter.filedirs = {}
local filedirs = MuExporter.filedirs

filedirs.main = "MuExporter/"
filedirs.atlas_split = filedirs.main .. "atlases/"
filedirs.individual  = filedirs.main .. "individual/"
filedirs.logs        = filedirs.main .. "logs/"
filedirs.bmw         = filedirs.main .. "Modded Balatro Wiki/"

---@param mod_name string
---@return string
filedirs.mod = function(mod_name)
	mod_name = Mu_f.filename_strip(mod_name)
	return filedirs.bmw .. mod_name .. "/"
end

---@param mod_name string
---@param item_type string
---@return string
filedirs.mod_imgs = function(mod_name, item_type)
	item_type = Mu_f.filename_strip(item_type)
	return filedirs.mod(mod_name) .. "Images/" .. item_type
end

---@param mod_name string
---@param item_type string
---@return string
filedirs.mod_pages = function(mod_name, item_type)
	item_type = Mu_f.filename_strip(item_type)
	return filedirs.mod(mod_name) .. "Pages/" .. item_type
end

MuExporter.items = {}
Mu_f.items = {}

MuExporter.log_size = 12
Mu_f.infoboxes = {}