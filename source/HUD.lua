hud = {}

function hud.draw()
  
  for i = 0, player1.hp-1 do
    local heartquad = assets.heartq[player1.color]
    local _,_,heartx,hearty = heartquad:getViewport()
    lg.draw(assets.hearts,heartquad,i * heartx,lg.getHeight() - hearty,0)
  end
  
end

return hud