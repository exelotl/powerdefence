local Orb = oo.class()

function Orb:init(scene, x, y)
	self.type = "orb"
	scene:add(self)
    self.body = lp.newBody(scene.world, x, y, 'static')
    self.shape = lp.newCircleShape(16)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='orb', data=self})
end

function Orb:update(dt) end
function Orb:draw()
    lg.draw(assets.orb, self.body:getX(), self.body:getY(), 0,1,1,16,16)
end


return Orb
