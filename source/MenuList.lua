local MenuList = oo.class()

function MenuList:init(x, y)
	self.x, self.y = x, y
	self.width = 500
	self.spacing = 75
	self.items = {} -- text and callback
	self.hoverPos = 0
end

function MenuList:centerH()
    local w, _ = lg.getDimensions()
    self.x = w/2 - self.width/2
end

function MenuList:add(text, callback)
	table.insert(self.items, {text=text, callback=callback})
end

-- nil if none selected
function MenuList:currentItemText()
    local currentItem = self.items[self.hoverPos]
    return currentItem and currentItem.text or nil
end

local prevMouseDown = false

function MenuList:update(dt)
	local mouseDown = love.mouse.isDown(1)
	local x = input.mousex
	local y = math.floor((input.mousey - self.y) / self.spacing) + 1

	if y > 0 and y <= #self.items and x >= self.x and x <= self.x + self.width then
		if mouseDown and not prevMouseDown then
			self.items[y].callback()
		end
	else
		y = 0
	end
	self.hoverPos = y

	prevMouseDown = mouseDown
end

function MenuList:draw()
	love.graphics.setBackgroundColor(0.1, 0, 0)


	if self.hoverPos > 0 then
		love.graphics.setColor(1.0,1.0,1.0,0.3)
		love.graphics.rectangle(
			"fill",
			self.x,
			self.y + (self.hoverPos-1)*self.spacing,
			self.width,
			self.spacing)
	end

	love.graphics.setColor(1.0,1.0,1.0)
	for i, item in ipairs(self.items) do
		love.graphics.printf(item.text, self.x+8, self.y + (i-1)*self.spacing + 10, self.width, 'center')
	end
end

return MenuList
