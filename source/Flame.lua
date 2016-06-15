local Flame = oo.class()

function Flame:init(scene, x, y, angle)
    self.type = "flame"
    scene:add(self)
    self.speed = 150
    self.duration = 1
    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(8)
    self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setUserData({dataType='flame', data=self})
    self.fixture:setSensor(true)
    self.body:setLinearVelocity(self.speed*math.cos(angle),
                                self.speed*math.sin(angle))
end


function Flame:update(dt)
    self.duration = self.duration - dt
    if self.duration < 0 then
        self.scene:remove(self)
    end
end

function Flame:draw()
    lg.draw(assets.flame, self.body:getX(), self.body:getY(), 0, 1, 1, 7, 7)
end


return Flame
