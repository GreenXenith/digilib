minetest.register_node("digilib:library", {
	description = "Digilines Library",
	groups = {cracky=3},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec","field[channel;Channel;${channel}")
	end,
	tiles = {
		"digilib_library_top.png^[combine:64x64:24,25=default_book.png",
		"jeija_microcontroller_bottom.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png",
		"jeija_microcontroller_sides.png"
	},
	drawtype = "nodebox",
	selection_box = {
		--From luacontroller
		type = "fixed",
		fixed = { -8/16, -8/16, -8/16, 8/16, -5/16, 8/16 },
	},
	node_box = {
		--From Luacontroller
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16}, -- Bottom slab
			{-5/16, -7/16, -5/16, 5/16, -6/16, 5/16}, -- Circuit board
			{-3/16, -6/16, -3/16, 3/16, -5/16, 3/16}, -- IC
		}
	},
	paramtype = "light",
	sunlight_propagates = true,
	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		if minetest.is_protected(pos,name) and not minetest.check_player_privs(name,{protection_bypass=true}) then
			minetest.record_protection_violation(pos,name)
			return
		end
		local meta = minetest.get_meta(pos)
		if fields.channel then meta:set_string("channel",fields.channel) end
	end,
	digiline = {
		receptor = {},
		effector = {
			action = function(pos, node, channel, msg)
				local meta = minetest.get_meta(pos)
				if meta:get_string("channel") ~= channel then return end
				if type(msg) == "string" or (msg.func and msg.func == "recipes") then
					if msg.item then msg = msg.item end
					digiline:receptor_send(pos, digiline.rules.default, channel, minetest.get_all_craft_recipes(msg))
				elseif msg.func == "groups" then
					if msg.item and msg.group then
						digiline:receptor_send(pos, digiline.rules.default, channel, minetest.get_item_group(msg.item, msg.group))
					end
				end
			end
		},
	},
})

minetest.register_craft({
	output = "digilib:library",
	type = "shapeless",
	recipe = {"default:book", "digilines:wire_std_00000000", "mesecons_luacontroller:luacontroller0000"}
})
