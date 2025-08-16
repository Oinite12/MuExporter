local list_width = 5
local export_zone_stylesheet = {
    [".root"] = {
        fillColour = G.C.UI.TRANSPARENT_DARK,
        align = "center-middle",
    },
    [".body"] = {
        align = "center-middle",
        padding = 0.05,
        minWidth = 21.5,
        minHeight = 15.75,
    },
    [".body-col"] = {
        align = "center-middle",
        minHeight = 15.75,
        noFill = true,
    },
    [".left-row"] = {
        minHeight = 7.875,
        noFill = true,
        padding = 0.15
    },
    [".list-container"] = {
        fillColour = lighten(G.C.JOKER_GREY, 0.5),
        roundness = 1,
        emboss = 0.2,
    },
    [".list"] = {
        fillColour = G.C.GREY,
        padding = 0.1,
        minHeight = 6.875,
        roundness = 1,
        outlineColour = lighten(G.C.JOKER_GREY, 0.5),
        outlineWidth = 1.5,
    },
    [".list-title-container"] = {
        align = "center-middle",
        minWidth = list_width,
        minHeight = 0.4,
    },
    [".list-title"] = {
        colour = G.C.UI.TEXT_LIGHT,
        scale = 0.75
    },
    [".list-contents"] = {
        minWidth = list_width,
        minHeight = 5.475
    },
    [".list-page-buttons"] = {
        align = "center-middle",
        padding = 0.2,
        minWidth = list_width,
        minHeight = 0.4,
    },
    [".item-label-container"] = {
        padding = 0.1,
    },
    [".item-label"] = {
        colour = G.C.UI.TEXT_LIGHT,
        scale = 0.5
    }
}

local function generate_list_item_jtml(args)
    args = args or {}
    args.label = args.label or "Test"

    return
    {"row", class="list-item", {
        create_toggle{
            col = true,
            hide_label = true,
            callback = args.callback,
            ref_table = args.ref_table,
            ref_value = args.ref_value
        },
        {"column", class="item-label-container", {
            {"text", class="item-label", text=args.label}
        }}
    }}
end

local function generate_mod_list_contents_jtml()
    local returntable = {}
    for _,mod in ipairs(G.exportzone.mod_list) do
        table.insert(returntable, generate_list_item_jtml{
            label = mod[2],
            ref_table = G.exportzone.mod_is_selected,
            ref_value = mod[1]
        })
    end
    return returntable
end

local function generate_item_list_contents_jtml()
    local returntable = {}
    for _,item in ipairs(G.exportzone.item_list) do
        table.insert(returntable, generate_list_item_jtml{
            label = item,
            ref_table = G.exportzone.item_is_selected,
            ref_value = item
        })
    end
    return returntable
end

local function generate_box(args)
    args = args or {}
    args.id = args.id or "list"
    args.label = args.label or "List"

    return
    {"row", class="list-container", {
        {"column", class="list", {
            {"row", class="list-title-container", {
                {"text", class="list-title", text=args.label}
            }},
            {"row", id=args.id .. "_contents", class="list-contents", args.gen_func()},
            {"row", class="list-page-buttons", {

            }},
        }}
    }}
end

Mu_f.create_UIBox_export_zone = function()
    local ez_mod_list = generate_box({id="mod_list", label=localize('b_muexp_mod_list'), gen_func = generate_mod_list_contents_jtml})
    local ez_item_list = generate_box({id="item_list", label=localize('b_muexp_item_list'), gen_func = generate_item_list_contents_jtml})

    local export_zone_jtml =
    {"root", class="root", {
        {"row", class="body", {
            {"column", class="body-col", {
                {"row", class="left-row", style={align="bottom-left"}, {ez_mod_list}},
                {"row", class="left-row", style={align="top-left"}, {ez_item_list}},
            }},
            {"column", class="body-col", style={minWidth = 15}, {

            }}
        }}
    }}

    return Mu_f.jtml_to_uibox(export_zone_jtml, export_zone_stylesheet)
end