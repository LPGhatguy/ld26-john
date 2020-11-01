--[[
Timed Queue
Queues events to happen in sequence after time
]]

local lib
local queue

queue = {
	stack = {},

	queue = function(self, time, pre, post)
		local stack = self.stack
		local queued = {
			time = time or 0,
			pre = pre,
			post = post
		}

		if (#stack == 0) then
			stack[1] = false
			stack[2] = queued
			self:cycle()
		else
			stack[#stack + 1] = queued
		end
	end,

	cycle = function(self)
		local last = lib.utility.table_pop(self.stack)

		if (last and last.post) then
			lib.utility.table_pop(last.post)(unpack(last.post))
		end

		local current = self.stack[1]

		if (current and current.pre) then
			lib.utility.table_pop(current.pre)(unpack(current.pre))
		end
	end,

	update = function(self, event)
		local current = self.stack[1]

		if (current) then
			if (event.delta > current.time) then
				current.time = 0
				self:cycle()
			else
				current.time = current.time - event.delta
			end
		end
	end,

	init = function(self, engine)
		lib = engine.lib

		lib.oop:objectify(self)
	end,
}

queue.event = {
	update = queue.update
}

return queue