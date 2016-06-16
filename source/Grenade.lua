local Grenade = oo.class()
local explosion = require "Explosion"

function Grenade:init(scene, x, y, angle)
	self.type = "bullet"
	scene:add(self)
    self.angle = angle
    self.speed = 200
    self.fuse = 5

    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    self.body:setBullet(true)
    self.shape = lp.newCircleShape(4)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='grenade', data=self})

    self.body:setAngle(self.angle)
    self.body:setLinearVelocity(self.speed*math.cos(self.angle),
                                self.speed*math.sin(self.angle))
    self.body:setLinearDamping(1,1)

    self.lastOutOfBoundsCheck = 0
end

function Grenade:explode()
    assets.playSfx(assets.sfx.boom)
    local x,y = self.body:getPosition()
    explosion.new(scene,x,y,40,0.5)
    self.scene:remove(self)
end

function Grenade:update(dt)

    self.fuse = self.fuse - dt
    if self.fuse < 0 then
        self:explode()
    end

end

function Grenade:draw()
    lg.draw(assets.grenade, self.body:getX(), self.body:getY(), self.body:getAngle(), 0.5, 0.5,8,8)
end



return Grenade