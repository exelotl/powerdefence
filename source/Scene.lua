local Scene = oo.class()
local debugWorldDraw = require "debugworlddraw"
require "physics"


function Scene:init()
	self.world = lp.newWorld(0, 0, true)

    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	self.entities = {}
	self.addlist = {}
	self.removelist = {}
	self.typelist = {}      -- map: typestring -> list of entities
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

		-- remove from the type list
		if e.type then
			for i, e2 in ipairs(self.typelist[e.type]) do
				if e == e2 then
					table.remove(self.typelist[e.type], i)
					break
				end
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
		if e.type then
			-- register the entity's type
			if not self.typelist[e.type] then self.typelist[e.type] = {} end
			table.insert(self.typelist[e.type], e)
		end
		if e.added then e:added() end
	end

	self.addlist = {}
	self.removelist = {}

	self.world:update(dt)

	for _,e in ipairs(self.entities) do
		e:update(dt)
	end
	-- account for changed types (if for some reason you want to do this)
	for type,list in pairs(self.typelist) do
		if #list > 0 then
			for i=#list, 1 -1 do
				local e = list[i]
				if e.type ~= type then
					table.remove(list, i)
					if e.type then
						table.insert(self.typelist[e.type], e)
					end
				end
			end
		end
	end
end

local nextsortid = 0
local sortids = {}

local function compareEntities(e1, e2)
	local b1,b2 = e1.body, e2.body
	if not (b1 and b2) then
      if not sortids[e1] then
          sortids[e1] = nextsortid
          nextsortid = nextsortid+1
      end
      if not sortids[e2] then
          sortids[e2] = nextsortid
          nextsortid = nextsortid+1
      end
      return sortids[e1] < sortids[e2]
  end
	local x1,y1 = b1:getPosition()
	local x2,y2 = b2:getPosition()
	if e1.depthOffset then y1 = y1 + e1.depthOffset end
	if e2.depthOffset then y2 = y2 + e2.depthOffset end
	return y1 < y2
end

function Scene:draw()
	table.sort(self.entities, compareEntities)

	for _,e in ipairs(self.entities) do
		e:draw()
	end
	if debugMode then
		debugWorldDraw(self.world, -1024, -1024, 2048, 2048)
	end
end

-- schedule entity to be added on the next frame
function Scene:add(e)
	assert(e ~= self)
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


function Scene:getNearest(type, e1)
	if not (e1.body and self.typelist[type]) then
		return
	end
	local x1, y1 = e1.body:getPosition()
	local nearest = nil
	local lowestMag = math.huge

	for _,e2 in ipairs(self.typelist[type]) do
		if e2.body and e2 ~= e1 then
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

	return nearest
end

return Scene
