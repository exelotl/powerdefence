local hud = {}

local assets = require "assets"


-- draw a number of hearts
-- pos = 'left' | 'right'
function drawHearts(number, color, pos)
    assert(pos == 'left' or pos == 'right')

    for i = 0, number-1 do
        local heartquad = assets.heartq[color]
        local _,_,heartx,hearty = heartquad:getViewport()
        local scale = cam.scale * 0.4
        local border = 10

        local x = 0
        if pos == 'left' then
            x = (i * heartx + border) * scale
        elseif pos == 'right' then
            x = lg.getWidth() - ((i+1) * heartx + border) * scale
        end

        local y = lg.getHeight() - (hearty + border) * scale

        lg.draw(assets.hearts,heartquad, x, y, 0, scale, scale)
    end
end

function drawWeapons(weapons, currentI, pos)
    assert(pos == 'left' or pos == 'right')

    local left = pos == 'left'

    local scale = cam.scale * 0.8
    local spacing = 10

    local x = cam.scale * 4
    x = left and x or lg:getWidth() - x
    local y = lg.getHeight() * 14/15

    local scalex = left and scale or -scale

    for i, weapon in ipairs(weapons) do
        local image = assets.weapons[weapon.image]
        local outline = assets.weaponso[weapon.image]

        y = y - (outline:getHeight() + spacing) * scale


        -- draw outline depending on remaining ammo
        if i == currentI then
            lg.setColor(1.0,1.0,1.0,0.6)
        else
            lg.setColor(0.6,0.6,0.6,0.6)
        end

        local ratio = math.max(math.min(weapon.ammo / weapon.maxAmmo, 1), 0)
        local w,h = outline:getDimensions()
        local gw,gh = lg.getDimensions()

        local ox, oy = (left and x-1*scale or x+1*scale), y-1*scale

        local sx = left and ox            or ox - w*ratio*scale
        local sw = left and w*ratio*scale or gw

        -- outlines are 2 pixels wider and taller than the weapon image
        lg.setScissor(sx, 0, sw, gh)
        lg.draw(outline, ox, oy, 0, scalex, scale)
        lg.setScissor() -- disable scissor


        -- draw weapon
        if i == currentI then
            lg.setColor(1.0,1.0,1.0,1.0)
        else
            lg.setColor(0.6,0.6,0.6,0.6)
        end

        if weapon.animated then
            local quad = assets.weaponsq[weapon.image][1]
            lg.draw(image, quad, x, y, 0, scalex, scale)
        else
            lg.draw(image, x, y, 0, scalex, scale)
        end
    end
end

function drawThrowable(throwable, pos)
    assert(pos == 'left' or pos == 'right')

    lg.setColor(0.8,0.8,0.8,1.0)
    local left = pos == 'left'

    local x = cam.scale * 50

    x = left and x or lg:getWidth() - x

    local y = lg.getHeight() * 13/15

    lg.circle('fill',x,y,16)
    lg.draw(assets[throwable.name],x,y,0,2,2,8,8)

end

function hud.draw()
    lg.setColor(1.0, 1.0, 1.0, 1.0)

    if player1:isAlive() then
        drawHearts(player1.hp, player1.color, 'left')
        drawWeapons(player1.weapons, player1.currentWeapon, 'left')
        drawThrowable(player1.throwables[player1.currentThrowable],'left')
    end

    lg.setColor(1.0, 1.0, 1.0, 1.0)

    if player2 and player2:isAlive() then
        drawHearts(player2.hp, player2.color, 'right')
        drawWeapons(player2.weapons, player2.currentWeapon, 'right')
        drawThrowable(player2.throwables[player2.currentThrowable],'right')
    end
end

return hud
