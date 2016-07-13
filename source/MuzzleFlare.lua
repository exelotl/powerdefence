local MF = oo.class()


function MF:init(scene, x, y, angle, scale, duration)
    self.duration = duration
    self.x = x
    self.y = y
    self.type = "muzzleFlare"
    self.scale = scale
    self.angle = angle

	scene:add(self)
end

function MF:update(dt)
    self.duration = self.duration - dt
    if self.duration < 0 then
        self.scene:remove(self)
    end
end

function MF:draw()
    -- offset is independent of scale
    lg.draw(assets.muzzleFlare, self.x, self.y, self.angle, self.scale, self.scale, 0, 3)
end


return MF
