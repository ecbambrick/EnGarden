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

local setPositionX, setPositionY
local applyFriction, applyGravity, applyLoopX, applyLoopY
local detectCollision, resolveCollision, applyCollisionsX, applyCollisionsY
local gravity, frict = 600, 300

----------------------------------------------------------------- MAIN FUNCTION

-- This system calculates push (movement) collisions seperately in both the
-- x and y directions. Each entity will check for the closest solid object
-- in its current path and stop right before it if it's close enough.
-- note: this system only resolves movement
local function system(dt)

    -- sort entities to ensure faster objects collide smoothly with slower 
    -- objects moving in the same direction
    local entities = Entities("position", "velocity")
    table.sort(entities, function(a,b) return a.velocity.x > b.velocity.x end)
    
    -- apply physical forces seperately in each dimension
    for i,e in ipairs(entities) do
    
        -- X-Axis Movement
        if e.physical then
            applyFriction(dt, e)
        end
        if e.collidable then
            applyCollisionsX(dt, e)
        end
        if e.loop then
            applyLoopX(dt, e)
        end
        updatePositionX(dt, e)
        
        -- Y-Axis Movement
        if e.physical then
            e.physical.grounded = false
            applyGravity(dt, e)
        end
        if e.collidable then
            applyCollisionsY(dt, e)
        end
        if e.loop then
            applyLoopY(dt, e)
        end
        updatePositionY(dt, e)
        
    end
end

---------------------------------------------------------------------- POSITION

-- update x position based on velocity
function updatePositionX(dt, entity)
    local velocity = entity.velocity
    local position = entity.position
    velocity.x = math.clamp(velocity.x, velocity.max.x)
    position.x = position.x + velocity.x * dt
end

-- update y position based on velocity
function updatePositionY(dt, entity)
    local velocity = entity.velocity
    local position = entity.position
    velocity.y = math.clamp(velocity.y, velocity.max.y)
    position.y = position.y + velocity.y * dt
end

-------------------------------------------------------------------------- LOOP

-- if an entity moves beyond a certain boundary, transport it to its opposite
-- boundary, simulating a loop
function applyLoopX(dt, e)
    if e.loop.x1 and e.loop.x2 then
        if e.position.x + e.position.width - 1 <= e.loop.x1 then
            e.position.x = e.loop.x2 - 1
        elseif e.position.x + 1 >= e.loop.x2 then 
            e.position.x = e.loop.x1 - e.position.width + 1
        end
    end
end

function applyLoopY(dt, e)
    if e.loop.y1 and e.loop.y2 then
        if e.position.y + e.position.height <= e.loop.y1 then
            e.position.y = e.loop.y2
        elseif e.position.y >= e.loop.y2 then 
            e.position.y = e.loop.y1 - e.position.height
        end
    end
end

---------------------------------------------------------------------- PHYSICAL

-- apply friction or completely halt movement if changing direction
function applyFriction(dt, entity)
    local velocity = entity.velocity
    local sign = math.sign(velocity.x)
    velocity.x = velocity.x - frict * math.sign(velocity.x) * dt
    if math.sign(velocity.x) ~= sign then
        velocity.x = 0
    end
end

-- weeeeeeeeeee
function applyGravity(dt, entity)
    local velocity = entity.velocity
    velocity.y = velocity.y + gravity * dt
end

-------------------------------------------------------------------- COLLISIONS

-- determine movement direction and check for collisions in that direction
function applyCollisionsX(dt, entity)
    local dir, object, collision
    if        entity.velocity.x >  0 then dir = "right"
    elseif    entity.velocity.x <  0 then dir = "left"
    elseif  entity.velocity.x == 0 then dir = "none" end
    object, collision = detectCollision(dt, entity, dir)
    if collision then
        resolveCollision(dt, entity, object, dir)
    end
end

function applyCollisionsY(dt, entity)
    local dir, object, collision
    if        entity.velocity.y >  0 then dir = "down"
    elseif    entity.velocity.y <  0 then dir = "up"
    elseif  entity.velocity.y == 0 then dir = "none" end
    object, collision = detectCollision(dt, entity, dir)
    if collision then
        resolveCollision(dt, entity, object, dir)
    end
end

-- Check against each other object until the closest one in the direction of
-- movement is found. If the two entities will collide next frame, mark it as
-- a collision
function detectCollision(dt, entity, direction)
    local minDist, actualDist
    local collision = false
    local closestObject
    local b, a = {}, {
        x1   = entity.position.x,
        x2   = entity.position.x + entity.position.width,
        y1   = entity.position.y,
        y2   = entity.position.y + entity.position.height,
        velX = entity.velocity.x * dt,
        velY = entity.velocity.y * dt,
    }
    
    -- check if the entities will collide within the next frame
    for i,object in ipairs(Entities("position", "collidable")) do
        if object ~= entity then
            local newDist
            b.x1 = object.position.x
            b.x2 = object.position.x + object.position.width
            b.y1 = object.position.y
            b.y2 = object.position.y + object.position.height
            
            --[[
                find ALL entities you will collide into next frame
                find the closest solid entity and stop before it
                ignore any entity farther than where you stop
                register everything left as a collision
            --]]
            
            if direction == "none"
            and a.x1 < b.x2 and a.x2 > b.x1
            and a.y1 < b.y2 and a.y2 > b.y1 then
                newDist = math.abs(a.y2 - b.y1)
                actualDist = 0
            
            elseif direction == "down"
            and a.x1 < b.x2 and a.x2 > b.x1
            and math.within(b.y1, a.y2, a.y2 + a.velY) then
                newDist = math.abs(a.y2 - b.y1)
                actualDist = math.abs(a.velY)
                
            elseif direction == "up"
            and a.x1 < b.x2 and a.x2 > b.x1
            and math.within(b.y2, a.y1 + a.velY, a.y1) then
                newDist = math.abs(a.y1 - b.y2)
                actualDist = math.abs(a.velY)
                
            elseif direction == "right"
            and a.y1 < b.y2 and a.y2 > b.y1
            and math.within(b.x1, a.x2, a.x2 + a.velX) then
                newDist = math.abs(a.x2 - b.x1)
                actualDist = math.abs(a.velX)

            elseif direction == "left"
            and a.y1 < b.y2 and a.y2 > b.y1 
            and math.within(b.x2, a.x1 + a.velX, a.x1) then
                newDist = math.abs(a.x1 - b.x2)
                actualDist = math.abs(a.velX)
            end
            
            -- check if this object is the closest
            if newDist and ( object.collidable.solid
            or object.collidable.oneway )
            and ( not minDist or newDist < minDist ) then
                minDist = newDist
                closestObject = object
            end
            
        end
    end
    
    -- check if this object actually collided
    if actualDist and minDist and actualDist >= minDist then
        collision = true
    end
    
    return closestObject, collision
end

-- resolve movement from a collision
function resolveCollision(dt, active, passive, direction)
    local a, b = {
        x1 = active.position.x,
        x2 = active.position.x + active.position.width,
        y1 = active.position.y,
        y2 = active.position.y + active.position.height,
    }, {
        x1 = passive.position.x,
        x2 = passive.position.x + passive.position.width,
        y1 = passive.position.y,
        y2 = passive.position.y + passive.position.height,
    }
    
    -- one way collision
    if active.collidable.active and passive.collidable.oneway then
        if direction == "down" then
            active.velocity.y = math.abs(a.y2 - b.y1)/dt
            updatePositionY(dt, active)
            active.velocity.y = 0
            if active.physical then
                active.physical.grounded = true
            end
        end
    end
    
    -- solid objects collide
    if active.collidable.active and passive.collidable.solid then
        if direction == "down" then
            active.velocity.y = math.abs(a.y2 - b.y1)/dt
            updatePositionY(dt, active)
            active.velocity.y = 0
            if active.physical then
                active.physical.grounded = true
            end
            
        elseif direction == "up" then
            active.velocity.y = -math.abs(a.y1 - b.y2)/dt
            updatePositionY(dt, active)
            active.velocity.y = 0
            
        elseif direction == "left" then
            active.velocity.x = -math.abs(a.x1 - b.x2)/dt
            updatePositionX(dt, active)
            active.velocity.x = 0
            
        elseif direction == "right" then
            active.velocity.x = math.abs(a.x2 - b.x1)/dt
            updatePositionX(dt, active)
            active.velocity.x = 0
        end
    end
    
end

--------------------------------------------------------------------------------

return system
