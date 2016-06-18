
local MenuList = require "MenuList"
local lighting = require "lighting"
local HUD = require "HUD"
local Scene = require "Scene"
local Player = require "Player"
local coordinator = require "coordinator"
local debugWorldDraw = require "external/debugworlddraw"



local game = {}



player1 = nil
player2 = nil




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

        -- main menu
        g.mainMenu = MenuList.new(0, 300)
        g.mainMenu:add('Start Game', function()
            g.currentMenu = g.gameModeMenu
        end)
        g.mainMenu:add('Cycle Player 1 Color', function()
            if g.player1Color == 4 then g.player1Color = 1
            else g.player1Color = g.player1Color + 1 end
        end)
        g.mainMenu:add('Cycle Player 2 Color', function()
            if g.player2Color == 4 then g.player2Color = 1
            else g.player2Color = g.player2Color + 1 end
        end)
        g.mainMenu:add('Exit', function()
            love.event.quit()
        end)

        -- game mode selection menu
        g.gameModeMenu = MenuList.new(0, 300)
        g.gameModeMenu:add('Orb Mode', function()
            g.gameMode = 'orb'
            game.setState('playing')
        end)
        g.gameModeMenu:add('Survival Mode', function()
            g.gameMode = 'survival'
            game.setState('playing')
        end)
        g.gameModeMenu:add('Back', function()
            g.currentMenu = g.mainMenu
        end)


        g.currentMenu = g.mainMenu

        lg.setFont(assets.menufont)

        g.colors = {1, 2, 3, 4} -- enum in Player.lua
        g.player1Color = g.colors[math.random(#g.colors)]
        g.player2Color = g.colors[math.random(#g.colors)]

    end,
    update = function(dt)
        local menuList = game.menu.globals.currentMenu

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

        g.currentMenu:draw()

        if g.currentLevel == g.mainMenu then

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

        elseif g.currentMenu == g.gameModeMenu then
            local itm = g.gameModeMenu:currentItemText()
            local txt = nil

            if itm == 'Orb Mode' then
                txt = 'Protect the orb. Kill all humans!'
            elseif itm == 'Survival Mode' then
                txt = 'Survive for as long as possible, no orb to protect'
            end

            if txt then
                lg.setColor(150,50,50)
                local sw, sh = lg.getDimensions()
                lg.push()
                lg.printf(txt, 0, sh*0.8, sw, 'center')
                lg.pop()
            end
        end
    end,
}












function drawMessage(string, y)
    y = y or 20
    lg.setColor(255,255,255)
    local sw, sh = lg.getDimensions()
    local scalex = sw/BASE_WIDTH
    lg.push()
    lg.scale(scalex)
    lg.printf(string, 0, y, BASE_WIDTH-5, 'right')
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
        coordinator.startGame(scene, game.menu.globals.gameMode)


        -- makes sure that the player tags in and the color is set correctly to
        -- reflect the choice from the menu
        player2 = nil
        input.joy2 = nil



        player1 = Player.new(scene, 1, game.menu.globals.player1Color)
        input.joy1 = nil


        love.resize(love.graphics.getDimensions())

        cam:zoomTo(2) -- set render scale
        cam:lookAt(0,0)

		lg.setFont(assets.gamefont)

    end,
    update = function(dt)
        if paused then
            -- prevent the global timer from increasing
            globalTimer = globalTimer - dt
            return
        end


        coordinator.update(dt)

        scene:update(dt)

        updateCamera(dt)

    end,

    draw = function()
        lg.setBackgroundColor(253,233,137)
        lg.setColor(255,255,255)


        cam:attach()
            coordinator.draw()
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
            coordinator.drawMessages()
        end

        if debugMode then
            cam:attach()
                -- passes area to search
                debugWorldDraw(scene.world, -1024, -1024, 2048, 2048)
            cam:detach()
        end
    end,
}





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
