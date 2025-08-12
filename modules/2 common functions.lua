-- A shorthand of adding an event to G.E_MANAGER that only defines the properties func.\
-- Event function will always return true, so "return true" is not required.\
-- Consequently, do not use this function if the event function needs to return a non-true value,\
-- or if other parameters such as trigger or blocking require specification.
---@param func function
---@return nil
Mu_f.simple_ev = function(func)
	G.E_MANAGER:add_event(Event {
		func = function()
			func()
			delay(0.1)
			return true
		end
	})
end

-- ============

---@type table<string, boolean>
local illegal_file_name_characters = {
	["#"]=true, ["<"]=true, [">"]=true, ["["]=true, ["]"] =true, ["|"]=true,
	[":"]=true, ["{"]=true, ["}"]=true, ["/"]=true, ["\\"]=true,
}

-- Replaces the characters #<>[]|:{}/\\ \
-- (illegal file name characters) with -.
---@param input string
---@return string
function Mu_f.filename_strip(input)
	local newstring = {}
	for i=1,#input do
		local char = input:sub(i,i)
		table.insert(newstring, illegal_file_name_characters[char] and "-" or char)
	end
	return table.concat(newstring)
end

-- ============

-- Returns a string of the form <atlas_name> <x>,<y>.png .
---@param atlas_name string
---@param x integer|string
---@param y integer|string
---@return string
function Mu_f.default_img_name(atlas_name, x, y)
	return ("%s %s,%s.png"):format(atlas_name, x, y)
end

-- ============

-- Sets a slash after the directory path if needed.
---@param dir_path string
---@return string
function Mu_f.set_dir_slash(dir_path)
	return dir_path:sub(-1) == "/" and dir_path or dir_path .. "/"
end