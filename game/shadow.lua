--[[
	KILLER DEMON SHADOW YEAH
]]

local lib
local asset
local shadow

shadow = {
	x = 0,
	y = 0,
	vx = 0,
	vy = 0,
	lifetime = 10,
	sound = "shadow_scream",

	update = function(self, event)
		self.lifetime = self.lifetime - event.delta
		if (self.lifetime <= 0) then
			self.world.entities[self.id] = nil
		else
			self.x = self.x + (self.vx * event.delta)
			self.y = self.y + (self.vy * event.delta)
			asset:get("shadow_scream"):setPosition(self.x, self.y, 0)

			self:check_and_kill()
		end
	end,

	draw = function(self, event)
		love.graphics.setColor(0, 0, 0, 80)
		love.graphics.circle("fill", self.x, self.y, 40, 20)
		love.graphics.circle("fill", self.x + 20 * math.sin(self.lifetime * 4.6), self.y, 40, 20)
		love.graphics.circle("fill", self.x - 20 * math.sin(self.lifetime * 4.7), self.y, 40, 20)
		love.graphics.circle("fill", self.x, self.y + 20 * math.cos(self.lifetime * 4.9), 40, 20)
		love.graphics.circle("fill", self.x, self.y - 20 * math.cos(self.lifetime * 5.1), 40, 20)
	end,

	check_and_kill = function(self)
		local gx, gy = self.world:world_to_grid(self.x, self.y)
		local cx, cy = self.world:world_to_grid(self.world.character.x, self.world.character.y)

		if (gx == cx and gy == cy) then
			self.world.game:kill_player()
		end
	end,

	spawn = function(self, time, x, y, vx, vy)
		self.x, self.y = self.world:grid_to_world(x, y)
		self.vx, self.vy = vx, vy
		self.lifetime = time

		asset:play_sound("shadow_scream")
		asset:get("shadow_scream"):setVelocity(vx / 80, vy / 80, 0)
	end,

	new = function(self, world)
		local instance = self:_new()

		instance.world = world
		instance.id = #world.entities + 1
		world.entities[instance.id] = instance

		return instance
	end,

	init = function(self, engine)
		asset = engine:lib_get("game.asset")

		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return shadow