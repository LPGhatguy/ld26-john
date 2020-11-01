--[[
Library Manager
Manage libraries elegantly
]]

local lib, engine_path
local lib_flat = {}
local lib_manage

lib_manage = {
	lib_nav_path = function(self, from, path, ensure)
		for child in path:gsub(":", ""):gmatch("[^%.]+") do
			if (from[child]) then
				from = from[child]
			elseif (ensure) then
				from[child] = {}
				from = from[child]
			else
				return false
			end
		end

		return from
	end,

	lib_get = function(self, paths)
		if (type(paths) == "table") then
			for key, path in next, paths do
				self:lib_get(path)
			end
		else
			local existing_lib = self:lib_nav_path(lib, paths)

			if (existing_lib) then
				return existing_lib
			else
				return self:lib_load(paths)
			end
		end
	end,

	lib_load = function(self, paths)
		if (type(paths) == "table") then
			for key, path in next, paths do
				self:lib_load(path)
			end
		else
			local abs_path = paths:gsub(":", engine_path)
			local slash_path = abs_path:gsub("%.", "/")

			if (love.filesystem.isFile(slash_path .. ".lua")) then
				self:lib_file_load(paths)
			else
				if (love.filesystem.isDirectory(slash_path)) then
					self:lib_folder_load(paths)
				end
			end
		end
	end,

	lib_folder_load = function(self, path)
		local slash_path = path:gsub(":", engine_path):gsub("%.", "/")
		local files = love.filesystem.enumerate(slash_path)

		for key, file_path in next, files do
			self:lib_get(path .. "." .. file_path:gsub("/", "%."):gsub(engine_path, ":"):match("([^%.]+)%..*$"))
		end
	end,

	lib_file_load = function(self, path)
		local loaded = require(path:gsub(":", engine_path))

		if (type(loaded) == "table") then
			local load_location = self:lib_nav_path(lib, path:match("([^%.]+)%.?.*$"), true)

			lib_flat[#lib_flat + 1] = loaded
			load_location[path:match("%.?([^%.]+)$")] = loaded

			if (type(loaded.init) == "function") then
				loaded:init(self)
			end
		end
	end,

	lib_batch_call = function(self, name)
		for key, library in next, lib_flat do
			if (library[name]) then
				library[name](library, self)
			end
		end
	end,

	init = function(self, engine)
		if (engine.lib) then
			lib = engine.lib
		else
			lib = {}
			engine.lib = lib
		end

		if (engine.lib_flat) then
			lib_flat = engine.lib_flat
		else
			lib_flat = {}
			engine.lib_flat = lib_flat
		end

		engine_path = engine.config.engine_path

		engine:inherit(self)
	end,

	close = function(self, engine)
		for key, library in next, lib_flat do
			if (lib_flat.close) then
				lib_flat:close(engine)
			end
		end
	end
}

setmetatable(lib_flat, {__mode = "v"})

return lib_manage