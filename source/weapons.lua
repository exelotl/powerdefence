
local Bullet = require "Bullet"
local Rocket = require "Rocket"
local Flame = require "Flame"
local Anim = require "Anim"


local Weapon = oo.class()

Weapon.name = nil
Weapon.image = nil
-- shoot offset is along the normal to the shooting angle
Weapon.offset = {x = nil, y = nil, shoot=nil}
Weapon.alwaysBehind = false
Weapon.animated = false
Weapon.singleShot = true
Weapon.rate = 0 -- delay between firing another bullet
Weapon.holder = nil -- entity holding the weapon, needs body,angle fields
Weapon.ammoType = Bullet
Weapon.maxAmmo = math.huge
Weapon.ammo = math.huge
Weapon.shake = 0

function Weapon:init(holder)
    self.holder = holder
end


function Weapon:draw()
	local x, y = self.holder.body:getPosition()
    local angle = self.holder.angle


    local scalex = 1
    if math.abs(angle) > math.pi / 2 then
        scalex =  -1
        angle = angle + math.pi
	end

	if self.animated then
        lg.draw(self.image, assets.weaponsq[self.image][self.anim.frame], x, y, angle, scalex, 1, self.offset.x, self.offset.y)
	else
        lg.draw(self.image, x, y, angle, scalex, 1, self.offset.x, self.offset.y)
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
            local a = self.holder.angle
            local rightAngle = math.pi/2
            local norm = math.abs(a) > rightAngle and a+rightAngle or a-rightAngle
            x = x + self.offset.shoot*math.cos(norm)
            y = y + self.offset.shoot*math.sin(norm)

            local b = self.ammoType.new(scene, x, y, a)
            self.lastShotTime = globalTimer
			self.ammo = self.ammo - 1
			screenShake = screenShake + self.shake

			if self.sfx then
				assets.playSfx(self.sfx)
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


local Pistol = oo.class(Weapon)
Pistol.shake = 1
function Pistol:init(holder)
    Weapon.init(self, holder)
    self.name = 'pistol'
    self.image = assets.weapons.pistol
    self.offset = {x=-8, y=1, shoot=0}
	self.maxAmmo = math.huge
	self.ammo = math.huge
	self.sfx = assets.sfxPistol
end

local MachineGun = oo.class(Weapon)
MachineGun.shake = 1
function MachineGun:init(holder)
    Weapon.init(self, holder)
    self.name = 'machineGun'
    self.image = assets.weapons.machineGun
    self.offset = {x=5, y=4, shoot=-1}
    self.singleShot = false
    self.rate = 0.1
	self.maxAmmo = 255
	self.ammo = 255
	self.sfx = assets.sfxMachineGun
end

local RocketLauncher = oo.class(Weapon)
function RocketLauncher:init(holder)
    Weapon.init(self, holder)
    self.name = 'rocketLauncher'
    self.image = assets.weapons.rocketLauncher
    self.offset = {x=28, y=16, shoot=5}
    self.alwaysBehind = true
    self.ammoType = Rocket
	self.maxAmmo = 16
	self.ammo = 16
	self.sfx = assets.sfxRocketLaunch
end


local LaserRifle = oo.class(Weapon)
LaserRifle.shake = 1
function LaserRifle:init(holder)
    Weapon.init(self, holder)
    self.name = 'laserRifle'
    self.image = assets.weapons.laserRifle
    self.offset = {x=3, y=5, shoot=0}
    self.animated = true
    self.anim = Anim.new({1, 2, 3, 4, 5, 6, 7, 8, rate=15})
    self.singleShot = false
    self.rate = 0.1
	self.maxAmmo = 32
	self.ammo = 32
	self.sfx = assets.sfxLaser
end


local Minigun = oo.class(Weapon)
Minigun.shake = 2
function Minigun:init(holder)
    Weapon.init(self, holder)
    self.name = 'minigun'
    self.image = assets.weapons.minigun
    self.offset = {x=3, y=8, shoot=0}
    self.animated = true
    self.restingAnim = {1}
    self.firingAnim = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, rate=25}
    self.anim = Anim.new(restingAnim)
    self.singleShot = false
    self.rate = 0.03
	self.maxAmmo = 512
	self.ammo = 512
	self.sfx = assets.sfxMinigun
end

local FlameThrower = oo.class(Weapon)
function FlameThrower:init(holder)
    Weapon.init(self, holder)
    self.name = 'flamethrower'
    self.image = assets.weapons.flameThrower
    self.offset = {x=10, y=0, shoot=-5}
    self.singleShot = false
    self.rate = 0.05
	self.maxAmmo = 512
	self.ammo = 512
    self.ammoType = Flame
	self.sfx = assets.sfxFlame
end

return {Pistol=Pistol, MachineGun=MachineGun, RocketLauncher=RocketLauncher,
        LaserRifle=LaserRifle, Minigun=Minigun, FlameThrower=FlameThrower}
