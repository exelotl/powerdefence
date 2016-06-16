
return function(map)
	
	local function getLayer(name)
		for i,layer in ipairs(map.layers) do
			if layer.name == name then
				return layer
			end
		end
	end
	
	local mapData = getLayer("tiles").data
	local batch = lg.newSpriteBatch(assets.tiles, map.width * map.height)
	
	for i=0, map.width-1 do
		for j=0, map.height-1 do
			local tid = mapData[i + j*map.height + 1]
			print(i, j, map.height, tid)
			local quad = assets.tileqs[tid]
			batch:add(quad, i*map.tilewidth, j*map.tileheight)
		end
	end
	
	local w = map.width * map.tilewidth
	local h = map.height * map.tileheight
	
	-- probably refactor this somewhere else?
	local mapEntity = {
		type = "map",
		update = function (self, dt) end,
		draw = function (self)
			lg.draw(batch, -w/2, -h/2)
		end
	}
	return mapEntity
end
