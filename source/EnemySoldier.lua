local Enemy = require "Enemy"

local EnemySoldier = oo.class(Enemy)

local ANIM_WALK = {1,2,3,4,5,6, rate = 15}
local ANIM_DIE = {7,8,9,10,11,12,13,14,15,16,17,18,19, rate = 15, loop=false}

function EnemySoldier:init(scene, x, y)
    Enemy.init(self, scene, x, y, lp.newRectangleShape(13, 26), ANIM_WALK, ANIM_DIE)
	self.hp = 3
end


function EnemySoldier:draw()
	local x, y = self.body:getPosition()
	local scalex = math.abs(self.moveDirection) > math.pi/2 and 1 or -1
	lg.draw(assets.soldier, assets.soldierq[self.anim.frame], x, y, 0, scalex, 1, 15, 16)
end



return EnemySoldier
