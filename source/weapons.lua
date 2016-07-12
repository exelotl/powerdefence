local Bullet = require "Bullet"
local Rocket = require "Rocket"
local Flame = require "Flame"
local Laser = require "Laser"
local SniperRound = require "SniperRound"
local Anim = require "Anim"
local MuzzleFlare = require "MuzzleFlare"


local wepAttrs = {
    None = {
        name = "none",
        image = nil,
        -- offset x and y are for drawing the gun itsself
        -- shoot offset is along the normal to the shooting angle (assume line
        --     of fire is horizontal line in image)
        -- spawn offset is distance in x and y from the holder to spawn the ammunition
        offset = {x = nil, y = nil, shoot=nil, spawn=16},
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
        name = "pistol",
        image = "pistol",
        offset = {x=-8, y=1, shoot=0, spawn=18},
        maxAmmo = math.huge,
        ammo = math.huge,
        sfx = "pistol", -- todo: automatically look up SFX based on name of weapon?
        shake = 1,
        flareScale = 0.5,
    },
    MachineGun = {
        name = 'machineGun',
        image = "machineGun",
        offset = {x=5, y=4, shoot=-1, spawn=27},
        singleShot = false,
        rate = 0.1,
        maxAmmo = 255,
        ammo = 255,
        sfx = "machineGun",
        shake = 1,
        flareScale = 1,
    },
    RocketLauncher = {
        name = "rocketLauncher",
        image = "rocketLauncher",
        offset = {x=28, y=16, shoot=5, spawn=32},
        alwaysBehind = true,
        ammoType = Rocket,
        maxAmmo = 16,
        ammo = 16,
        sfx = "rocketLaunch",
        shake = 1,
    },
    StupidRocketLauncher = {
        name = "rocketLauncher",
        image = "stupidRocketLauncher",
        offset = {x=31, y=49, shoot=39, spawn=32},
        alwaysFront = true,
        ammoType = Rocket,
        maxAmmo = 16,
        ammo = 16,
        sfx = "rocketLaunch",
        shake = 1,
    },
    LaserRifle = {
        name = "laserRifle",
        image = "laserRifle",
        offset = {x=3, y=5, shoot=0, spawn=30},
        animated = true,
        restingAnim = {1},
        firingAnim = {1, 2, 3, 4, 5, 6, 7, 8, rate=15},
        singleShot = false,
        rate = 0.1,
        ammoType =  Laser,
        maxAmmo = 100,
        ammo = 100,
        sfx = "laser",
        shake = 1,
    },
    Minigun = {
        name = "minigun",
        image = "minigun",
        offset = {x=3, y=8, shoot=0, spawn=44},
        animated = true,
        restingAnim = {1},
        firingAnim = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, rate=25},
        singleShot = false,
        rate = 0.03,
        maxAmmo = 512,
        ammo = 512,
        sfx = "minigun",
        shake = 2,
        flareScale = 2,
    },
    FlameThrower = {
        name = "flamethrower",
        image = "flameThrower",
        offset = {x=12, y=0, shoot=3, spawn=35},
        singleShot = false,
        rate = 0.05,
        maxAmmo = 512,
        ammo = 512,
        ammoType = Flame,
        sfx = "flamethrower",
        
    },
    SniperRifle = {
        name = "sniperrifle",
        image = "sniperRifle",
        alwaysFront = true,
        offset = {x=10, y=3, shoot=-3, spawn=30},
        singleShot = true,
        rate = 1,
        maxAmmo = 20,
        ammo = 20,
        ammoType = SniperRound,
        sfx = "sniper",
        shake = 10,
        flareScale = 1.5,
    },
    uzi = {
        name = "uzi",
        image = "uzi",
        offset = {x=-3, y=2, shoot=1, spawn=20},
        singleShot = false,
        rate = 0.05,
        maxAmmo = 512,
        ammo = 512,
        ammoType = Bullet,
        sfx = "uzi",
        shake = 0.5,
        flareScale = 0.5,
    },
}

local Weapon = oo.class(wepAttrs.None)

function Weapon:init(holder)
    self.holder = holder
    if self.animated then
        self.anim = Anim.new(self.restingAnim)
    end
end

function Weapon:getAngle()
    local aim = self.holder.aimAngle
    if angleLeftRight(aim) == 'left' then
        return aim - self.holder.gunOffsetAngle
    else
        return aim + self.holder.gunOffsetAngle
    end
end

function Weapon:draw()
    local x, y = self.holder.body:getPosition()
    local angle = self:getAngle()

    local image = assets.weapons[self.image]

    -- flip once the _player_ faces left, not the gun
    local scalex = 1
    if angleLeftRight(self.holder.aimAngle) == 'left' then
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
            local a = self:getAngle()
            local rightAngle = math.pi/2
            -- flip the normal once the _player_ faces left, not the gun
            local norm = angleLeftRight(self.holder.aimAngle) == 'left' and a+rightAngle or a-rightAngle
            x = x + self.offset.spawn*math.cos(a) + self.offset.shoot*math.cos(norm)
            y = y + self.offset.spawn*math.sin(a) + self.offset.shoot*math.sin(norm)
            
            local b = self.ammoType.new(scene, x, y, a)
            self.lastShotTime = globalTimer
            if not debugMode then
                self.ammo = self.ammo - 1
            end
            screenShake = screenShake + self.shake
            
            if self.flareScale then
                MuzzleFlare.new(scene,x,y,a,self.flareScale,0.05)
            end

            if self.sfx and assets.sfx[self.sfx] then
                assets.playSfx(assets.sfx[self.sfx])
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
