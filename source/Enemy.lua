require 'helperMath'
local PeriodicEvent = require "PeriodicEvent"
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
    -- note: to stagger the updates: MAKE SURE this value is co-prime with the
    -- rate of spawning
	self.normalPickTargetInterval = 0.5 + math.random()*0.5
	self.wonderingPickTargetInterval = 2 + math.random()*1 -- when no target
	self.pickTargetEvent = PeriodicEvent.new(self.normalPickTargetInterval)
end

function Enemy:isAlive()
    return self.hp > 0
end

-- overload this to provide different AI behaviour
function Enemy:pickTarget()
    -- returns {entity, dx, dy, magsq} or nil
    local res = self.scene:getNearest({'player','orb'}, self)
    if res then
        self.target = res.entity
        self.moveDirection = math.atan2(res.dy, res.dx)
        self.pickTargetEvent:setInterval(self.normalPickTargetInterval)
    else
        self.target = nil
        self.moveDirection = math.random()*2*math.pi
        self.pickTargetEvent:setInterval(self.wonderingPickTargetInterval)
    end
end

function Enemy:update(dt)
    if self:isAlive() then
        if self.pickTargetEvent:isReady() then
            self:pickTarget()
        end

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
        self.scene:changeTypeString(self, 'deadEnemy')
		if self.onDeath then self.onDeath() end
		self.anim:play(self.deathAnim)
		self.scene:removePhysicsFrom(self)
    end
end


return Enemy
