---@meta

---@class Mu.CenterExporter
---@field key string An identifier of the item type being exported.
---@field prepare_values function Prepares the values associated with a given item into a table.
---@field item_type_name? string The name of the item type being exported, all words capitalized.
---@field item_list? table A list of items with their values.
---@field vanilla_item_type_name? string The name of the item type that is used by vanilla Balatro. Example: "Back" instead of "Deck".
---@field ordered_item_list? table The table that contains the order of items of the given item type.
---@field loc_desc? table The localization table that contains entries of the given item type.
---@field infobox_template? fun(self: Mu.CenterExporter, args: table): string Generates an infobox of an item.
---@field register_template? fun(self: Mu.CenterExporter, args: table): string Generates a register of an item.
---@field generate_list_page? fun(self: Mu.CenterExporter, mod_name: string, item_order: string[]): boolean Generates a page containing a table of items.
---@field get_localization_text? fun(self: Mu.CenterExporter, item_key: string): {center: table, name: string, unparsed_effect: table, unparsed_unlock: table} Prepares an item's localization for further parsing.
---@field wikitext_unlock? fun(params_table: table, parsed_unlock: table): nil Parses a table of boxes of unlock descriptions into wikitext.
---@field wikitext_effect? fun(params_table: table, parsed_effect: table): nil Parses a table of boxes of effect descriptions into wikitext.
---@field generate_ordered_mod_item_list? fun(self: Mu.CenterExporter, mod_object: Mod): string[] Generates an ordered list of items of a given item type in a mod.
---@field export_sprite? fun(self: Mu.CenterExporter, item_key: string): boolean Exports an item's sprite.
---@field generate_indiviudal_page? fun(self: Mu.CenterExporter, item_key: string): boolean Generates a single page containing an item's infobox. Only runs if an item type's infobox is defined.
---@field generate_registry_section? fun(self: Mu.CenterExporter, mod_name: string, item_order: string[]): boolean Generates a section containing registers for items of a given item type.
---@field mass_export? fun(self: Mu.CenterExporter, mod_id: string): nil Exports all of the items of a given item type from a mod.
---@overload fun(self: Mu.CenterExporter): Mu.CenterExporter
MuExporter.obj.CenterExporter = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, Mu.CenterExporter|table>
MuExporter.exporters = {}