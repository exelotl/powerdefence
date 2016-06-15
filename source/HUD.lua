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
        local imgo = assets.weaponso[weapon.image]

        y = y - (image:getHeight() + spacing) * scale



        -- draw outline depending on remaining ammo
        if i == currentI then
            lg.setColor(255,255,255,150)
        else
            lg.setColor(150,150,150,150)
        end

        local ratio = math.min(weapon.ammo / weapon.maxAmmo, 1)
        if weapon.animated then
            local quad = assets.weaponsoq[weapon.image][1]
            local qx,qy,qw,qh = quad:getViewport()

            local leftx = left and x              or x - ratio*qw*scale
            local draww = left and ratio*qw*scale or qw*scale+5

            lg.setScissor(leftx, y, draww, qh*scale)
            lg.draw(imgo, quad, x, y, 0, scalex, scale, 1, 1)
            lg.setScissor()
        else
            local w,h = image:getDimensions()

            local leftx = left and x             or x - ratio*w*scale
            local draww = left and ratio*w*scale or imgo:getWidth()*scale+5

            lg.setScissor(leftx, y, draww, h*scale)
            lg.draw(imgo, x, y, 0, scalex, scale, 1, 1)
            lg.setScissor()
        end


        -- draw weapon
        if i == currentI then
            lg.setColor(255,255,255,255)
        else
            lg.setColor(150,150,150,150)
        end

        if weapon.animated then
            local quad = assets.weaponsq[weapon.image][1]
            lg.draw(image, quad, x, y, 0, scalex, scale)
        else
            lg.draw(image, x, y, 0, scalex, scale)
        end
    end
end

function hud.draw()
    lg.setColor(255, 255, 255, 255)

    if player1:isAlive() then
        drawHearts(player1.hp, player1.color, 'left')
        drawWeapons(player1.weapons, player1.currentWeapon, 'left')
    end

    lg.setColor(255, 255, 255, 255)

    if player2 and player2:isAlive() then
        drawHearts(player2.hp, player2.color, 'right')
        drawWeapons(player2.weapons, player2.currentWeapon, 'right')
    end
end

return hud
