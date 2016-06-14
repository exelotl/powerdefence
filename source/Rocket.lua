local Rocket = oo.class()

local explosion = require "Explosion"

function Rocket:init(scene, x, y, angle)
    self.type = "rocket"
	scene:add(self)
    self.angle = angle
    self.speed = 200

    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(7)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='rocket', data=self})

    self.body:setAngle(self.angle)
    self.body:setLinearVelocity(self.speed*math.cos(self.angle),
                                self.speed*math.sin(self.angle))

    -- explode may be initiated multiple times if the rocket collides with
    -- multiple bodies in the same update
    self.hasExploded = false

    self.lastOutOfBoundsCheck = 0
end

function Rocket:update(dt)

    -- remove rockets that have escaped the map
    if globalTimer > self.lastOutOfBoundsCheck + 1 then
        local x, y = self.body:getPosition()
        local mapRadius = 2000
        if x^2+y^2 > mapRadius^2 then
            self.scene:remove(self)
        end
        self.lastOutOfBoundsCheck = globalTimer
    end

end

function Rocket:draw()
    lg.draw(assets.rocket, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, 7, 4)
end

function Rocket:explode()
    if not self.hasExploded then
        assets.playSfx(assets.sfxBoom)
        local x,y = self.body:getPosition()
        explosion.new(scene,x,y,40,0.5)
        self.hasExploded = true
    end
end


return Rocket
