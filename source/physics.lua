
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

    bulletEnemy = {
        test = function(aType, bType) return aType == 'bullet' and bType == 'enemy' end,
        callback = function(bulletFix, enemyFix, coll)
            local enemy = enemyFix:getUserData().data
            enemy:takeDamage()
        end
    },
    bulletOrb = {
        test = function(aType, bType) return aType == 'bullet' and bType == 'orb' end,
        callback = function(bulletFix, orbFix, coll)
            local orb = orbFix:getUserData().data
            orb:takeDamage()
        end
    },

    enemyPlayer = {
        test = function(aType, bType) return aType == 'enemy' and bType == 'player' end,
        callback = function(enemyFix, playerFix, coll)
            local player = playerFix:getUserData().data
            local enemy = enemyFix:getUserData().data
            local force = 50
            local nx, ny = coll:getNormal()
            player.body:applyLinearImpulse(force*nx, force*ny)
            enemy.body:applyLinearImpulse(-force*nx, -force*ny)
            player:takeDamage()
        end
    },
    enemyOrb = {
        test = function(aType, bType) return aType == 'enemy' and bType == 'orb' end,
        callback = function(enemyFix, orbFix, coll)
            local orb = orbFix:getUserData().data
            local enemy = enemyFix:getUserData().data
            orb:takeDamage()
            enemy.hp = 1
            enemy:takeDamage()
        end
    },
}



local function bulletCleanup(bulletFix)
    local bullet = bulletFix:getUserData().data
    bullet.scene:remove(bullet)
end



function beginContact(a, b, coll)
    local aType = a:getUserData() and a:getUserData().dataType or nil
    local bType = b:getUserData() and b:getUserData().dataType or nil
    --printf('collision %s %s', aType, bType)

    for _, cb in pairs(collisionCallbacks) do
        if     cb.test(aType, bType) then cb.callback(a, b, coll)
        elseif cb.test(bType, aType) then cb.callback(b, a, coll)
        end
    end

    if aType == 'bullet' then bulletCleanup(a) end
    if bType == 'bullet' then bulletCleanup(b) end
end


function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end
