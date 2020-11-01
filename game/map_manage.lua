--[[
	Manages and renders maps!
]]

local lib
local asset
local map_manage

map_manage = {
	tile_size = 16,
	tile_scale = 6,
	tile_source = {
		{"tilefloor_small", "tilefloor_big", "bed_top", "bed_bottom"}, -- 1 - 4
		{"fall_rubble1", "fall_rubble2", "fall_rubble3", "fall_rubble4"}, -- 5 - 8
		{"stairs_down_left", "stairs_down_right", "floor_base", "lamp"}, -- 9 - 12
		{"bed_table", "comfy_chair", "sidewalk", "dark_gray"}, -- 13 - 16
		{"wall_up", "wall_down", "wall_right", "wall_left"}, -- 17 - 20
		{"wall_top_right_outer", "wall_top_left_outer", "wall_bottom_left_outer", "wall_bottom_right_outer"}, -- 21 - 24
		{"wall_top_right_inner", "wall_top_left_inner", "wall_bottom_left_inner", "wall_bottom_right_inner"}, -- 25 - 28
		{"window_right", "door_up", "door_down", ""} -- 29 - 32
	},
	tile_quads = {},
	changing_map = false,
	maps = {},
	glow = {
		{200, 50, 1}, --1
		{200, 30, 0.5}, --2
		{210, 45, 1.2}, --3
		{180, 60, 0.7}, --4
		{180, 60, 1.6}, --5
	},
	map_resource = {
		[1] = function(self)
			asset:load_sound("ambient1", "ambient1.ogg"):setLooping(true)

			local pulse1 = asset:load_world_sound("pulse1", "pulse1.ogg")
			pulse1:setLooping(true)
			pulse1:setPosition(200, 2200, 0)
			pulse1:setDistance(200, 2500)

			asset:load_sound("wake_up1", "wake_up1.ogg")
			asset:load_sound("wake_up2", "wake_up2.ogg")
			asset:load_sound("wake_up3", "wake_up3.ogg")
			asset:load_sound("wake_up4", "wake_up4.ogg")

			asset:load_sound("second_theme", "second_theme.ogg", "stream")
		end,

		[2] = function(self)
			local whistle_stereo = asset:load_sound("whistle1_stereo", "whistle1_stereo.ogg", "stream")
			whistle_stereo:setLooping(true)
			whistle_stereo:setVolume(0.1)

			local whistle1 = asset:load_sound("whistle1", "whistle1.ogg", "stream")
			whistle1:setVolume(0.5)
			whistle1:setLooping(true)
			whistle1:setPosition(90, 150, 0)
			whistle1:setDistance(50, 800)

			asset:load_sound("scratch1", "scratch1.ogg", "stream"):setLooping(true)
			asset:load_sound("scratch2", "scratch2.ogg", "stream"):setLooping(true)
			asset:load_sound("scratch3", "scratch3.ogg", "stream"):setLooping(true)
			asset:load_sound("scratch4", "scratch4.ogg", "stream"):setLooping(true)
			asset:load_sound("scratch5", "scratch5.ogg", "stream"):setLooping(true)

			asset:load_sound("bang1", "bang1.ogg")
			asset:load_sound("pass_out", "pass_out.ogg")
			asset:load_sound("door_open", "door_open.ogg")
		end,

		[4] = function(self)
			asset:load_sound("tunnel_ambient", "tunnel_ambient.ogg", "stream"):setLooping(true)
			asset:load_sound("tunnel_cue1", "tunnel_cue1.ogg")
			asset:load_sound("tunnel_cue2", "tunnel_cue2.ogg")
		end,
	},

	map_in = {
		[1] = function(self, game)
			game:queue(game:fade_in(1))
			game:note("Use [W] and [S] and [MOUSE] to move.", 3)
			game:note("Hold [SHIFT] to sprint", 3)

			asset:play_sound("ambient1")
		end,

		[2] = function(self, game)
			game:note("Press [SPACE] to observe objects.", 2)
			game:queue(function(this, event)
				asset:play_sound("whistle1")
			end)
			game:queue(game:fade_in(1))
		end,

		[3] = function(self, game)
			asset:play_sound("door_open")
			asset:play_sound("whistle1_stereo")

			game:queue(game:fade_in(2))
		end,

		[4] = function(self, game)
			asset:play_sound("tunnel_ambient")
			game:queue(game:fade_in(2))
		end,

		[5] = function(self, game)
			game:queue(game:fade_in(2))
		end,
	},

	map_out = {
		[1] = function(self, game)
			local sound1 = game:sound_fade(2)
			local fade1 = game:fade_out(2)

			game:queue(function(this, event)
				sound1(this, event)
				return fade1(this, event)
			end)

			game:queue(game:wait(1))
			game:queue(function()
				asset:play_sound("second_theme")
			end)

			game:queue(game:wait(4))
			game:queue(function()
				self:change_map(2, true)
			end)
		end,

		[2] = function(self, game)
			game:queue(game:fade_out(1))
			game:queue(function()
				self:change_map(3, true)
			end)
		end,

		[3] = function(self, game)
			local sound1 = game:sound_fade(2)
			local fade1 = game:fade_out(2)

			game:queue(function(this, event)
				sound1(this, event)
				return fade1(this, event)
			end)

			game:queue(function()
				self:change_map(4, true)
			end)
		end,

		[4] = function(self, game)
			game:queue(game:fade_out(2))

			game:queue(function()
				self:change_map(5, true)
			end)
		end,
	},

	load_maps = function(self, folder)
		local maps = love.filesystem.enumerate(folder)

		for key, name in pairs(maps) do
			local id = tonumber(name)

			if (id) then
				local dir = folder .. id .. "/"

				local loaded = self:load_map(love.image.newImageData(dir .. "map.png"), id)
				loaded:load_special(love.image.newImageData(dir .. "special.png"))
				self:render_map(loaded)
			end
		end
	end,

	load_map = function(self, data, id)
		local object = lib.game.map:new(data)

		self.maps[id] = object

		return object
	end,

	render_map = function(self, map)
		local size = self.tile_size
		local scale = self.tile_scale
		local rendersize = size * scale

		for key, layer in next, map.layers do
			if (not map.batches[key]) then
				map.batches[key] = love.graphics.newSpriteBatch(asset:get("image_tiles"), 500, "static")
			end

			local batch = map.batches[key]
			batch:bind()

			for x, xlayer in next, layer do
				for y, tile_id in next, xlayer do
					local quad = self.tile_quads[tile_id]

					if (quad) then
						batch:addq(quad,
							rendersize * x - rendersize,
							rendersize * y - rendersize,
							0,
							scale, -scale,
							0, 16)
					else
						print("can't file tile ID", tile_id)
					end
				end
			end

			batch:unbind()
		end
	end,

	load_tiles = function(self)
		local image_w, image_h = asset:get("image_tiles"):getWidth(), asset:get("image_tiles"):getHeight()
		local tiles = self.tile_source
		local id = 0

		for y = 1, #tiles do
			local tile_array = tiles[y]

			for x = 1, #tile_array do
				id = id + 1

				self.tile_quads[id] = love.graphics.newQuad(
					x * self.tile_size - self.tile_size,
					y * self.tile_size - self.tile_size,
					self.tile_size,
					self.tile_size,
					image_w,
					image_h)
			end
		end
	end,

	cycle_map = function(self)
		if (not changing_map) then
			changing_map = true
			if (self.map_out[self.current_id]) then
				self.map_out[self.current_id](self, self.world.game)
			end
		end
	end,

	spawn_player = function(self)
		if (self.current_map) then
			if (self.current_map.spawn) then
				local spawn_x, spawn_y = self.world:grid_to_world(unpack(self.current_map.spawn))

				self.world.character.x = spawn_x
				self.world.character.y = spawn_y

				self.world.character:update({delta = 0})
			end
		end
	end,

	spawn_shadow = function(self, velocity)
		if (self.current_map) then
			if (self.current_map.shadow_spawn) then
				local x, y = unpack(self.current_map.shadow_spawn)
				local shadow = lib.game.shadow:new(self.world)

				shadow:spawn(10, x, y, unpack(velocity))
			end
		end
	end,

	load_map_resources = function(self, id)
		if (self.map_resource[id]) then
			self.map_resource[id](self)
		end
	end,

	change_map = function(self, id, set)
		self:load_map_resources(id)

		if (not set) then
			self.world.game:queue(self.world.game:sound_fade(1))
		end

		lib.game.special_tiles.flags = {}

		self.current_map = self.maps[id]
		self.current_id = id

		self:spawn_player()

		if (self.map_in[id]) then
			self.map_in[id](self, self.world.game)
		end

		if (not set) then
			self.world.game:queue(self.world.game:fade_in(1))
		end

		changing_map = false
	end,

	do_collisions = function(self, x, y)
		if (self.current_map) then
			local character = self.world.character
			if (not (x == character.collide_x and y == character.collide_y)) then
				character.collide_x = x
				character.collide_y = y

				local x = self.current_map.special[x]
				if (x) then
					local tile = x[y]
					if (tile) then
						lib.game.special_tiles:touch_tile(self.world, unpack(tile))
					end
				end
			end
		end
	end,

	do_interact = function(self, x, y)
		if (self.current_map) then
			local x = self.current_map.special[x]
			if (x) then
				local tile = x[y]
				if (tile) then
					lib.game.special_tiles:interact_tile(self.world, unpack(tile))
				end
			end
		end
	end,

	collides = function(self, x, y)
		if (self.current_map) then
			if (x > 0 and y > 0 and x <= self.current_map.width and y <= self.current_map.height) then
				local x = self.current_map.collision[x]
				if (x) then
					return x[y]
				end
			else
				return true
			end
		end
	end,

	draw = function(self, event)
		if (self.current_map) then
			local cglow = self.glow[self.current_id]
			local c = cglow[1] + cglow[2] * math.sin(self.world.time * cglow[3])

			love.graphics.setColor(c, c, c)
			self.current_map:draw()
		end
	end,

	new = function(self, world)
		local instance = self:_new()

		instance.world = world

		return instance
	end,

	init = function(self, engine)
		asset = engine:lib_get("game.asset")
		engine:lib_get("game.map")
		engine:lib_get("game.special_tiles")

		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return map_manage