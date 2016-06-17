oo = require "oo"
flux = require "flux"
assets = require "assets"
input = require "input"
require 'camera'
local limitFrameRate = require "limitframerate"
local EnemyGrunt = require "EnemyGrunt"
local EnemySoldier = require "EnemySoldier"
local lighting = require "lighting"
local game = require "game"

local piefiller = require "external.piefiller"

local animSpeed = 1
debugMode = false -- global debug flag (toggle: F1). Use as you wish
profilerEnabled = false



function love.load(arg)

    -- allows debugging (specifically breakpoints) in ZeroBrane
    --if arg[#arg] == '-debug' then require('mobdebug').start() end

	-- for printing in zerobrane
	io.stdout:setvbuf("no")

	lf = love.filesystem
	ls = love.sound
	la = love.audio
	lp = love.physics
	lt = love.thread
	li = love.image
	lg = love.graphics
	lm = love.mouse
	lj = love.joystick
	lw = love.window

	assets.load()


	globalTimer = 0

	math.randomseed(os.time())


    game.load()
    lighting.init()

	pie = piefiller:new()
end


function love.update(dt)
	limitFrameRate(60)

	if profilerEnabled then pie:attach() end

    flux.update(dt*animSpeed) -- update tweening system
    globalTimer = globalTimer + dt

    game.update(dt)

	-- no love.blah function for joystick axis change
    input.checkJoystickAxes()

	if profilerEnabled then pie:detach() end
end


function love.draw()
    game.draw()
	if profilerEnabled then pie:draw() end

    if debugMode then
        lg.setColor(255,0,0)
        love.graphics.print('debug on', 20, 20)
        love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 20, 40)
    else
        lg.setColor(100, 100, 100)
        love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 20, 20)
    end
end

