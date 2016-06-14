
local MenuList = require "MenuList"
local level = require "level"
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
local debugWorldDraw = require "external/debugworlddraw"



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


function game.setState(newState)
    game.state = newState
    game.load()
end



game.menu = {
    globals = {},
    load = function()
        game.menu.globals = {} -- reset globals
        local g = game.menu.globals

        love.mouse.setVisible(true)
        input.currentState = input.states.menu

        g.menuList = MenuList.new(0, 300)
        g.menuList:add('Start Game', function()
            game.setState('playing')
        end)
        g.menuList:add('Cycle Player 1 Color', function()
            if g.player1Color == 4 then g.player1Color = 1
            else g.player1Color = g.player1Color + 1 end
        end)
        g.menuList:add('Cycle Player 2 Color', function()
            if g.player2Color == 4 then g.player2Color = 1
            else g.player2Color = g.player2Color + 1 end
        end)

        lg.setFont(assets.menufont)

        g.colors = {1, 2, 3, 4} -- enum in Player.lua
        g.player1Color = g.colors[math.random(#g.colors)]
        g.player2Color = g.colors[math.random(#g.colors)]

    end,
    update = function(dt)
        local menuList = game.menu.globals.menuList

        menuList:centerH()
        local _, h = lg.getDimensions()
        menuList.y = h * 0.40
        menuList:update(dt)
    end,

    draw = function()
        local g = game.menu.globals

        lg.setBackgroundColor(50,50,50)
        lg.setColor(255,255,255)

        local xscale = lg.getWidth()/1920
        local yscale = lg.getHeight()/1080
        lg.draw(assets.title, 0, 0, 0, xscale,yscale)

        g.menuList:draw()

        local width, height = lg.getDimensions()
        local playerIndent = lg.getWidth()/8
        local sf = lg.getWidth()/100

        -- draw masks around player 1
        lg.setColor(255,255,255)
        local mask = assets.playerm[g.player1Color]
        local quad = assets.playerq[1]
        lg.draw(mask, quad, playerIndent, height/2, 0, sf, sf, 8+1, 8)
        lg.draw(mask, quad, playerIndent, height/2, 0, sf, sf, 8, 8+1)
        lg.draw(mask, quad, playerIndent, height/2, 0, sf, sf, 8-1, 8)
        lg.draw(mask, quad, playerIndent, height/2, 0, sf, sf, 8, 8-1)

        -- draw player 1
        lg.draw(assets.player[g.player1Color], assets.playerq[1],
            playerIndent, height/2, 0, sf, sf, 8, 8)


        -- draw masks around player 2
        lg.setColor(255,255,255)
        mask = assets.playerm[g.player2Color]
        quad = assets.playerq[5]
        lg.draw(mask, quad, width-playerIndent, height/2, 0, sf, sf, 8+1, 8)
        lg.draw(mask, quad, width-playerIndent, height/2, 0, sf, sf, 8, 8+1)
        lg.draw(mask, quad, width-playerIndent, height/2, 0, sf, sf, 8-1, 8)
        lg.draw(mask, quad, width-playerIndent, height/2, 0, sf, sf, 8, 8-1)

        -- draw player2
        lg.draw(assets.player[g.player2Color], assets.playerq[5],
            width-playerIndent, height/2, 0, sf, sf, 8, 8)
    end,
}











-- mode module holds day/night status


local redSpawner = nil
local greenSpawner = nil
local currentLevel = nil

local lastSpawnTime = 0
function spawn()
    wave.new(scene, 0.1, 25, 500, EnemySoldier)
    wave.new(scene, 0.3, 75, 500, EnemyGrunt)
end

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
    globals = {},
    load = function()
        game.playing.globals = {} -- reset globals
        local pg = game.playing.globals

        love.mouse.setVisible(false)
        input.currentState = input.states.playing


        scene = Scene.new()

        -- not game over
        pg.isDoomed = false

        -- set to day time
        mode.lastSunrise = globalTimer
        mode.current = 'day'
        lighting.init()

        -- makes sure that the player tags in and the color is set correctly to
        -- reflect the choice from the menu
        player2 = nil
        input.joy2 = nil

        player1 = Player.new(scene, 1, game.menu.globals.player1Color)

        local e = EnemyGrunt.new(scene, 100, 100)
        e.hp = 9999
        e.moveForce = 0

        orb = Orb.new(scene, 0, 0)

        love.resize(love.graphics.getDimensions())

        cam:zoomTo(2) -- set render scale
        cam:lookAt(0,0)

		lg.setFont(assets.gamefont)

    end,
    update = function(dt)
        if paused then return end


        if mode.isSunset() and not debugMode then
            mode.toggle()
            spawn()
        end

        if globalTimer > lastSpawnTime + 15 then
            spawn()
            if player1:isAlive() then player1.hp = player1.hp + 1 end
            if player2 and player2:isAlive() then player2.hp = player2.hp + 1 end

            for _, w in ipairs(player1.weapons) do
                w:reload()
            end

            if player2 then
                for _, w in ipairs(player2.weapons) do
                    w:reload()
                end
            end
            lastSpawnTime = globalTimer
        end

        -- end of the wave

        --[[
        if mode.current == 'night' and not scene.typelist.enemy or #scene.typelist.enemy == 0 then
            for _, e = ipairs(scene.typelist.deadEnemy) do
                scene:remove(e)
            end
        end
        --]]

        -- game over
        if (not player1:isAlive() and (not player2 or not player2:isAlive()))
            or orb.hp <= 0 then
            if not debugMode then
                initiateGameOver()
            end
        end

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
            p1x = p1x + math.cos(player1.aimAngle) * dist1
            p1y = p1y + math.sin(player1.aimAngle) * dist1
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
		if debugMode then
            cam.x = currentCamX
            cam.y = currentCamY
        else
            cam.x = currentCamX + math.random(-screenShake, screenShake)
            cam.y = currentCamY + math.random(-screenShake, screenShake)
        end

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


        if paused then
            drawMessage('Paused')
        else
            if mode.current == 'day' then
                drawMessage(('time until sunset: %.1f'):format(mode.timeUntilSunset()))
            else
                drawMessage(('%d enemies remaining'):format(scene.typelist.enemy and #scene.typelist.enemy or 0))
            end
        end

        if debugMode then
            cam:attach()
                -- passes area to search
                debugWorldDraw(scene.world, -1024, -1024, 2048, 2048)
            cam:detach()
        end
    end,
}

-- playing globals
local pg = game.playing.globals



-- can be called many times but only initiates game over sequence once
function initiateGameOver()
    if not pg.doomed then
        pg.doomed = true
        assets.playSfx(assets.sfxOrbDestroy)

        -- delay showing the game over screen
        flux.to({}, 4, {}):oncomplete(function()
            game.setState('gameOver')
        end)
    end
end




game.gameOver = {
    load = function()
        -- delay registering clicks as taking back to main menu
        flux.to({}, 1, {}):oncomplete(function()
            input.currentState = input.states.gameOverScreen
        end)
    end,
    update = function(dt)

    end,

    draw = function()
        lg.setBackgroundColor(50,50,50)
        lg.setColor(255,255,255)

        local xscale = lg.getWidth()/1920
        local yscale = lg.getHeight()/1080
        lg.draw(assets.gameOver, 0, 0, 0, xscale,yscale)
    end,
}


return game
