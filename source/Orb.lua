local Orb = oo.class()

function Orb:init(x, y)
    self.initx = x
    self.inity = y
end

function Orb:added()
    self.body = lp.newBody(self.scene.world, self.initx, self.inity, 'static')
    self.shape = lp.newCircleShape(16)
    self.fixture = lp.newFixture(self.body, self.shape)

end
function Orb:update(dt) end
function Orb:draw()
    lg.draw(assets.orb, self.body:getX(), self.body:getY(), 0,1,1,16,16)
end


return Orb
