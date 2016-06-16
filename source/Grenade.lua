local Grenade = oo.class()
local Explosion = require "Explosion"

function Grenade:init(scene, x, y, angle, throwStrength)
	self.type = "grenade"
	scene:add(self)
    self.throwStrength = throwStrength
    self.fuse = 2 + 1*math.random()

    self.body = lp.newBody(scene.world, x, y, 'dynamic')

    self.body:setLinearDamping(1)
    self.body:setAngularDamping(3)
    self.body:setBullet(true)

    self.shape = lp.newCircleShape(4)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='grenade', data=self})

    self.body:setAngle(angle)
    self.body:applyAngularImpulse(-20 + 40*math.random())
    self.body:applyLinearImpulse(throwStrength*math.cos(angle),
                                 throwStrength*math.sin(angle))

end

function Grenade:explode()
    assets.playSfx(assets.sfx.boom)
    local x,y = self.body:getPosition()
    Explosion.new(self.scene, x, y, 40, 0.5)
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
