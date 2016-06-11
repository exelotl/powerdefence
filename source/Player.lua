local Player = oo.class()

Player.COLOR_BLUE   = 1
Player.COLOR_GREEN  = 2
Player.COLOR_PINK   = 3
Player.COLOR_YELLOW = 4

function Player:init(scene)
	self.color = Player.COLOR_BLUE
	self.speed = 70
	self.moveDirection = 0
	self.moving = false
	self.angle = 0
end

function Player:added()
	self.body = lp.newBody(self.scene.world, 0, 0, "dynamic")
	self.shape = lp.newCircleShape(8)
	self.fixture = lp.newFixture(self.body, self.shape)
end

function Player:update(dt)
    if self.moving then
        self.body:setLinearVelocity(self.speed*math.cos(self.moveDirection), self.speed*math.sin(self.moveDirection))
    else
        self.body:setLinearVelocity(0, 0)
    end

    -- only look at the mouse if the mouse was the last thing to be touched out
    -- of mouse/gamepad. The gamepad updates the aim as soon as the message
    -- comes in rather than here
    if input.lastAim == 'mouse' then
        player1:pointAtMouse()
    end
end

function Player:draw()
	local x, y = self.body:getPosition()
	lg.draw(assets.player[self.color], assets.playerq[1], x, y)

    local angle = self.angle
    local scalex = 1
    if math.abs(angle) > math.pi / 2 then
        scalex =  -1
        angle = angle + math.pi
    end
	local offsetx, offsety = -7, 8
	lg.draw(assets.weapons.pistol, x, y, angle, scalex, 1, offsetx, offsety)
end

-- given input from the keyboard or gamepad: this method is called to change the
-- walking direction
function Player:move(angle)
    self.moveDirection = angle
    self.moving = true
    printf('walking in angle: %f', angle)
end


function Player:pointAtMouse()
	local x, y = self.body:getPosition()
    local mx, my = cam:worldCoords(input.mousex, input.mousey)
	local dx = mx - x
	local dy = my - y
	self.angle = math.atan2(dy, dx)
	print(dy)
end

-- when the gamepad axis goes from not in the dead zone to inside the dead zone.
-- or when the keyboard keys are released
function Player:stopMoving()
    self.moving = false
    print('stopped walking')
end

return Player
