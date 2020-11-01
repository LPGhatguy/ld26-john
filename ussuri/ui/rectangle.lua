--[[
Rectangle
A rectangle with borders
Inherits ui.base
]]

local lib
local rectangle

rectangle = {
	background_color = {100, 100, 100},
	border_color = {200, 200, 200},
	border_width = 2,

	draw = function(self)
		local border_width = self.border_width
		local half_border = math.ceil(border_width / 2)

		love.graphics.setColor(self.background_color)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

		love.graphics.setColor(self.border_color)
		love.graphics.setLineWidth(border_width)
		love.graphics.rectangle("line", self.x - half_border, self.y - half_border,
			self.width + border_width, self.height + border_width)
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.ui.base, true)
	end
}

return rectangle