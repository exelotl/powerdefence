local Bullet = oo.class()

function Bullet:init(x, y, angle)
    self.x = x
    self.y = y
    self.angle = angle
    self.speed = 200
end

function Bullet:added()
    self.body = lp.newBody(self.scene.world, self.x, self.y)
    self.shape = lp.newCircleShape(8)
    self.fixture = lp.newFixture(self.body, self.shape)

    self.body:setAngle(self.angle)
    self.body:setLinearVelocity(self.speed*math.cos(self.angle),
                                self.speed*math.sin(self.angle))

end
function Bullet:update(dt) end
function Bullet:draw() end


return Bullet
