--[[
	Asset Loader and Manager
]]

local lib
local asset

asset = {
	sound_directory = "asset/sound/",
	image_directory = "asset/image/",
	font_directory = "asset/font/",
	loaded = {},

	get = function(self, name)
		return self.loaded[name]
	end,

	play_sound = function(self, name)
		self.loaded[name]:stop()
		self.loaded[name]:play()
	end,

	load_image = function(self, name, filename)
		local image = love.graphics.newImage(self.image_directory .. filename)

		self.loaded[name] = image

		return image
	end,

	load_sound = function(self, name, filename, type)
		local sound = love.audio.newSource(self.sound_directory .. filename, type or "static")

		self.loaded[name] = sound

		return sound
	end,

	load_world_sound = function(self, name, filename)
		local sound = love.audio.newSource(self.sound_directory .. filename, "static")
		sound:setDistance(50, 500)
		sound:setRolloff(0.2)
		sound:setPosition(0, 0, 0)

		self.loaded[name] = sound

		return sound
	end,

	load_font = function(self, name, size)
		local font = love.graphics.newFont(size)

		self.loaded[name] = font

		return font
	end,

	load_font_file = function(self, name, path, size)
		local font = love.graphics.newFont(self.font_directory .. path, size)

		self.loaded[name] = font

		return font
	end,

	init = function(self, engine)
		lib = engine.lib
	end
}

return asset