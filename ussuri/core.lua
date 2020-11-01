local lib, config, corelib = {}, {}, {}
local engine_core = {}

local engine_path = debug.getinfo(1).short_src:match("([^%.]*)[\\/][^%.]*%..*$"):gsub("[\\/]", ".") .. "."
config.engine_path = engine_path

local version_meta = {
	__tostring = function(self)
		return table.concat(self, ".")
	end
}

local lib_batch_load = function(batch)
	for key, lib_name in next, batch do
		local name = lib_name:match("([^%.:]*)$")
		local loaded = require(lib_name:gsub("^:", config.engine_path))

		loaded:init(engine_core)

		lib[name] = loaded
		corelib[name] = loaded
	end
end

engine_core.init = function(self, glib)
	lib = glib or lib
	self.lib = lib

	config = require(engine_path .. "config")
	config.engine_path = config.engine_path or engine_path
	self.config = config

	setmetatable(config.version, version_meta)

	lib_batch_load(config.lib_core)

	self:lib_load(config.lib_folders)
	self:lib_batch_call("post_init")

	return self
end

engine_core.close = function(self)
	for key, library in pairs(corelib) do
		if (library.close) then
			library:close(self)
		end
	end

	self.lib = {}
	corelib = {}
end

engine_core.quit = function(self)
	love.event.push("quit")
	self:close()
end

return engine_core