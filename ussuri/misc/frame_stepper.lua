--[[
Frame Stepper
Performs an action a number of times per update and disconnects after a set number of frames
]]

local lib
local frame_stepper

frame_stepper = {
	steps_per_update = 1,
	steps_left = 0,

	update = function(self, event)
		if (self.action and self.steps_left ~= 0) then
			for count = 1, self.steps_per_update do
				self.steps_left = self.steps_left - 1

				if (self.steps_left ~= 0) then
					self:action(event)
				else
					break
				end
			end
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end,
}

frame_stepper.event = {
	update = frame_stepper.update
}

return frame_stepper