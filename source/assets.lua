local assets = {}

function assets.load()
  assets.background = love.graphics.newImage("assets/placeholders/floor.png")
  assets.fft = love.graphics.newImage("assets/placeholders/forcefieldtop.png")
  assets.ffb = love.graphics.newImage("assets/placeholders/forcefieldbottom.png")
end

return assets