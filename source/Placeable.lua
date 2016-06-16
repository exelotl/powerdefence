
local Placeable = oo.class()

function Placeable:init(scene)
    self.type = "placeable"
    scene:add(self)
end







local HWall = oo.class(Placeable)

function HWall:init(scene)
    Placeable.init(self, scene)
    self.x = 100
    self.y = 100
    self.width = 128
    self.height = 32
end

function HWall:draw()
    lg.rectangle('fill', self.x, self.y, self.width, self.height)
end


return {Placeable=Placeable, HWall=HWall}
