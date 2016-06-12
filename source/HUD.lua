local hud = {}

function hud.draw()
  
  for i = 0, player1.hp-1 do
    local heartquad = assets.heartq[player1.color]
    local _,_,heartx,hearty = heartquad:getViewport()
    local scale = cam.scale * 0.4
    heartx = heartx * scale
    hearty = hearty *  scale
    lg.draw(assets.hearts,heartquad,i * heartx + 10 * scale,lg.getHeight() - hearty - 10 * scale,0,scale,scale)
  end
  
  if player2 then
    for i = 1, player2.hp do
      local heartquad = assets.heartq[player2.color]
      local _,_,heartx,hearty = heartquad:getViewport()
      local scale = cam.scale * 0.4
      heartx = heartx * scale
      hearty = hearty *  scale
      lg.draw(assets.hearts,heartquad,lg.getWidth() - i * heartx - 10 * scale,lg.getHeight() - hearty - 10 * scale,0,scale,scale)
    end
  end
end

return hud