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
