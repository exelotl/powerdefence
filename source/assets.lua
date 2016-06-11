local assets = {}

function assets.load()

	lg.setDefaultFilter("nearest", "nearest") -- for sharp pixel zooming

	assets.player = {
		lg.newImage("assets/player_blue.png"),
		lg.newImage("assets/player_green.png"),
		lg.newImage("assets/player_pink.png"),
		lg.newImage("assets/player_yellow.png")
	}
	assets.weapons = {
        pistol = lg.newImage("assets/pistol.png")
    }

	-- animation frames for all player graphics
	assets.playerq = {
		lg.newQuad(0, 0, 16, 16, assets.player[1]:getDimensions()),
		lg.newQuad(16, 0, 16, 16, assets.player[1]:getDimensions()),
	}

	assets.background = love.graphics.newImage("assets/placeholders/floor.png")
	assets.fft = love.graphics.newImage("assets/placeholders/forcefieldtop.png")
	assets.ffb = love.graphics.newImage("assets/placeholders/forcefieldbottom.png")
end

return assets
