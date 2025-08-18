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

-- ============
function Mu_f.set_contained_card(key)
	-- Card needs to be created to access locvars
	local area = G.export_zone.CenterContainer
	if area.cards[1] then
		local thing = area.cards[1]
		area:remove_card(thing)
		thing:remove()
	end
	return SMODS.add_card {
		key = key,
		area = area,
		skip_materialize = true,
		no_edition = true,
	}
end

-- ============

-- Removes spaces around the input.
---@param input string
---@return string
function Mu_f.trim(input)
	local returnstr = input:gsub("^%s+", ""):gsub("%s+$", "")
	return returnstr
end
local trim = Mu_f.trim

-- Splits the input by a character or Lua pattern.
---@param input string
---@param sep string
---@param doTrim? boolean
---@return table<number,string>
function Mu_f.split(input, sep, doTrim)
	-- this function taken from https://stackoverflow.com/a/7615129
	if sep == nil then sep = "%s" end
	local t = {}
	for str in input:gmatch("([^"..sep.."]+)") do
		table.insert(t, doTrim and trim(str) or str)
	end
	return t
end
local split = Mu_f.split

-- ============

-- Creates a file name for images that complies with the BMW style guide.
---@param item_name string
---@param mod string
---@param extension string
---@return string
function Mu_f.format_image_name(item_name, mod, extension)
	item_name = Mu_f.filename_strip(item_name)
	return ("%s (%s).%s"):format(item_name, mod, extension)
end

-- ============

-- Generates a wikitext template in block format.
---@param name string
---@param params table<string, any>
---@param order table<integer, string>
---@return string
function Mu_f.block_template_string(name, params, order)
	local start_tag = "{{" .. name
	local end_tag   = "}}"

	local concat_table = {start_tag}
	for _,param_name in ipairs(order) do
		local param_value = params[param_name]
		if param_value ~= nil then
			table.insert(concat_table, ("| %s = %s"):format(param_name, param_value))
		end
	end
	table.insert(concat_table, end_tag)
	return table.concat(concat_table, "\n")
end

-- ============

-- Sets variables in descriptions.\
-- Descriptions should contain a table for each box in an item's description;\
-- then each such table should contain a list of strings for the item's description.
---@param variables table<integer, any>
---@param descriptions table<integer, table<integer, string>>
function Mu_f.set_loc_vars(variables, descriptions)
	for i, value in ipairs(variables) do
		for _, box in ipairs(descriptions) do
			for row, text in ipairs(box) do
				box[row] = text:gsub(("#%s#"):format(i), value)
			end
		end
	end
end

-- ============

MuExporter.undefined_ct_codes = {}

-- Determines which CT code to use.
---@param text_colour string
---@param background_colour string
---@param variable string
---@return string|nil
local function determine_code(text_colour, background_colour, variable)
	if variable then return "UNKNOWN-COLOUR" end
	if not text_colour and not background_colour then return end
	local undefined_ct_code = ("C:%s, X:%s"):format(text_colour or "{}", background_colour or "{}")
	MuExporter.undefined_ct_codes[undefined_ct_code] = true
	return "UNDEFINED-COLOUR"
end

-- Transcribes a single line of a Balatro description into wikitext.
---@param line string
---@return string
function Mu_f.transcribe_desc_line(line)
	local line_prepare = {}
	local split_line = split(line, "{")

	for _,section in ipairs(split_line) do
		local section_split = split(section, "}")
		local control = #section_split == 2 and section_split[1] or ""
		control = trim(control)
		local text = section_split[#section_split] or ""

		local section_info = {text = text}

		local start_tag = "<%s>"
		local end_tag = "</%s>"
		local ct_format = "{{ct|%s|%s}}"

		-- Parse control syntax
		local control_split = split(control, ",")
		for _,control_segment in ipairs(control_split) do
			local seg_split = split(control_segment, ":", true)
			local control_key = seg_split[1]
			local control_value = seg_split[2]
			section_info[control_key:lower()] = control_value
		end

		-- Determine CT code
		section_info.ct_code = determine_code(section_info.c, section_info.x, section_info.v)

		-- Determine size tags
		if section_info.s then
			section_info.s = tonumber(section_info.s)
			if section_info.s > 1 then
				start_tag = start_tag:format("big")
				end_tag = end_tag:format("big")
			elseif section_info.s < 1 then
				start_tag = start_tag:format("small")
				end_tag = end_tag:format("small")
			else
				section_info.s = nil
				start_tag = ""
				end_tag = ""
			end
		else
			start_tag = ""
			end_tag = ""
		end

		local preserve_startspace = text:sub(1, 1) == " " and " " or ""
		local preserve_endspace   = text:sub(text:len(), text:len()) == " " and " " or ""

		section_info.final_text = table.concat({
			preserve_startspace,
			start_tag,
			section_info.ct_code and ct_format:format(section_info.ct_code, trim(text)) or trim(text),
			end_tag,
			preserve_endspace
		})
		table.insert(line_prepare, section_info)
	end

	local line_concat = {}

	for i=1, (#line_prepare) do
		local segment = line_prepare[i]   -- 1
		local next_seg = line_prepare[i+1]  -- 2
		local cross_seg = line_prepare[i+2] -- 3

		-- Merging Ct groups
		-- Segments must NOT be scaled otherwise this will happen and break things:
		-- <big>{{Ct|test|... {{Ct|test2|...}}</big> test}}
		if (
			segment.ct_code and not segment.s
			and next_seg and next_seg.ct_code -- Check required as there is no nil ct_code
			and cross_seg and cross_seg.ct_code and not cross_seg.s
			and cross_seg.ct_code == segment.ct_code
		) then
			line_prepare[i].final_text = segment.final_text:gsub("}}$", "")
			line_prepare[i+2].final_text = cross_seg.final_text:gsub(("^{{ct|%s|"):format(cross_seg.ct_code), "")
		end

		-- Merging size groups
		if (
			segment.s and next_seg and next_seg.s and segment.s == next_seg.s
		) then
			line_prepare[i].final_text = segment.final_text:gsub("</big>$",""):gsub("</small>$","")
			line_prepare[i+1].final_text = next_seg.final_text:gsub("<^[^/]big>",""):gsub("<^[^/]small>","")
		end

		table.insert(line_concat, line_prepare[i].final_text)
	end

	return table.concat(line_concat)
end

-- Transcribes a Balatro description table into wikitext.
---@param input table
---@return table
function Mu_f.transcribe_description(input)
	local all_boxes = {}

	for _,box in ipairs(input) do
		local parsed_table = {}
		for _,line in ipairs(box) do
			table.insert(parsed_table, Mu_f.transcribe_desc_line(line))
		end
		table.insert(all_boxes, parsed_table)
	end

	return all_boxes
end