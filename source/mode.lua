
local lighting = require "lighting"
local mode = {}

-- 'day' | 'night'
mode.current = 'day'


function mode.toggle()
    if     mode.current == 'day'   then mode.current = 'night'
    elseif mode.current == 'night' then mode.current = 'day'  end
    flux.to(lighting, 5, {amount= mode.current == 'day' and 0 or 255})
end

return mode
