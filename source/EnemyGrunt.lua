local Anim = require "Anim"

local EnemyGrunt = oo.class()

local ANIM_WALK = {1,2,3,4,5,6, rate = 15}

function EnemyGrunt:init(scene, x, y)
	scene:add(self)
	self.alive = true
	self.body = lp.newBody(scene.world, x, y, "dynamic")
	self.body:setFixedRotation(true)
	--self.shape = lp.newCircleShape(10)
	self.shape = lp.newRectangleShape(13,26)
	self.fixture = lp.newFixture(self.body, self.shape)
	self.anim = Anim.new(ANIM_WALK)
	self.angle = 0
	self.speed = 20
	self.target = nil
end

function EnemyGrunt:update(dt)
	self.target = self.scene:getNearest("player", self.body:getPosition())
	self.target = player1
	if self.target then
		local x1, y1 = self.body:getPosition()
		local x2, y2 = self.target.body:getPosition()
		self.angle = math.atan2(y2-y1, x2-x1)
		self.body:setLinearVelocity(
			math.cos(self.angle) * self.speed,
			math.sin(self.angle) * self.speed)
	end
	self.anim:update(dt)
end

function EnemyGrunt:draw()
	local x, y = self.body:getPosition()
	local dir = math.abs(self.angle) > math.pi/2 and 1 or -1
	lg.draw(assets.grunt, assets.gruntq[self.anim.frame], x, y, 0, dir, 1, 15, 16)
end

return EnemyGrunt