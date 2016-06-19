require 'helperMath'
local Anim = require "Anim"

local Enemy = oo.class()


function Enemy:init(scene, x, y, shape, defaultAnim, deathAnim)
	scene:add(self)
	self.type = "enemy"
	self.body = lp.newBody(scene.world, x, y, "dynamic")
	self.body:setFixedRotation(true)
	--self.shape = lp.newCircleShape(10)
	self.body:setMass(0.1)
    self.body:setLinearDamping(10)
	self.shape = shape
	self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setUserData({dataType='enemy', data=self})
	self.moveForce = 120
	self.moveDirection = 0
	self.target = nil
	self.hp = 1
	self.deathAnim = deathAnim
	self.anim = Anim.new(defaultAnim)
	self.depthOffset = 8
	self.onDeath = nil -- a callback function (optional)

	-- updating the target is expensive
	self.targetUpdateRate = 0.5
	self.lastTargetUpdateTime = 0
end

function Enemy:isAlive()
    return self.hp > 0
end

function Enemy:update(dt)
    if self:isAlive()
        and globalTimer > self.lastTargetUpdateTime + self.targetUpdateRate then
        -- update target
        self.target = self.scene:getNearest("player", self)
        if self.target then
            local x1, y1 = self.body:getPosition()
            local x2, y2 = self.target.body:getPosition()
            self.moveDirection = angleTo(x1, y1, x2, y2)
        end
        self.lastTargetUpdateTime = globalTimer
    end

    if self:isAlive() then
        self.body:applyForce(fromPolar(self.moveForce, self.moveDirection))
    end
	self.anim:update(dt)
end


function Enemy:draw()

end

function Enemy:takeDamage(amount)
    local amount = amount or 1
    self.hp = self.hp - amount
    if self.hp <= 0 then
		self.type = 'deadEnemy'
		if self.onDeath then self.onDeath() end
		self.anim:play(self.deathAnim)
		self.scene:removePhysicsFrom(self)
    end
end


return Enemy
