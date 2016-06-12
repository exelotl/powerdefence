
--[[
example usage:
    self.fixture:setUserData({dataType='this data type', data=self})

--]]

local collisionCallbacks = {
    bulletPlayer = {
        test = function(aType, bType) return aType == 'bullet' and bType == 'player' end,
        callback = function(bulletFix, playerFix, coll)
            local player = playerFix:getUserData().data
            player:takeDamage()
        end
    },



    bulletCleanup = {
        test = function(aType, bType) return aType == 'bullet' end,
        callback = function(bulletFix, _, coll)
            -- set to not collide?
            -- destroy the bullet
        end
    },
}






function beginContact(a, b, coll)
    local aType = a:getUserData() and a:getUserData().dataType or nil
    local bType = b:getUserData() and b:getUserData().dataType or nil
    printf('collision %s %s', aType, bType)

    for _, cb in pairs(collisionCallbacks) do
        if     cb.test(aType, bType) then cb.callback(a, b)
        elseif cb.test(bType, aType) then cb.callback(b, a)
        end
    end
end


function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end
