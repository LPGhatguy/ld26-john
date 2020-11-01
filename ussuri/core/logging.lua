--[[
Logging Module
Writes logs to output and to the file stream
]]

local lib
local config
local logging

logging = {
	history = {},

	write = function(self, ...)
		local out = table.concat({...}, " ")

		if (config.history) then
			self.history[#self.history + 1] = out
		end

		if (config.realtime) then
			self:report(out)
		end
	end,

	report = function(self, ...)
		print(...)
	end,

	clear = function(self)
		self.history = {}
	end,

	save = function(self, filename)
		if (not love.filesystem.exists(config.save_directory)) then
			love.filesystem.mkdir(config.save_directory)
		end

		local file_out = love.filesystem.newFile(config.save_directory .. "/" .. filename .. ".txt")

		if (file_out:open("w")) then
			file_out:write(table.concat(self.history, "\r\n"))
			file_out:close()
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)

		engine.log = self:new()

		config = {
			realtime = false,
			history = false,
			autosave = false,
			save_directory = "logs"
		}

		engine.config.log = config

		engine.log:write("Using engine version " .. tostring(engine.config.version))
	end,

	close = function(self, engine)
		engine.log:write("End")

		if (config.autosave) then
			engine.log:save(os.date():gsub("[/: ]", "-"))
		end
	end
}

return logging