
local Bullet = require "Bullet"
local Rocket = require "Rocket"
local Flame = require "Flame"
local Anim = require "Anim"


local wepAttrs = {
	None = {
		name = "none",
		image = nil,
		-- offset x and y are for drawing the gun itsself
		-- shoot offset is along the normal to the shooting angle
		offset = {x = nil, y = nil, shoot=nil},
		alwaysBehind = false,
		animated = false,
		singleShot = true,
		rate = 0,           -- delay between firing another bullet
		holder = nil,       -- entity holding the weapon, needs body,angle fields
		ammoType = Bullet,
		maxAmmo = math.huge,
		ammo = math.huge,
		shake = 0
	},
	Pistol = {
		shake = 1,
		name = "pistol",
		image = "pistol",
		offset = {x=-8, y=1, shoot=0},
		maxAmmo = math.huge,
		ammo = math.huge,
		sfx = "pistol", -- todo: automatically look up SFX based on name of weapon?
	},
	MachineGun = {
		shake = 1,
		name = 'machineGun',
		image = "machineGun",
		offset = {x=5, y=4, shoot=-1},
		singleShot = false,
		rate = 0.1,
		maxAmmo = 255,
		ammo = 255,
		sfx = "machineGun"
	},
	RocketLauncher = {
		name = "rocketLauncher",
		image = "rocketLauncher",
		offset = {x=28, y=16, shoot=5},
		alwaysBehind = true,
		ammoType = Rocket,
		maxAmmo = 16,
		ammo = 16,
		sfx = "rocketLaunch",
	},
	LaserRifle = {
		shake = 1,
		name = "laserRifle",
		image = "laserRifle",
		offset = {x=3, y=5, shoot=0},
		animated = true,
		restingAnim = {1},
		firingAnim = {1, 2, 3, 4, 5, 6, 7, 8, rate=15},
		singleShot = false,
		rate = 0.1,
		maxAmmo = 32,
		ammo = 32,
		sfx = "laser",
	},
	Minigun = {
		shake = 2,
		name = "minigun",
		image = "minigun",
		offset = {x=3, y=8, shoot=0},
		animated = true,
		restingAnim = {1},
		firingAnim = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, rate=25},
		singleShot = false,
		rate = 0.03,
		maxAmmo = 512,
		ammo = 512,
		sfx = "minigun",
	},
	FlameThrower = {
		name = "flamethrower",
		image = "flameThrower",
		offset = {x=12, y=0, shoot=3},
		singleShot = false,
		rate = 0.05,
		maxAmmo = 512,
		ammo = 512,
		ammoType = Flame,
		sfx = "flamethrower",
	}
}

local Weapon = oo.class(wepAttrs.None)

function Weapon:init(holder)
    self.holder = holder
	if self.animated then
		self.anim = Anim.new(self.restingAnim)
	end
end

function Weapon:draw()
	local x, y = self.holder.body:getPosition()
    local angle = self.holder.aimAngle
	local image = assets.weapons[self.image]

    local scalex = 1
    if math.abs(angle) > math.pi / 2 then
        scalex =  -1
        angle = angle + math.pi
	end

	if self.animated then
		local quads = assets.weaponsq[self.image]
        lg.draw(image, quads[self.anim.frame], x, y, angle, scalex, 1, self.offset.x, self.offset.y)
	else
        lg.draw(image, x, y, angle, scalex, 1, self.offset.x, self.offset.y)
    end
end

function Weapon:update(dt)
	if self.animated then
        self.anim:update(dt)
    end

	if self.isShooting then
        local fire = false
        if self.singleShot then
            fire = not self.lastShotTime
        else
            fire = not self.lastShotTime or globalTimer >= self.lastShotTime + self.rate
        end

        if fire and self.ammo > 0 then
            local x, y = self.holder.body:getPosition()
            local a = self.holder.aimAngle
            local rightAngle = math.pi/2
            local norm = math.abs(a) > rightAngle and a+rightAngle or a-rightAngle
            x = x + 16*math.cos(a) + self.offset.shoot*math.cos(norm)
            y = y + 16*math.sin(a) + self.offset.shoot*math.sin(norm)

            local b = self.ammoType.new(scene, x, y, a)
            self.lastShotTime = globalTimer
			self.ammo = self.ammo - 1
			screenShake = screenShake + self.shake

			if self.sfx and assets.sfx[self.sfx] then
				assets.playSfx(assets.sfx[self.sfx])
			end

			if self.ammo <= 0 then
				self.ammo = 0
                -- remove the weapon from the holder
                for i = 1,#self.holder.weapons do
                    if self.holder.weapons[i] == self then
                        table.remove(self.holder.weapons, i)
                        break
                    end
                end
			end
        end
    end
end


function Weapon:startShooting()
    self.isShooting = true
    self.lastShotTime = nil
    if self.firingAnim then self.anim:play(self.firingAnim) end
end

function Weapon:stopShooting()
    self.isShooting = false
    self.lastShotTime = nil
    if self.restingAnim then self.anim:play(self.restingAnim) end
end

function Weapon:reload()
    self.ammo = self.maxAmmo
end

-- Generate all the weapon classes based on their attribute definitions
-- All have Weapon as the base class, and properties from the
--  corresponding attribute definition are mixed in.
local weapons = {}

for name,attrs in pairs(wepAttrs) do
	weapons[name] = oo.class(Weapon, attrs)
end

return weapons
