--[[
	Deals with special tilemaps and their data.
]]

local asset
local lib
local special

special = {
	sounds = {"wake_up1", "wake_up2", "wake_up3", "wake_up4", "pulse1", -- 1 - 5
		"scratch1", "scratch2", "scratch3", "scratch4", "scratch5", -- 6 - 10
		"tunnel_cue1", "tunnel_cue2" -- 11 - 12
	},
	positions = {
		[150] = "spawn",
		[160] = "shadow_spawn"
	},
	properties = {},
	flags = {},

	vectors = {
		[1] = {500, 0},
		[2] = {0, 500}
	},

	observations = {
		"Your bed. Unmade and slightly damp with sweat.", --1
		"A lamp. It is missing a bulb and is unplugged.", --2
		"A bed-side table. The drawer is open; it is empty.", --3
		"The window is open. All you see outside is black.", --4
		"A soft chair. The fabric is beginning to tear.", --5
		"The door is locked.", --6
	},

	touch_tiles = {
		[1] = function(self, world, g, b) --play sound (1)
			asset:play_sound(self.sounds[g])
		end,
		[2] = function(self, world, g, b) --stop sound (2)
			asset:get(self.sounds[g]):stop()
		end,
		[3] = function(self, world, g, b) --play sound, once (3)
			if (not self.flags[b]) then
				asset:play_sound(self.sounds[g])
				self.flags[b] = true
			end
		end,
		[4] = function(self, world, g, b) --set level (4)
			world.map_manage:change_map(g)
		end,
		[5] = function(self, world, g, b) --cycle level (5)
			world.map_manage:cycle_map()
		end,
		[6] = function(self, world, g, b) --move player (6)
			local x, y = world:grid_to_world(g, b)
			world.character.x = x
			world.character.y = y
		end,
		[7] = function(self, world, g, b) --player shake (7)
			world.shaking = true
		end,
		[8] = function(self, world, g, b) --player pass out (8)
			if not (self.flags["pass_out"]) then
				self.flags["pass_out"] = true

				asset:play_sound("pass_out")
				local soundfade = world.game:sound_fade(3)
				local eyefade = world.game:fade_out(3)

				world.game:queue(function(this, event)
					soundfade(this, event)
					return eyefade(this, event)
				end)

				world.game:queue(function()
					world.character.mobile = false
					world.shaking = false
				end)

				world.game:queue(world.game:wait(3))

				world.game:queue(function(this, event)
					world.character.mobile = true
				end)
				world.game:queue(world.game:fade_in(2))
			end
		end,
		[9] = function(self, world, g, b) -- trigger shadow from shadow_spawn with velocity vector g, flag b (9)
			if (not self.flags[b]) then
				self.flags[b] = true
				world.map_manage:spawn_shadow(self.vectors[g] or {0, 0})
			end
		end,
		[10] = function(self, world, g, b) -- game over (10)
			if (not self.flags.ending) then
				self.flags.ending = true
				world.game:ending()
			end
		end,
	},

	interact_tiles = {
		[50] = function(self, world, g, b) --observation (50)
			world.game:note(self.observations[g] or "INVALID OBSERVATION ID", 3)
		end
	},

	touch_tile = function(self, world, id, ...)
		local tile = self.touch_tiles[id]

		if (tile) then
			tile(self, world, ...)
		end
	end,

	interact_tile = function(self, world, id, ...)
		local tile = self.interact_tiles[id]

		if (tile) then
			tile(self, world, ...)
		end
	end,

	init = function(self, engine)
		asset = engine:lib_get("game.asset")
		lib = engine.lib
	end,
}

return special