
local lighting = {}


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
            lg.draw(assets.lights.surround, player1.body:getX(), player1.body:getY(), player1.angle, 0.25, 0.25, 256, 256)
        cam:detach()
    love.graphics.setCanvas()

    lg.setColor(r, g, b, a)
end

function lighting.applyLights()
    lg.setBlendMode('subtract')
        lg.draw(lighting.canvas)
    lg.setBlendMode('alpha')
end


return lighting
