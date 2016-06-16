
local lighting = require "lighting"
local mode = {}

-- 'day' | 'night'
-- must also set lighting.amount to sync with this
mode.current = 'day'

mode.lastSunrise = 0
mode.dayLength = 20 -- seconds

function mode.timeUntilSunset()
    return mode.lastSunrise + mode.dayLength - globalTimer
end
function mode.isSunset()
    return mode.current == 'day' and mode.timeUntilSunset() <= 0
end

function mode.toggle()
    if     mode.current == 'day'   then mode.current = 'night'
    elseif mode.current == 'night' then mode.current = 'day'  end
    flux.to(lighting, 5, {amount = mode.current == 'day' and 0 or 255})
    if mode.current == 'day' then
        mode.lastSunrise = globalTimer
    end
end

return mode
