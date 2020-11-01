--[[
Multiple Line Textbox
A textbox with more than one line
Inherits ui.rectangle, input.text_multiline
]]

local lib
local textbox

textbox = {
	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.ui.rectangle, "rectangle")
		self:inherit(lib.input.text_multiline, "text")
	end,
}

return textbox