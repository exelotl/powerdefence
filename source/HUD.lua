local hud = {}

local assets = require "assets"

function hud.draw()
  
  local p1wy = lg.getHeight() - lg.getHeight()/15
  local p1wx = 10 * cam.scale * 0.4
  local p2wx = lg.getWidth() - 10 * cam.scale * 0.4
  local p2wy = p1wy
  
  for i = 0, player1.hp-1 do
    local heartquad = assets.heartq[player1.color]
    local _,_,heartx,hearty = heartquad:getViewport()
    local scale = cam.scale * 0.4
    heartx = heartx * scale
    hearty = hearty *  scale
    lg.draw(assets.hearts,heartquad,i * heartx + 10 * scale,lg.getHeight() - hearty - 10 * scale,0,scale,scale)
  end
  
  for i,weapon in ipairs(player1.weapons) do
    local scale = cam.scale * 0.8
    p1wy = p1wy - (weapon.image:getHeight() * scale) - (10 * scale)
    
    if player1.currentWeapon == i then
      lg.setColor(255,255,255,255)
    else
      lg.setColor(150,150,150,255)
    end
    
    local imgo = assets.weaponso[weapon.image]
    
    lg.draw(imgo, p1wx, p1wy, 0,scale,scale,1,1)
    
    
    if player1.currentWeapon == i then
      lg.setColor(255,255,255,255)
    else
      lg.setColor(255,0,0,150)
    end
    
    lg.draw(weapon.image, p1wx, p1wy, 0,scale,scale)
  end
  
  lg.setColor(255,255,255,255)
  
  
  if player2 then
    for i = 1, player2.hp do
      local heartquad = assets.heartq[player2.color]
      local _,_,heartx,hearty = heartquad:getViewport()
      local scale = cam.scale * 0.4
      heartx = heartx * scale
      hearty = hearty *  scale
      lg.draw(assets.hearts,heartquad,lg.getWidth() - i * heartx - 10 * scale,lg.getHeight() - hearty - 10 * scale,0,scale,scale)
    end
    
    for i,weapon in ipairs(player2.weapons) do
      local scale = cam.scale * 0.8
      p2wy = p2wy - weapon.image:getHeight() * scale - (10 * scale)
      
      if player2.currentWeapon == i then
      lg.setColor(255,255,255,255)
    else
      lg.setColor(150,150,150,255)
    end
      local imgo = assets.weaponso[weapon.image]
    
      lg.draw(imgo, p2wx - imgo:getWidth()*scale, p2wy, 0,scale,scale,-1,1)
      
      if player2.currentWeapon == i then
        lg.setColor(255,255,255,255)
      else
        lg.setColor(255,0,0,150)
      end
      
      lg.draw(weapon.image, p2wx - weapon.image:getWidth()*scale, p2wy, 0,scale,scale)
    end
    
  end
end

return hud