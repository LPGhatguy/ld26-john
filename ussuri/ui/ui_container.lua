--[[
UI Container
A UI item that contains other items
Inherits ui.base, utility.container
]]

local lib
local ui_container
local point_in_item

ui_container = {
	clips_children = false,

	update = function(self, event)
		self:trigger_child_event("update", event)
	end,

	draw = function(self, event)
		love.graphics.push()
		love.graphics.setColor(255, 255, 255)
		love.graphics.translate(self.x, self.y)

		if (self.clips_children) then
			self:start_scissor(event.stack)
		end

		self:trigger_child_event("draw", event)

		love.graphics.pop()

		if (self.clips_children) then
			self:end_scissor()
		end
	end,

	mousedown = function(self, event)
		local mouse_x, mouse_y = event.x, event.y
		local trans_x, trans_y = mouse_x - self.x, mouse_y - self.y

		local stack = event.stack
		stack[#stack + 1] = self
		event.up = self

		local contains_mouse = point_in_item(self, mouse_x, mouse_y)

		if (self.visible and (not self.clips_children or contains_mouse)) then
			event.cancel = contains_mouse

			local searching = true

			for key, child in next, self.children do
				event.x = trans_x - child.x
				event.y = trans_y - child.y

				if (child.visible) then
					if (point_in_item(child, trans_x, trans_y)) then
						self:call_child_event(child, "mousedown", event)

						if (child.active) then
							break
						end
					else
						self:call_child_event(child, "mousedown_sibling", event)
					end
				end
			end
		end

		stack[#stack] = nil
		event.up = stack[#stack]

		event.x = mouse_x
		event.y = mouse_y
	end,

	mouseup = function(self, event)
		local mouse_x, mouse_y = event.x, event.y
		local trans_x, trans_y = mouse_x - self.x, mouse_y - self.y

		local stack = event.stack
		stack[#stack + 1] = self
		event.up = self

		local contains_mouse = point_in_item(self, mouse_x, mouse_y)

		if (self.visible and (not self.clips_children or contains_mouse)) then
			event.cancel = contains_mouse

			local searching = true

			for key, child in next, self.children do
				event.x = trans_x - child.x
				event.y = trans_y - child.y

				if (child.visible) then
					if (point_in_item(child, trans_x, trans_y)) then
						self:call_child_event(child, "mouseup", event)

						if (child.active) then
							break
						end
					else
						self:call_child_event(child, "mouseup_sibling", event)
					end
				end
			end
		end

		stack[#stack] = nil
		event.up = stack[#stack]

		event.x = mouse_x
		event.y = mouse_y
	end,

	mousedown_global = function(self, event)
		self:trigger_child_event("mousedown_global", event)
	end,

	mouseup_global = function(self, event)
		self:trigger_child_event("mouseup_global", event)
	end,

	init = function(self, engine)
		lib = engine.lib

		point_in_item = lib.ui.point_in_item

		lib.oop:objectify(self)
		self:inherit(lib.ui.base, true)
		self:inherit(lib.utility.container)
	end
}

ui_container.event = {
	update = ui_container.update,
	draw = ui_container.draw,
	mousedown = ui_container.mousedown,
	mouseup = ui_container.mouseup
}

return ui_container