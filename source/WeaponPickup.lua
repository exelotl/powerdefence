local weapons = require "weapons"

local WP = oo.class()

function WP:init(scene, x, y)
    self.type = "pickup"
    scene:add(self)
    self.body = lp.newBody(scene.world, x, y, 'dynamic')
    
    --pick a random weapon
    local keyset = {}
    for k, v in pairs(weapons) do
        if not v.excludeFromPickups then
            table.insert(keyset, k)
        end
    end
    self.weapon = weapons[keyset[math.random(#keyset - 1) + 1]]
    
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
        lg.draw(image, assets.weaponsq[self.weapon.image][1], self.body:getX(), self.body:getY(),0,1,1,imageo:getWidth()/2,imageo:getHeight()/2)
    else
        lg.draw(image, self.body:getX(), self.body:getY(),0,1,1,image:getWidth()/2,image:getHeight()/2)
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
        table.insert(player.weapons,self.weapon.new(player))
    end
    scene:remove(self)
end

return WP
