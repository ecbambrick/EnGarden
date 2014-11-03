local canPlant, move, jump, shortenJump, setFuse
local createPlantFromSeed, createTreePlatform, destroyPlant

----------------------------------------------------------------- MAIN FUNCTION

-- manage the player's state and actions, such as jumping, moving and planting
-- plant state is also managed here. It should be in its own system, but isn't
-- due to time constraints
local function update(dt)
    for i,e in ipairs(Entities("player", "input", "velocity")) do
        local input1 = e.input.previous
        local input2 = e.input.list
        
        -- movement
        if table.contains(input2, "left")  then move(e, -1, dt) end
        if table.contains(input2, "right") then move(e, 1, dt) end
        if table.contains(input2, "jump")  then jump(e) end
        
        -- stop jump short if jump key is released
        if table.contains(input1, "jump")
        and not table.contains(input2, "jump") then
            shortenJump(e)
        end
        
        -- modify sprite based on state
        if e.player.state == "dead"    then e.sprite.image = Assets.player_jump
        elseif not e.physical.grounded then e.sprite.image = Assets.player_jump
        elseif e.velocity.x ~= 0       then e.sprite.image = Assets.player_run
        else                                e.sprite.image = Assets.player_stand
        end
        
        -- planting seeds
        if e.player.state == "carry" and e.physical.grounded 
        and table.contains(input2, "down") and canPlant(e) then
        
            -- prevent instantly uprooting the next frame if you're 
            -- holding "down"
            local recover = coroutine.create(setPlantingState)
            coroutine.resume(recover, e)
            
            -- generate plant from seed
            local plant, seedType = createPlantFromSeed(e.seedholder.seed, e)
            
            if seedType == "flower" then
                love.audio.stop(Assets.coin)
                love.audio.play(Assets.coin)
                SCORE = SCORE + 1
            
            elseif seedType == "tree" then
                createTreePlatform(plant)
                
            elseif seedType == "bomb" then
                local explode = coroutine.create(setFuse)
                coroutine.resume(explode, plant)
            end
            
        end
    end
end

------------------------------------------------------- PLAYER ACTION FUNCTIONS

-- temporarily disallow planting
function setPlantingState(e)
    e.player.state = "planting"
    wait(0.15)
    e.player.state = "default"
end

-- move left or right
function move(e, dir, dt)
    e.velocity.x = e.velocity.x + dir * 500 * dt
    e.sprite.sx = dir
    if dir < 0 then
        e.sprite.ox = e.position.width
    else
        e.sprite.ox = 0
    end
end

-- jump
function jump(e)
    if e.physical.grounded and e.input.jumped == false then
        love.audio.play(Assets.jump)
        e.input.jumped = true
        e.velocity.y = -200
    end
end

-- shorten jump to allow variable-size jumps depending on how long
-- you hold down the jump button
function shortenJump(e)
    e.input.jumped = false
    if  e.velocity.y < -50 then
        e.velocity.y = -50
    end
end

-- determine if the player can plant a seed by seeing if he or she
-- is not standing on an edge
-- this should be in the collision system, but isn't due to time constrains
function canPlant(e)
    local pos = math.round(e.position.x/TILE_SIZE)*TILE_SIZE+1
    local b, a = {}, {
            x1 = e.position.x,
            y1 = e.position.y,
            x2 = e.position.x + e.position.width,
            y2 = e.position.y + e.position.height,
    }
    for j,object in ipairs(Entities("collidable", "position")) do
        b.x1 = object.position.x
        b.x2 = object.position.x + object.position.width
        b.y1 = object.position.y
        b.y2 = object.position.y + object.position.height
        if math.within(pos, b.x1, b.x2) and a.y2 == b.y1 then
            return true
        end
    end
    return false
end

-------------------------------------------------------- PLANT ACTION FUNCTIONS

-- turns the seed entity into a plant entity of the same type
function createPlantFromSeed(seed, player)
    local seedType = seed.seed.type
    if seedType == "tree" then
        seed.sprite = { image = Assets.tree }
        seed.plant = { type = "tree" }
        seed.position.x = math.round(player.position.x/TILE_SIZE)*TILE_SIZE-7
    elseif seedType == "flower" then
        seed.sprite = { image = Assets.flower_alive }
        seed.plant = { type = "flower" }
        seed.position.x = math.round(player.position.x/TILE_SIZE)*TILE_SIZE
    elseif seedType == "sleep" then
        seed.sprite = { image = Assets.flower_sleep }
        seed.plant = { type = "sleep" }
        seed.position.x = math.round(player.position.x/TILE_SIZE)*TILE_SIZE - 4
    elseif seedType == "bomb" then
        seed.sprite = { image = Assets.flower_bomb }
        seed.position.x = math.round(player.position.x/TILE_SIZE)*TILE_SIZE - 4
        seed.plant = { type = "bomb" }
    end
    seed.collidable  = { solid = false, active=true }
    seed.position.z = 2
    seed.position.width = seed.sprite.image:getWidth()
    seed.position.height = seed.sprite.image:getHeight()
    seed.position.y = player.position.y + player.position.height - seed.position.height
    seed.seed = nil
    seed.velocity = nil
    return seed, seedType
end

-- create a one-way platform so the player can jump on trees
function createTreePlatform(tree)
    platform = Entities.newSolid(
                            tree.position.x + 4, 
                            tree.position.y + 4, 
                            tree.position.width - 8, 
                            1, 
                            "oneway")
    tree.platform = platform
end

-- set a bomb flower to explode after a set time
function setFuse(e)
    wait(0.8)
    e.sprite.image = Assets.flower_bomb2
    wait(0.8)
    e.sprite.image = Assets.flower_bomb3
    wait(0.8)
    e.position.x = e.position.x - 6
    e.sprite.image = Assets.explosion
    e.explosion = {}
    e.collidable = { active = false, solid = false }
    e.position.width = 24
    e.position.height = 24
    wait(0.2)
    destroyPlant(e)
end

-- destroys a plant and creates a seed
function destroyPlant(plant)
    local seedX = plant.position.x + plant.position.width/2 - 2
    local seedY = plant.position.y
    local seedT = plant.plant.type
    
    -- remove plant
    table.removevalue(Entities, plant)
    table.clear(plant)
    
    -- create new seed
    local seed = Entities.newSeed(seedX, seedY, seedT)
    seed.velocity.y = -150
end

--------------------------------------------------------------------------------

return update
