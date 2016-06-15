local Enemy = require "Enemy"

local EnemyGrunt = oo.class(Enemy)

local ANIM_WALK = {1,2,3,4,5,6, rate = 15}
local ANIM_DIE = {7,8,9,10,11,12,13,14,15,16, rate = 15, loop=false}
local ANIM_FIRE = {17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33, rate = 15, loop=false}

function EnemyGrunt:init(scene, x, y)
    Enemy.init(self, scene, x, y, lp.newRectangleShape(13, 26), ANIM_WALK, ANIM_DIE)
	self.hp = 2
end

function EnemyGrunt:draw()
	local x, y = self.body:getPosition()
	local scalex = math.abs(self.moveDirection) > math.pi/2 and 1 or -1
	lg.draw(assets.grunt, assets.gruntq[self.anim.frame], x, y, 0, scalex, 1, 15, 16)
end

function EnemyGrunt:burn()
    self.hp = self.hp - 1
    if self.hp <= 0 then
		self.type = 'deadEnemy'
		self.anim:play(ANIM_FIRE)
		self.scene:removePhysicsFrom(self)
    end
end

return EnemyGrunt
