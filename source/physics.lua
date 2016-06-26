
require 'helperMath'

--[[
example usage:
    self.fixture:setUserData({dataType='this data type', data=self})

--]]


-- apply impulse from two colliding bodies directed away from the point of collision
-- applyA and applyB are whether to apply the impulse to that body
function impulseBetween(bodyA, bodyB, force, applyA, applyB)
    local ax, ay = bodyA:getPosition()
    local bx, by = bodyB:getPosition()
    local fx, fy = directionTo(ax, ay, bx, by)
    if applyA then bodyA:applyLinearImpulse(-force*fx, -force*fy) end
    if applyB then bodyB:applyLinearImpulse(force*fx, force*fy) end
end

local bulletForce = 20
local explosionForce = 200

local collisionCallbacks = {
    bulletPlayer = {
        test = function(aType, bType) return (aType == 'bullet' or aType == 'laser') and bType == 'player' end,
        callback = function(bulletFix, playerFix, coll)
            local player = playerFix:getUserData().data
            local bullet = bulletFix:getUserData().data

            if bullet.damage then player:takeDamage(bullet.damage)
            else player:takeDamage() end

            if player:isAlive() then
                impulseBetween(bulletFix:getBody(), player.body, bulletForce, false, true)
            end
        end
    },
    bulletEnemy = {
        test = function(aType, bType) return (aType == 'bullet' or aType == 'laser')  and bType == 'enemy' end,
        callback = function(bulletFix, enemyFix, coll)
            local enemy = enemyFix:getUserData().data
            local bullet = bulletFix:getUserData().data

            if bullet.damage then enemy:takeDamage(bullet.damage)
            else enemy:takeDamage() end

            -- if they are dead let them fall straight down
            if enemy:isAlive() then
                impulseBetween(bulletFix:getBody(), enemy.body, bulletForce, false, true)
            end
        end
    },
    bulletOrb = {
        test = function(aType, bType) return aType == 'bullet' and bType == 'orb' end,
        callback = function(bulletFix, orbFix, coll)
            local orb = orbFix:getUserData().data
            local bullet = bulletFix:getUserData().data

            if bullet.damage then orb:takeDamage(bullet.damage)
            else orb:takeDamage() end

            impulseBetween(bulletFix:getBody(), orb.body, bulletForce, false, true)
        end
    },

    enemyPlayer = {
        test = function(aType, bType) return aType == 'enemy' and bType == 'player' end,
        callback = function(enemyFix, playerFix, coll)
            local player = playerFix:getUserData().data
            local enemy = enemyFix:getUserData().data
            player:takeDamage()

            -- if they are dead let them fall straight down
            impulseBetween(enemy.body, player.body, 50,
                enemy:isAlive(), player:isAlive())
        end
    },
    enemyOrb = {
        test = function(aType, bType) return aType == 'enemy' and bType == 'orb' end,
        callback = function(enemyFix, orbFix, coll)
            local enemy = enemyFix:getUserData().data
            local orb = orbFix:getUserData().data
            orb:takeDamage()
            enemy:takeDamage(99)

            impulseBetween(orb.body, enemy.body, 100+200*math.random(),
                false, true)
        end
    },
    explosionOrb = {
        -- note: before making orb dynamic: did not fire. Maybe sensors can't
        -- collide with static bodies?
        test = function(aType, bType) return aType == 'explosion' and bType == 'orb' end,
        callback = function(explosionFix, orbFix, coll)
            local orb = orbFix:getUserData().data
            orb:takeDamage(4)

            impulseBetween(explosionFix:getBody(), orb.body, explosionForce, false, true)
        end
    },
    explosionPlayer = {
        test = function(aType, bType) return aType == 'explosion' and bType == 'player' end,
        callback = function(explosionFix, playerFix, coll)
            local player = playerFix:getUserData().data
            player:takeDamage(4)

            impulseBetween(explosionFix:getBody(), player.body, explosionForce, false, true)
        end
    },
    explosionEnemy = {
        test = function(aType, bType) return aType == 'explosion' and bType == 'enemy' end,
        callback = function(explosionFix, enemyFix, coll)
            local enemy = enemyFix:getUserData().data
            enemy:takeDamage(4)

            impulseBetween(explosionFix:getBody(), enemy.body, explosionForce, false, true)
        end
    },
    grenadeTriggering = {
        test = function(aType, bType) return aType == 'grenade' and
            (bType == 'rocket' or
             bType == 'bullet' or
             bType == 'explosion')
        end,
        callback = function(grenadeFix, otherFix, coll)
            local grenade = grenadeFix:getUserData().data
            grenade:explode()
        end
    },
    rocketCollidable = {
        test = function(aType, bType) return aType == 'rocket' and
            (bType == 'enemy' or
             bType == 'player' or
             bType == 'orb' or
             bType == 'rocket' or
             bType == 'bullet' or
             bType == 'explosion' or
             bType == 'grenade' or
             bType == 'glowstick')
        end,
        callback = function(rocketFix, otherFix, coll)
            local rocket = rocketFix:getUserData().data
            rocket:explode()
        end
    },
    flamePlayer = {
        test = function(aType, bType) return aType == 'flame' and bType == 'player' end,
        callback = function(Fix, playerFix, coll)
            local player = playerFix:getUserData().data
            player:takeDamage()
        end
    },
    flameEnemy = {
        test = function(aType, bType) return aType == 'flame' and bType == 'enemy' end,
        callback = function(flameFix, enemyFix, coll)
            local enemy = enemyFix:getUserData().data
            enemy:burn() -- different death animation from takeDamage
        end
    },
    healthPlayer = {
        test = function(aType, bType) return aType == 'healthPickup' and bType == 'player' end,
        callback = function(hpFix, playerFix, coll)
            --TODO: play a sound here?
            local player = playerFix:getUserData().data
            player.hp = player.hp + 1
            local helpik =  hpFix:getUserData().data
            helpik.scene:remove(helpik)
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

    if aType == 'rocket' then bulletCleanup(a) end
    if bType == 'rocket' then bulletCleanup(b) end

    if aType == 'laser' then bulletCleanup(a) end
    if bType == 'laser' then bulletCleanup(b) end
end


function endContact(a, b, coll)
end

function preSolve(a, b, coll)
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end
