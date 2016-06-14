local Orb = oo.class()

function Orb:init(scene, x, y)
	self.type = "orb"
	scene:add(self)
    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    self.body:setMass(999)
    self.body:setLinearDamping(100)
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

function Orb:takeDamage(amount)
    local amount = amount or 1
    self.hp = self.hp - amount
end


return Orb
