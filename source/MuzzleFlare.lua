local MF = oo.class()


function MF:init(scene, x, y, angle, scale, duration)
    self.duration = duration
    self.initx = x
    self.inity = y
    self.type = "muzzleFlare"
    self.scale = scale
    self.angle = angle
	scene:add(self)
end

function MF:added()
    self.body = lp.newBody(scene.world, self.initx, self.inity, 'static')
end

function MF:update(dt)
    self.duration = self.duration - dt
    if self.duration < 0 then
        self.scene:remove(self)
    end
end

function MF:draw()
    lg.draw(assets.muzzleFlare, self.body:getX(), self.body:getY(), self.angle, self.scale, self.scale, 0, 3 * self.scale)
end


return MF
