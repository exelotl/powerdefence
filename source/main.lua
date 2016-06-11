oo = require "oo"
cam = (require "camera")()
flux = require "flux"
assets = require "assets"
input = require "input"
local limitFrameRate = require "limitframerate"
local Scene = require "Scene"
local Player = require "Player"

local animSpeed = 1
debug = false -- global debug flag (toggle: F1). Use as you wish

player1 = nil
player2 = nil

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

	assets.load()

	-- lg.setFont(assets.font)

	globalTimer = 0

	math.randomseed(os.time())

	scene = Scene.new()


	player1 = Player.new()
	scene:add(player1)

	cam:zoomTo(2) -- set render scale
	cam:lookAt(0,0)
end


function love.update(dt)
	limitFrameRate(60)

	flux.update(dt*animSpeed) -- update tweening system
	globalTimer = globalTimer + dt
	scene:update(dt)
  cam:lookAt(player1.body:getPosition())
    -- no love.blah function for joystick axis change
	input.checkJoystickAxes()

	limitFrameRate(60)
end


function love.draw()
	lg.setBackgroundColor(255,255,255)
	lg.setColor(255,255,255)

	cam:attach()

	lg.draw(assets.background,-512,-512,0,1,1,0,0,0,0)
	lg.draw(assets.fft,-512,-512,0,1,1,0,0,0,0)
	
	scene:draw()
  lg.draw(assets.ffb,-512,-512,0,1,1,0,0,0,0)

	cam:detach()
end

