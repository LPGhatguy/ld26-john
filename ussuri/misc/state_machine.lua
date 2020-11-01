--[[
State Machine
A state machine with self-nesting support
]]

local lib
local machine

machine = {
	state = "",
	handlers = {},
	pre_handlers = {},
	post_handlers = {},
	event = {},

	set_state = function(self, state)
		local old_state = self.state

		local pass = {
			stack = {},
			from = self.state,
			to = state
		}

		self.event["state_changing"](self, pass)

		if (pass.cancel) then
			return
		end

		self.state = state

		self.event["state_changed"](self, pass)

		if (pass.cancel) then
			self.state = old_state
		end
	end,

	add_handler = function(self, event_name, handler)
		self.handlers[event_name] = handler
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end
}

setmetatable(machine.event, {
	__index = function(self, key)
		local event = function(machine, event_pass, ...)
			local handlers = machine.handlers[machine.state]

			local pre_handler = machine.pre_handlers[key]
			local post_handler = machine.post_handlers[key]

			if (pre_handler) then
				pre_handler(machine, event_pass, ...)
			end

			if (handlers) then
				local method = handlers[key]

				if (method) then
					method(machine, event_pass, ...)
				else
					if (handlers.event) then
						local event_handler = handlers.event[key]

						if (event_handler) then
							local stack = event_pass.stack

							stack[#stack + 1] = machine
							event_pass.up = machine

							event_handler(handlers, event_pass, ...)

							stack[#stack] = nil
							event_pass.up = stack[#stack]
						end
					else
						if (getmetatable(handlers)) then
							handlers(machine, event_pass, ...)
						end
					end
				end
			end

			if (post_handler) then
				post_handler(machine, event_pass, ...)
			end
		end

		machine.handlers[key] = event
		return event
	end
})

return machine