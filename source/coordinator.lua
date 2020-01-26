local Orb = require "Orb"
local Enemy = require "Enemy"
local EnemyGrunt = require "EnemyGrunt"
local EnemySoldier = require "EnemySoldier"
local loadMap = require "loadMap"
local PeriodicEvent = require "PeriodicEvent"
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
    spawnKillRatio = (spawn interval = spawnKillRatio * kill interval), smaller: more difficult. should be <1

    spawnEvent
    spawnRateUpdateEvent

    d.enemyDeaths = MovingAverageRate, -- used to balance the spawn rate

    spawnPDF = {}, -- enemy type probability density function (should sum to 1)
    startTime = globalTimer value when the game started
    gameOverTime = nil until game over, then set to the time of game over
}

--]]



function coordinator.toggleDayNight()
    assert(d.mode == 'orb') -- only used in orb mode

    if     d.time == 'day'   then d.time = 'night'
    elseif d.time == 'night' then d.time = 'day'  end

    flux.to(coordinator.gameData, 5, {lightingAmount = d.time == 'day' and 0 or 1})

    if d.time == 'day' then
        d.lastSunrise = globalTimer
    elseif d.time == 'night' then
        d.currentNight = d.currentNight + 1
        d.currentWave = 1
        if d.nights[d.currentNight][d.currentWave] then
            d.spawnEvent:setFrequency(d.nights[d.currentNight][d.currentWave].rate)
        end
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

    d.map = loadMap(require("assets/maps/map1"))

	if mode == 'survival' then
        -- set to night
        d.time = 'night'
        d.lightingAmount = 1.0 -- full lighting pass

        d.isDoomed = false

        -- remember: larger interval => smaller rate
        d.slowestSpawnInterval = 0.5
        d.spawnKillRatio = 0.8 -- spawn interval = spawnKillRatio * kill interval
        d.spawnPDF = {
            EnemyGrunt = 0.8,
            EnemySoldier = 0.2,
        }
        d.spawnEvent = PeriodicEvent.new(d.slowestSpawnInterval) -- seconds
        d.spawnRateUpdateEvent = PeriodicEvent.new(3) -- seconds

        -- used to balance the spawn rate
        d.enemyDeaths = MovingAverageRate.new(10) -- seconds, window size

        d.startTime = globalTimer -- used to determine the score

        d.gameOverTime = nil

    elseif mode == 'orb' then
        -- set to day
        d.time = 'day'
        d.lightingAmount = 0.0 -- no lighting pass

        d.lastSunrise = globalTimer
        d.dayLength = 10 -- seconds

        d.orb = Orb.new(scene, 0, 0)

        d.isDoomed = false

        d.currentNight = 0 -- start in day: first sunset advance to first night
        d.currentWave = 1
        d.spawnEvent = PeriodicEvent.new()

        local standardPDF = {
            EnemyGrunt = 0.8,
            EnemySoldier = 0.2,
        }

        -- enemies for this wave only
        d.waveEnemies = {}
        -- [night][wave]
        --TODO: allow for custom logic for a wave, maybe {customLogic = function()...}
        --[[
        d.nights = {
            [1] = {
                {ammo={EnemyGrunt=10, EnemySoldier=0}, rate=1, pdf=standardPDF},
                {ammo={EnemyGrunt=10, EnemySoldier=0}, rate=1, pdf=standardPDF},
            },
            [2] = {
                {ammo={EnemyGrunt=0, EnemySoldier=4}, rate=1, pdf=standardPDF},
                {ammo={EnemyGrunt=0, EnemySoldier=4}, rate=1, pdf=standardPDF},
            },
        }
        --]]
        d.nights = {
            [1] = {
                {ammo={EnemyGrunt=2, EnemySoldier=0}, rate=1, pdf=standardPDF},
                {ammo={EnemyGrunt=2, EnemySoldier=0}, rate=1, pdf=standardPDF},
            },
            [2] = {
                {ammo={EnemyGrunt=0, EnemySoldier=2}, rate=1, pdf=standardPDF},
            },
            [3] = {
                {ammo={EnemyGrunt=20, EnemySoldier=20}, rate=1, pdf=standardPDF},
                {ammo={EnemyGrunt=20, EnemySoldier=20}, rate=1, pdf=standardPDF},
            }
        }

    end
end


-- can be called many times but only initiates game over sequence once
function coordinator.initiateGameOver()
    assert(d.mode == 'orb' or d.mode == 'survival')

    if not d.isDoomed then
        if d.mode == 'orb' then
            d.isDoomed = true
            assets.playSfx(assets.sfx.orbDestroy)

            -- delay showing the game over screen
            flux.to({}, 4, {}):oncomplete(function()
                game.setState('gameOver')
            end)
        elseif d.mode == 'survival' then
            d.isDoomed = true
            -- delay registering clicks as taking back to main menu
            flux.to({}, 1, {}):oncomplete(function()
                input.currentState = input.states.gameOverScreen
            end)
            d.gameOverTime = globalTimer
        end
    end
end

function coordinator.initiateWin()
    assert(d.mode == 'orb' and not d.isDoomed)

    if not d.isDoomed then
        -- delay showing the game over screen
        flux.to({}, 1, {}):oncomplete(function()
            game.setState('win')
        end)
    end

end


local function spawn()
    assert(d.mode == 'survival' or d.mode == 'orb')

    if d.mode == 'survival' then
        local enemyType = enemyTypes[pickFromPDF(d.spawnPDF)]
        assert(enemyType)

        local spawnAngle = math.random()*2*math.pi
        local spawnDistance = 500 + math.random()*100

        local sx, sy = fromPolar(spawnDistance, spawnAngle)

        local e = enemyType.new(d.scene, sx, sy)
        e.onDeath = function() d.enemyDeaths:logEvent() end
    elseif d.mode == 'orb' then
        local wave = d.nights[d.currentNight][d.currentWave]
        if not wave then return end -- eg if game over

        -- choose an enemy type to spawn based on the wave pdf and ammo
        local enemyTypeName

        -- if there are 0 options to choose from: do nothing
        -- if there is 1 option to choose from: ignore the pdf and spawn that enemy
        local options = 0
        for name,ammo in pairs(wave.ammo) do
            if ammo > 0 then
                options = options + 1
                enemyTypeName = name
            end
        end

        if options == 0 then
            return
        elseif options == 1 then
            -- enemyTypeName already set by the iteration over the options
        else
            -- more than 1 option

            -- use the pdf to get the enemy type name
            while not enemyTypeName or
                  wave.ammo[enemyTypeName] <= 0 do
                enemyTypeName = pickFromPDF(wave.pdf)
                assert(enemyTypeName)
                assert(wave.ammo[enemyTypeName])
            end
        end



        local enemyType = enemyTypes[enemyTypeName]


        local spawnAngle = math.random()*2*math.pi
        local spawnDistance = 500 + math.random()*100

        local sx, sy = fromPolar(spawnDistance, spawnAngle)

        local e = enemyType.new(d.scene, sx, sy)
        table.insert(d.waveEnemies, e)

        wave.ammo[enemyTypeName] = wave.ammo[enemyTypeName] - 1
    end
end

local function enemiesRemaining()
    local n = 0

    local wave = d.nights[d.currentNight][d.currentWave]

    if wave then
        -- not over if any enemies left to spawn
        for _,enemyTypeAmmo in pairs(wave.ammo) do
            n = n + enemyTypeAmmo
        end

        for _,e in ipairs(d.waveEnemies) do
            if e.type ~= 'deadEnemy' then
                n = n + 1
            end
        end
    end

    return n
end

local function progressWave()
    assert(d.mode == 'orb' and d.time == 'night')

    local wave = d.nights[d.currentNight][d.currentWave]
    if not wave then return end -- eg if game over

    local waveEnded = true

    -- not over if any enemies left to spawn
    for _,enemyTypeAmmo in pairs(wave.ammo) do
        if enemyTypeAmmo > 0 then
            waveEnded = false
            break
        end
    end

    -- not over if any enemies from the wave are alive
    for _,e in ipairs(d.waveEnemies) do
        if e.type ~= 'deadEnemy' then
            waveEnded = false
            break
        end
    end



    if waveEnded then
        d.currentWave = d.currentWave + 1

        -- check for end of night
        if d.currentWave > #d.nights[d.currentNight] then -- end of night
            -- check for end of game (win)
            if d.currentNight + 1 > #d.nights then
                coordinator.initiateWin()
            else
                -- sunrise
                coordinator.toggleDayNight()
            end
        else
            -- configure next wave
            d.spawnEvent:setFrequency(d.nights[d.currentNight][d.currentWave].rate)
        end


        -- clean up enemies from this wave
        for _,e in ipairs(d.waveEnemies) do
            scene:remove(e)
        end
        d.waveEnemies = {}

        -- re-gen health
        if player1:isAlive() then player1.hp = player1.hp + 1 end
        if player2 and player2:isAlive() then player2.hp = player2.hp + 1 end

        -- reload weapons
        for _, w in ipairs(player1.weapons) do
            w:reload()
        end
        if player2 then
            for _, w in ipairs(player2.weapons) do
                w:reload()
            end
        end
    end
end



function coordinator.update(dt)
    if d.mode == 'survival' then

        -- don't spawn new enemies or update the spawn rate if game over
        if not d.isDoomed then

            -- spawn
            if d.spawnEvent:isReady() then
                spawn()
            end

            -- update spawn rate
            if d.spawnRateUpdateEvent:isReady() then
                local newInterval = math.min(
                    d.enemyDeaths:getAvgInterval() * d.spawnKillRatio,
                    d.slowestSpawnInterval)

                d.spawnEvent:setInterval(newInterval)

                -- interval always shrinks
                if newInterval < d.slowestSpawnInterval then
                    d.slowestSpawnInterval = lerp(newInterval, d.slowestSpawnInterval, 0.5)
                end
            end

        end

        if not player1:isAlive() and (not player2 or not player2:isAlive())then
            coordinator.initiateGameOver()
        end

    elseif d.mode == 'orb' then

        if coordinator.isSunset() then
            coordinator.toggleDayNight()
        end


        if d.time == 'night' then
            if d.spawnEvent:isReady() then
                spawn()
            end

            -- check if wave / night is over
            progressWave()
        end


        --[[
        if mode.current == 'night' and not scene.types.enemy or #scene.types.enemy == 0 then
            for _, e = ipairs(scene.types.deadEnemy) do
                scene:remove(e)
            end
        end
        --]]

        -- game over
        local allDead = not player1:isAlive() and (not player2 or not player2:isAlive())
        if allDead or d.orb.hp <= 0 then
            if not debugMode then
                screenShake = screenShake + 100*dt
                coordinator.initiateGameOver()
            end
        end
    end
end


local function drawForceFieldTop()
    if d.time == 'day' then
        local ratio = math.sin(globalTimer) + 1.0
        lg.setColor(1.0, 1.0, 1.0, ratio)
        lg.draw(assets.fft, -512, -512,0)

        lg.setColor(1.0, 1.0, 1.0, 1.0 - ratio)
        lg.draw(assets.fft2, -512, -512, 0)

        lg.setColor(1.0, 1.0, 1.0, 1.0)
    end
end
local function drawForceFieldBottom()
    if d.time == 'day' then
        local ratio = math.sin(globalTimer) + 1.0
        lg.setColor(1.0, 1.0, 1.0, ratio)
        lg.draw(assets.ffb, -512, -512, 0)

        lg.setColor(1.0, 1.0, 1.0, 1.0 - ratio)
        lg.draw(assets.ffb2, -512, -512, 0)

        lg.setColor(1.0, 1.0, 1.0, 1.0)
    end
end


-- draw things which depend on the current state of the game
function coordinator.draw()
	d.map:draw()

    drawForceFieldTop()
    scene:draw()
    drawForceFieldBottom()
end


function coordinator.drawMessages()
    lg.setColor(0.8, 0.8, 0.8)
    if d.mode == 'survival' then
        local timeSurvived = d.isDoomed and d.gameOverTime - d.startTime or globalTimer - d.startTime
        drawMessage(('Time Survived: %.1f'):format(timeSurvived))
        drawMessage(('spawns/sec: %.1f'):format(1 / d.spawnEvent.interval), 40)

        if d.isDoomed then
            lg.setColor(1.0, 1.0, 1.0)
            drawCenterMessage('Game Over')
        end
    elseif d.mode == 'orb' then
        if d.time == 'day' then
            drawMessage(('time until sunset: %.1f'):format(coordinator.timeUntilSunset()))
        else
            drawMessage(('%d enemies remaining'):format(enemiesRemaining()))
            drawMessage(('night %d/ wave %d'):format(d.currentNight, d.currentWave), 40)
        end
    end

end


return coordinator
