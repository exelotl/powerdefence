oo = require "oo"
cam = (require "camera")()
flux = require "flux"
assets = require "assets"
input = require "input"
local limitFrameRate = require "limitframerate"
local Scene = require "Scene"

local animSpeed = 1
debug = false -- global debug flag (toggle: F1). Use as you wish

function love.load(arg)

    -- allows debugging (specifically breakpoints) in ZeroBrane
    if arg[#arg] == '-debug' then require('mobdebug').start() end

	lf = love.filesystem
	ls = love.sound
	la = love.audio
	lp = love.physics
	lt = love.thread
	li = love.image
	lg = love.graphics
	lm = love.mouse
	lj = love.joystick

	assets.load()
	-- lg.setFont(assets.font)

	globalTimer = 0

	math.randomseed(os.time())

	scene = Scene.new()

	cam:zoomTo(2) -- set render scale
end


function love.update(dt)
	limitFrameRate(60)

	flux.update(dt*animSpeed) -- update tweening system
	globalTimer = globalTimer + dt
	scene:update(dt)

    -- no love.blah function for joystick axis change
	input.checkJoystickAxes()

	limitFrameRate(60)
end


function love.draw()
	lg.setBackgroundColor(255,255,255)
	lg.setColor(255,255,255)

	cam:attach()
	scene:draw()
	cam:detach()
end

