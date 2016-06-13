local Orb = oo.class()

function Orb:init(x, y)
    self.initx = x
    self.inity = y
end

function Orb:added()
    self.body = lp.newBody(self.scene.world, self.initx, self.inity, 'static')
    self.shape = lp.newCircleShape(16)
    self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='orb', data=self})
	self.hp = 6
end
function Orb:update(dt) end

function Orb:draw()
    lg.draw(assets.orb, assets.orbq[clamp(7 - self.hp, 1, 7)],
            self.body:getX(), self.body:getY(), 0,1,1,16,16)
end

function Orb:takeDamage()
    self.hp = self.hp - 1
end


return Orb
