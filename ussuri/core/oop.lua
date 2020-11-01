--[[
Object Orientation
Enables instantation and inheritance of objects
]]

local lib, table_deepcopy, table_merge
local oop

oop = {
	objectify = function(self, to)
		table_merge(self.object, to)
	end,

	object = {
		inherit = function(self, from, base)
			if (from) then
				table_merge(from, self, true)

				if (base) then
					if (base == true) then
						self.base = from
					else
						self["_" .. tostring(base)] = from
					end
				end
			else
				print("Cannot inherit from nil! (id: " .. tostring(base) .. ")")
			end
		end,
		_new = function(self)
			return table_deepcopy(self, {}, true)
		end
	},

	init = function(self, engine)
		lib = engine.lib
		table_deepcopy = lib.utility.table_deepcopy
		table_merge = lib.utility.table_merge

		self.object.new = self.object._new

		self:objectify(engine)
	end
}

return oop