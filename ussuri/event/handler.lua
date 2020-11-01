--[[
Event Handler
Creates and passes events to objects that have registred.
]]

local lib
local event_handler

local handler_compare = function(first, second)
	return first[3] < second[3]
end

local event_prop_meta = {
	__index = function(self, key)
		local handler = function(this, ...)
			rawget(self, "_handler"):event_trigger(key, ...)
		end

		self[key] = handler

		return handler
	end
}

event_handler = {
	event = {},
	events = {},

	event_create = function(self, event_names)
		if (type(event_names) == "table") then
			for key, event_name in next, event_names do
				if (not self.events[event_name]) then
					self.events[event_name] = {data = self.event_data:new()}
				end
			end
		else
			if (not self.events[event_names]) then
				self.events[event_names] = {data = self.event_data:new()}
			end
		end
	end,

	event_hook_object = function(self, event_names, object)
		if (type(event_names) == "table") then
			for key, event_name in next, event_names do
				self:event_hook_object(event_name, object)
			end
		elseif (event_names) then
			local event = self.events[event_names]
			local object_events = object.event

			if (event and object_events) then
				local method = object_events[event_names]

				if (method) then
					local priority = object_events[event_names .. "_priority"]

					event[#event + 1] = {object, method, priority or 0}
				end
			end
		else
			local object_events = object.event

			if (object_events) then
				for event_name, method in next, object_events do
					if (type(method) == "function" or type(method) == "table") then
						local event = self.events[event_name]

						if (event) then
							local priority = object_events[event_name .. "_priority"]

							event[#event + 1] = {object, method, priority or 0}
						end
					end
				end
			end
		end
	end,

	event_hook_light = function(self, event_names, object, method, priority)
		if (type(event_names) == "table") then
			for key, event_name in next, event_names do
				self:event_hook_light(event_name, object, method, priority)
			end
		else
			local event = self.events[event_names]

			if (event) then
				event[#event + 1] = {object or {}, method, priority or 0}
			end
		end
	end,

	event_sort = function(self, event_names)
		if (type(event_names) == "table") then
			for key, event_name in next, event_names do
				local event = self.events[event_name]

				if (event) then
					table.sort(event, handler_compare)
				end
			end
		elseif (event_names) then
			local event = self.events[event_names]

			if (event) then
				table.sort(event, handler_compare)
			end
		else
			for event_name, event in next, self.events do
				table.sort(event, handler_compare)
			end
		end
	end,

	event_trigger = function(self, event_name, data)
		local event = self.events[event_name]

		if (event) then
			local event_data = event.data
			event_data:update(data)

			for key = 1, #event do
				local handler = event[key]
				local flags = event_data.flags

				handler[2](handler[1], event_data)

				if (flags.event_unhook) then
					event[key] = nil
					flags.event_unhook = false
				end

				if (flags.event_cancel) then
					break
				end
			end

			return event_data
		else
			print("WARNING: Attempt to call event '" .. tostring(event_name) .. "' (an undefined event)")
		end
	end,

	new = function(self)
		local instance = self:_new()

		instance.event._handler = instance

		return instance
	end,

	event_data = {
		stack = {},
		flags = {},

		update = function(self, data)
			if (data) then
				for key, value in next, data do
					self[key] = value
				end
			end

			self.stack = {}
			self.flags = {}
		end
	},

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
		lib.oop:objectify(self.event_data)

		engine.event = self:new()
	end
}

event_handler.event._handler = event_handler
setmetatable(event_handler.event, event_prop_meta)

return event_handler