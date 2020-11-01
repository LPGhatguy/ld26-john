--[[
Event Functor
A drop-in replacement for functions with multiple bodies
]]

local functor, meta

functor = {
	handlers = {},

	call = function(self, ...)
		if (self.pre) then
			self:pre(...)
		end

		for key, value in next, self.handlers do
			value(...)
		end

		if (self.post) then
			self:post(...)
		end
	end,

	connect = function(self, method)
		table.insert(self.handlers, method)
	end,

	new = function(self, method)
		local instance = self:_new()

		instance:connect(method)

		return instance
	end,

	init = function(self, engine)
		setmetatable(self, meta)

		engine.lib.oop:objectify(self)
	end
}

meta = {
	__call = functor.call,
	__add = functor.connect
}

return functor