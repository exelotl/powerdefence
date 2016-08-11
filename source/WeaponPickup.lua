local weapons = require "weapons"

local WP = oo.class()


local excludedWeapons = {None=true}
local droppableWeapons = {}

for name, _ in pairs(weapons) do
    if not excludedWeapons[name] then
        table.insert(droppableWeapons, name)
    end
end


function WP:init(scene, x, y)
    self.type = "pickup"
    scene:add(self)
    self.body = lp.newBody(scene.world, x, y, 'dynamic')

    --pick a random weapon
    -- random gives integer from 1 to n
    self.weapon = weapons[droppableWeapons[math.random(#droppableWeapons)]]

    local image = assets.weaponso[self.weapon.image]

    self.shape = lp.newRectangleShape(image:getWidth(), image:getHeight())
    self.fixture = lp.newFixture(self.body, self.shape)
    self.fixture:setUserData({dataType='pickup', data=self})
    self.fixture:setSensor(true)
end

function WP:update(dt) end

function WP:draw()
    local image = assets.weapons[self.weapon.image]
    local imageo = assets.weaponso[self.weapon.image]
    if self.weapon.animated then
        lg.draw(image, assets.weaponsq[self.weapon.image][1],
            self.body:getX(), self.body:getY(),
            0,1,1, imageo:getWidth()/2, imageo:getHeight()/2)
    else
        lg.draw(image, self.body:getX(), self.body:getY(),
            0,1,1, image:getWidth()/2, image:getHeight()/2)
    end
end

function WP:pickup(player)
    local exists = false
    for i, w in ipairs(player.weapons) do
        if w.name == self.weapon.name then
            w:reload()
            exists = true
        end
    end
    if not exists then
        table.insert(player.weapons, self.weapon.new(player))
    end
    scene:remove(self)
end

return WP
