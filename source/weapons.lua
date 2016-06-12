

local Gun = oo.class()


function Gun:init()
    self.name = nil
    self.image = nil
    self.offset = {x = nil, y = nil}
end


function Gun:draw(x, y, angle)
    local scalex = 1
    if math.abs(angle) > math.pi / 2 then
        scalex =  -1
        angle = angle + math.pi
	end

	lg.draw(self.image, x, y, angle, scalex, 1, self.offset.x, self.offset.y)
end





local Pistol = oo.class(Gun)
function Pistol:init()
    self.name = 'pistol'
    self.image = assets.weapons.pistol
    self.offset = {x=-8, y=1}
end


return {Pistol=Pistol}
