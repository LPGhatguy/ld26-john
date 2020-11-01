--[[
	Game World
]]

local lib
local world

world = {
	screen_width = 0,
	screen_height = 0,
	time = 0,
	shaking = false,
	entities = {},

	update = function(self, event)
		self.camera:update(event)
		self.character:update(event)

		for key, entity in next, self.entities do
			entity:update(event)
		end

		self.time = self.time + event.delta

		if (not self.camera.freelook) then
			self.camera.x = self.character.x
			self.camera.y = self.character.y
		end
	end,

	draw = function(self, event)
		self:draw_start()

		self.map_manage:draw()
		self.character:draw()

		for key, entity in next, self.entities do
			entity:draw(event)
		end

		self:draw_end()
	end,

	keydown = function(self, event)
		self.camera:keydown(event)

		if (event.key == " ") then
			self:interact()
		end
	end,

	set_active = function(self, state)
		self.state.update = state
		self.state.draw = state
		self.state.keydown = state
	end,

	screen_to_world = function(self, x, y)
		x = x + math.floor(self.camera.x) - self.halfwidth
		y = -y + math.floor(self.camera.y) + self.halfheight

		return x, y
	end,

	world_to_grid = function(self, x, y)
		local tile_drawn = self.map_manage.tile_scale * self.map_manage.tile_size
		return math.ceil(x / tile_drawn), math.ceil(y / tile_drawn)
	end,

	grid_to_world = function(self, x, y)
		local tile_drawn = self.map_manage.tile_scale * self.map_manage.tile_size
		return x * tile_drawn - tile_drawn / 2, y * tile_drawn - tile_drawn / 2
	end,

	draw_start = function(self)
		love.graphics.setColor(255, 255, 255)
		love.graphics.push()

		love.graphics.translate(-math.floor(self.camera.x) + self.halfwidth, math.floor(self.camera.y) + self.halfheight)
		love.graphics.scale(1, -1)

		if (self.shaking) then
			love.graphics.rotate(math.sin(self.time * 3) * 0.02)
		end
	end,

	draw_end = function(self)
		love.graphics.pop()
		love.graphics.setColor(255, 255, 255)
	end,

	interact = function(self)
		local x, y = self.character.x, self.character.y
		local direction = lib.utility.round(self.character.mr * 2 / math.pi) + 2
		local x, y = self:world_to_grid(x, y)
		
		if (direction == 0 or direction == 4) then
			x = x - 1
		elseif (direction == 3) then
			y = y + 1
		elseif (direction == 2) then
			x = x + 1
		elseif (direction == 1) then
			y = y - 1
		end

		self.map_manage:do_interact(x, y)
	end,

	new = function(self, game)
		local instance = self:_new()

		instance.game = game

		instance.camera = lib.game.camera:new()

		instance.width = love.graphics.getWidth()
		instance.height = love.graphics.getHeight()

		instance.halfwidth = instance.width / 2
		instance.halfheight = instance.height / 2

		instance.map_manage = lib.game.map_manage:new(instance)
		instance.map_manage:load_tiles()

		instance.character = lib.game.character:new(instance)

		return instance
	end,

	init = function(self, engine)
		engine:lib_get("game.asset")
		engine:lib_get("game.camera")
		engine:lib_get("game.map_manage")
		engine:lib_get("game.character")

		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return world