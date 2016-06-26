local Scene = oo.class()
require "physics"


function Scene:init()
	self.world = lp.newWorld(0, 0, true)

    self.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	self.entities = {}
	self.addlist = {}
	self.removelist = {}
	self.removePhysicsList = {}

	self.updateTypes = {} -- elements: {entity, newType} entities who's type string has changed
	self.types = {}      -- typestring -> list of entities
end

function Scene:update(dt)

	-- add all from the add list
	for _,e in ipairs(self.addlist) do
		e.scene = self
		table.insert(self.entities, e)
		if e.type then
			-- register the entity's type
			if not self.types[e.type] then self.types[e.type] = {} end
			table.insert(self.types[e.type], e)
		end
		if e.added then e:added() end
	end

	-- update the types
	for _,item in ipairs(self.updateTypes) do
        local e = item.entity
		if e.type then
		    -- remove the old type mapping
			removeFirst(self.types[e.type], e)
		end

        -- register the new type
        e.type = item.newType
        if not self.types[e.type] then self.types[e.type] = {} end

        table.insert(self.types[e.type], e)
	end

	-- remove physics from all from the remove physics list
	for _,e in ipairs(self.removePhysicsList) do
		-- remove from the physics world
		if e.body then
            -- cannot destroy the body because the entity and the scene may use
            -- it for keeping track of position
			-- hopefully this will reduce the amount of work done
			e.fixture:destroy()
		    -- shape cannot be destroyed
		end
    end

	-- remove all from the remove list
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
		    assert(self.types[e.type])
		    assert(contains(self.types[e.type], e))
		    removeFirst(self.types[e.type], e)
		end

		-- remove from the physics world
		if e.body then
			e.body:destroy() -- also removes the fixture
		    -- shape cannot be destroyed
		end
	end


	self.addlist = {}
	self.removelist = {}
	self.removePhysicsList = {}

	self.world:update(dt)

	for _,e in ipairs(self.entities) do
		e:update(dt)
	end
	-- account for changed types (if for some reason you want to do this)
	for type,list in pairs(self.types) do
		if #list > 0 then
			for i=#list, 1 -1 do
				local e = list[i]
				if e.type ~= type then
					table.remove(list, i)
					if e.type then
						table.insert(self.types[e.type], e)
					end
				end
			end
		end
	end
end

local nextsortid = 0
local sortids = setmetatable({}, {__mode='k'})
-- kinda hacky stuff here
-- if you try to sort an entity without a body, it will be assigned an ID
-- that way, we can ensure that entities are always drawn in the same order
-- otherwise, we sort by the Y position of the entity
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
		if e.draw then e:draw() end
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

-- remove the entities fixture from the world
-- but does not destroy the entity or body or fixture
function Scene:removePhysicsFrom(e)
	for _,v in ipairs(self.removePhysicsList) do
		if e == v then
			return
		end
	end
	table.insert(self.removePhysicsList, e)

    -- see: https://love2d.org/wiki/Remove_Workaround
    e.fixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
end

function Scene:changeTypeString(e, newType)
    table.insert(self.updateTypes, {entity=e, newType=newType})
end


-- return {entity, dx, dy, magsq} for the nearest entity to the given entity. If
-- none are found returns nil
function Scene:getNearest(searchTypes, e1)
	assert(e1 and e1.body)

	local x1, y1 = e1.body:getPosition()
	local nearest = nil
	local lowestMagSq = math.huge
	local dx, dy

	for _,type in ipairs(searchTypes) do
        -- it doesn't matter if this is nil
        local searchEs = self.types[type]

        if searchEs then
            for _,e2 in ipairs(searchEs) do
                if e2.body and e2 ~= e1 then
                    local x2, y2 = e2.body:getPosition()
                    dx = x2 - x1
                    dy = y2 - y1
                    local magSq = dx*dx + dy*dy
                    if magSq < lowestMagSq then
                        lowestMagSq = magSq
                        nearest = e2
                    end
                end
            end
        end
    end

    if not nearest then
        return nil
    else
        return {entity=nearest, dx=dx, dy=dy, magSq=lowestMagSq}
    end
end

return Scene
