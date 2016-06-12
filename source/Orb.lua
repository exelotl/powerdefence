local Orb = oo.class()

function Orb:init(x, y)
    self.initx = x
    self.inity = y
    self.angle = 0
end

function Orb:added()
    self.body = lp.newBody(self.scene.world, self.initx, self.inity, 'static')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(16)
    self.fixture = lp.newFixture(self.body, self.shape)

    self.body:setAngle(self.angle)

end
function Orb:update(dt) end
function Orb:draw()
    lg.draw(assets.orb, self.body:getX(), self.body:getY(), self.body:getAngle(),1,1,16,16)
end


return Orb