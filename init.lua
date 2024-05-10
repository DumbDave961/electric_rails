--LV Rail
local desc = technic.getter("@1 Rail", technic.getter("LV"))
local active_desc = technic.getter("@1 Active", desc)
local unpowered_desc = technic.getter("@1 Unpowered", desc)
local demand = 5
	
local function rail_run(pos, node)
	local meta = minetest.get_meta(pos)
	local eu_input = meta:get_int("LV_EU_input")
	
	if eu_input < demand and node.name == "electric_rails:lv_rail" then
		technic.swap_node(pos, "moreores:copper_rail")
		meta:set_string("infotext", unpowered_desc)
	elseif eu_input >= demand and node.name == "moreores:copper_rail" then
		technic.swap_node(pos, "electric_rails:lv_rail")
		meta:set_string("infotext", active_desc)
	end
end
	
carts:register_rail("electric_rails:lv_rail", {
	description = (desc),
	tiles = {
		"moreores_copper_rail.png",
		"moreores_copper_rail_curved.png",
		"moreores_copper_rail_t_junction.png",
		"moreores_copper_rail_crossing.png"
	},
	drop = "moreores:copper_rail",
	connect_sides = {"front", "left", "back", "right", "bottom"},
	technic_run = rail_run,
	groups = carts:get_rail_groups({technic_machine = 1, technic_lv = 1, not_in_creative_inventory = 1}),
	}, {acceleration = 5})

--override copper rail
minetest.override_item("moreores:copper_rail", {
	groups = carts:get_rail_groups({technic_machine = 1, technic_lv = 1}),
	connect_sides = {"front", "left", "back", "right", "bottom"},
	technic_run = rail_run,
	on_construct = function(pos)
		meta:set_string("infotext", desc)
		meta:set_int("LV_EU_demand", demand)
	end,
})

technic.register_machine("LV", "moreores:copper_rail", technic.receiver)
technic.register_machine("LV", "electric_rails:lv_rail", technic.receiver)
