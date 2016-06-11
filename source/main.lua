oo = require "oo"
cam = (require "camera")()
flux = require "flux"
assets = require "assets"
local limitFrameRate = require "limitframerate"
local Scene = require "Scene"

local animSpeed = 1

function love.load()
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
end


function love.mousepressed(x, y)
	
end

function love.keypressed(key)
	if key=="f" then
		local fs = love.window.getFullscreen()
		love.window.setFullscreen(not fs, "desktop")
		-- update camera?
	end
	if key=="escape" or key=="q" then
		love.event.quit()
	end
	
end

function love.draw()
	lg.setBackgroundColor(255,255,255)
	lg.setColor(255,255,255)
	
	cam:attach()
	
	scene:draw()
	
	cam:detach()
end

