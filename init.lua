--LV Rail
if rails_to_use == "technic" or "both" then
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
		},
		{acceleration = 5})
	
	--override copper rail
	minetest.override_item("moreores:copper_rail", {
		groups = carts:get_rail_groups({technic_machine = 1, technic_lv = 1}),
		connect_sides = {"front", "back", "bottom"},
		technic_run = rail_run,
		on_construct = function(pos)
			meta:set_string("infotext", desc)
			meta:set_int("LV_EU_demand", demand)
		end,
	})	
	technic.register_machine("LV", "moreores:copper_rail", technic.receiver)
	technic.register_machine("LV", "electric_rails:lv_rail", technic.receiver)
end

--Powered Rail for elepower
if rails_to_use == "elepower" or "both" then
	--override copper rail
	minetest.override_item("moreores:copper_rail", {
		on_construct = function (pos)
			meta:set_int("storage", 0)
		
			ele.clear_networks(pos)
		end,
		after_destruct = function (pos)
			ele.clear_networks(pos)
		end,
		groups = carts:get_rail_groups({ele_machine = 1, ele_storage = 1}),
		ele_capacity = 4,
		ele_inrush   = 4,
	})
	
	--register the powered rail
	carts:register_rail("electric_rails:powered_rail", {
		description = carts.get_translator("Powered Rail"),
		tiles = {
			"moreores_copper_rail.png",
			"moreores_copper_rail_curved.png",
			"moreores_copper_rail_t_junction.png",
			"moreores_copper_rail_crossing.png"
		},
		groups = carts:get_rail_groups({ele_machine = 1, ele_user = 1, not_in_creative_inventory = 1}),
		drop = "moreores:copper_rail",
		ele_capacity = 32,
		ele_usage    = 1,
		ele_inrush   = 4,
		}, {acceleration = 5})
	
	function unpowered_rail_swap(new_rail)
		local meta = minetest.get_meta(pos)
		local storage = meta:get_int("storage")
		if storage < 1 then
			minetest.swap_node(pos, {name = new_rail})
			meta:set_int("storage", 0)
		end
	end
	
    minetest.register_abm({
        nodenames = {"electric_rails:powered_rail"}, -- replace with the name of the rail
		interval = 1, -- runs every 1 second
    	chance = 1, -- always fires
		action = unpowered_rail_swap("moreores:copper_rail"),
    })
	
	function rail_is_powered(new_rail)
		local meta = minetest.get_meta(pos)
		local storage = meta:get_int("storage")
		if storage > 1 then
			minetest.swap_node(pos, name = {new_rail})
			meta:set_int("storage", 4)
			meta:set_string("infotext", ele.capacity_text)
    	end
	end
	
    minetest.register_abm({
        nodenames = {"moreores:copper_rail"}, -- replace with the name of the rail
		interval = 1, -- runs every 1 second
    	chance = 1, -- always fires
		action = rail_is_powered("electric_rails:powered_rail"),
    })
end