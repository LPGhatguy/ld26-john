--[[
	Initializes the game and hands control over to the game loop
]]

local ussuri = require("ussuri")
local lib

local world
local game

function love.load()
	lib = ussuri.lib

	love.graphics.setDefaultImageFilter("nearest", "nearest")
	love.audio.setDistanceModel("inverse")

	ussuri:lib_folder_load("game")
	ussuri:lib_folder_load("lost")

	world = lib.game.world:new()
	world.map_manage:load_maps("asset/map/")

	game = lib.lost.game_manage:new(world)
	world.game = game

	game:start()

	ussuri.event:event_hook_object({"update", "draw", "keydown", "mousedown"}, game)
end