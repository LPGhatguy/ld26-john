--[[
Plain Text Label
Draws text
Inherits ui.rectangle
]]

local lib
local textlabel

textlabel = {
	text = "",
	align = "left",
	text_color = {255, 255, 255},
	border_width = 0,

	draw = function(self, event)
		self._rectangle.draw(self, event)

		if (self.font) then
			love.graphics.setFont(self.font)
		end

		love.graphics.setColor(self.text_color)
		love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
	end,

	new = function(self, text, font)
		local instance = self:_new()

		instance.text = text or ""
		instance.font = font or ""

		return instance
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.ui.rectangle, "rectangle")
	end,
}

return textlabel