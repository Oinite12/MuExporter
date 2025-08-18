Mu_f.items.Vouchers = {}
MuExporter.items.Vouchers = {}

local log = Mu_f.log
local simple_ev = Mu_f.simple_ev
local item_F = Mu_f.items.Vouchers
local item_List = MuExporter.items.Vouchers

-- ============
-- DATA PARSING
-- ============

-- Gets a list of Vouchers in the order seen in the Collection.
---@param mod_object Mod
---@return table<integer, string>
function item_F.get_items_in_collection_order(mod_object)
	return Mu_f.items.Centers.get_centers_in_collection_order(mod_object, "Voucher")
end

-- ============

---@class Mu.VoucherInfo
---@field name string
---@field nakedname string
---@field internalid string
---@field mod string
---@field image string
---@field buyprice number
---@field parsed_effect Mu.BoxList
---@field parsed_unlock Mu.BoxList
local j_info_tbl = {}

-- Prepares various descriptions and values associated with the Joker.
---@param key string
---@return Mu.VoucherInfo
function item_F.prepare_values(key)
	if item_List[key] then return item_List[key] end

	local item = Mu_f.set_contained_card(key)
	local center = item.config.center
	local loc_info = Mu_f.items.Centers.get_localization_text("Voucher", key)

	local item_info         = {}
	item_info.name          = Mu_f.transcribe_desc_line(loc_info.name)
	item_info.nakedname     = loc_info.name:gsub("{.*}", "")
	item_info.internalid    = key
	item_info.mod           = center.mod.name
	item_info.image         = Mu_f.format_image_name(item_info.nakedname, item_info.mod, "png")
	item_info.buyprice      = center.cost
	item_info.parsed_effect = Mu_f.transcribe_description(loc_info.unparsed_effect)
	item_info.parsed_unlock = Mu_f.transcribe_description(loc_info.unparsed_unlock)

	item_List[key] = item_info
	return item_info
end

-- ============

-- Generates a VoucherInfobox template.
---@param args Mu.VoucherInfo
---@return string
Mu_f.registers.Vouchers = function(args)
	local params = {}

	params.name       = args.name
	params.internalid = args.internalid
	params.mod        = args.mod
	params.buyprice   = args.buyprice
    Mu_f.items.Centers.wikitext_unlock(params, args.parsed_unlock)
    if #args.parsed_effect > 0 then
		params.effect = table.concat(args.parsed_effect[1], "<br>")
    end

	return Mu_f.block_template_string("VoucherInfobox", params, {
		"name",
		"internalid",
		"mod",
		"effect",
		"unlock",
		"buyprice",
	})
end

-- ============
-- INDIVIDUAL ELEMENT EXPORTS
-- ============

-- Exports the sprite of a Joker and properly names it.\
-- Returns true if export succeeded, else false.
---@param key string
---@return boolean
function item_F.export_sprite(key)
    return Mu_f.items.Centers.export_sprite(key, "Vouchers", "Voucher")
end

-- ============
-- GROUP EXPORTS
-- ============

--[[ UNUSED - not sure how to go about the two-tier stuff
-- Generates the page for the mod's list of Jokers.\
-- Returns true if generation succeeded, else false.\
-- item_order must be a list of Joker keys.
---@param mod_name string
---@param item_order table<integer, string>
---@return boolean
function item_F.generate_list_page(mod_name, item_order)
end
]]

function item_F.generate_registry_section(mod_name, item_order)
    local section_format = [[== Vouchers ==
<div class="minibox-gallery">
%s
</div>]]
    local register_concat_table = {}
    for _,voucher_key in ipairs(item_order) do
        local voucher_info = item_F.prepare_values(voucher_key)
        table.insert(register_concat_table, Mu_f.registers.Vouchers(voucher_info))
    end

    local register_contents = table.concat(register_concat_table, "\n")
    local section = section_format:format(register_contents)

    ----
    
    local dir = MuExporter.filedirs.mod(mod_name)
    local file_name = "Voucher registry section.txt"

    love.filesystem.createDirectory(dir)
    local did_succeed, err = love.filesystem.write(dir .. file_name, section)
    if not did_succeed then
        print(err)
    end
    print(did_succeed)
end

-- ============
-- MASS-EXPORT
-- ============

-- Exports Joker images and data of a given mod.
---@param mod_id string
---@return nil
function item_F.mass_export(mod_id)
	Mu_f.items.Centers.mass_export("Vouchers", "Voucher", mod_id)
end