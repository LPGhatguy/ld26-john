--[[
Styled Text Label
Draws styled text
Inherits ui.rectangle
]]

local lib
local textlabel

textlabel = {
	text = "",
	border_width = 0,

	refurbish = function(self, text)
		if (text) then
			self.text = text
		end

		self.content_text, self.content_color = lib.ui:color_decompose(self.text)
	end,

	draw = function(self, event)
		self._rectangle.draw(self, event)

		if (self.font) then
			love.graphics.setFont(self.font)
		end

		self:start_scissor(event.stack)

		lib.ui:print_decomposed(self.content_text, self.content_color, self.x, self.y)

		self:end_scissor()
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.ui.rectangle, "rectangle")

		self:refurbish()
	end
}

return textlabel