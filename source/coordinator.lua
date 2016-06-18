local Orb = require "Orb"
local Enemy = require "Enemy"
local EnemyGrunt = require "EnemyGrunt"
local EnemySoldier = require "EnemySoldier"
require "helperMath"
local game -- cannot require here since it causes a recursive loop


-- whereas 'game.lua' deals with the application state: menu/game/game over
-- the coordinator deals with state within the game world, depending on the
-- current game mode

coordinator = {}

local enemyTypes = {EnemyGrunt=EnemyGrunt, EnemySoldier=EnemySoldier}


-- for use with the current game mode
coordinator.gameData = {}
local d = coordinator.gameData
--[[
note: not all game modes will use all fields

gameData = {
-- used by all modes
    mode = 'survival' | 'orb',
    scene = scene to place the entities into,

    isDoomed = whether the game is lost,

    time = 'day' | 'night',  -- needs to be in sync with lighting.amount
    lightingAmount = 0-255, -- opacity for the lighting pass

-- used only by orb mode
    lastSunrise = globalTimer value last time sunrise happened,
    dayLength = time in seconds between lastSunrise and the next sunset,
    orb = the orb entity,

-- used only by survival mode
    slowestSpawnInterval = 0.5, -- largest interval in seconds between spawning
    currentSpawnInterval = ?, -- the current interval between spawns
    spawnKillRatio = (spawn interval = spawnKillRatio * kill interval), smaller: more difficult. should be <1

    lastSpawnTime = globalTimer value last time an enemy spawned
    lastSpawnRateUpdateTime = the globalTimer value the last time the spawn rate was updated
    d.enemyDeaths = MovingAverageRate, -- used to balance the spawn rate

    spawnPDF = {}, -- enemy type probability density function (should sum to 1)
    startTime = globalTimer value when the game started
}

--]]



function coordinator.toggleDayNight()
    --assert(d.mode == 'orb')

    if     d.time == 'day'   then d.time = 'night'
    elseif d.time == 'night' then d.time = 'day'  end

    flux.to(coordinator.gameData, 5, {lightingAmount = d.time == 'day' and 0 or 255})

    if d.time == 'day' then
        d.lastSunrise = globalTimer
    end
end


function coordinator.timeUntilSunset()
    assert(d.mode == 'orb')
    return d.lastSunrise + d.dayLength - globalTimer
end

function coordinator.isSunset()
    assert(d.mode == 'orb')
    return d.time == 'day' and coordinator.timeUntilSunset() <= 0
end







function coordinator.startGame(scene, mode)
    assert(mode == 'survival' or mode == 'orb')
    game = game or require 'game'

    -- TODO: might want to clean up this global and do something better with it
    enemiesKilled = 0

    coordinator.gameData = {}
    d = coordinator.gameData

    d.scene = scene
    d.mode = mode

    if mode == 'survival' then
        -- set to night
        d.time = 'night'
        d.lightingAmount = 255 -- full lighting pass

        d.isDoomed = false

        -- remember: larger interval => smaller rate
        d.slowestSpawnInterval = 0.5
        d.currentSpawnInterval = d.slowestSpawnInterval
        d.spawnKillRatio = 0.8 -- spawn interval = spawnKillRatio * kill interval
        d.spawnPDF = {
            EnemyGrunt = 0.8,
            EnemySoldier = 0.2,
        }
        d.lastSpawnTime = globalTimer
        d.lastSpawnRateUpdateTime = globalTimer

        -- used to balance the spawn rate
        d.enemyDeaths = MovingAverageRate.new(10) -- seconds, window size

        d.startTime = globalTimer

    elseif mode == 'orb' then
        -- set to day
        d.time = 'day'
        d.lightingAmount = 0 -- no lighting pass

        d.lastSunrise = globalTimer
        d.dayLength = 15 -- seconds

        d.orb = Orb.new(scene, 0, 0)

        d.isDoomed = false
    end
end


-- can be called many times but only initiates game over sequence once
function coordinator.initiateGameOver()
    if not d.isDoomed then
        d.isDoomed = true
        assets.playSfx(assets.sfx.orbDestroy)

        -- delay showing the game over screen
        flux.to({}, 4, {}):oncomplete(function()
            game.setState('gameOver')
        end)
    end
end


function spawn()
    assert(d.mode == 'survival')
    local enemyType = enemyTypes[pickFromPDF(d.spawnPDF)]
    assert(enemyType)

    local spawnAngle = math.random()*2*math.pi
    local spawnDistance = 500 + math.random()*100

    local sx, sy = fromPolar(spawnDistance, spawnAngle)

    local e = enemyType.new(d.scene, sx, sy)
    e.onDeath = function() d.enemyDeaths:logEvent() end
end


function coordinator.update(dt)
    if d.mode == 'survival' then

        if globalTimer > d.lastSpawnTime + d.currentSpawnInterval then
            spawn()
            d.lastSpawnTime = globalTimer
        end

        if globalTimer > d.lastSpawnRateUpdateTime + 3 then
            d.currentSpawnInterval = math.min(d.enemyDeaths:getAvgInterval() * d.spawnKillRatio, d.slowestSpawnInterval)

            -- interval always shrinks
            if d.currentSpawnInterval < d.slowestSpawnInterval then
                d.slowestSpawnInterval = lerp(d.currentSpawnInterval, d.slowestSpawnInterval, 0.5)
            end

            d.lastSpawnRateUpdateTime = globalTimer
        end

    elseif d.mode == 'orb' then

        if coordinator.isSunset() and not debugMode then
            coordinator.toggleDayNight()
            spawn()
        end


        if not d.lastSpawnTime then d.lastSpawnTime = globalTimer end
        if globalTimer > d.lastSpawnTime + 15 then
            spawn()

            if player1:isAlive() then player1.hp = player1.hp + 1 end
            if player2 and player2:isAlive() then player2.hp = player2.hp + 1 end

            for _, w in ipairs(player1.weapons) do
                w:reload()
            end

            if player2 then
                for _, w in ipairs(player2.weapons) do
                    w:reload()
                end
            end
            d.lastSpawnTime = globalTimer
        end


        --[[
        if mode.current == 'night' and not scene.typelist.enemy or #scene.typelist.enemy == 0 then
            for _, e = ipairs(scene.typelist.deadEnemy) do
                scene:remove(e)
            end
        end
        --]]

        -- game over
        if (not player1:isAlive() and (not player2 or not player2:isAlive()))
            or d.orb.hp <= 0 then
            if not debugMode then
                screenShake = screenShake + 100*dt
                coordinator.initiateGameOver()
            end
        end
    end
end



local function drawForceFieldTop()
    if d.time == 'day' then
        local ratio = math.sin(globalTimer)*255 + 255
        lg.setColor(255,255,255,ratio)
        lg.draw(assets.fft,-512,-512,0)

        lg.setColor(255,255,255,255-ratio)
        lg.draw(assets.fft2,-512,-512,0)

        lg.setColor(255,255,255,255)
    end
end
local function drawForceFieldBottom()
    if d.time == 'day' then
        local ratio = math.sin(globalTimer)*255 + 255
        lg.setColor(255,255,255,ratio)
        lg.draw(assets.ffb,-512,-512,0)

        lg.setColor(255,255,255,255-ratio)
        lg.draw(assets.ffb2,-512,-512,0)

        lg.setColor(255,255,255,255)
    end
end


-- draw things which depend on the current state of the game
function coordinator.draw()
    lg.draw(assets.background,-512,-512,0,1,1,0,0,0,0)

    drawForceFieldTop()
    scene:draw()
    drawForceFieldBottom()
end



function coordinator.drawMessages()
    if d.mode == 'survival' then
        drawMessage(('Time Survived: %.1f'):format(globalTimer - d.startTime))
        drawMessage(('spawns/sec: %.1f'):format(1 / d.currentSpawnInterval), 40)
    elseif d.mode == 'orb' then
        if d.time == 'day' then
            drawMessage(('time until sunset: %.1f'):format(coordinator.timeUntilSunset()))
        else
            local numEnemies = d.scene.typelist.enemy and #d.scene.typelist.enemy or 0
            drawMessage(('%d enemies remaining'):format(numEnemies))
        end
    end
end




return coordinator

