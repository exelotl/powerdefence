local Anim = require "Anim"
local weapons = require "weapons"

local Player = oo.class()

Player.COLOR_BLUE   = 1
Player.COLOR_GREEN  = 2
Player.COLOR_PINK   = 3
Player.COLOR_YELLOW = 4

local ANIM_IDLE_R = {1}
local ANIM_IDLE_L = {5}
local ANIM_WALK_R = {1, 2, 3, 4, rate = 15}
local ANIM_WALK_L = {5, 6, 7, 8, rate = 15}

function Player:init(scene, playerNum)
	self.type = "player"
	scene:add(self)
	self.color = playerNum == 1 and Player.COLOR_BLUE or Player.COLOR_PINK
	self.anim = Anim.new()
	self.speed = 150
	self.moveDirection = 0
	self.moving = false
	self.angle = 0
	self.playerNum = playerNum -- 1 or 2
	self.hp = 5
    self.weapons = {weapons.Pistol.new(self), weapons.MachineGun.new(self),
                    weapons.RocketLauncher.new(self), weapons.LaserRifle.new(self),
                    weapons.Minigun.new(self)}
	self.currentWeapon = 1
	
	local x = self.playerNum == 1 and -32 or 32
	local y = 0
	self.body = lp.newBody(scene.world, x, y, "dynamic")
	self.shape = lp.newCircleShape(8)
	self.fixture = lp.newFixture(self.body, self.shape)
	self.fixture:setUserData({dataType='player', data=self})
end

function Player:update(dt)
	self.anim:update(dt)
    if self.moving then
        self.body:setLinearVelocity(self.speed*math.cos(self.moveDirection),
                                    self.speed*math.sin(self.moveDirection))
    else
        self.body:setLinearVelocity(0, 0)
    end

    -- only look at the mouse if the mouse was the last thing to be touched out
    -- of mouse/gamepad. The gamepad updates the aim as soon as the message
    -- comes in rather than here
    if input.lastAim == 'mouse' then
        player1:pointAtMouse()
    end

    if self.weapons[self.currentWeapon] then
        self.weapons[self.currentWeapon]:update(dt)
    end
    
    local x, y = self.body:getPosition()
    local force = 50
    if x > 512 then
        self.body:applyLinearImpulse(-force, 0)
    elseif x < -512 then
        self.body:applyLinearImpulse(force, 0)
    end
    if y > 512 then
        self.body:applyLinearImpulse(0, -force)
    elseif y < -512 then
        self.body:applyLinearImpulse(0, force)
    end
end

function Player:draw()
	local x, y = self.body:getPosition()

    local angle = self.angle
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

	local gun = self.weapons[self.currentWeapon]
	local inFront = true
	if gun then
        if gun.alwaysBehind
        then inFront = false
        else inFront = 0 <= self.angle and self.angle <= math.pi end
    end

	if gun and not inFront then gun:draw() end

	lg.draw(assets.player[self.color], assets.playerq[self.anim.frame], x, y, 0, 1, 1, 8, 8)

	if gun and inFront then gun:draw() end
end

-- given input from the keyboard or gamepad: this method is called to change the
-- walking direction
function Player:move(angle)
    self.moveDirection = angle
    self.moving = true
    --printf('walking in angle: %f', angle)
end


function Player:pointAtMouse()
	local x, y = self.body:getPosition()
    local mx, my = cam:worldCoords(input.mousex, input.mousey)
	local dx = mx - x
	local dy = my - y
	self.angle = math.atan2(dy, dx)
end

-- when the gamepad axis goes from not in the dead zone to inside the dead zone.
-- or when the keyboard keys are released
function Player:stopMoving()
    self.moving = false
    --print('stopped walking')
end

function Player:takeDamage()
    self.hp = self.hp - 1
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

function Player:startShooting()
    local gun = self.weapons[self.currentWeapon]
    if gun then
        gun:startShooting()
    end
end

function Player:stopShooting()
    local gun = self.weapons[self.currentWeapon]
    if gun then gun:stopShooting() end
end

return Player
