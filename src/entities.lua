-- the list of all the game objects
-- also contains factory methods for each type of game object
local entities = {}

-------------------------------------------------------------- ENTITY MANAGEMNT

-- return a list of all entities containing the supplied component names
function entities.filter(self, ...)
    local list = {}
    
    -- append to list if an entity contains all of the keys in arg
    for i,entity in ipairs(self) do
        local success = true
        for j,componentName in ipairs(arg) do
            if entity[componentName] == nil then
                success = false
            end
        end
        if success then
            table.insert(list, entity)
        end
    end
    
    return list
end

-------------------------------------------------------- ENTITY FACTORY METHODS

-- title screen display
function entities.newTitle(x, y, image)
    return table.insert(Entities, {
        description = { "title" },
        position    = { x = math.floor(x - image:getWidth()/2),
                        y = math.floor(y - image:getHeight()/2), 
                        z = 0 },
        sprite      = { image = image },
    })
end

-- map to load
function entities.newMap(file)
    return table.insert(Entities, {
        description = { "map" },
        map         = { loaded = false, map = {}, path = file, children = {} },
    })
end

-- camera
function entities.newCamera(x, y, target)
    x = x or 0
    y = y or 0
    return table.insert(Entities, {
        description = { "camera" },
        position    = { x = x, y = y }, 
        camera      = { target = target, scale = 1 },
        bounds      = { x1 = 0, x2 = 0, y1 = 0, y2 = 0 }
    })
end

-- solid object such as a platform or the ground
function entities.newSolid(x, y, width, height, type)
    local collideType
    if type == "oneway" then 
        collideType = { solid = false, active = false, oneway = true }
    elseif type == "solid" then 
        collideType = { solid = true, active = false, oneway = false }
    end
    return table.insert(entities, {
        description     = { "solid("..x.."|"..y.."}" },
        position        = { x = x, y = y, width = width, height = height },
        debugrectangle  = { color = {255,255,255,255}, style = "line" },
        collidable      = collideType,
    })
end

-- the player character
function entities.newPlayer(x, y, width, height, loopX, loopY)
    return table.insert(entities, {
        description = { "player" },
        player      = { state = "default", input = nil, flip = false },
        sprite      = { image = Assets.player_stand, r = 0, sx = 1, sy = 1, ox = 0, oy = 0 },
        position    = { x = x, y = y, z = 100, width = 8, height =11 }, 
        velocity    = { x = 0, y = 0, max = { x = 60, y = 250 } },
        physical    = { gravity = true, grounded = false },
        collidable  = { solid = false, active = true, oneway = false, collidee = {} },
        input       = { list = {}, previous = {}, jumped = false },
    })
end

-- standard enemy
function entities.newEnemy(x, y, width, height, seed)
    return table.insert(entities, {
        description = { "enemy" },
        position    = { x = x, y = y, width = width, height = height, z = 90 }, 
        velocity    = { x = 0, y = 0, max = { x = 20, y = 250 } },
        physical    = { gravity = true, grounded = false },
        collidable  = { solid = false, active=true },
        sprite      = { image = Assets.enemy },
        ai          = { state = "right", seed = seed, type = "default" }
    })
end

-- spikey enemy
function entities.newSpikeEnemy(x, y, width, height, seed)
    return table.insert(entities, {
        description = { "enemy" },
        position    = { x = x, y = y, width = width, height = height, z = 90 }, 
        velocity    = { x = 0, y = 0, max = { x = 120, y = 250 } },
        physical    = { gravity = true, grounded = false },
        collidable  = { solid = false, active=true },
        sprite      = { image = Assets.spike1 },
        ai          = { state = "right", seed = seed, type = "spike" }
    })
end

-- plantable seed
function entities.newSeed(x, y, type)
    local image
    if type == "flower" then image = Assets.seed2
    elseif type == "tree" then image = Assets.seed1
    elseif type == "bomb" then image = Assets.seed4
    elseif type == "sleep" then image = Assets.seed3 end
    return table.insert(entities, {
        description = { "seed" },
        seed        = { type = type },
        position    = { x = x, y = y, width = 8, height = 8, z = 30 }, 
        velocity    = { x = 0, y = 0, max = { x = 20, y = 250 } },
        physical    = { gravity = true, grounded = false },
        collidable  = { solid = false, active=true },
        sprite      = { image = image }
    })
end

-- planted flower or tree
function entities.newFlower(x, y, type)
    return table.insert(entities, {
        description = { "flower" },
        flower      = { state = "dead" },
        position    = { x = x, y = y, width = 8, height = 8, z = 30 }, 
        collidable  = { solid = false, active = false },
        sprite      = { image = Assets.flower_dead },
    })
end

-- area that spawns flying enemies
function entities.newSpawner(x, width, type)
    return table.insert(entities, {
        description = { "spawner" },
        position    = { x = x, y = 0, width = width, height = WINDOW_HEIGHT }, 
        collidable  = { solid = false, active = false },
        spawner     = { type = "fly", current = 0, max = 5, count = 100 },
    })
end

-- flying enemy
function entities.newFly(x,y,owner)
    return table.insert(entities, {
        description = { "fly" },
        sin         = { count = 0 },
        position    = { x = x, y = y, width = 8, height = 8, z = 10 }, 
        offset      = { x = x, y = y }, 
        collidable  = { solid = false, active = false },
        fly         = { owner = owner },
        sprite      = { image = Assets.fly },
        velocity    = { x = 0, y = 0, max = { x = 50, y = 250 } },
    })
end

-- shooting enemy
function entities.newShooter(x,y,seed)
    return table.insert(entities, {
        description = { "shooter" },
        shootAI     = { shoot = true },
        position    = { x = x, y = y, width = 8, height = 8, z = 10 },
        collidable  = { solid = false, active = true },
        velocity    = { x = 0, y = 0, max = { x = 0, y = 250 } },
        physical    = { grounde = true, gravity = true },
        ai          = { state = "default", seed = seed, type = "shooter" },
        sprite      = { image = Assets.shooter },
    })
end

-- shot from a shooting enemy
function entities.newShot(x,y,dir)
    return table.insert(entities, {
        description = { "shot" },
        position    = { x = x, y = y, width = 2, height = 2 },
        collidable  = { solid = false, active = false },
        shot        = { dir = dir, state = "default" },
        rectangle   = { style = "fill", color = { 255, 255, 255, 255 } },
        velocity    = { x = 0, y = 0, max = { x = 120, y = 250 } },
    })
end

-- block which is breakable by bomb plants
function entities.newBreakable(x,y,owner)
    return table.insert(entities, {
        description = { "breakable" },
        position    = { x = x, y = y, width = 8, height = 8, z = 10 }, 
        collidable  = { solid = true, active = true },
        sprite      = { image = Assets.breakable },
        breakable   = {},
    })
end

--------------------------------------------------------------------------------

return setmetatable(entities, { __call = entities.filter })
