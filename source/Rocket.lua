local Rocket = oo.class()

local explosion = require "Explosion"

function Rocket:init(scene, x, y, angle)
    self.type = "rocket"
	scene:add(self)
    self.initx = x + 16*math.cos(angle)
    self.inity = y + 16*math.sin(angle)
    self.angle = angle
    self.speed = 200
end

function Rocket:added()
    self.body = lp.newBody(self.scene.world, self.initx, self.inity, 'dynamic')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(6)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='rocket', data=self})

    self.body:setAngle(self.angle)
    self.body:setLinearVelocity(self.speed*math.cos(self.angle),
                                self.speed*math.sin(self.angle))
end

function Rocket:update(dt)

end

function Rocket:draw()
    lg.draw(assets.rocket, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, 4, 2)
end

function Rocket:explode()
    local x,y = self.body:getPosition()
    explosion.new(scene,x,y,30,1)
end


return Rocket