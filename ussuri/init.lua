local path = debug.getinfo(1).short_src:match("([^%.]*)[\\/][^%.]*%..*$"):gsub("[\\/]", ".") .. "."
local engine = require(path .. "core")

function love.run()
	engine:init()
	local engine_event = engine.event

	love.graphics.setFont(love.graphics.newFont())

	love.handlers = setmetatable({
		keypressed = function(b, u)
			if love.keypressed then love.keypressed(b, u) end
			engine_event:fire_keydown(b, u)
		end,

		keyreleased = function(b)
			if love.keyreleased then love.keyreleased(b) end
			engine_event:fire_keyup(b)
		end,

		mousepressed = function(x, y, b)
			if love.mousepressed then love.mousepressed(x, y, b) end
			engine_event:fire_mousedown(x, y, b)
		end,

		mousereleased = function(x, y, b)
			if love.mousereleased then love.mousereleased(x, y, b) end
			engine_event:fire_mouseup(x, y, b)
		end,

		joystickpressed = function(j, b)
			if love.joystickpressed then love.joystickpressed(j, b) end
			engine_event:fire_joydown(j, b)
		end,

		joystickreleased = function(j, b)
			if love.joystickreleased then love.joystickreleased(j, b) end
			engine_event:fire_joyup(j, b)
		end,

		focus = function(f)
			if love.focus then love.focus(f) end
			engine_event:fire_focus(f)
		end,

		quit = function()
			return
		end,
		}, {
		__index = function(self, name)
			error("Unknown event: " .. name)
		end,
	})

    math.randomseed(os.time())
    math.random() math.random()

	if love.load then love.load(arg) end

	local dt = 0
	local event, timer, graphics = love.event, love.timer, love.graphics

	while (true) do
		if (event) then
			event.pump()

			for e, a, b, c, d in event.poll() do
				if (e == "quit") then
					if (not love.quit or not love.quit()) then
						if (love.audio) then
							love.audio.stop()
						end

						engine:close()

						return
					end
				end

				love.handlers[e](a, b, c, d)
			end
		end

		if (timer) then
			timer.step()
			dt = timer.getDelta()
		end

		if (love.update) then
			love.update(dt)
		end
		engine_event:fire_update(dt)

		if (graphics) then
			graphics.clear()

			engine_event:fire_draw()
			if (love.draw) then
				love.draw()
			end
		end

		if (timer) then
			timer.sleep(0.001)
		end

		if (graphics) then
			graphics.present()
		end
	end
end

return engine