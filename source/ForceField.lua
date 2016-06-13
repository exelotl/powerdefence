
local ForceField = {}
local mode = require "mode"

--draws the force field
function ForceField.drawTop()
  if mode.current == 'day' then
	local ratio = math.sin(globalTimer)*255 + 255
    lg.setColor(255,255,255,ratio)
    lg.draw(assets.fft,-512,-512,0)
    lg.setColor(255,255,255,255-ratio)
    lg.draw(assets.fft2,-512,-512,0)
    lg.setColor(255,255,255,255)
  end
end

function ForceField.drawBottom()
  if mode.current == 'day' then
	local ratio = math.sin(globalTimer)*255 + 255
    lg.setColor(255,255,255,ratio)
    lg.draw(assets.ffb,-512,-512,0)
    lg.setColor(255,255,255,255-ratio)
    lg.draw(assets.ffb2,-512,-512,0)
    lg.setColor(255,255,255,255)
  end
end

return ForceField