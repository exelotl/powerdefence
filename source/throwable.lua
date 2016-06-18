local assets = require "assets"
local Grenade = require "Grenade"
local Glowstick = require "Glowstick"


local throAttrs = {
	None = {
		name = "none",
		image = nil,

		animated = false,
		holder = nil,       -- entity holding the weapon, needs body,angle fields

		maxAmmo = math.huge,
		ammo = math.huge,

        throwStrength = 200,

		spawnRadius = 16, -- how far in x and y to spawn away from the holder
	},
    Grenade = {
        name = "grenade",
        image = assets.grenade,

        ammoType = Grenade,
        maxAmmo = 50,
        ammo = 50,
        sfx = "whoosh",

        throwStrength = 10,

		spawnRadius = 16, -- how far in x and y to spawn away from the holder
    },
    Glowstick = {
        name = "glowstick",
        image = assets.glowstick,

        ammoType = Glowstick,
        maxAmmo = 50,
        ammo = 50,
        sfx = "whoosh",

        throwStrength = 10,

		spawnRadius = 16, -- how far in x and y to spawn away from the holder
    },
}

local Throwable = oo.class(throAttrs.None)

function Throwable:init(holder)
    self.holder = holder
	if self.animated then
		self.anim = Anim.new(self.restingAnim)
	end
end

function Throwable:throw()
    if self.ammo > 0 then
        local x, y = self.holder.body:getPosition()
        local a = self.holder.aimAngle
        x = x + self.spawnRadius*math.cos(a)
        y = y + self.spawnRadius*math.sin(a)

        local b = self.ammoType.new(scene, x, y, a, self.throwStrength)
        self.ammo = self.ammo - 1

        if self.sfx and assets.sfx[self.sfx] then
            assets.playSfx(assets.sfx[self.sfx])
        end
    end
end

function Throwable:draw() end

function Throwable:update(dt) end

function Throwable:reload()
    self.ammo = self.maxAmmo
end


local throwable = {}

for name,attrs in pairs(throAttrs) do
	throwable[name] = oo.class(Throwable, attrs)
end

return throwable
