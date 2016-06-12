
local ForceField = {}

local count = 0
local changeval = 1

--updates the count value
local function changeCount()
  count = count + changeval
  if count > 100 then
    count = 100
    changeval = -changeval
  elseif count < 0 then
    count = 0
    changeval = -changeval
  end
end

--draws the force field
function ForceField.drawTop()
  draw1 = 255 * (count/100)
  draw2 = 255 - draw1
  lg.setColor(255,255,255,draw1)
  lg.draw(assets.fft,-512,-512,0)
  lg.setColor(255,255,255,draw2)
  lg.draw(assets.fft2,-512,-512,0)
  lg.setColor(255,255,255,255)
end

function ForceField.drawBottom()
  draw1 = 255 * (count/100)
  draw2 = 255 - draw1
  lg.setColor(255,255,255,draw1)
  lg.draw(assets.ffb,-512,-512,0)
  lg.setColor(255,255,255,draw2)
  lg.draw(assets.ffb2,-512,-512,0)
  lg.setColor(255,255,255,255)
  changeCount()
end

return ForceField