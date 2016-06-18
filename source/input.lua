--[[ input system

Guideline:
- global key bindings (eg quit) can be placed directly into the appropriate love
function. Bind actions to input events for the game state dependent actions (eg
place tower)

--]]

require 'external/utils'
require 'gameConfig'
local lighting = require "lighting"
local Player = require "Player"
local game = require "game"
local coordinator = require "coordinator"

local input = {}

input.states = {}

-- ordering depends on the order that a button is pressed on them
input.joy1 = nil
input.joy2 = nil

-- cache mouse position
input.mousex = 0
input.mousey = 0

-- the last device used to aim player 1
-- 'mouse' | 'joy'
input.lastAim = 'mouse'

-- record the last value of the firing trigger axis to determine whether this
-- update the value crosses the trigger point
input.lastjoy1Trigger = axisConfig1.deadZones[axisConfig1.trigger]
input.lastjoy2Trigger = axisConfig2.deadZones[axisConfig2.trigger]

-- magnitude of the look axes (roughly 0 to 1)
input.joy1LookMag = 0
input.joy2LookMag = 0


-- record whether the axes used for walking are in the dead zone
input.joy1dead = true
input.joy2dead = true

input.states.menu = {
    playerControl = false,
    actions = {},
    kbdPress = {},
    kbdRelease = {},
    mousePress = {},
    mouseRelease = {},
    mouseMove = function(x, y, dx, dy) end,
    wheelMove = function(x, y) end,
    joy1Press = {},
    joy1Release = {},

    joy2Press = {},
    joy2Release = {},
}

input.states.gameOverScreen = {
    playerControl = false,
    actions = {
        reset = function()
            game.state = 'menu'
            game.load()
        end
    },
    kbdPress = {},
    kbdRelease = {},
    mousePress = {
        [1] = 'reset'
    },
    mouseRelease = {},
    mouseMove = function(x, y, dx, dy) end,
    wheelMove = function(x, y) end,
    joy1Press = {},
    joy1Release = {},

    joy2Press = {},
    joy2Release = {},
}

input.states.playing = {
    -- whether input should move the characters in this state
    playerControl = true,

    actions = {
        player1StartShooting = function()
            player1:startShooting()
        end,
        player1StopShooting = function()
            player1:stopShooting()
        end,

        player1NextWeapon = function()
            player1:nextWeapon()
        end,
        player1PrevWeapon = function()
            player1:prevWeapon()
        end,

        player1Grenade = function()
            player1:throw()
        end,
        player2Grenade = function()
            player2:throw()
        end,
        
        player1NextThrowable = function()
            player1:nextThrowable()
        end,
        player2NextThrowable = function()
            if player2 then player2:nextThrowable() end
        end,

        player2NextWeapon = function()
            if player2 and player2:isAlive() then player2:nextWeapon() end
        end,
        player2PrevWeapon = function()
            if player2 and player2:isAlive() then player2:prevWeapon() end
        end,


        togglePause = function()
            paused = not paused
        end,
    },


    kbdPress = {
        p = 'togglePause',
        q = 'player1NextThrowable',
    },
    kbdRelease = {},


    mousePress = {
        [1] = 'player1StartShooting',
        [2] = 'player1Grenade'
    },
    mouseRelease = {
        [1] = 'player1StopShooting',
    },

    mouseMove = function(x, y, dx, dy) end,
    wheelMove = function(x, y)
        if y >= 0 then
            player1:nextWeapon()
        else
            player1:prevWeapon()
        end
    end,

    joy1Press = {
        y = 'player1NextWeapon',
        x = 'player1PrevWeapon',
        rightshoulder = 'player1Grenade',
        leftshoulder = 'player1NextThrowable',
    },
    joy1Release = {},

    joy2Press = {
        y = 'player2NextWeapon',
        x = 'player2PrevWeapon',
        rightshoulder = 'player2Grenade',
        leftshoulder = 'player2NextThrowable',
    },
    joy2Release = {},

}

input.states.testing = {
    -- whether input should move the characters in this state
    playerControl = true,

    actions = {
        -- to test two different functions
        printApress = function() print('A press') end,
        printArelease = function() print('A release') end,
        printBpress = function() print('B press') end,
        printBrelease = function() print('B release') end,
        printCpress = function() print('C press') end,
        printCrelease = function() print('C release') end,
		toggleFullscreen = function()
			lw.setFullscreen(not lw.getFullscreen())
		end
    },



    kbdPress = {
        a = 'printApress',
        b = 'printBpress',
		f = 'toggleFullscreen'
    },
    kbdRelease = {
        a = 'printArelease',
        b = 'printBrelease'
    },


    mousePress = {
        [1] = 'printApress',
        [2] = 'printBpress'
    },
    mouseRelease = {
        [1] = 'printArelease',
        [2] = 'printBrelease'
    },

    mouseMove = function(x, y, dx, dy)
        printf('mouse move(%d, %d, %d, %d)', x, y, dx, dy)
    end,
    wheelMove = function(x, y)
        printf('wheel move(%d, %d)', x, y)
    end,

    joy1Press = {
        a = 'printApress',
        b = 'printBpress'
    },
    joy1Release = {
        a = 'printArelease',
        b = 'printBrelease'
    },

    joy2Press = {
        a = 'printApress',
        b = 'printCpress'
    },
    joy2Release = {
        a = 'printArelease',
        b = 'printCrelease'
    },
}


input.currentState = input.states.menu







-- given an action string: lookup and run the function registered in
-- currentState.actions
local function doAction(a)
    if not a then return end
    local action = input.currentState.actions[a]
    if action then return action() end
end

-- removes binding of physical gamepad to player 1 or 2. next to press becomes
-- player 1, second to press becomes player 2
function input.resetJoysticks()
    input.joy1 = nil
    input.joy2 = nil
end

-- given an array of axes, get an array of which axes are inside dead zones
function isDead(axes, config)
    local dead = {}
    for i = 1, #axes do
        dead[i] = math.abs(axes[i]-config.deadZones[i]) <= config.deadZoneTolerance
    end
    return dead
end

-- there is no love.blah function for handling joystick axis change, so instead
-- calling this function from the update function
function input.checkJoystickAxes()
    -- short circuit if player control isn't currently enabled (eg for the menu)
    if not input.currentState.playerControl then return end

    if input.joy1 then
        local axes = {input.joy1:getAxes()}
        local dead = isDead(axes, axisConfig1)

        -- aiming
        if not dead[axisConfig1.lookX] or not dead[axisConfig1.lookY] then
            local lookx, looky = axes[axisConfig1.lookY], axes[axisConfig1.lookX]
            player1.aimAngle = math.atan2(lookx, looky)
            input.joy1LookMag = lookx^2+looky^2
            input.lastAim = 'joy'
        end

        -- movement
        if not dead[axisConfig1.moveX] or not dead[axisConfig1.moveY] then
            player1:move(math.atan2(axes[axisConfig1.moveY], axes[axisConfig1.moveX]))
            input.joy1dead = false
        else
            -- only send one stop walking signal. This is so it does not
            -- interfere with the keyboard input
            if not input.joy1dead then
                player1:stopMoving()
                input.joy1dead = true
            end
        end

        -- trigger
        local wasPressed = input.lastjoy1Trigger > axisConfig1.triggerActivationPoint
        local isPressed = axes[axisConfig1.trigger] > axisConfig1.triggerActivationPoint
        if not wasPressed and isPressed then
            player1:startShooting()
        elseif wasPressed and not isPressed then
            player1:stopShooting()
        end
        input.lastjoy1Trigger = axes[axisConfig1.trigger]

    end

    if input.joy2 and player2 then
        local axes = {input.joy2:getAxes()}
        local dead = isDead(axes, axisConfig2)

        -- aiming
        if not dead[axisConfig2.lookX] or not dead[axisConfig2.lookY] then
            local lookx, looky = axes[axisConfig2.lookY], axes[axisConfig2.lookX]
            player2.aimAngle = math.atan2(lookx, looky)
            input.joy2LookMag = lookx^2+looky^2
        end

        -- movement
        if not dead[axisConfig2.moveX] or not dead[axisConfig2.moveY] then
            player2:move(math.atan2(axes[axisConfig2.moveY], axes[axisConfig2.moveX]))
            input.joy2dead = false
        else
            -- only send one stop walking signal. This is so it does not
            -- interfere with the keyboard input
            if not input.joy2dead then
                player2:stopMoving()
                input.joy2dead = true
            end
        end

        -- trigger
        local wasPressed = input.lastjoy2Trigger > axisConfig2.triggerActivationPoint
        local isPressed = axes[axisConfig2.trigger] > axisConfig2.triggerActivationPoint
        if not wasPressed and isPressed then
            player2:startShooting()
        elseif wasPressed and not isPressed then
            player2:stopShooting()
        end
        input.lastjoy2Trigger = axes[axisConfig2.trigger]
    end
end

function checkKeyboardAxis()
    if not input.currentState.playerControl then return end

    local up = love.keyboard.isDown('w', 'up')
    local down = love.keyboard.isDown('s', 'down')
    local left = love.keyboard.isDown('a', 'left')
    local right = love.keyboard.isDown('d', 'right')

    local y = 0
    if up then y = y - 1 end
    if down then y = y + 1 end

    local x = 0
    if right then x = x + 1 end
    if left then x = x - 1 end


    if x ~= 0 or y ~= 0 then
        -- Note: using atan is a waste of resources here
        player1:move(math.atan2(y, x))
    else
        player1:stopMoving()
    end

end



function love.keypressed(key, unicode)
	if profilerEnabled then pie:keypressed(key, unicode) end

    -- global key bindings
    if key == "f1" then
        debugMode = not debugMode
    end
	if key == "f2" then
		local fs = love.window.getFullscreen()
		love.window.setFullscreen(not fs, "desktop")
		-- update camera?
	end
    if key == "escape" then
        love.event.quit()
    end
    if key == "f3" then
        coordinator.toggleDayNight()
    end

    if key == "f4" then
        lighting.canvas:newImageData():encode('png', 'lighting-pass.png')
    end

	if key == "f5" then
		profilerEnabled = not profilerEnabled
	end

	if key == "f6" then
	    -- noclip
		player1.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
		if player2 then player2.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) end
	end



    -- debug stuff
    -- lighting.canvas:newImageData():encode('png', 'lighting-pass.png')



    checkKeyboardAxis()

    -- game state dependent actions
    return doAction(input.currentState.kbdPress[key])
end

function love.keyreleased(key, unicode)

    checkKeyboardAxis()

    -- game state dependent actions
    return doAction(input.currentState.kbdRelease[key])
end



function love.mousepressed(x, y, button)
	pie:mousepressed(x,y,button)
    -- game state dependent actions
    return doAction(input.currentState.mousePress[button])
end

function love.mousereleased(x, y, button)
    -- game state dependent actions
    return doAction(input.currentState.mouseRelease[button])
end


function love.mousemoved(x, y, dx, dy)
    input.mousex = x
    input.mousey = y
    input.lastAim = 'mouse'
    -- game state dependent handler
    return input.currentState.mouseMove(x, y, dx, dy)
end

function love.wheelmoved(x, y)
    return input.currentState.wheelMove(x, y)
end



function love.gamepadpressed(j, button)
    --print(button)
    
    if singleGamepadTwoPlayers then
        if not input.joy2 then
            input.joy2 = j

            player2 = Player.new(scene, 2, game.menu.globals.player2Color)
        end
    else
        -- if new (not touched before) then assign it to the next available slot
        -- (player 1 or player 2)
        if not input.joy1 then
            input.joy1 = j
        elseif not input.joy2 and j ~= input.joy1 then
            input.joy2 = j

            player2 = Player.new(scene, 2, game.menu.globals.player2Color)
        end
    end

    -- game state dependent actions
    if j == input.joy1 then
        return doAction(input.currentState.joy1Press[button])
    elseif j == input.joy2 then
        return doAction(input.currentState.joy2Press[button])
    end
    -- ignore any other joysticks
end


function love.gamepadreleased(j, button)
    -- game state dependent actions
    if j == input.joy1 then
        return doAction(input.currentState.joy1Release[button])
    elseif j == input.joy2 then
        return doAction(input.currentState.joy2Release[button])
    end
    -- ignore any other joysticks
end





return input
