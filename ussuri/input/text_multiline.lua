--[[
Multiple Line Text Input Manager
Handles input for a multiline textbox
]]

local lib, input
local text

text = {
	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return text