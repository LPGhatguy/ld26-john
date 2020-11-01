--[[
Input Manager
Game-orientated control binding manager
]]

local lib
local input

input = {
	actions = {},
	buttons = {},

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return input