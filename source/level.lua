

local Level  = oo.class()

function Level:init()
    self.waves = {}
    self.currentWave = 1
end

function Level:enemiesLeft()
    enemiesLeft = 0
    for i,wave in ipairs(self.waves) do
        enemiesLeft = enemiesLeft + wave.ammo
    end
    return enemiesLeft
end

function Level:update(dt)
    if not waves[currentWave].active then
        waves[currentWave].active = true
    end
    if waves[currentWave].ammo == 0 then
        currentWave = currentWave + 1
    end
    
end


function Level:addWave(wave)
    table.insert(self.waves, #(self.waves) + 1, wave)
end


return Level
