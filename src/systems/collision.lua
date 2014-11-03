local bouncePlayer, reviveFlower, carrySeed, destroyPlant, uprootPlant
local setToSleep, spawnFly, killPlayer, killFly, killEnemy, destroyWall
local filterCollisions, calculateCollisions, resolveCollisions

----------------------------------------------------------------- MAIN FUNCTION

-- This system handles all player-NCP and NPC-NPC interactions
-- due to the limited amount of time, I wasn't able to combine it with the
-- physics system's collision detection, so it's a bit redundant at points
local function system(dt)

    -- do not check for NPC-NPC interactions if there is no player
    -- since the collision detection is brute force O(n^2), this can at
    -- least reduce n to a much smaller amount
    local player = Entities("player")[1]
    local collidableEntities = Entities("position", "collidable")
    if player then
        local potentialCollisions = filterCollisions(collidableEntities, player)
        local collisions = calculateCollisions(potentialCollisions)        
        for i,v in ipairs(collisions) do
            resolveCollision(v[1], v[2])
        end
    end
    
end

----------------------------------------------------------- COLLISION DETECTION

-- only check collisions that are within viewing distance of the player
-- this is to trim out any entities that we don't care about
function filterCollisions(entities, player)
    local potentialCollisions = {}
    for i,e in ipairs(entities) do
        if math.abs(e.position.x - player.position.x) < WINDOW_WIDTH/2
        and math.abs(e.position.y - player.position.y) < WINDOW_HEIGHT/2 then
            table.insert(potentialCollisions, e)
        end
    end
    return potentialCollisions
end

-- calculate actual collions
function calculateCollisions(potentialCollisions)
    local collisions = {}
    local a,b = {}, {}
    for i,entity in ipairs(potentialCollisions) do
        a.x1 = entity.position.x
        a.x2 = entity.position.x + entity.position.width
        a.y1 = entity.position.y
        a.y2 = entity.position.y + entity.position.height
        for j,object in ipairs(potentialCollisions) do
            if object ~= entity then
                b.x1 = object.position.x
                b.x2 = object.position.x + object.position.width
                b.y1 = object.position.y
                b.y2 = object.position.y + object.position.height
                if a.x1 < b.x2 and a.x2 > b.x1 
                and a.y1 < b.y2 and a.y2 > b.y1 then
                    table.insert(collisions, { entity, object } )
                end
            end
        end
    end
    return collisions
end

------------------------------------------------------------ COLLISIONS RESULTS

-- resolve collisions by applying game logic to each collision
function resolveCollision(a, b)

	-- player touches a non-flower plant while holding down
	if a.player and b.plant and a.player.state == "default" 
	and table.contains(a.input.list, "down") and b.plant.type ~= "flower" then
		destroyPlant(b, b.platform)
		local uproot = coroutine.create(uprootPlant)
		coroutine.resume(uproot, a)
	end

    -- sleeping plant touches spikey enemy
    if a.ai and a.ai.type == "spike" and a.ai.state ~= "dead"
    and b.plant and b.plant.type == "sleep" then
        setToSleep(a)
    end
    
    -- player is hit by a projectile
    if a.player and a.player.state ~= "dead" and b.shot then
        killPlayer(a)
    end
    
    -- player is within a fly spawning area
    -- and the spawner has not spawned the maximum number of flies
    if a.player and b.spawner
    and b.spawner.current < b.spawner.max and b.spawner.count > 1 then
        spawnFly(b, a)
    end
    
    -- player is hit by a fly
    if a.player and a.player.state ~= "dead"
    and b.fly and b.fly.state ~= "dead" then
        if a.velocity.y > 0  then
            bouncePlayer(a)
            killFly(b)
        else
            killPlayer(a)
        end
    end
    
    -- player is hit by an explosion
    if a.player and b.explosion then
        killPlayer(a)
    end
    
    -- enemy is hit by an explosion
    if b.ai and a.explosion and b.ai.state ~= "dead" then
        killEnemy(b)
    end
    
    -- breakable wall is hit by an explosion
    if a.explosion and b.breakable then
        destroyWall(b)
    end
    
    -- player collides with an enemy
    if a.player and a.player.state ~= "dead"
    and b.ai and b.ai.state ~= "dead" then
    
        -- player hits an active spike
        if b.ai.type == "spike" and b.ai.state ~= "sleep" then
            killPlayer(a)
            
        -- player jumps on an enemy
        elseif a.velocity.y > 0 then
            bouncePlayer(a)
            killEnemy(b)
            
        -- player runs into a non-passive, non-spikey enemy
        elseif not ( b.ai.type == "spike" and b.ai.state == "sleep") then
            killPlayer(a)
        end
        
    end
    
    -- player touches a seed while carrying nothing
    if a.player and b.seed 
    and b.velocity.y == 0 and a.player.state == "default" then
        carrySeed(a, b)
    end
    
    -- player touches a flower
    if a.player and b.flower then
        reviveFlower(b)
    end
end

-------------------------------------------------------------- ACTION FUNCTIONS

-- put spikey enemy in passive, killable state
function setToSleep(e)
    e.ai.state = "sleep"
    e.sprite.image = Assets.spike2
    e.velocity.x = 0
end

-- spawn a flying enemy
function spawnFly(e, player)
    Entities.newFly(
        player.position.x + WINDOW_WIDTH/2, 
        math.random(0,WINDOW_HEIGHT),
        e
    )
    e.spawner.current = e.spawner.current + 1
    e.spawner.count = 0
end

-- kill the player
function killPlayer(e)
    e.velocity.y = -100
    e.velocity.x = 0
    e.collidable.active = false
    e.player.state = "dead"
end

-- kill a flying enemy
function killFly(e)
    e.physical = { gravity = true, grounded = false }
    e.fly.state = "dead"
    e.velocity.y = -100
    e.collidable.active = false
end

-- kill a non-flying enemy
function killEnemy(e)
    e.ai.state = "dead"
    e.velocity.y = -100
    e.collidable.active = false
    Entities.newSeed(e.position.x, e.position.y, e.ai.seed)
end

-- delete a breakable wall
function destroyWall(e)
    table.removevalue(Entities, e)
    table.clear(e)
end
    
-- cause a mid-air jump for the player
function bouncePlayer(e)
    e.velocity.y = -120
    e.physical.grounded = true
end

-- give the player a seed
function carrySeed(player, seed)
    player.player.state = "carry"
    player.seedholder = { seed = seed }
    seed.seed.owner = player
    seed.physical = nil
    seed.velocity = nil
    seed.collidable = nil
end

-- change flower to alive and add a point to the score
function reviveFlower(e)
    love.audio.stop(Assets.coin)
    love.audio.play(Assets.coin)
    SCORE = SCORE + 1
    e.flower.state = "alive"
    e.sprite.image = Assets.flower_alive
    e.collidable = nil
end

-- destroy a plant and create a seed in its place
function destroyPlant (plant, platform)
	local seedX = plant.position.x + plant.position.width/2 - 2
	local seedY = plant.position.y
	local seedT = plant.plant.type
	
	-- if you planted a tree, remove its one-way platform
	if platform then
		table.removevalue(Entities, platform)
		table.clear(platform)
	end
	
	-- remove plant
	table.removevalue(Entities, plant)
	table.clear(plant)
	
	-- create new seed
	local seed = Entities.newSeed(seedX, seedY, seedT)
	seed.velocity.y = -150
end

-- change player state while uprooting a plant
function uprootPlant(e)
	e.player.state = "uprooting"
	wait(0.15)
	e.player.state = "default"
end

--------------------------------------------------------------------------------

return system
