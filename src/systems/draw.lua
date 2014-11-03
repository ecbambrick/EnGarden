local drawMap, drawSprite, drawRectangle

----------------------------------------------------------------- MAIN FUNCTION

-- handles all draw functionality and camera transformations
local function drawSystem()

    -- set camera
    local camera = Entities("camera")[1]
    if camera then
        setCamera(camera)
    end
    love.graphics.setBackgroundColor(105,233,233)
    
    -- draw clouds
    local sprites = Entities("position", "sprite")
    for i,e in ipairs(sprites) do
        if e.position.z == 0 then
            drawSprite(e)
        end
    end
    
    -- draw map
    for i,e in ipairs(Entities("map")) do
        drawMap(e, camera)
    end
    
    -- draw rectangles such as projectiles
    for i,e in ipairs(Entities("position", "rectangle")) do
        drawRectangle(e)
    end
    
    -- draw spites in order of z position
    table.sort(sprites, function(a,b) return a.position.z < b.position.z end)
    for i,e in ipairs(sprites) do
        if e.position.z > 0 then
            drawSprite(e)
        end
    end
    
    --unset camera translation
    if camera then
        love.graphics.pop()
    end
    
    -- draw score icon
    love.graphics.draw(Assets.flower_alive, 4, 4)
    
    -- unset camera scale
    if camera then
        love.graphics.pop()
    end
    
    -- draw score
    love.graphics.print(SCORE, 90, 19)
    
end

---------------------------------------------------------------- DRAW FUNCTIONS

function setCamera(e)
        love.graphics.push()
        love.graphics.scale(WINDOW_SCALE)
        love.graphics.push()
        love.graphics.scale(e.camera.scale)
        love.graphics.translate(-e.position.x, -e.position.y)
end

function drawMap(e, camera)
    if e.map.loaded then
        e.map.map:setDrawRange(
                        camera.position.x, 
                        camera.position.y, 
                        WINDOW_WIDTH, 
                        WINDOW_HEIGHT
        )
        e.map.map:draw()
    end
end

function drawSprite(e)
    love.graphics.draw(
                    e.sprite.image,
                    e.position.x, 
                    e.position.y, 
                    e.sprite.r, 
                    e.sprite.sx, 
                    e.sprite.sy, 
                    e.sprite.ox, 
                    e.sprite.oy
    )
end

function drawRectangle(e)
    local x,y = e.position.x, e.position.y
    local width,height = e.position.width, e.position.height
    love.graphics.setColor(e.rectangle.color)
    love.graphics.rectangle(e.rectangle.style, x, y, width, height)
    love.graphics.setColor(255,255,255,255)
end

--------------------------------------------------------------------------------

return drawSystem
