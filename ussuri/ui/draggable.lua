--[[
Draggable UI Item
Enables dragging of an object (not necessariliy the dragger)
]]

local lib
local dragger

dragger = {
	drag_target = dragger,
	dragging = false,
	offset_x = 0,
	offset_y = 0,

	update = function(self, event)
		if (self.dragging) then
			self.drag_target.x = self.offset_x + love.mouse.getX()
			self.drag_target.y = self.offset_y + love.mouse.getY()
		end
	end,

	mousedown = function(self, event)
		self.dragging = true
		self.offset_x = self.drag_target.x - event.abs_x
		self.offset_y = self.drag_target.y - event.abs_y
	end,

	mouseup_global = function(self, event)
		self.dragging = false
	end,

	new = function(self, target)
		local instance = self:_new()

		instance.drag_target = target or instance

		return instance
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.ui.base, true)
	end
}

return dragger