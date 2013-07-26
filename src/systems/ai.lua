--[[----------------------------------------------------------------------------

    Copyright (C) 2013 by Cole Bambrick
    cole.bambrick@gmail.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.

--]]----------------------------------------------------------------------------

local isOnEdge, follow, turn, shootProjectile, updateSpawner, freeSpawner
local move, moveWave, kill, isOffscreen

----------------------------------------------------------------- MAIN FUNCTION

-- runs the AI for each type of enemy, as well as seeds
local function update(dt)
    local camera = Entities("camera")[1]
    local player = Entities("player")[1]
    local map = Entities("map")[1]
    
    -- projectile AI
    for i,e in ipairs(Entities("shot")) do
        if isOffscreen(e, camera) then
            kill(e)
        else
            move(e, dt)
        end
    end
    
    -- Projectile launcher AI
    -- if visible, create a new projectile and then wait 3 seconds
    for i,e in ipairs(Entities("shootAI")) do
        if not isOffscreen(e, camera) and e.shootAI.shoot then
            local shoot = coroutine.create(shootProjectile)
            coroutine.resume(shoot, e)
        end
    end
    
    -- Fly spawning AI
    for i,e in ipairs(Entities("spawner")) do
        updateSpawner(e, dt)
    end
    
    -- flying enemy AI
    for i,e in ipairs(Entities("fly")) do
        if e.fly.state ~= "dead" then
            moveWave(e, dt)
        end
        -- if off screen
        if e.position.x + e.position.width < camera.position.x
        or e.position.y > WINDOW_HEIGHT + 100 then
            freeSpawner(e.fly.owner.spawner)
            kill(e)
        end
    end
    
    -- seed AI
    for i,e in ipairs(Entities("seed")) do
        local owner = e.seed.owner
        if owner then
            follow(e, owner)
        end
    end

    -- AI shared between all moving, physics-based enemies
    for i,e in ipairs(Entities("ai", "velocity", "physical")) do
    
        -- turn around when you hit a wall
        if e.velocity.x == 0 and e.ai.state ~= "dead" then
            turn(e)
        end
        
        -- turn around if you are about to fall off a cliff
        if e.ai.state == "left" then
            if isOnAnyEdge(e, "left") then
                e.ai.state = "right"
                e.velocity.x = 500 * dt
            else
                e.velocity.x = e.velocity.x - 500 * dt
            end
        elseif e.ai.state == "right" then
            if isOnAnyEdge(e, "right") then
                e.ai.state = "left"
                e.velocity.x = -500 * dt
            else
                e.velocity.x = e.velocity.x + 500 * dt
            end
        end
        
        -- delete if beyond the map boundaries
        if e.position.y > map.map.map.height*TILE_SIZE then
            kill(e)
        end
        
    end
end

-------------------------------------------------------------- ACTION FUNCTIONS

-- move left or right depending on state
function move(e, dt)
    if e.shot.dir == "left" then
        e.velocity.x = e.velocity.x - 500 * dt
    else
        e.velocity.x = e.velocity.x + 500 * dt
    end
end

-- move in a wave pattern to the left
function moveWave(e, dt)
    e.velocity.x = e.velocity.x - 500 * dt
    e.sin.count = e.sin.count + dt
    e.position.y = math.sin(e.sin.count*4)*20 + e.offset.y
end

-- destroy entity
function kill(e)
    table.removevalue(Entities, e)
    table.clear(e)
end

-- create a projectile object and wait 3 seconds
function shootProjectile(e)
    e.shootAI.shoot = false
    Entities.newShot(e.position.x, e.position.y + 3, "left")
    wait(3)
    if e.ai.state ~= "dead" then
        e.shootAI.shoot = true
    end
end

-- update counter for spawning flies
function updateSpawner(e, dt)
    e.spawner.count = e.spawner.count + dt
end

-- free up a slot on the number of flies you can currently spawn
function freeSpawner(e)
    if e.current > 0 then 
        e.current = e.current - 1 
    end
end

-- follow another entity
function follow(e1, e2)
    e1.position.x = e2.position.x
    e1.position.y = e2.position.y - e2.position.height
end

-- turn around
function turn(e)
    if e.ai.state == "left" then 
        e.ai.state = "right"
    elseif e.ai.state == "right" then
        e.ai.state = "left"
    end
end

----------------------------------------------------------- COLLISION FUNCTIONS

-- check if an entity is on any edge of any platform/the ground
function isOnAnyEdge(e, dir)
    for j,object in ipairs(Entities("collidable", "position")) do
        if isOnEdge(e, object, dir) then
            return true
        end
    end
    return false
end

-- checks if an entity is ontop of another and on its edge
-- this code should be part of collision detection, but isn't due
-- to time constraints
function isOnEdge(e1, e2,  dir)
    local a, b = {}, {}
    a.x1 = e1.position.x
    a.x2 = e1.position.x + e1.position.width
    a.y1 = e1.position.y
    a.y2 = e1.position.y + e1.position.height
    b.x1 = e2.position.x
    b.x2 = e2.position.x + e2.position.width
    b.y1 = e2.position.y
    b.y2 = e2.position.y + e2.position.height
    if dir == "left" and a.x1 < b.x1 and a.x2 > b.x1 and a.y2 == b.y1 then
        return true
    elseif dir == "right" and a.x2 > b.x2 and a.x1 < b.x2 and a.y2 == b.y1 then
        return true
    else
        return false
    end
end

function isOffscreen(e, camera)
	if e.position.x + e.position.width < camera.position.x
	or e.position.x > camera.position.x + WINDOW_WIDTH then
		return true
	else
		return false
	end
end

--------------------------------------------------------------------------------

return update
