--[[
Button
A clickable button
Inherits ui.rectangle
]]

local lib
local button

button = {
	background_color = {180, 180, 180},

	mousedown = function(self, event)
		self:event_mousedown(event)
	end,

	mouseup = function(self, event)
		self:event_mouseup(event)
	end,

	added = function(self, event)
		local stack = event.stack
		local parent = stack[#stack]

		parent:register(self, "mousedown", "mouseup")
	end,

	new = function(self)
		local instance = self:_new()

		instance.event_mousedown = lib.event.functor:new()
		instance.event_mouseup = lib.event.functor:new()
		instance.draw = self._rectangle.draw

		return instance
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.ui.rectangle, "rectangle")
	end
}

return button