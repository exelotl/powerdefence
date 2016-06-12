
local lighting = {}

-- 0 => no lighting calculation (day)
-- 255 => full night time
lighting.amount = 0

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
            --level = 50
            --lg.setColor(level, level, level)
            --lg.circle('fill', 0, 0, 50)
            lg.setColor(0, 50, 100)
            local originx, originy = 10, 128
            local x = player1.body:getX()+20*math.cos(player1.angle)
            local y = player1.body:getY()+20*math.sin(player1.angle)
            lg.draw(assets.lights.torch, x, y, player1.angle, 0.4, 0.4, originx, originy)
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
