--[[
UI Utility Library
Provides various UI utility methods
Monkey-patches the logging module inside the engine core for colored text stripping
]]

local lib
local ui, logging_extension

logging_extension = {
	log_writes = function(self, color, ...)
		self:log_write("\b" .. color .. "\b", ...)
	end,

	log_strip_style = function(self, text)
		local out = text:gsub("\b.-\b%s?", "")

		return out
	end,

	log_report = function(self, ...)
		print(self:log_strip_style(table.concat({...}, " ")))

		self:event_log()
	end
}

ui = {
	colors = {
		["white"] = {255, 255, 255},
		["black"] = {0, 0, 0},
		["red"] = {200, 0, 0},
		["blue"] = {0, 100, 220},
		["green"] = {0, 200, 80},
		["cyan"] = {0, 200, 200},
		["magenta"] = {200, 0, 200},
		["yellow"] = {200, 200, 0},
		["pink"] = {200, 0, 200}
	},

	point_in_item = function(item, x, y)
		local item_x, item_y = item.x, item.y

		return (x > item_x and x < item_x + item.width) and
			(y > item_y and y < item_y + item.height)
	end,

	color_add = function(self, name, color)
		if (not self.colors[name]) then
			self.colors[name] = color
		end
	end,

	color_decompose = function(self, text)
		local out_text = {}
		local out_color = {}

		local uncolored = string.match(text, "^[^\b]+")
		if (uncolored) then
			out_text[1] = string.match(text, "^[^\b]+")
			out_color[1] = "white"
		end

		for color_piece, text_piece in string.gmatch(text, "\b(.-)\b%s?([^\b]*)") do
			local tab_fixed = text_piece:gsub("\t", (" "):rep(3))

			table.insert(out_text, tab_fixed)
			table.insert(out_color, color_piece)
		end

		return out_text, out_color
	end,

	print_decomposed = function(self, text, color, x, y)
		local font = love.graphics.getFont()
		local atx, aty = x, y

		for id, piece in next, text do
			love.graphics.setColor(self.colors[color[id]])
			love.graphics.print(piece, atx, aty)

			local _, newlines = piece:gsub("\n", "")

			atx = atx + font:getWidth(piece)

			if (newlines > 0) then
				aty = aty + font:getHeight() * newlines
				atx = x
			end
		end
	end,

	prints = function(self, text, x, y)
		local text, color = self:color_decompose(text)
		local font = love.graphics.getFont()
		local atx, aty = x, y

		for id, piece in next, text do
			love.graphics.setColor(self.colors[color[id]])
			love.graphics.print(piece, atx, aty)

			local _, newlines = piece:gsub("\n", "")

			atx = atx + font:getWidth(piece)

			if (newlines > 0) then
				aty = aty + font:getHeight() * newlines
				atx = x
			end
		end
	end,

	init = function(self, engine)
		lib = engine.lib
		utility = lib.utility

		logging_extension.event_log = lib.event.functor:new()
		utility.table_deepcopy(logging_extension, engine, utility.DESCENDENTS_ONLY)
	end
}

return ui