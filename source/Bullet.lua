local Bullet = oo.class()

function Bullet:init(x, y, angle)
    self.initx = x + 16*math.cos(angle)
    self.inity = y + 16*math.sin(angle)
    self.angle = angle
    self.speed = 400
end

function Bullet:added()
    self.body = lp.newBody(self.scene.world, self.initx, self.inity, 'dynamic')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(8)
    self.fixture = lp.newFixture(self.body, self.shape)

    self.body:setAngle(self.angle)
    self.body:setLinearVelocity(self.speed*math.cos(self.angle),
                                self.speed*math.sin(self.angle))

end
function Bullet:update(dt) end
function Bullet:draw()
    lg.draw(assets.bullet, self.body:getX(), self.body:getY(), self.body:getAngle())
end


return Bullet
