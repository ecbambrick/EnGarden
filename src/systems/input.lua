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
