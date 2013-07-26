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

-- have the camera track a target if a target exists
local function system()
    for i,e in ipairs(Entities("camera")) do
        local target = e.camera.target
        
        -- make sure target is valid
        if target and target.position then
            e.position.x = math.clamp(
                target.position.x - WINDOW_WIDTH/2,
                e.bounds.x1,
                e.bounds.x2 - WINDOW_WIDTH
            )
            e.position.y = math.clamp(
                target.position.y - WINDOW_HEIGHT/2 + 8,
                e.bounds.y1,
                e.bounds.y2 - WINDOW_HEIGHT
            )
        end
        
    end
end

--------------------------------------------------------------------------------

return system
