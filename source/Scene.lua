local Scene = oo.class()
local debugWorldDraw = require "debugworlddraw"
require "physics"


function Scene:init()
	self.world = lp.newWorld(0, 0, true)

    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	self.entities = {}
	self.addlist = {}
	self.removelist = {}
end

function Scene:update(dt)
	for _,e in ipairs(self.removelist) do
		-- activate removal callback
		if e.removed then e:removed() end
		e.scene = nil
		
		-- remove from the entity list
		for i, e2 in ipairs(self.entities) do
			if e == e2 then
				table.remove(self.entities, i)
				break
			end 
		end
		
		-- remove from the physics world
		if e.body then
			e.body:destroy()
		end
	end
	for _,e in ipairs(self.addlist) do
		e.scene = self
		table.insert(self.entities, e)
		if e.added then e:added() end
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
	for i,v in ipairs(self.removelist) do
		if e == v then
			return
		end
	end
	table.insert(self.removelist, e)
end


function Scene:getNearest(e1, ...)
	if not e1.body then
		return
	end
	local types = {...}
	local x1, y1 = e1.body:getPosition()
	local nearest = nil
	local lowestMag = math.huge

	for _,e2 in ipairs(self.entities) do
		if e2.body and e2.type and e2 ~= e1 then
			local matchedType = false
			for _,t in ipairs(types) do
				if e2.type == t then
					matchedType = true
					break
				end
			end
			if matchedType then
				local x2, y2 = e2.body:getPosition()
				local dx = x2 - x1
				local dy = y2 - y1
				local mag = dx*dx + dy*dy
				if mag < lowestMag then
					lowestMag = mag
					nearest = e2
				end
			end
		end
	end
	
	return nearest
end

return Scene
