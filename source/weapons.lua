
local Bullet = require "Bullet"


local Weapon = oo.class()

Weapon.name = nil
Weapon.image = nil
Weapon.offset = {x = nil, y = nil}
Weapon.alwaysBehind = false


function Weapon:draw(x, y, angle)
    local scalex = 1
    if math.abs(angle) > math.pi / 2 then
        scalex =  -1
        angle = angle + math.pi
	end

	lg.draw(self.image, x, y, angle, scalex, 1, self.offset.x, self.offset.y)
end


function Weapon:startShooting(x, y, angle)
    local b = Bullet.new(x, y, angle)
    scene:add(b)
end

function Weapon:stopShooting()

end




local Pistol = oo.class(Weapon)
function Pistol:init()
    self.name = 'pistol'
    self.image = assets.weapons.pistol
    self.offset = {x=-8, y=1}
end

local MachineGun = oo.class(Weapon)
function MachineGun:init()
    self.name = 'machineGun'
    self.image = assets.weapons.machineGun
    self.offset = {x=5, y=4}
end

local RocketLauncher = oo.class(Weapon)
function RocketLauncher:init()
    self.name = 'rocketLauncher'
    self.image = assets.weapons.rocketLauncher
    self.offset = {x=28, y=16}
    self.alwaysBehind = true
end


return {Pistol=Pistol, MachineGun=MachineGun, RocketLauncher=RocketLauncher}
