local Scene = oo.class()
local debugWorldDraw = require "debugworlddraw"

function Scene:init()
	self.world = lp.newWorld(0, 0, true)
	self.entities = {}
	self.addlist = {}
	self.removelist = {}
end

function Scene:update(dt)
	for _,e in ipairs(self.removelist) do
		e:removed()
		e.scene = nil
		for i, e2 in ipairs(self.entities) do
			if e == e2 then
				table.remove(self.entities, i)
				break
			end
		end
	end
	for _,e in ipairs(self.addlist) do
		e.scene = self
		table.insert(self.entities, e)
		e:added()
	end
	
	self.addlist = {}
	self.removelist = {}
	
	for _,e in ipairs(self.entities) do
		e:update(dt)
	end
	
	self.world:update(dt)
end

function Scene:draw()
	for _,e in ipairs(self.entities) do
		e:draw()
	end
	if debug then
		debugWorldDraw(self.world, -1024, -1024, 2048, 2048)
	end
end

-- schedule entity to be added on the next frame
function Scene:add(e)
	table.insert(self.addlist, e)
end

-- schedule entity to be removed on the next frame
function Scene:remove(e)
	table.insert(self.removelist, e)
end

return Scene