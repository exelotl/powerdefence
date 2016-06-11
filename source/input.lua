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


input.states.day = {
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
    joy1Axis = function(axisNum, val) end,


    joy2Press = {

    },
    joy2Release = {},
    joy2Axis = function(axisNum, val) end,

}

input.states.testing = {
    actions = {
        -- to test two different functions
        printApress = function() print('A press') end,
        printArelease = function() print('A release') end,
        printBpress = function() print('B press') end,
        printBrelease = function() print('B release') end,
        printCpress = function() print('C press') end,
        printCrelease = function() print('C release') end,
    },



    kbdPress = {
        a = 'printApress',
        b = 'printBpress'
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
    joy1Axes = function(axisValues)
        printf('joy1 axes move: ' .. table.tostring(axisValues))
    end,

    joy2Press = {
        a = 'printApress',
        b = 'printCpress'
    },
    joy2Release = {
        a = 'printArelease',
        b = 'printCrelease'
    },
    joy2Axes = function(axisValues)
        printf('joy2 axes move: ' .. table.tostring(axisValues))
    end,
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

-- there is no love.blah function for handling joystick axis change, so instead
-- calling this function from the update function
function input.checkJoystickAxes()
    if input.joy1 then
        local j1axes = {input.joy1:getAxes()}
        local alldead = true
        for i = 1,#input.deadZones do
            if math.abs(input.deadZones[i] - j1axes[i]) > input.deadZoneTolerance then
                alldead = false
                break
            end
        end
        if not alldead then input.currentState.joy1Axes(j1axes) end
    end

    if input.joy2 then
        local j2axes = {input.joy2:getAxes()}
        local alldead = true
        for i = 1,#input.deadZones do
            if math.abs(input.deadZones[i] - j2axes[i]) > input.deadZoneTolerance then
                alldead = false
                break
            end
        end
        if not alldead then input.currentState.joy2Axes(j2axes) end
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


    -- game state dependent actions
    return doAction(input.currentState.kbdPress[key])
end

function love.keyreleased(key, unicode)
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
