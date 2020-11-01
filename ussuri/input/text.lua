--[[
Single Line Text Input Manager
Manages input of a single line textbox
]]

local lib, input
local text

text = {
	cursor = 0,
	selection = 0,
	limit = -1,
	text = "",
	enabled = true,

	keydown = function(self, event)
		local key = event.key

		if (self.enabled) then
			local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
			local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

			if (ctrl) then
				if (key == "a") then
					self:set_cursor(math.huge)
					self.selection = 0
				elseif (key == "d") then
					self.selection = self.cursor
				elseif (key == "c") then
					input:copy(self:get_selection())
				elseif (key == "x") then
					input:copy(self:get_selection())

					if (self.selection ~= self.cursor) then
						self:backspace()
					end
				elseif (key == "v") then
					local min, max = math.min(self.cursor, self.selection), math.max(self.cursor, self.selection)
					self:text_in(input:paste())
				end
			else
				if (key:len() == 1) then
					self:text_in(string.char(event.unicode))
				elseif (key == "backspace") then
					self:backspace(1)
				elseif (key == "delete") then
					self:backspace(-1)
				elseif (key == "right") then
					self:move_cursor(1, shift)
				elseif (key == "left") then
					self:move_cursor(-1, shift)
				elseif (key == "end") then
					self:set_cursor(math.huge, shift)
				elseif (key == "home") then
					self:set_cursor(0, shift)
				elseif (key == "return") then
					self.enabled = false
					self:event_text_submit()
				elseif (key == "tab" or key == "escape") then
					self.enabled = false
				end
			end
		end
	end,

	backspace = function(self, side)
		local side = side or 1
		local cursor, selection, text = self.cursor, self.selection, self.text

		if (selection == cursor) then
			selection = math.max(selection - side, 0)
		end

		if (selection < cursor) then
			self.text = text:sub(1, selection) .. text:sub(cursor + 1)
		elseif (selection > cursor) then
			self.text = text:sub(1, cursor) .. text:sub(selection + 1)
		end

		self.cursor = math.min(selection, cursor)
		self.selection = self.cursor
	end,

	get_selection = function(self)
		local min, max = math.min(self.cursor, self.selection), math.max(self.cursor, self.selection)

		return self.text:sub(min + 1, max)
	end,

	text_in = function(self, text)
		if (self.cursor ~= self.selection) then
			self:backspace()
		end

		self:text_at(text, self.cursor)
	end,

	text_at = function(self, text, x)
		self.text = self.text:sub(1, x) .. text .. self.text:sub(x + 1)
		self.text = self.text:sub(1, self.limit)

		self:move_cursor(text:len())
	end,

	move_cursor = function(self, x, keep_selection)
		self:set_cursor(self.cursor + (x or 0), keep_selection)
	end,

	set_cursor = function(self, x, keep_selection)
		self.cursor = math.min(math.max(x, 0), self.text:len())

		if (not keep_selection) then
			self.selection = self.cursor
		end
	end,

	new = function(self, text)
		local new = self:_new()

		new.text = text or new.text
		self.event_text_submit = lib.event.functor:new()

		return new
	end,

	init = function(self, engine)
		lib = engine.lib
		input = lib.input

		self.event_text_submit = lib.event.functor:new()

		lib.oop:objectify(self)
	end
}

text.event = {
	keydown = text.keydown
}

return text