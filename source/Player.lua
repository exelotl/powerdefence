require 'helperMath'
local Anim = require "Anim"
local weapons = require "weapons"
local throwable = require "throwable"

local Player = oo.class()

Player.COLOR_BLUE   = 1
Player.COLOR_GREEN  = 2
Player.COLOR_PINK   = 3
Player.COLOR_YELLOW = 4

local ANIM_IDLE_R = {1}
local ANIM_IDLE_L = {5}
local ANIM_WALK_R = {1, 2, 3, 4, rate = 15}
local ANIM_WALK_L = {5, 6, 7, 8, rate = 15}

function Player:init(scene, playerNum, color)
	self.type = "player"
	scene:add(self)
	self.color = color or (playerNum == 1 and Player.COLOR_BLUE or Player.COLOR_PINK)
	self.anim = Anim.new()
	self.moveForce = 300
	self.moveDirection = 0
	self.moving = false
	self.aimAngle = 0
	self.playerNum = playerNum -- 1 or 2
	self.hp = 5
	self.timeOfDeath = nil -- assigned to globalTimer upon death
    self.weapons = {weapons.Pistol.new(self), weapons.MachineGun.new(self),
                    weapons.RocketLauncher.new(self), weapons.LaserRifle.new(self),
                    weapons.Minigun.new(self),weapons.FlameThrower.new(self)}
	self.currentWeapon = 1

    self.throwables = {throwable.Grenade.new(self),throwable.Glowstick.new(self)}
    self.currentThrowable = 1

	self.placeables = {}
    self.currentPlaceable = 1


	local x = self.playerNum == 1 and -32 or 32
	local y = 0
	self.body = lp.newBody(scene.world, x, y, "dynamic")
	self.body:setMass(0.1)
    self.body:setLinearDamping(10)
	self.shape = lp.newCircleShape(8)
	self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='player', data=self})
end

function Player:isAlive()
    return self.hp > 0
end

function Player:update(dt)
    if self:isAlive() then
        self.anim:update(dt)
        if self.moving then
            self.body:applyForce(fromPolar(self.moveForce, self.moveDirection))
        end

        -- only look at the mouse if the mouse was the last thing to be touched out
        -- of mouse/gamepad. The gamepad updates the aim as soon as the message
        -- comes in rather than here
        if input.lastAim == 'mouse' then
            player1:aimAtMouse()
        end

        if self.weapons[self.currentWeapon] then
            self.weapons[self.currentWeapon]:update(dt)
        end

        local x, y = self.body:getPosition()
        -- must overcome walking otherwise can escape map using explosions and stay still
        local force = self.moveForce + 100
        if x > 512 then
            self.body:applyForce(-force, 0)
        elseif x < -512 then
            self.body:applyForce(force, 0)
        end
        if y > 512 then
            self.body:applyForce(0, -force)
        elseif y < -512 then
            self.body:applyForce(0, force)
        end
    end
end

function Player:draw()
	local x, y = self.body:getPosition()
    local gunInFront = true
    local gun = self.weapons[self.currentWeapon]

    if self:isAlive() then
        local angle = self.aimAngle
        local scalex = 1
        if math.abs(angle) > math.pi / 2 then
            scalex =  -1
            angle = angle + math.pi
        end
        if self.moving then
            self.anim:play(scalex == 1 and ANIM_WALK_R or ANIM_WALK_L)
        else
            self.anim:play(scalex == 1 and ANIM_IDLE_R or ANIM_IDLE_L)
        end

        if gun then
            if gun.alwaysBehind
            then gunInFront = false
            else gunInFront = 0 <= self.aimAngle and self.aimAngle <= math.pi end
        end

        if gun and not gunInFront then gun:draw() end
    else
        self.anim:play(ANIM_IDLE_R)
    end

	local rotation = self:isAlive() and 0 or math.pi/2
	lg.draw(assets.player[self.color], assets.playerq[self.anim.frame], x, y, rotation, 1, 1, 8, 8)

    if self:isAlive() and gun and gunInFront then
        gun:draw()
    end
end

-- given input from the keyboard or gamepad: this method is called to change the
-- walking direction
function Player:move(angle)
    self.moveDirection = angle
    self.moving = true
    --printf('walking in angle: %f', angle)
end


function Player:aimAtMouse()
	local x, y = self.body:getPosition()
    local mx, my = cam:worldCoords(input.mousex, input.mousey)
	local dx = mx - x
	local dy = my - y
	self.aimAngle = math.atan2(dy, dx)
end

-- when the gamepad axis goes from not in the dead zone to inside the dead zone.
-- or when the keyboard keys are released
function Player:stopMoving()
    self.moving = false
end

function Player:takeDamage(amount)
    if not debugMode then
        local amount = amount or 1

        self.hp = self.hp - amount
        if not self:isAlive() then
            self.type = 'deadPlayer'
            self.timeOfDeath = globalTimer
            self.scene:removePhysicsFrom(self)
        end
    end
end

function Player:nextWeapon()
    if self.currentWeapon == #self.weapons then
        self.currentWeapon = 1
    else
        self.currentWeapon = self.currentWeapon + 1
    end
end

function Player:prevWeapon()
    if self.currentWeapon == 1 then
        self.currentWeapon = #self.weapons
    else
        self.currentWeapon = self.currentWeapon - 1
    end
end

function Player:nextThrowable()
    if self.currentThrowable == #self.throwables then
        self.currentThrowable = 1
    else
        self.currentThrowable = self.currentThrowable + 1
    end
end

function Player:startShooting()
    if self:isAlive() then
        local gun = self.weapons[self.currentWeapon]
        if gun then
            gun:startShooting()
        end
    end
end

function Player:stopShooting()
    if self:isAlive() then
        local gun = self.weapons[self.currentWeapon]
        if gun then gun:stopShooting() end
    end
end

function Player:throw()
    if self:isAlive() then
        local throw = self.throwables[self.currentThrowable]
        if throw then throw:throw() end
    end
end

return Player
