cam = (require 'external/camera')()


screenShake = 4
local currentCamX = 0
local currentCamY = 0


-- for scaling the window
BASE_WIDTH = 400
BASE_HEIGHT = 240

-- lerp between the living players and apply screen shake
function updateCamera(dt)
    -- if both alive: lerp between
    -- if one player dead or not spawned: focus completely on the other
    -- if all dead or not spawned: look at 0, 0

    -- deal with player 1
    local p1x, p1y = 0, 0
    if player1:isAlive() then
        local dist1 = 75
        p1x, p1y = player1.body:getPosition()
        if input.lastAim == 'joy' then dist1 = dist1*input.joy1LookMag end
        p1x = p1x + math.cos(player1.aimAngle) * dist1
        p1y = p1y + math.sin(player1.aimAngle) * dist1
    end

    -- deal with player2
    local p2x, p2y = 0, 0
    if player2 and player2:isAlive() then
        local dist2 = 75*input.joy2LookMag
        p2x, p2y = player2.body:getPosition()
        p2x = p2x + math.cos(player2.aimAngle) * dist2
        p2y = p2y + math.sin(player2.aimAngle) * dist2

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
        -- no camera shake
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
end


function love.resize(w, h)
	local ratiox = w / BASE_WIDTH
	local ratioy = h / BASE_HEIGHT
	flux.to(cam, 1, {scale = math.max(ratiox, ratioy)})
end
