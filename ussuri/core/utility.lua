--[[
General Utility Library
Contains methods used by much of the engine
]]

local utility

utility = {
	DESCENDENTS_ONLY = {},

	round = function(num)
		if (num >= 0) then
			return math.floor(num + 0.5)
		else
			return math.ceil(num - 0.5)
		end
	end,

	string_split = function(source, splitter)
		local last = 1
		local current
		local out = {}

		while (true) do
			current = source:find(splitter, last, true)

			if (not current) then
				break
			end

			table.insert(out, source:sub(last, current - 1))
			last = current + splitter:len()
		end

		table.insert(out, source:sub(last))

		return out
	end,

	table_contains = function(from, search)
		for key, value in next, from do
			if (value == search) then
				return true
			end
		end

		return false
	end,

	table_equals = function(first, second)
		if (second and type(first) == "table" and type(second) == "table") then
			for key, value in pairs(first) do
				local success = false

				if (type(value) == type(second[key])) then
					if (type(value) == "table") then
						success = utility.table_equals(value, second[key])
					else
						success = (second[key] == value)
					end
				end

				if (not success) then
					return false
				end
			end

			return true
		else
			return false
		end
	end,

	table_pop = function(from, key)
		local key = key or 1
		local value = from[key]

		if (type(key) == "number") then
			table.remove(from, key)
		else
			from[key] = nil
		end

		return value
	end,

	table_deepcopy = function(from, to, meta, original)
		local to = to or {}
		local original = original or from

		for key, value in pairs(from) do
			if (type(value) == "table") then
				if (value ~= original) then
					if (meta ~= utility.DESCENDENTS_ONLY) then
						to[key] = utility.table_deepcopy(value, {}, meta, original)
					else
						to[key] = utility.table_deepcopy(value, {}, true, original)
					end
				end
			else
				to[key] = value
			end
		end

		if (meta and meta ~= utility.DESCENDENTS_ONLY) then
			setmetatable(to, getmetatable(from))
		end

		return to
	end,

	table_copy = function(from, to, meta)
		local to = to or {}

		for key, value in pairs(from) do
			to[key] = value
		end

		if (meta) then
			setmetatable(to, getmetatable(from))
		end

		return to
	end,

	table_merge = function(from, to, meta, merge_children, original)
		local original = original or from

		for key, value in pairs(from) do
			if (not to[key]) then
				if (type(value) == "table") then
					if (value == original) then
						to[key] = value
					else
						if (merge_children) then
							to[key] = utility.table_merge(value, {}, meta, true, original)
						else
							to[key] = utility.table_deepcopy(value, {}, meta, false, original)
						end
					end
				else
					to[key] = value
				end
			end
		end

		return to
	end,

	table_tree = function(location, level, max_depth)
		local out = ""
		local level = level or 0
		local max_depth = max_depth or 6

		for key, value in next, location do
			out = out .. ("\t"):rep(level) ..
				"(" .. type(key) .. ") " ..
				tostring(key) .. ": "

			if (type(value) == "string") then
				out = out .. "\"" .. value .. "\""
			elseif (type(value) == "table") then
				if (level < max_depth) then
					out = out .. "(table)\n" .. utility.table_tree(value, level + 1, max_depth)
				end
			elseif (type(value) == "function") then
				out = out .. "(" .. tostring(value):gsub("00+", "") .. ")"
			else
				out = out .. tostring(value)
			end

			out = out .. "\n"
		end

		return out:sub(1, -2)
	end,

	table_size = function(the_table, recursive)
		local size = 0

		if (recursive) then
			for key, value in next, the_table do
				size = size + 1
				if (type(value) == "table") then
					size = size + utility.table_size(value, true)
				end
			end
		else
			for key, value in next, the_table do
				size = size + 1
			end
		end
	end,

	init = function(self, engine)
		return self
	end
}

return utility