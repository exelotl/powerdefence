oo = require "oo"
cam = (require "camera")()
flux = require "flux"
assets = require "assets"
input = require "input"
local limitFrameRate = require "limitframerate"
local EnemyGrunt = require "EnemyGrunt"
local lighting = require "lighting"
local mode = require "mode"
local game = require "game"

local piefiller = require "external.piefiller"

local animSpeed = 1
debugMode = false -- global debug flag (toggle: F1). Use as you wish
profilerEnabled = false

-- for scaling the window
BASE_WIDTH = 400
BASE_HEIGHT = 240


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
end

function love.resize(w, h)
	local ratiox = w / BASE_WIDTH
	local ratioy = h / BASE_HEIGHT
	flux.to(cam, 1, {scale = math.max(ratiox, ratioy)})
end
