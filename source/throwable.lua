local Grenade = require "Grenade"


local throAttrs = {
	None = {
		name = "none",
		image = nil,

		animated = false,
		holder = nil,       -- entity holding the weapon, needs body,angle fields
        
		maxAmmo = math.huge,
		ammo = math.huge,
	},
    Grenade = {
        name = "grenade",
        image = assets.grenade,
        
        ammoType = Grenade,
        maxAmmo = 50,
        ammo = 50,
        sfx = "whoosh",
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
            local rightAngle = math.pi/2
            --local norm = math.abs(a) > rightAngle and a+rightAngle or a-rightAngle
            x = x + 16*math.cos(a)--+ self.offset.shoot*math.cos(norm)
            y = y + 16*math.sin(a)-- + self.offset.shoot*math.sin(norm)
            
            local b = self.ammoType.new(scene, x, y, a)
			self.ammo = self.ammo - 1

			if self.sfx and assets.sfx[self.sfx] then
				assets.playSfx(assets.sfx[self.sfx])
			end

			if self.ammo <= 0 then
				self.ammo = 0
                -- remove the weapon from the holder
                for i = 1,#self.holder.weapons do
                    if self.holder.weapons[i] == self then
                        table.remove(self.holder.throwable, i)
                        break
                    end
                end
			end
        end
end

function Throwable:draw() end

function Throwable:update(dt) end

function Throwable:reload()
    self.ammo = self.maxAmmo
end

-- Generate all the weapon classes based on their attribute definitions
-- All have Weapon as the base class, and properties from the
--  corresponding attribute definition are mixed in.
local throwable = {}

for name,attrs in pairs(throAttrs) do
	throwable[name] = oo.class(Throwable, attrs)
end

return throwable