local wave = oo.class()
local EnemyGrunt = require "EnemyGrunt"
local EnemySoldier = require "EnemySoldier"

function wave:init(scene, delay, ammo, distance, EnemyType)
	self.type = "wave"
	scene:add(self)
    self.x = 0
    self.y = 0
    self.delay = delay
    self.lastSpawn = 0
    self.ammo = ammo
    self.distance = distance
    self.EnemyType = EnemyType
end

function wave:update(dt)
  if globalTimer - self.lastSpawn > self.delay and self.ammo > 0 then
    self.lastSpawn = globalTimer
    local rand = math.random() * 2 * math.pi
    local x = self.x + math.cos(rand) * self.distance
    local y = self.x - math.sin(rand) * self.distance
    self.EnemyType.new(self.scene, x, y)
    self.ammo = self.ammo - 1
  end
end

function wave:draw() end

return wave