--[[
UI Image
Used for drawing standalone UI images
Inherits ui.base
]]

local lib
local image

image = {
	auto_size = true,

	draw = function(self)
		local image = self.image

		if (self.auto_size) then
			love.graphics.draw(image, self.x, self.y)
		else
			love.graphics.draw(image, self.x, self.y, 0, self.width / image:getWidth(), self.height / image:getHeight())
		end
	end,

	new = function(self, image)
		local instance = self:_new()

		instance.image = image or love.graphics.newImage()

		return instance
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		self:inherit(lib.ui.base, true)
	end
}

return image