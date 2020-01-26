local assets = {}

local function makeQuads(img, quadw, quadh)
    local w, h = img:getDimensions()
    local t = {}
    for y=0, h-1, quadh do
        for x=0, w-1, quadw do
            table.insert(t, lg.newQuad(x, y, quadw, quadh, w, h))
        end
    end
    return t
end

local function makeMask(imgData)
    local maskPixels = li.newImageData(imgData:getDimensions())
    maskPixels:mapPixel(function(x,y,r,g,b,a)
        r,g,b,a = imgData:getPixel(x,y)
        return 255, 255, 255, (a>0 and 255 or 0)
    end)
    return lg.newImage(maskPixels)
end

local function makeOutline(imgData)
    local w,h = imgData:getDimensions()
    local maskPixels = li.newImageData(w+2,h+2)
    local function tryGetPixel(x,y)
        if x < 0 or x >= w or y < 0 or y >= h then
            return 0
        end
        local r,g,b,a = imgData:getPixel(x, y)
        return a>0 and 1 or 0
    end
    maskPixels:mapPixel(function(x,y,r,g,b,a)
        x = x-1
        y = y-1
        local neighbours = tryGetPixel(x+1, y+1)
                         + tryGetPixel(x,   y+1)
                         + tryGetPixel(x-1, y+1)
                         + tryGetPixel(x+1, y)
                         + tryGetPixel(x-1, y)
                         + tryGetPixel(x+1, y-1)
                         + tryGetPixel(x,   y-1)
                         + tryGetPixel(x-1, y-1)
        return 255, 255, 255, ((neighbours>0 and neighbours<8) and 255 or 0)
    end)
    return lg.newImage(maskPixels)
end

local function makeSfx(str, count)
    local t = {}
    for i=1, count do
        t[i] = la.newSource(str, 'static')
    end
    return t
end

local sfxIndices = setmetatable({}, {__mode='k'})

function assets.playSfx(t)
    local n = sfxIndices[t]
    if not n or n > #t then n = 1 end
    t[n]:stop()
    t[n]:play()
    sfxIndices[t] = n + 1
end

function assets.load()

    lg.setDefaultFilter("nearest", "nearest") -- for sharp pixel zooming

    assets.tiles = lg.newImage("assets/tiles.png")
    assets.tileqs = makeQuads(assets.tiles, 32, 32)

    assets.player_data = {
        li.newImageData("assets/player_blue.png"),
        li.newImageData("assets/player_green.png"),
        li.newImageData("assets/player_pink.png"),
        li.newImageData("assets/player_yellow.png")
    }
    assets.player = {}
    -- generate quads and masks:
    assets.playerq = makeQuads(assets.player_data[1], 16, 16)
    assets.playerm = {}
    for i,v in ipairs(assets.player_data) do
        assets.playerm[i] = makeMask(v)
        assets.player[i] = lg.newImage(v)
    end

    assets.playero = {}
    for i,v in ipairs(assets.player_data) do
        assets.playero[i] = makeOutline(v)
    end

    assets.hearts = lg.newImage("assets/heart.png")
    assets.heartq = makeQuads(assets.hearts,32,32)
    assets.reticule = lg.newImage('assets/reticule.png')

    assets.weapon_data = {
        pistol = li.newImageData("assets/weapons/pistol.png"),
        machineGun = li.newImageData("assets/weapons/machinegun.png"),
        rocketLauncher = li.newImageData("assets/weapons/rocketlauncher.png"),
        stupidRocketLauncher = li.newImageData("assets/weapons/stupidrocketlauncher.png"),
        laserRifle = li.newImageData("assets/weapons/laserrifle.png"),
        minigun = li.newImageData("assets/weapons/minigun.png"),
        flameThrower = li.newImageData("assets/weapons/flamethrower.png"),
        sniperRifle = li.newImageData("assets/weapons/sniper.png"),
        uzi = li.newImageData("assets/weapons/UZI.png"),
    }

    assets.weapons = {}
    for name, data in pairs(assets.weapon_data) do
        assets.weapons[name] = lg.newImage(data)
    end

    assets.weaponsq = {
        laserRifle = makeQuads(assets.weapons.laserRifle, 32, 13),
        minigun = makeQuads(assets.weapons.minigun, 46, 16),
    }
    assets.weaponsm = {
        pistol = makeMask(assets.weapon_data.pistol),
        machineGun = makeMask(assets.weapon_data.machineGun),
        rocketLauncher = makeMask(assets.weapon_data.rocketLauncher),
        stupidRocketLauncher = makeMask(assets.weapon_data.rocketLauncher), -- re-use mask for regular launcher
        laserRifle = makeMask(assets.weapon_data.laserRifle),
        minigun = makeMask(assets.weapon_data.minigun),
        flameThrower = makeMask(assets.weapon_data.flameThrower),
        sniperRifle = makeMask(assets.weapon_data.sniperRifle),
        uzi = makeMask(assets.weapon_data.uzi),
    }
    -- for animated weapons: the outline is for the first frame only
    assets.weaponso = {
        pistol = lg.newImage("assets/weapons/pistolo.png"),
        machineGun = lg.newImage("assets/weapons/machineguno.png"),
        rocketLauncher = lg.newImage("assets/weapons/rocketlaunchero.png"),
        stupidRocketLauncher = lg.newImage("assets/weapons/rocketlaunchero.png"), -- re-use
        laserRifle = lg.newImage("assets/weapons/laserrifleo.png"),
        minigun = lg.newImage("assets/weapons/miniguno.png"),
        flameThrower = lg.newImage("assets/weapons/flamethrowero.png"),
        sniperRifle = lg.newImage("assets/weapons/snipero.png"),
        uzi = lg.newImage("assets/weapons/UZIo.png"),
    }


    assets.bullet = lg.newImage("assets/bullet.png")
    assets.rocket = lg.newImage("assets/rocket.png")
    assets.flame = lg.newImage("assets/flame.png")
    assets.laser = lg.newImage("assets/laser.png")
    assets.sniperRound = lg.newImage("assets/sniperRound.png")
    
    assets.muzzleFlare = lg.newImage("assets/muzzleflare.png")

    assets.grenade = lg.newImage("assets/grenade.png")
    assets.glowstick = lg.newImage("assets/glowstick.png")

    assets.explosion = lg.newImage("assets/explosion.png")
    assets.explosionq = makeQuads(assets.explosion,64,64)

    assets.healthPack = lg.newImage("assets/healthpack.png")

    assets.grunt = love.graphics.newImage("assets/grunt.png")
    assets.gruntq = makeQuads(assets.grunt, 32, 32)

    assets.soldier = lg.newImage("assets/soldier.png")
    assets.soldierq = makeQuads(assets.soldier, 32, 32)

    assets.lights = {
        surround = lg.newImage('assets/glow_white.png'),
        torch = lg.newImage('assets/torch_white.png')
    }

    assets.background = lg.newImage("assets/placeholders/floor.png")
    assets.fft = lg.newImage("assets/placeholders/forcefieldtop.png")
    assets.ffb = lg.newImage("assets/placeholders/forcefieldbottom.png")
    assets.fft2 = lg.newImage("assets/placeholders/forcefieldtop2.png")
    assets.ffb2 = lg.newImage("assets/placeholders/forcefieldbottom2.png")
    local orbData = li.newImageData("assets/orb.png")
    assets.orb = lg.newImage(orbData)
    assets.orbq = makeQuads(orbData, 32, 32)
    assets.orbm = makeMask(orbData)

    assets.title = lg.newImage("assets/title.png")

    assets.gamefont = lg.newFont("assets/Skullboy.ttf", 16)
    assets.menufont = lg.newFont("assets/Little-League.ttf", 25)

    assets.title = lg.newImage("assets/title.png")
    assets.gameOver = lg.newImage("assets/gameOver.png")
    assets.sfx = {
        pistol = makeSfx("assets/sfx/pistol.wav", 3),
        machineGun = makeSfx("assets/sfx/machine_gun.wav", 3),
        minigun = makeSfx("assets/sfx/minigun.wav", 3),
        boom = makeSfx("assets/sfx/boom.wav", 2),
        rocketLaunch = makeSfx("assets/sfx/rocket_launch.wav", 2),
        orbDestroy = makeSfx("assets/sfx/orb_destroy.wav", 1),
        laser = makeSfx("assets/sfx/laser.wav", 3),
        flamethrower = makeSfx("assets/sfx/flame.wav", 3),
        whoosh = makeSfx("assets/sfx/whoosh.wav",1),
        debugBlip = makeSfx("assets/sfx/debug_blip.ogg", 10),
        sniper = makeSfx("assets/sfx/sniper2.wav",1),
        uzi = makeSfx("assets/sfx/uzi.wav",1),
    }
end

-- use the debug blip to make a sound when something happens. Eg I used
-- it to determine that all the enemy target updates were happening at
-- once
function debugBlip()
    assets.playSfx(assets.sfx.debugBlip)
end

return assets
