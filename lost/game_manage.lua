--[[
	Manages game-level stuff like states and the UI
]]

local lib
local engine
local asset
local game

game = {
	state = "title",
	event = {},
	queued = {},
	fader_color = {0, 0, 0},
	fader_alpha = 255,
	note_text = "Hello, world!",
	note_alpha = 0,
	stating = false,

	pre = {
		update = function(self, event)
			if (self.state ~= "paused") then
				if (self.queued[1]) then
					local result = self.queued[1](self, event)

					if (not result) then
						table.remove(self.queued, 1)
					end
				end
			end
		end
	},

	post = {
		draw = function(self, event)
			if (self.state ~= "paused") then
				local color = self.fader_color
				love.graphics.setColor(color[1], color[2], color[3], self.fader_alpha)
				love.graphics.rectangle("fill", 0, 0, self.world.width, self.world.height)

				love.graphics.setColor(255, 255, 255, self.note_alpha)
				love.graphics.setFont(asset:get("note_font"))
				love.graphics.printf(self.note_text, 0, 16, self.world.width, "center")
			end
		end
	},

	states = {
		title = {
			draw = function(self, event)
				love.graphics.setColor(255, 255, 255)
				love.graphics.draw(asset:get("title_screen"), 0, 0)
			end,

			keydown = function(self, event)
				if (not self.stating) then
					self.stating = true
					asset:play_sound("boop15")

					local eyefade = self:fade_out(1)
					local earfade = self:sound_fade(1)
					self:queue(function(self, event)
						earfade(self, event)
						return eyefade(self, event)
					end)

					self:queue(function()
						self.world.map_manage:change_map(1, true)
						self:set_state("playing")
						self.stating = false
					end)

					self:queue(self:fade_in(1))
				end
			end,

			mousedown = function(self, event)
				if (not self.stating) then
					self.stating = true
					asset:play_sound("boop15")

					local eyefade = self:fade_out(1)
					local earfade = self:sound_fade(1)
					self:queue(function(self, event)
						earfade(self, event)
						return eyefade(self, event)
					end)

					self:queue(function(self, event)
						self.world.map_manage:change_map(1, true)
						self:set_state("playing")
						self.stating = false
					end)

					self:queue(self:fade_in(1))
				end
			end
		},

		playing = {
			update = function(self, event)
				self.world:update(event)
			end,

			draw = function(self, event)
				self.world:draw(event)
			end,

			keydown = function(self, event)
				if (event.key == "escape") then
					love.audio.pause()
					self:set_state("paused")
				else
					self.world:keydown(event)
				end
			end
		},

		paused = {
			draw = function(self, event)
				love.graphics.setFont(asset:get("note_font"))
				love.graphics.setColor(255, 255, 255)
				love.graphics.printf("Paused.\nPress [ESCAPE] to resume.\nPress [TAB] to quit.", 0, 322, 1024, "center")
			end,

			keydown = function(self, event)
				if (event.key == "escape") then
					self:set_state("playing")
					love.audio.resume()
				elseif (event.key == "tab") then
					engine:quit()
				end
			end,
		},

		game_over = {
			draw = function(self, event)
				love.graphics.setFont(asset:get("note_font"))
				love.graphics.setColor(255, 255, 255)
				love.graphics.printf("Game over.\nPress [ESCAPE] to quit.\nPress [SPACE] to play again.", 0, 360, 1024, "center")
			end,

			keydown = function(self, event)
				if (event.key == "escape") then
					engine:quit()
				elseif (event.key == " ") then
					self:queue(self:fade_out(2))
					self:queue(function()
						self:set_state("title")
						self:start()
					end)
				end
			end,
		},
	},

	set_state = function(self, state)
		local pass = {from = self.state, to = state}

		self.event.state_changing(self, pass)
		self.state = state

		self.event.state_changed(self, pass)
	end,

	queue = function(self, method)
		table.insert(self.queued, method)
	end,

	sound_fade = function(self, time)
		local step = 1 / time
		local volume = 1

		return function(self, event)
			volume = volume - step * event.delta
			love.audio.setVolume(volume)

			if (volume <= 0) then
				love.audio.stop()
				love.audio.setVolume(1)
			else
				return true
			end
		end
	end,

	fade_out = function(self, time)
		local step = 255 / time

		return function(self, event)
			self.fader_alpha = self.fader_alpha + step * event.delta

			if (self.fader_alpha >= 255) then
				self.fader_alpha = 255
			else
				return true
			end
		end
	end,

	fade_in = function(self, time)
		local step = 255 / time

		return function(self, event)
			self.fader_alpha = self.fader_alpha - step * event.delta

			if (self.fader_alpha <= 0) then
				self.fader_alpha = 0
			else
				return true
			end
		end
	end,

	wait = function(self, time)
		local elapsed = 0

		return function(self, event)
			elapsed = elapsed + event.delta

			if (elapsed <= time) then
				return true
			end
		end
	end,

	note = function(self, text, time)
		local step = 255 / 0.5

		self:queue(function(self, event)
			self.note_text = text
		end)

		self:queue(function(self, event)
			self.note_alpha = self.note_alpha + step * event.delta

			if (self.note_alpha >= 255) then
				self.note_alpha = 255
			else
				return true
			end
		end)

		self:queue(self:wait(time))

		self:queue(function(self, event)
			self.note_alpha = self.note_alpha - step * event.delta

			if (self.note_alpha <= 0) then
				self.note_alpha = 0
			else
				return true
			end
		end)
	end,

	ending = function(self)
		local fade = self:fade_out(2)
		local sfade = self:sound_fade(2)
		self:queue(function(self, event)
			sfade(self, event)
			return fade(self, event)
		end)

		self:queue(function()
			self.world.character.mobile = false
			self.world.character.anim_step = 1
		end)

		self:queue(self:fade_in(1))
		self:queue(self:fade_out(2))

		self:queue(function()
			asset:play_sound("wake_up1")
		end)

		self:queue(self:fade_in(1))
		self:queue(self:fade_out(2))

		self:queue(function()
			asset:play_sound("wake_up2")
		end)

		self:queue(self:fade_in(1))
		self:queue(self:fade_out(2))

		self:queue(function()
			asset:play_sound("wake_up4")
		end)

		self:queue(self:wait(2))

		local fade = self:fade_out(2)
		local sfade = self:sound_fade(2)
		self:queue(function(self, event)
			sfade(self, event)
			return fade(self, event)
		end)

		self:queue(function()
			self:set_state("game_over")
			self:queue(self:fade_in(2))
		end)
	end,

	kill_player = function(self)
		if (self.world.character.alive == true) then
			self.world.character.alive = false
			self.world.character.mobile = false
			asset:play_sound("player_die")

			self:queue(self:fade_out(1))
			self:queue(function()
				self.world.map_manage:spawn_player()
			end)

			self:queue(self:wait(2))
			self:queue(self:fade_in(2))
			self:queue(function()
				self.world.character.alive = true
				self.world.character.mobile = true
			end)
		end
	end,

	start = function(self)
		self:queue(self:wait(0.4))
		self:queue(function()
			asset:get("title_music"):stop()
			asset:play_sound("title_music")
		end)
		self:queue(self:fade_in(1))

		self.world.character.mobile = true
	end,

	new = function(self, world)
		local instance = self:_new()

		instance.world = world

		return instance
	end,

	init = function(self, gengine)
		gengine:lib_get("lost.load_content")
		lib = gengine.lib

		asset = lib.game.asset
		engine = gengine

		lib.oop:objectify(self)
	end
}

setmetatable(game.event, {
	__index = function(self, key)
		local method = function(instance, event)
			local proxied = instance.states[instance.state][key]
			local pre = instance.pre[key]
			local post = instance.post[key]

			if (pre) then
				pre(instance, event)
			end

			if (proxied) then
				proxied(instance, event)
			end

			if (post) then
				post(instance, event)
			end
		end

		self[key] = method

		return method
	end
})

return game