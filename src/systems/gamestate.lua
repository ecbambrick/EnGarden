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

local loadNextMap, reloadMap

----------------------------------------------------------------- MAIN FUNCTION

-- handles the state of the game, mostly changing between gameover screens,
-- title screens, and determining which map to load when completing a stage
local function update(dt)
    local player = Entities("player")[1]
    local map = Entities("map")[1]
    
    if player and map ~= nil then
        local mapPath = map.map.path
    
        -- player moves beyond the right-hand boundary of the map
        if player.position.x > map.map.map.width*TILE_SIZE then
            LAST_SCORE = SCORE
            loadNextMap(mapPath)
        
        -- player moves below the map (ie - falls), game over, reload the map
        elseif player.position.y > map.map.map.height*TILE_SIZE then
            SCORE = LAST_SCORE
            reloadMap(mapPath)
        end
    end
end

------------------------------------------------------------------- MAP LOADING

-- clear and reload the current map
function reloadMap(map)

    -- clear out current entities and create the game over screen
    for i,e in ipairs(Entities) do
        Entities[i] = nil
        table.clear(e)
    end
    Entities.newTitle(WINDOW_WIDTH/2, WINDOW_HEIGHT/2, Assets.gameover)
    Entities.newCamera()
    
    -- reload the map after 2 seconds
    local resume = coroutine.create(function()
        wait(2)
        table.remove(Entities, 1)
        Entities.newMap(map)
    end)
    coroutine.resume(resume)
    
end

-- clear the current map, determine which map to load next, and then load it
function loadNextMap(currentMap)
    local nextMap
    
    -- clear out the current entities
    for i,e in ipairs(Entities) do
        Entities[i] = nil
        table.clear(e)
    end
    
    -- add new title depending on which map to load
    if currentMap == Assets.map1 then
        Entities.newTitle(WINDOW_WIDTH/2, WINDOW_HEIGHT/2, Assets.stage1)
        nextMap = Assets.map2
		
    elseif currentMap == Assets.map2 then
        Entities.newTitle(WINDOW_WIDTH/2, WINDOW_HEIGHT/2, Assets.stage2)
        nextMap = Assets.map3
        
    elseif currentMap == Assets.map3 then
        Entities.newTitle(WINDOW_WIDTH/2, WINDOW_HEIGHT/2, Assets.stage3)
        nextMap = Assets.map4
    
    elseif currentMap == Assets.map4 then
        Entities.newTitle(WINDOW_WIDTH/2, WINDOW_HEIGHT/4, Assets.ending)
        nextMap = Assets.map5
    end
    Entities.newCamera()
    
    -- load next map in co-routine after a certain amount of time
    local resume = coroutine.create(function()
        if nextMap ~= Assets.map5 then
            wait(2)
            table.remove(Entities, 1)
        end
        Entities.newMap(nextMap)
    end)
    coroutine.resume(resume)
    
end

--------------------------------------------------------------------------------

return update
