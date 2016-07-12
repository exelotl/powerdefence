local Enemy = require "Enemy"

local EnemySoldier = oo.class(Enemy)

local ANIM_WALK = {1,2,3,4,5,6, rate = 15}
local ANIM_DIE = {7,8,9,10,11,12,13,14,15,16,17,18,19, rate = 15, loop=false}
local ANIM_FIRE = {20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52, rate = 15, loop = false}

function EnemySoldier:init(scene, x, y)
    Enemy.init(self, scene, x, y, lp.newRectangleShape(13, 26), ANIM_WALK, ANIM_DIE)
    self.hp = 3
end


function EnemySoldier:draw()
    local x, y = self.body:getPosition()
    local scalex = angleLeftRight(self.moveDirection) == 'left' and 1 or -1
    lg.draw(assets.soldier, assets.soldierq[self.anim.frame], x, y, 0, scalex, 1, 15, 16)
end



function EnemySoldier:burn()
    self.hp = self.hp - 1
    if self.hp <= 0 then
        self.scene:changeTypeString(self, 'deadEnemy')
		if self.onDeath then self.onDeath() end
        self.anim:play(ANIM_FIRE)
        self.scene:removePhysicsFrom(self)
    end
end

return EnemySoldier
