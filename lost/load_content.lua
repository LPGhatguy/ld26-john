--[[
Loads all the game's base and initial content.
]]

local content_loader

content_loader = {
	init = function(self, ussuri)
		local lib = ussuri.lib

		local asset = lib.game.asset

		asset:load_font("default_font")
		asset:load_font_file("note_font", "pixel_arial.ttf", 32)
		asset:load_image("title_screen", "title_screen.png")
		asset:load_sound("title_music", "title_music.ogg", "stream"):setLooping(true)
		asset:load_sound("boop15", "boop15.ogg")

		asset:load_image("image_tiles", "tiles.png")
		asset:load_image("image_john", "john.png")

		asset:load_world_sound("johnstep", "johnstep.ogg")
		asset:load_world_sound("shadow_scream", "shadow_scream.ogg"):setDistance(40, 50)
		asset:load_sound("player_die", "player_die.ogg")
	end
}

return content_loader