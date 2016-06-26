local HealthPickup = oo.class()

function HealthPickup:init(scene, x, y)
    self.type = "healthPickup"
    scene:add(self)
    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    self.shape = lp.newRectangleShape(16, 16)
    self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setUserData({dataType='healthPickup', data=self})
    self.fixture:setSensor(true)
end

function HealthPickup:update(dt) end

function HealthPickup:draw()
    lg.draw(assets.healthPack, self.body:getX(), self.body:getY(), 0,0.5,0.5,16,16)
end

return HealthPickup
