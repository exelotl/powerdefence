local SniperRound = oo.class()

local PeriodicEvent = require "PeriodicEvent"

function SniperRound:init(scene, x, y, angle)
    self.type = "sniperRound"
    scene:add(self)
    self.angle = angle
    self.speed = 1000
    self.damage = 4
    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(4)
    self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setUserData({dataType='bullet', data=self})

    self.body:setAngle(self.angle)
    self.body:setLinearVelocity(self.speed*math.cos(self.angle),
                                self.speed*math.sin(self.angle))
    self.body:setMass(100)

    self.checkOutOfBoundsEvent = PeriodicEvent.new(1)
end


function SniperRound:update(dt)
    -- remove bullets that have escaped the map
    if self.checkOutOfBoundsEvent:isReady() then
        local x, y = self.body:getPosition()
        local mapRadius = 2000
        if x^2+y^2 > mapRadius^2 then
            self.scene:remove(self)
        end
    end
end

function SniperRound:draw()
    lg.draw(assets.sniperRound, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, 4, 2)
end


return SniperRound
