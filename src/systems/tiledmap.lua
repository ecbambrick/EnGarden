local newSolid, loadMap, newCloud, loadTilemap, loadEntities

----------------------------------------------------------------- MAIN FUNCTION

-- loads maps from TMX files as well as populating entities from those maps
local function mapSystem(dt)
    for i,e in ipairs(Entities("map")) do
    
        -- load map
        if not e.map.loaded then loadMap(e.map) end
        
        -- set camera boundaries
        for i,c in ipairs(Entities("camera")) do
            c.bounds.x2 = e.map.map.width * TILE_SIZE
            c.bounds.y2 = e.map.map.height * TILE_SIZE
        end
        
    end
end

------------------------------------------------------------------- MAP LOADING

-- load the map and its entities
function loadMap(map)
    loadTilemap(map)
    loadEntities(map)
end

-- load the map from a file through AdvancedTiledLoader
function loadTilemap(map)
    map.loaded = true
    map.map = AdvancedTiledLoader.load(map.path)
    map.map.drawObjects = false
end

-- load player and NPC objects
function loadEntities(map)

    -- solids such as platforms, the ground, and walls
    for i,o in pairs(map.map("Solid").objects) do
        local newObject = newSolid(o)
        table.insert(Entities, newObject)
    end

    -- flowers
    for i,o in pairs(map.map("flowers").objects) do
        Entities.newFlower(o.x, o.y)
    end
    
    -- clouds of varying sizes
    for i,o in pairs(map.map("clouds").objects) do
        local newClouds = newCloud(o, map)
        for i in ipairs(newClouds) do
            table.insert(Entities, newClouds[i])
        end
    end
    
    for i,o in pairs(map.map("NPC").objects) do
    
        -- clouds
        if o.type == "cloud" then
            local newClouds = newCloud(o, map)
            for i in ipairs(newClouds) do
                table.insert(Entities, newClouds[i])
            end
        end
        
        -- the player
        if o.type == "player" then
            local player = Entities.newPlayer(o.x, o.y, o.width, o.height, 
                map.map.width*TILE_SIZE, map.map.height*TILE_SIZE
            )
            for i,c in ipairs(Entities("camera")) do
                c.camera.target = player
            end
        end
        
        -- standard red enemy
        if o.type == "enemy" then
            Entities.newEnemy(o.x, o.y, o.width, o.height, o.properties.type)
        end
        
        -- breakable wall
        if o.type == "breakable" then
            Entities.newBreakable(o.x, o.y, o.width, o.height, o.properties.type)
        end
        
        -- shooting enemy
        if o.type == "shooter" then
            Entities.newShooter(o.x, o.y, o.properties.type)
        end
        
        -- spikey enemy
        if o.type == "spike" then
            Entities.newSpikeEnemy(o.x, o.y, o.width, o.height, o.properties.type)
        end
        
        -- spawner for flying enemies
        if o.type == "flyspawner" then
            Entities.newSpawner(o.x, o.width, "fly")
        end
    end
end
    
--------------------------------------------------------------- ENTITY CREATION

-- new solid object such as a platform hitbox or the ground's hitbox
function newSolid(object)
    return {
        description        = { object.x.."|"..object.y },
        position        = { x = object.x, y = object.y, width = object.width, height = object.height },
        debugrectangle    = { color = {255,255,255,255}, style = "line" },
        collidable        = { solid = true, active = false, oneway = false, collidee = {} },
    }
end

-- new set of clouds with varying width
function newCloud(object, map)
    local clouds = {}
    local speed = math.random(1,3)
    table.insert(clouds, {
        position        = { x = object.x, y = object.y, z=0, width = object.width, height = object.height },
        velocity        = { x = -speed, y = 0, max = { x = 5, y = 5 }, accel = 10000 },
        sprite            = { image = Assets.cloud1 },
        loop            = { x1 = 0, x2 = map.map.width * TILE_SIZE },
    })
    if object.width >= TILE_SIZE * 2 then
        table.insert(clouds, {
            position        = { x = object.x + TILE_SIZE, y = object.y, z=0, width = object.width, height = object.height },
            velocity        = { x = -speed, y = 0, max = { x = 5, y = 5 }, accel = 10000 },
            sprite            = { image = Assets.cloud2 },
            loop            = { x1 = 0, x2 =  map.map.width * TILE_SIZE },
        })
    end
    return clouds
end

--------------------------------------------------------------------------------

return mapSystem
