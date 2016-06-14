local Bullet = oo.class()

function Bullet:init(scene, x, y, angle)
	self.type = "bullet"
	scene:add(self)
    self.angle = angle
    self.speed = 800

    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(4)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='bullet', data=self})

    self.body:setAngle(self.angle)
    self.body:setLinearVelocity(self.speed*math.cos(self.angle),
                                self.speed*math.sin(self.angle))

    self.lastOutOfBoundsCheck = 0
end


function Bullet:update(dt)

    -- remove bullets that have escaped the map
    if globalTimer > self.lastOutOfBoundsCheck + 1 then
        local x, y = self.body:getPosition()
        local mapRadius = 2000
        if x^2+y^2 > mapRadius^2 then
            self.scene:remove(self)
        end
        self.lastOutOfBoundsCheck = globalTimer
    end

end

function Bullet:draw()
    lg.draw(assets.bullet, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, 4, 2)
end


return Bullet
