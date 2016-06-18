

-- 0-255
ambientDarkness = 240

-- whether the sole gamepad should be assigned to player 2
-- true  => player1:keyboard/mouse                player2:gamepad_1
-- false => player1:gamepad_1 and keyboard/mouse  player2:gamepad_2
singleGamepadTwoPlayers = false




-- hard coded profiles


benAxisConfig1 = {
    deadZones = {0, 0, 0, 0, -1, -1},
    deadZoneTolerance = 0.2,
    moveX = 1,
    moveY = 2,
    lookX = 4,
    lookY = 5,
    trigger = 6,
    triggerActivationPoint = 0.46,
}

benAxisConfig2 = {
    deadZones = {0, 0, 0, 0, -1, -1},
    deadZoneTolerance = 0.2,
    moveX = 1,
    moveY = 2,
    lookX = 4,
    lookY = 5,
    trigger = 6,
    triggerActivationPoint = 0.46,
}






defaultAxisConfig1 = {
    deadZones = {0, 0, 0, 0, -1, -1},
    deadZoneTolerance = 0.2,
    moveX = 1,
    moveY = 2,
    lookX = 3,
    lookY = 4,
    trigger = 5,
    triggerActivationPoint = 0.46,
}

defaultAxisConfig2 = {
    deadZones = {0, 0, 0, 0, -1, -1},
    deadZoneTolerance = 0.2,
    moveX = 1,
    moveY = 2,
    lookX = 3,
    lookY = 4,
    trigger = 5,
    triggerActivationPoint = 0.46,
}


axisConfig1 = defaultAxisConfig1
axisConfig2 = defaultAxisConfig2

