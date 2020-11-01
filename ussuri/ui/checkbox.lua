--[[
Two-State Check Box
Checks Boxes
Inherits ui.rectangle
]]

local lib
local checkbox

checkbox = {
	checked = false,
	width = 10,
	height = 10,
	background_color = {200, 200, 200},
	check_color = {0, 80, 200},
	border_color = {50, 50, 50},

	draw = function(self)
		self._rectangle.draw(self)

		if (self.checked) then
			love.graphics.setColor(self.check_color)
			love.graphics.rectangle("fill", self.x + 1, self.y + 1, self.width - 2, self.height - 2)
		end
	end,

	mousedown = function(self, event)
		self.checked = not self.checked
		self:event_toggle()
	end,

	init = function(self, engine)
		lib = engine.lib

		self.event_toggle = lib.event.functor:new()

		lib.oop:objectify(self)
		self:inherit(lib.ui.rectangle, "rectangle")
	end
}

checkbox.event = {
	draw = checkbox.draw,
	mousedown = checkbox.mousedown
}

return checkbox