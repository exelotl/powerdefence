local Glowstick = oo.class()

function Glowstick:init(scene, x, y, angle, throwStrength)
	self.type = "glowstick"
	scene:add(self)
    self.throwStrength = throwStrength
    self.maxfuse = 40
    self.fuse = 30 + 10*math.random()
    
    mincolorvalue = 75
    self.r = mincolorvalue + (255 - mincolorvalue) * math.random()
    self.g = mincolorvalue + (255 - mincolorvalue) * math.random()
    self.b = mincolorvalue + (255 - mincolorvalue) * math.random()

    self.body = lp.newBody(scene.world, x, y, 'dynamic')

    self.body:setLinearDamping(1)
    self.body:setAngularDamping(2)
    self.body:setBullet(true)

    self.shape = lp.newCircleShape(4)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='glowstick', data=self})

    self.body:setAngle(angle)
    self.body:applyAngularImpulse(-20 + 40*math.random())
    self.body:applyLinearImpulse(throwStrength*math.cos(angle),
                                 throwStrength*math.sin(angle))

end

function Glowstick:update(dt)
    self.fuse = self.fuse - dt
    if self.fuse < 0 then
        self.scene:remove(self)
    end
end

function Glowstick:draw()
    lg.setColor(self.r,self.g,self.b,255)
    lg.draw(assets.glowstick, self.body:getX(), self.body:getY(), self.body:getAngle(), 0.5, 0.5,8,8)
    lg.setColor(255,255,255,255)
end



return Glowstick