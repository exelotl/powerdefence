
local lighting = {}

-- 0 => no lighting calculation (day)
-- 255 => full night time
lighting.amount = 255

function lighting.init()
    lighting.canvas = lg.newCanvas()
end


function lighting.renderLights()
    local r, g, b, a = lg.getColor()
    love.graphics.setCanvas(lighting.canvas)
        local level = 180
        lg.setColor(level, level, level)
        lg.rectangle('fill', 0, 0, lg.getDimensions())
        cam:attach()


            lg.setColor(150, 150, 0)
            lg.draw(assets.lights.surround, 0, 0, 0, 0.3, 0.3, 256, 256)

            lg.setColor(0, 50, 100)
            local originx, originy = 10, 128


            local angle = player1.angle
            local x = player1.body:getX()+10*math.cos(angle)
            local y = player1.body:getY()+10*math.sin(angle)
            lg.draw(assets.lights.torch, x, y, angle, 0.4, 0.4, originx, originy)


            if player2 then
                angle = player2.angle
                x = player2.body:getX()+10*math.cos(angle)
                y = player2.body:getY()+10*math.sin(angle)
                lg.draw(assets.lights.torch, x, y, angle, 0.4, 0.4, originx, originy)
            end
        cam:detach()
    love.graphics.setCanvas()

    lg.setColor(r, g, b, a)
end

function lighting.applyLights()
    lg.setBlendMode('subtract')
        lg.setColor(255, 255, 255, lighting.amount)
        lg.draw(lighting.canvas)
    lg.setBlendMode('alpha')
end


return lighting
