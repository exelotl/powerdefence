local MenuList = oo.class()

function MenuList:init(x, y)
	self.x, self.y = x, y
	self.width = 100
	self.spacing = 30
	self.items = {}
	self.hoverPos = 0
end

function MenuList:add(text, callback)
	table.insert(self.items, {text=text, callback=callback})
end

function MenuList:update(dt)
	local x = input.mousex
	local y = math.floor((input.mousey - self.y) / self.spacing) + 1
	
	if y > 0 and y <= #self.items and x >= self.x and x <= self.x + self.width then
		if love.mouse.isDown(1) then
			self.items[y].callback()
		end
	else
		y = 0
	end
	self.hoverPos = y
end

function MenuList:draw()
	love.graphics.setBackgroundColor(30, 0, 0)
	
	if self.hoverPos > 0 then
		love.graphics.setColor(255,255,255,80)
		love.graphics.rectangle(
			"fill",
			self.x,
			self.y + (self.hoverPos-1)*self.spacing,
			self.width,
			self.spacing)
	end
	
	love.graphics.setColor(255,255,255)
	for i, item in ipairs(self.items) do
		love.graphics.print(item.text, self.x+8, self.y + (i-1)*self.spacing + 10)
	end
end

return MenuList