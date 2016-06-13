
local ForceField = require "ForceField"
local lighting = require "lighting"
local HUD = require "HUD"
local Scene = require "Scene"
local Player = require "Player"
local Orb = require "Orb"
local wave = require "wave"



local game = {}



player1 = nil
player2 = nil

orb = nil








-- 'menu' | 'playing' | 'gameOver'
game.state = 'menu'

function game.load()
    game[game.state].load()
end
function game.update(dt)
    game[game.state].update(dt)
end
function game.draw()
    game[game.state].draw()
end


game.menu = {
    load = function()
        love.mouse.setVisible(true)
        input.currentState = input.states.menu
    end,
    update = function(dt)
    end,

    draw = function()
        lg.setBackgroundColor(50,50,50)
        lg.setColor(255,255,255)


    end,
}


game.playing = {
    load = function()
        love.mouse.setVisible(false)
        input.currentState = input.states.night

        scene = Scene.new()

        lighting.init()

        player1 = Player.new(scene, 1)

        orb = Orb.new(scene, 0,0)

        wavey = wave.new(scene, 0,1000,500)
        love.resize(love.graphics.getDimensions())
        cam:zoomTo(2) -- set render scale
        cam:lookAt(0,0)
    end,
    update = function(dt)
        scene:update(dt)

        -- camera
        local dist1 = 75
		local p1x, p1y = player1.body:getPosition()
		if input.lastAim == 'joy' then dist1 = dist1*input.joy1LookMag end
		p1x = p1x + math.cos(player1.angle) * dist1
		p1y = p1y + math.sin(player1.angle) * dist1

		local dist2 = 75*input.joy2LookMag
		local p2x, p2y = p1x, p1y
		if player2 then
			p2x, p2y = player2.body:getPosition()
			p2x = p2x + math.cos(player2.angle) * dist2
			p2y = p2y + math.sin(player2.angle) * dist2
		end

		local ratio = 0.5
		local targetx = lerp(p1x, p2x, ratio)
		local targety = lerp(p1y, p2y, ratio)

		local lerpAmount = math.min(dt*5, 1)
		currentCamX = lerp(cam.x, targetx, lerpAmount)
		currentCamY = lerp(cam.y, targety, lerpAmount)
		cam.x = currentCamX + math.random(-screenShake, screenShake)
		cam.y = currentCamY + math.random(-screenShake, screenShake)

		screenShake = screenShake - dt*screenShake*10
		if screenShake < 0.1 then
			screenShake = 0
		end

    end,

    draw = function()
        lg.setBackgroundColor(253,233,137)
        lg.setColor(255,255,255)


        cam:attach()
            lg.draw(assets.background,-512,-512,0,1,1,0,0,0,0)

            ForceField:drawTop()
            scene:draw()
            ForceField:drawBottom()
        cam:detach()


        -- doesn't affect the output during the day
        lighting.renderLights()
        lighting.applyLights()

        HUD.draw()

        if debugMode then
            lg.setColor(255,0,0)
            love.graphics.print('debug on', 20, 20)
            love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 20, 40)
        else
            love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 20, 20)
        end

        if input.lastAim == 'mouse' then
            lg.setColor(255,255,255)
            lg.draw(assets.reticule, input.mousex, input.mousey, 0, cam.scale*0.6, cam.scale*0.6, 7, 7)
        end
        lg.setColor(255,255,255)
    end,
}

game.gameOver = {
    load = function()
    end,
    update = function(dt)

    end,

    draw = function()

    end,
}


return game
