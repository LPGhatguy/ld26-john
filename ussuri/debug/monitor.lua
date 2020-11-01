--[[
Debug Monitor
Used for quick or custom debug information
]]

local monitor

monitor = {
	enabled = false,
	dark = false,
	font_size = 18,
	numeric_accuracy = 3,
	toggle_modifiers = {"lctrl"},
	toggle_key = "q",
	lookups = {},

	values = {
		fps = 0,
		time = 0
	},

	event = {
		draw_priority = 502,
		draw = function(self)
			if (self.enabled) then
				local out = ""

				for key, value in next, self.values do
					out = out .. key:upper() .. ": " .. self:draw_value(value) .. "\n"
				end

				for key, value in next, self.lookups do
					out = out .. key:upper() .. ": " .. self:draw_value(value[1][value[2]]) .. "\n"
				end

				love.graphics.setFont(self.font)

				love.graphics.setColor(0, 0, 0)
				love.graphics.print(out, 6, 6)
				love.graphics.print(out, 4, 4)

				love.graphics.setColor(255, 255, 0)
				love.graphics.print(out, 5, 5)
			end
		end,

		update_priority = -502,
		update = function(self, event)
			self.values.fps = love.timer.getFPS()
			self.values.time = self.values.time + event.delta
		end,

		keydown_priority = -502,
		keydown = function(self, event)
			if (event.key == self.toggle_key and love.keyboard.isDown(unpack(self.toggle_modifiers))) then
				self.enabled = not self.enabled
				event.flags.cancel = true
			end
		end
	},

	draw_value = function(self, value)
		if (type(value) == "number") then
			return tostring(value):match("%d*%.?" .. ("%d?"):rep(self.numeric_accuracy))
		else
			return tostring(value)
		end
	end,

	init = function(self, engine)
		self.font = love.graphics.newFont(self.font_size)
	end
}

return monitor