local Anim = require "Anim"

local Player = oo.class()

Player.COLOR_BLUE   = 1
Player.COLOR_GREEN  = 2
Player.COLOR_PINK   = 3
Player.COLOR_YELLOW = 4

local ANIM_IDLE = {1}
local ANIM_WALK = {1, 2, 3, 4, rate = 15}

function Player:init(scene)
	self.color = Player.COLOR_BLUE
	self.anim = Anim.new(ANIM_WALK)
end

function Player:added()
	self.body = lp.newBody(self.scene.world, 0, 0, "dynamic")
	self.shape = lp.newCircleShape(8)
	self.fixture = lp.newFixture(self.body, self.shape)
end

function Player:update(dt)
	self.anim:update(dt)
end

function Player:draw()
	local x, y = self.body:getPosition()
	lg.draw(assets.player[self.color], assets.playerq[self.anim.frame], 0, x, y, 1, 1, 6, 7)
end

-- given input from the keyboard or gamepad: this method is called to change the
-- walking direction
function Player:walk(angle)
    self.moveDirection = angle
    self.moving = true
	self.anim:play(ANIM_WALK)
end

-- when the gamepad axis goes from not in the dead zone to inside the dead zone.
-- or when the keyboard keys are released
function Player:stopWalking()
    self.moving = false
	self.anim:play(ANIM_IDLE)
end

return Player
