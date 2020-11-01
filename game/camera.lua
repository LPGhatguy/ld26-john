--[[
	Game Camera
]]

local lib
local camera

camera = {
	x = 0,
	y = 0,
	freelook_speed = 400,
	freelook = false,

	update = function(self, event)
		--LOL! I forgot to get rid of this in the first public release.
		--[[
		if (self.freelook) then
			local delta_x, delta_y = 0, 0

			if (love.keyboard.isDown("k")) then
				delta_x = 1
			elseif (love.keyboard.isDown("h")) then
				delta_x = -1
			end

			if (love.keyboard.isDown("u")) then
				delta_y = 1
			elseif (love.keyboard.isDown("j")) then
				delta_y = -1
			end

			if (delta_x ~= 0 or delta_y ~= 0) then
				local length = math.sqrt(delta_x ^ 2 + delta_y ^ 2)
				self.x = self.x + (delta_x * self.freelook_speed * event.delta) / length
				self.y = self.y + (delta_y * self.freelook_speed * event.delta) / length
			end
		end
		]]
	end,

	keydown = function(self, event)
		--[[
		if (event.key == "-") then
			self.freelook = not self.freelook
		end
		]]
	end,

	translate = function(self, x, y)
		self.x = self.x + x
		self.y = self.y + y
	end,

	game_position = function(self, x, y)
		if (not self.freelook) then
			self.x = x
			self.y = y
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return camera