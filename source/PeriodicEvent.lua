
local PeriodicEvent = oo.class()

--[[

example usage:

// in constructor
self.someUpdateEvent = PeriodicEvent.new(2.5) -- every 2.5 seconds

// in update function
if self.someUpdateEvent:isReady() then
    // do the update
end


--]]

function PeriodicEvent:init(interval)
    assert(interval)
    self.interval = interval
    self.lastFired = globalTimer
end

-- seconds
function PeriodicEvent:setInterval(i)
    self.interval = i
end

-- events/second
function PeriodicEvent:setFrequency(f)
    self.interval = 1/f
end

-- events/second
function PeriodicEvent:getFrequency()
    return 1 / self.interval
end

-- is ready to fire again, use this in an if statement in an update function
function PeriodicEvent:isReady()
    local ready = globalTimer >= self.interval + self.lastFired
    if ready then self.lastFired = globalTimer end
    return ready
end


return PeriodicEvent
