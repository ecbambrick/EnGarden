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

local delay, delayMax = 0, 0.1

----------------------------------------------------------------- MAIN FUNCTION

-- handle player input and system events such as quitting the game
return function(dt)
        
    -- ensure there's at least a 0.15 delay between each input
    if delay <= delayMax then
        delay = delay + dt
    else
        for i,e in ipairs(Entities("input", "velocity", "physical")) do
        
            -- save last input
            e.input.previous = table.copy(e.input.list)
            table.clear(e.input.list)
                
            -- movement input
            if e.player.state ~= "dead" then
                if love.keyboard.isDown("left") then
                    table.insert(e.input.list, "left")
                end
                if love.keyboard.isDown("right") then
                    table.insert(e.input.list, "right")
                end
                if love.keyboard.isDown("up") or love.keyboard.isDown("z") then
                    table.insert(e.input.list, "jump")
                end
                if love.keyboard.isDown("down") then
                    table.insert(e.input.list, "down")
                end
            end
            
        end
    end
    
    -- system input
    if love.keyboard.isDown("lalt") and love.keyboard.isDown("f4") then
        love.event.quit()
    end

--------------------------------------------------------------------------------
    
end
