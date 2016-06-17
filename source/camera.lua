cam = (require 'external/camera')()
local coordinator = require 'coordinator'

screenShake = 4
local currentCamX = 0
local currentCamY = 0


-- for scaling the window
BASE_WIDTH = 400
BASE_HEIGHT = 240

local lastAlive = nil


local function getLookPos(player, joyMag)
    local x, y = player.body:getPosition()
    local dist = 75*joyMag

    x = x + math.cos(player.aimAngle) * dist
    y = y + math.sin(player.aimAngle) * dist

    return x, y
end

-- return a table of positions to lerp between
local function getLivingPlayersLookPos()
    local ret = {}

    if player1:isAlive() then
        -- if using mouse: assume look magnitude of 1
        local joyMag = (input.lastAim == 'joy') and input.joy1LookMag or 1
        local x, y = getLookPos(player1, joyMag)
        table.insert(ret, {x=x,y=y})
    end

    if player2 and player2:isAlive() then
        local x, y = getLookPos(player2, input.joy2LookMag)
        table.insert(ret, {x=x,y=y})
    end

    return ret
end

local function getLastAlive()
    assert(not player1:isAlive() and (not player2 or not player2:isAlive()))

    local lastAlive
    if not player2 then
        lastAlive = player1
    else
        if player1.timeOfDeath > player2.timeOfDeath then
            lastAlive = player1
        else
            lastAlive = player2
        end
    end
    return lastAlive
end

-- lerp between the living players and apply screen shake
function updateCamera(dt)
    -- if both alive: lerp between
    -- if one player dead or not spawned: focus completely on the other
    -- if all dead or not spawned:
    --    if an orb is present: look at the orb
    --    else: look at the last player to die

    local orb = coordinator.gameData.orb

    local lookPos = getLivingPlayersLookPos()
    local numAlive = #lookPos
    assert(numAlive <= 2)

    -- target x and y to approach
    local tx, ty

    if numAlive == 2 then
        local ratio = 0.5
        tx = lerp(lookPos[1].x, lookPos[2].x, ratio)
        ty = lerp(lookPos[1].y, lookPos[2].y, ratio)
    elseif numAlive == 1 then
        tx = lookPos[1].x
        ty = lookPos[1].y
    elseif numAlive == 0 then
        if orb then
            tx, ty = orb.body:getPosition()
        else
            tx, ty = getLastAlive().body:getPosition()
        end
    end


    local lerpAmount = math.min(dt*5, 1)
    currentCamX = lerp(cam.x, tx, lerpAmount)
    currentCamY = lerp(cam.y, ty, lerpAmount)

    if debugMode then
        -- no camera shake
        cam.x = currentCamX
        cam.y = currentCamY
    else
        cam.x = currentCamX + math.random(-screenShake, screenShake)
        cam.y = currentCamY + math.random(-screenShake, screenShake)
    end

    screenShake = screenShake - dt*screenShake*10
    if screenShake < 0.1 then screenShake = 0 end
end


function love.resize(w, h)
	local ratiox = w / BASE_WIDTH
	local ratioy = h / BASE_HEIGHT
	flux.to(cam, 1, {scale = math.max(ratiox, ratioy)})
end
