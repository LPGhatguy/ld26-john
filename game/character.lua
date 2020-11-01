--[[
	This is you: this is John.
]]

local lib
local asset
local character

character = {
	x = 1,
	y = 1,
	r = 0,
	walk_speed = 180,
	sprint_speed = 500,
	walk_anim_speed = 0.12,
	sprint_anim_speed = 0.08,
	anim_time = 0,
	anim_step = 1,
	walk_anim = {1, 2, 3, 2, 1, 4, 5, 4},
	walk_quads = {},
	step_sound = {
		[3] = true,
		[7] = true
	},
	collide_x = 0,
	collide_y = 0,
	mobile = true,
	alive = true,

	update = function(self, event)
		local moving = false
		local delta_f = 0
		local wmouse_x, wmouse_y = self.world:screen_to_world(love.mouse.getPosition())

		if (love.keyboard.isDown("w")) then
			delta_f = 1
			moving = true
		elseif (love.keyboard.isDown("s")) then
			delta_f = -1
			moving = true
		end

		local r = math.atan2(wmouse_y - self.y, wmouse_x - self.x)
		self.mr = r
		self.r = r - math.pi / 2

		if (self.mobile) then
			if (moving) then
				local delta_x = math.cos(r) * delta_f
				local delta_y = math.sin(r) * delta_f
				local length = math.sqrt(delta_x ^ 2 + delta_y ^ 2)
				local sprinting = love.keyboard.isDown("lshift")

				local move_speed = sprinting and self.sprint_speed or self.walk_speed
				local anim_speed = sprinting and self.sprint_anim_speed or self.walk_anim_speed

				local x, y = self.x, self.y

				local target_x = x + (move_speed * delta_x * event.delta / length)
				local target_y = y + (move_speed * delta_y * event.delta / length)

				if (not self.world.map_manage:collides(self.world:world_to_grid(x, target_y))) then
					self.y = target_y
				end

				if (not self.world.map_manage:collides(self.world:world_to_grid(target_x, y))) then
					self.x = target_x
				end

				self.world.map_manage:do_collisions(self.world:world_to_grid(self.x, self.y))

				love.audio.setPosition(self.x, self.y, 0)

				self.anim_time = self.anim_time + event.delta

				if (self.anim_time > anim_speed) then
					self.anim_time = self.anim_time - anim_speed
					self.anim_step = (self.anim_step) % (#self.walk_anim) + 1

					if (self.step_sound[self.anim_step]) then
						asset:get("johnstep"):setPosition(self.x, self.y, 0)
						asset:play_sound("johnstep")
					end
				end
			else
				self.anim_time = 0
				self.anim_step = 1
			end
		end
	end,

	draw = function(self, event)
		love.graphics.drawq(asset:get("image_john"), self.walk_quads[self.walk_anim[self.anim_step]],
			self.x, self.y, self.r,
			4, -4,
			8, 8)
	end,

	load_quads = function(self)
		for frame = 1, 5 do
			self.walk_quads[frame] = love.graphics.newQuad(16 * frame - 16, 0, 16, 16, 80, 16)
		end
	end,

	new = function(self, world)
		local instance = self:_new()

		instance.world = world
		instance:load_quads()

		return instance
	end,

	init = function(self, engine)
		engine:lib_get("game.asset")
		lib = engine.lib

		asset = lib.game.asset

		lib.oop:objectify(self)
	end
}

return character