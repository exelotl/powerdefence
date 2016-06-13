
local ForceField = require "ForceField"
local lighting = require "lighting"
local HUD = require "HUD"



local game = {}

-- 'menu' | 'playing' | 'gameOver'
game.state = 'playing'

function game.update(dt)
    game[game.state].update(dt)
end
function game.draw()
    game[game.state].draw()
end


game.menu = {
    update = function(dt)

    end,

    draw = function()

    end,
}


game.playing = {
    update = function(dt)
        scene:update(dt)

        -- camera
        local dist = 75
        local p1x, p1y = player1.body:getPosition()
        if input.lastAim == 'joy' then dist = dist*input.joy1LookMag end

        p1x = p1x + math.cos(player1.angle) * dist
        p1y = p1y + math.sin(player1.angle) * dist
        local dist = 75*input.joy2LookMag
        local p2x, p2y = p1x, p1y
        if player2 then
            p2x, p2y = player2.body:getPosition()
            p2x = p2x + math.cos(player2.angle) * dist
            p2y = p2y + math.sin(player2.angle) * dist
        end

        local ratio = 0.5
        local targetx = lerp(p1x, p2x, ratio)
        local targety = lerp(p1y, p2y, ratio)

        local lerpAmount = math.min(dt*5, 1)
        cam:lookAt(lerp(cam.x, targetx, lerpAmount), lerp(cam.y, targety, lerpAmount))

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
    update = function(dt)

    end,

    draw = function()

    end,
}


return game
