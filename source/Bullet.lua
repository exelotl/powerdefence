local Bullet = oo.class()

function Bullet:init(scene, x, y, angle)
	self.type = "bullet"
	scene:add(self)
    x = x + 16*math.cos(angle)
    y = y + 16*math.sin(angle)
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
end


function Bullet:update(dt)

end

function Bullet:draw()
    lg.draw(assets.bullet, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, 4, 2)
end


return Bullet
