local Explosion = oo.class()

function Explosion:init(scene, x, y, radius, duration)
	self.duration = duration
    self.initx = x
    self.inity = y
    self.type = "orb"
    self.radius = radius
	scene:add(self)
	self.hp = 6
end

function Explosion:added()
    self.body = lp.newBody(scene.world, self.initx, self.inity, 'static')
    self.shape = lp.newCircleShape(self.radius)
    self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setSensor(true)
	self.fixture:setUserData({dataType='explosion', data=self})
	assets.playSfx(assets.sfxBoom)
end

function Explosion:update(dt)
    self.duration = self.duration - dt
    if self.duration < 0 then
        self.scene:remove(self)
    end
    
end

function Explosion:draw()
    local x,y = self.body:getPosition()
    lg.circle("fill",x,y,self.radius)
end

function Explosion:takeDamage()
    self.hp = self.hp - 1
end


return Explosion