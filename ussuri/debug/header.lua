--[[
Debug Header
Intercepts Keystrokes to assist in speedy debugging
]]

local engine, lib
local header

header = {
	event = {
		keydown_priority = -503,
		keydown = function(self, event)
			if (love.keyboard.isDown("lctrl")) then
				if (event.key == "tab") then
					event.flags.cancel = true

					if (love.keyboard.isDown("lshift")) then
						engine.config.log.autosave = true
						engine.log:write(lib.utility.table_tree(engine))
					end

					engine:quit()
				end
			end
		end
	},

	init = function(self, g_engine)
		engine = g_engine
		lib = engine.lib
	end
}

return header