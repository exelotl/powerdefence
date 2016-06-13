
require 'gameConfig'

local lighting = {}

-- 0 => no lighting calculation (day)
-- 255 => full night time
lighting.amount = 0

function lighting.init()
    lighting.canvas = lg.newCanvas()
    lighting.amount = 0 -- start in day time
end


function lighting.renderLights()
    love.graphics.setCanvas(lighting.canvas)
        lg.setColor(ambientDarkness, ambientDarkness, ambientDarkness)
        lg.rectangle('fill', 0, 0, lg.getDimensions())
        cam:attach()


            -- orb glow
            lg.setColor(150, 150, 0)
            local scale = 1 + math.sin(globalTimer*3)*0.2
            lg.draw(assets.lights.surround, 0, 0, 0, scale, scale, 256, 256)

            -- orb mask
            lg.setColor(50, 50, 50)
            lg.draw(assets.orbm, assets.orbq[clamp(7 - orb.hp, 1, 7)],
                orb.body:getX(), orb.body:getY(), 0, 1, 1, 16, 16)


            lg.setColor(0, 50, 100)
            local originx, originy = 10, 128

            -- player1 torch
            if player1:isAlive() then
                local angle = player1.angle
                local x = player1.body:getX()+10*math.cos(angle)
                local y = player1.body:getY()+10*math.sin(angle)
                lg.draw(assets.lights.torch, x, y, angle, 0.4, 0.4, originx, originy)

                -- draw glow
                lg.setColor(100, 100, 100)
                x = player1.body:getX()
                y = player1.body:getY()
                lg.draw(assets.playerm[1], assets.playerq[player1.anim.frame], x, y, player1.rotation, 1, 1, 8, 8)
            end

            -- player2 torch
            if player2 and player2:isAlive() then
                angle = player2.angle
                x = player2.body:getX()+10*math.cos(angle)
                y = player2.body:getY()+10*math.sin(angle)
                lg.draw(assets.lights.torch, x, y, angle, 0.4, 0.4, originx, originy)

                -- draw glow
                lg.setColor(100, 100, 100)
                x = player2.body:getX()
                y = player2.body:getY()
                lg.draw(assets.playerm[2], assets.playerq[player2.anim.frame], x, y, player2.rotation, 1, 1, 8, 8)
            end

            -- explosions
            local allExplosions = scene.typelist.explosion
            if allExplosions then
                for _, e in ipairs(allExplosions) do
                    lg.setColor(50, 50, 50)
                    local scale = 0.5
                    lg.draw(assets.lights.surround, e.body:getX(), e.body:getY(), 0, scale, scale, 256, 256)
                end
            end

        cam:detach()
    love.graphics.setCanvas()
end

function lighting.applyLights()
    lg.setBlendMode('subtract')
        lg.setColor(255, 255, 255, lighting.amount)
        lg.draw(lighting.canvas)
    lg.setBlendMode('alpha')
end


return lighting
