local Flame = oo.class()

function Flame:init(scene, x, y, angle)
	self.type = "flame"
	scene:add(self)
    x = x + 16*math.cos(angle)
    y = y + 16*math.sin(angle)
    self.angle = angle
    self.speed = 150
	self.duration = 1
    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(4)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='flame', data=self})
    self.fixture:setSensor(true)
    self.body:setAngle(self.angle)
    self.body:setLinearVelocity(self.speed*math.cos(self.angle),
                                self.speed*math.sin(self.angle))
end


function Flame:update(dt)
    self.duration = self.duration - dt
    if self.duration < 0 then
        self.scene:remove(self)
    end
end

function Flame:draw()
    lg.draw(assets.flame, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1, 4, 2)
end


return Flame
