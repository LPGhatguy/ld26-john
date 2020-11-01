--[[
Base UI Item
The father of all UI items
]]

local lib
local base

base = {
	x = 0,
	y = 0,
	z = 0,
	width = 0,
	height = 0,
	visible = true,

	get_absolute_position = function(self, stack)
		local x, y = self.x, self.y

		for key, item in next, stack do
			if (item.x and item.y) then
				x = x + item.x
				y = y + item.y
			end
		end

		return x, y
	end,

	start_scissor = function(self, stack, x, y, w, h)
		local abs_x, abs_y = self:get_absolute_position(stack)
		local sx, sy, sw, sh = love.graphics.getScissor()
		self.scissor_x, self.scissor_y = sx, sy
		self.scissor_width, self.scissor_height = sw, sh

		love.graphics.setScissor(x or abs_x, y or abs_y, w or self.width, h or self.height)
	end,

	end_scissor = function(self)
		if (self.scissor_x) then
			love.graphics.setScissor(self.scissor_x, self.scissor_y, self.scissor_w, self.scissor_h)
		else
			love.graphics.setScissor()
		end
	end,

	draw = function(self)
	end,

	added = function(self, event)
		event.stack[#event.stack]:register(self, "draw")
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return base