

-- given input from the keyboard or gamepad: this method is called to change the
-- walking direction
function Player:walk(angle)
    self.moveDirection = angle
    self.moving = true
end

-- when the gamepad axis goes from not in the dead zone to inside the dead zone.
-- or when the keyboard keys are released
function Player:stopWalking()
    self.moving = false
end
