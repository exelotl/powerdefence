hud = {}

function hud.draw()
  
  for i = 0, player1.hp-1 do
    local heartquad = assets.heartq[player1.color]
    local _,_,heartx,hearty = heartquad:getViewport()
    local scale = cam.scale * 0.4
    heartx = heartx * scale
    hearty = hearty *  scale
    lg.draw(assets.hearts,heartquad,i * heartx + 10 * scale,lg.getHeight() - hearty - 10 * scale,0,scale,scale)
  end
  
end

return hud