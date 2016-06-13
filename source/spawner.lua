local spawner = oo.class()
local EnemyGrunt = require "EnemyGrunt"

function spawner:init(x, y, delay)
    self.x = x
    self.y = y
    self.delay = delay
    self.lastSpawn = 0
end

function spawner:added() end
function spawner:update(dt)
  if globalTimer - self.lastSpawn > self.delay then
    self.lastSpawn = globalTimer
    EnemyGrunt.new(scene,self.x,self.y)
    print("spawn")
  end
end
function spawner:draw() end

return spawner