local Explosion = oo.class()

function Explosion:init(scene, x, y, radius, duration)
	self.type = "orb"
    self.radius = radius
	scene:add(self)
    self.body = lp.newBody(scene.world, x, y, 'static')
    self.shape = lp.newCircleShape(radius)
    self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setSensor(true)
	self.fixture:setUserData({dataType='explosion', data=self})
	self.hp = 6
end

function Explosion:update(dt) end

function Explosion:draw()
    local x,y = self.body:getPosition()
    lg.circle("fill",x,y,self.radius)
end

function Explosion:takeDamage()
    self.hp = self.hp - 1
end


return Explosion