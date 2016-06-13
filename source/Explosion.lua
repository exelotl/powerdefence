local Explosion = oo.class()
local Anim = require "Anim"

local ANIM_EXPLOSION = {1,2,3,4,5,6,7,8,9,10,11, rate = 15, loop = false}

function Explosion:init(scene, x, y, radius, duration)
	self.anim = Anim.new(ANIM_EXPLOSION)
    self.duration = duration
    self.initx = x
    self.inity = y
    self.type = "explosion"
    self.radius = radius
	scene:add(self)
end

function Explosion:added()
    self.body = lp.newBody(scene.world, self.initx, self.inity, 'static')
    self.shape = lp.newCircleShape(self.radius)
    self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setSensor(true)
	self.fixture:setUserData({dataType='explosion', data=self})
    self.anim:play(ANIM_EXPLOSION)
end

function Explosion:update(dt)
    self.duration = self.duration - dt
    screenShake = screenShake + 3
    if self.duration < 0 then
        self.scene:remove(self)
    end
    self.anim:update(dt)
end

function Explosion:draw()
    local x,y = self.body:getPosition()
    lg.draw(assets.explosion, assets.explosionq[self.anim.frame], x, y,0,1,1,32,32)
end


return Explosion
