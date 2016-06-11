local assets = {}

local function makeQuads(img, quadw, quadh)
	local w, h = img:getDimensions()
	local t = {}
	for x=0, w-1, quadw do
		for y=0, h-1, quadh do
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
	
	assets.background = love.graphics.newImage("assets/placeholders/floor.png")
	assets.fft = love.graphics.newImage("assets/placeholders/forcefieldtop.png")
	assets.ffb = love.graphics.newImage("assets/placeholders/forcefieldbottom.png")
end

return assets