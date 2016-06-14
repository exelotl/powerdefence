

-- 0-255
ambientDarkness = 255--180

-- whether the sole gamepad should be assigned to player 2
-- true  => player1:keyboard/mouse                player2:gamepad_1
-- false => player1:gamepad_1 and keyboard/mouse  player2:gamepad_2
singleGamepadTwoPlayers = true


axisConfig1 = {
    deadZones = {0, 0, 0, 0, -1, -1},
    deadZoneTolerance = 0.2,
    moveX = 1,
    moveY = 2,
    lookX = 4,
    lookY = 5,
    trigger = 6,
    triggerActivationPoint = 0.46,
}

axisConfig2 = {
    deadZones = {0, 0, 0, 0, -1, -1},
    deadZoneTolerance = 0.2,
    moveX = 1,
    moveY = 2,
    lookX = 4,
    lookY = 5,
    trigger = 6,
    triggerActivationPoint = 0.46,
}
