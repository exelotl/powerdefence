--[[ input system

Guideline:
- global key bindings (eg quit) can be placed directly into the appropriate love
function. Bind actions to input events for the game state dependent actions (eg
place tower)

--]]

require 'external/utils'

local input = {}

input.states = {}

-- ordering depends on the order that a button is pressed on them
input.deadZones = {0, 0, 0, 0, -1, -1}
input.deadZoneTolerance = 0.2
input.joy1 = nil
input.joy2 = nil

-- cache mouse position
input.mousex = 0
input.mousey = 0

-- the last device used to aim player 1
-- 'mouse' | 'joy'
input.lastAim = 'mouse'

-- record whether the axes used for walking are in the dead zone
input.joy1dead = true
input.joy2dead = true


input.states.day = {
    -- whether input should move the characters in this state
    playerControl = true,

    actions = {
    },


    kbdPress = {

    },
    kbdRelease = {},


    mousePress = {

    },
    mouseRelease = {},

    mouseMove = function(x, y, dx, dy) end,

    joy1Press = {

    },
    joy1Release = {},

    joy2Press = {

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


input.currentState = input.states.testing







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
function isDead(axes)
    local dead = {}
    for i = 1, #axes do
        dead[i] = math.abs(axes[i]-input.deadZones[i]) <= input.deadZoneTolerance
    end
    return dead
end

-- there is no love.blah function for handling joystick axis change, so instead
-- calling this function from the update function
function input.checkJoystickAxes()
    if not input.currentState.playerControl then return end

    if input.joy1 then
        local axes = {input.joy1:getAxes()}
        local dead = isDead(axes)

        -- aiming
        if not dead[3] or not dead[4] then
            player1.angle = math.atan2(axes[4], axes[3])
            input.lastAim = 'joy'
        end

        -- movement
        if not dead[1] or not dead[2] then
            player1:move(math.atan2(axes[2], axes[1]))
            input.joy1dead = false
        else
            -- only send one stop walking signal. This is so it does not
            -- interfere with the keyboard input
            if not input.joy1dead then
                player1:stopMoving()
                input.joy1dead = true
            end
        end

    end

    if input.joy2 then
        local axes = {input.joy2:getAxes()}
        local dead = isDead(j2axes)

        if not dead[1] or not dead[2] then
            player2:move(math.atan2(axes[2], axes[1]))
            input.joy2dead = false
        else
            -- only send one stop walking signal. This is so it does not
            -- interfere with the keyboard input
            if not input.joy2dead then
                player2:stopMoving()
                input.joy2dead = true
            end
        end
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
    -- global key bindings
    if key == "f1" then
        debug = not debug
    end
	if key == "f2" then
		local fs = love.window.getFullscreen()
		love.window.setFullscreen(not fs, "desktop")
		-- update camera?
	end
    if key == "escape" then
        love.event.quit()
    end


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



function love.gamepadpressed(j, button)
    -- if new (not touched before) then assign it to the next available slot
    -- (player 1 or player 2)
    if not input.joy1 then
        input.joy1 = j
    elseif not input.joy2 and j ~= input.joy1 then
        input.joy2 = j
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
