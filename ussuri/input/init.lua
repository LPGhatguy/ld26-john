--[[
Input Service
Presently just provides access to a string for the application's clipboard
]]

local input

input = {
	clipboard = "",

	copy = function(self, text)
		self.clipboard = text
	end,

	paste = function(self)
		return self.clipboard
	end
}

return input