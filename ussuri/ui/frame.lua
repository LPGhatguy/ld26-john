--[[
UI Frame
A frame for holding other UI elements
Inherits ui.ui_container, ui.rectangle
]]

local lib
local frame

frame = {
	draw = function(self, event)
		self._rectangle.draw(self, event)
		self._ui_container.draw(self, event)
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.ui.ui_container, "ui_container")
		self:inherit(lib.ui.rectangle, "rectangle")

		self.event.draw = self.draw
	end
}

return frame