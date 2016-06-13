
local MenuList = require "MenuList"
local Level = require "level"
local ForceField = require "ForceField"
local lighting = require "lighting"
local HUD = require "HUD"
local Scene = require "Scene"
local Player = require "Player"
local Orb = require "Orb"
local wave = require "wave"
local mode = require "mode"
local EnemyGrunt = require "EnemyGrunt"
local EnemySoldier = require "EnemySoldier"



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


local menuList = nil
local colors = {1, 2, 3, 4} -- enum in Player.lua
player1Color = Player.COLOR_BLUE
player2Color = Player.COLOR_PINK

game.menu = {
    load = function()
        love.mouse.setVisible(true)
        input.currentState = input.states.menu

        menuList = MenuList.new(0, 300)
        menuList:add('Start Game', function()
            game.state = 'playing'
            game.load()
        end)
        menuList:add('Cycle Player 1 Color', function()
            if player1Color == 4 then player1Color = 1
            else player1Color = player1Color + 1 end
        end)
        menuList:add('Cycle Player 2 Color', function()
            if player2Color == 4 then player2Color = 1
            else player2Color = player2Color + 1 end
        end)

        lg.setFont(assets.menufont)


    end,
    update = function(dt)
        menuList:centerH()
        local _, h = lg.getDimensions()
        menuList.y = h * 0.40
        menuList:update(dt)
    end,

    draw = function()
        lg.setBackgroundColor(50,50,50)
        lg.setColor(255,255,255)

        menuList:draw()

        local width, height = lg.getDimensions()
        local playerIndent = 300
        local sf = 20

        lg.setColor(255,255,255)
        lg.draw(assets.playerm[player1Color], assets.playerq[1],
            playerIndent, height/2, 0, sf, sf, 8+1, 8)
        lg.draw(assets.playerm[player1Color], assets.playerq[1],
            playerIndent, height/2, 0, sf, sf, 8, 8+1)
        lg.draw(assets.playerm[player1Color], assets.playerq[1],
            playerIndent, height/2, 0, sf, sf, 8-1, 8)
        lg.draw(assets.playerm[player1Color], assets.playerq[1],
            playerIndent, height/2, 0, sf, sf, 8, 8-1)
        -- draw player 1
        lg.draw(assets.player[player1Color], assets.playerq[1],
            playerIndent, height/2, 0, sf, sf, 8, 8)


        lg.setColor(255,255,255)
        lg.draw(assets.playerm[player2Color], assets.playerq[5],
            width-playerIndent, height/2, 0, sf, sf, 8+1, 8)
        lg.draw(assets.playerm[player2Color], assets.playerq[5],
            width-playerIndent, height/2, 0, sf, sf, 8, 8+1)
        lg.draw(assets.playerm[player2Color], assets.playerq[5],
            width-playerIndent, height/2, 0, sf, sf, 8-1, 8)
        lg.draw(assets.playerm[player2Color], assets.playerq[5],
            width-playerIndent, height/2, 0, sf, sf, 8, 8-1)
        -- draw player2
        lg.draw(assets.player[player2Color], assets.playerq[5],
            width-playerIndent, height/2, 0, sf, sf, 8, 8)
    end,
}











-- mode module holds day/night status


local currentLevel = 1
local levels = {
    {
        Level.new()
    },
}

local redSpawner = nil
local greenSpawner = nil


function drawMessage(string)
    lg.setColor(255,255,255)
    local sw, sh = lg.getDimensions()
    local scalex = sw/BASE_WIDTH
    lg.push()
    lg.scale(scalex)
    lg.printf(string, 0, 20, BASE_WIDTH-5, 'right')
    lg.pop()
end


game.playing = {
    load = function()
        love.mouse.setVisible(false)
        input.currentState = input.states.playing

        scene = Scene.new()

        lighting.init()

        -- makes sure that the player tags in and the color is set correctly to
        -- reflect the choice from the menu
        player2 = nil

        player1 = Player.new(scene, 1)
        player1.color = player1Color

        orb = Orb.new(scene, 0, 0)

        mode.lastSunrise = globalTimer

        love.resize(love.graphics.getDimensions())

        cam:zoomTo(2) -- set render scale
        cam:lookAt(0,0)

		lg.setFont(assets.gamefont)
    end,
    update = function(dt)
        if mode.isSunset() then
            mode.toggle()
            wavey = wave.new(scene, 0, 50, 500, EnemySoldier)
        end

        -- end of the wave
        --[[
        if mode.current == 'night' and not scene.typelist.enemy or #scene.typelist.enemy == 0 then
            for _, e = ipairs(scene.typelist.deadEnemy) do
                scene:remove(e)
            end
        end
        --]]

        scene:update(dt)

        -- camera
        -- if both alive: lerp between
        -- if one player dead or not spawned: focus completely on the other
        -- if all dead or not spawned: look at 0, 0
        local p1x, p1y = 0, 0
        if player1:isAlive() then
            local dist1 = 75
            p1x, p1y = player1.body:getPosition()
            if input.lastAim == 'joy' then dist1 = dist1*input.joy1LookMag end
            p1x = p1x + math.cos(player1.angle) * dist1
            p1y = p1y + math.sin(player1.angle) * dist1
        end

		local p2x, p2y = 0, 0
		if player2 and player2:isAlive() then
            local dist2 = 75*input.joy2LookMag
			p2x, p2y = player2.body:getPosition()
			p2x = p2x + math.cos(player2.angle) * dist2
			p2y = p2y + math.sin(player2.angle) * dist2

			if not player1:isAlive() then p1x, p1y = p2x, p2y end
		else
		    p2x, p2y = p1x, p1y
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


        if input.lastAim == 'mouse' and player1:isAlive() then
            lg.setColor(255,255,255)
            lg.draw(assets.reticule, input.mousex, input.mousey, 0, cam.scale*0.6, cam.scale*0.6, 7, 7)
        end
        lg.setColor(255,255,255)


        if mode.current == 'day' then
            drawMessage(('time until sunset: %.1f'):format(mode.timeUntilSunset()))
        else
            drawMessage(('%d enemies remaining'):format(scene.typelist.enemy and #scene.typelist.enemy or 0))
        end


        if debugMode then
            lg.setColor(255,0,0)
            love.graphics.print('debug on', 20, 20)
            love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 20, 40)
        else
            love.graphics.print(string.format('FPS: %d', love.timer.getFPS()), 20, 20)
        end


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
