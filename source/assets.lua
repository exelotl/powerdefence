local assets = {}

local function makeQuads(img, quadw, quadh)
	local w, h = img:getDimensions()
	local t = {}
	for y=0, h-1, quadh do
		for x=0, w-1, quadw do
			table.insert(t, lg.newQuad(x, y, quadw, quadh, w, h))
		end
	end
	return t
end

function assets.load()

	lg.setDefaultFilter("nearest", "nearest") -- for sharp pixel zooming

	assets.player = {
		lg.newImage("assets/player_blue.png"),
		lg.newImage("assets/player_green.png"),
		lg.newImage("assets/player_pink.png"),
		lg.newImage("assets/player_yellow.png")
	}

	assets.playerq = makeQuads(assets.player[1], 16, 16)

	assets.weapons = {
        pistol = lg.newImage("assets/pistol.png")
    }
    assets.bullet = lg.newImage("assets/bullet.png")

	assets.background = love.graphics.newImage("assets/placeholders/floor.png")
	assets.fft = love.graphics.newImage("assets/placeholders/forcefieldtop.png")
	assets.ffb = love.graphics.newImage("assets/placeholders/forcefieldbottom.png")
  assets.fft2 = love.graphics.newImage("assets/placeholders/forcefieldtop2.png")
	assets.ffb2 = love.graphics.newImage("assets/placeholders/forcefieldbottom2.png")
end

return assets
