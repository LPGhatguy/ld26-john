--[[
	Map Data Object
]]

local lib
local map

map = {
	width = 0,
	height = 0,
	layers = {},
	special = {},
	batches = {},
	collision = {},

	load = function(self, data, base_layer)
		local width, height = data:getWidth(), data:getHeight()

		if (width > self.width) then
			self.width = width
		end

		if (height > self.height) then
			self.height = height
		end

		local rlayer = {}
		local glayer = {}
		local blayer = {}

		for x = 1, width do
			local rxlayer = {}
			local gxlayer = {}
			local bxlayer = {}

			for y = 1, height do
				local r, g, b, a = data:getPixel(x - 1, y - 1)

				if (a > 0) then
					if (r ~= 0) then
						rxlayer[height - y + 1] = r
					end

					if (g ~= 0) then
						gxlayer[height - y + 1] = g
					end

					if (b ~= 0) then
						bxlayer[height - y + 1] = b
					end
				end
			end

			rlayer[x] = rxlayer
			glayer[x] = gxlayer
			blayer[x] = bxlayer
		end

		self.layers[base_layer] = rlayer
		self.layers[base_layer + 1] = glayer
		self.layers[base_layer + 2] = blayer
	end,

	load_special = function(self, data)
		local width, height = data:getWidth(), data:getHeight()

		for x = 1, width do
			local cxlayer = {}
			local sxlayer = {}

			for y = 1, height do
				local r, g, b, a = data:getPixel(x - 1, y - 1)

				if (r ~= 0 and a ~= 0) then
					sxlayer[height - y + 1] = {r, g, b}

					local position_name = lib.game.special_tiles.positions[r]
					if (position_name) then
						self[position_name] = {x, height - y + 1}
					end

					local property_name = lib.game.special_tiles.properties[r]
					if (property_name) then
						self[property_name] = {g, b}
					end
				end

				if (a > 200) then
					cxlayer[height - y + 1] = true
				end
			end

			self.collision[x] = cxlayer
			self.special[x] = sxlayer
		end
	end,

	draw = function(self)
		for key, batch in next, self.batches do
			love.graphics.draw(batch, 0, 0)
		end
	end,

	new = function(self, data)
		local instance = self:_new()

		if (data) then
			instance:load(data, 1)
		end

		return instance
	end,

	init = function(self, engine)
		engine:lib_get("game.special_tiles")
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

return map