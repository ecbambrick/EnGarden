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

TILE_SIZE = 8
WINDOW_SCALE = 6
WINDOW_HEIGHT = love.graphics.getHeight() / WINDOW_SCALE
WINDOW_WIDTH = love.graphics.getWidth() / WINDOW_SCALE
LAST_SCORE = 0
SCORE = 0

----------------------------------------------------------- GAME INITIALIZATION

function love.load()

    -- intialize external libraries
    Entities            = require "entities"
    AdvancedTiledLoader = require "lib.AdvTiledLoader.loader"
                          require "lib.utility"
                          require "lib.coroutines"
    
    -- initialize graphical settings
    love.graphics.setDefaultImageFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")
    
    -- external audio/visual resources
	-- these should be loaded/unloaded from memory as necessary but aren't
	-- due to time constraints
    Assets = {
        -- images
        cloud1          = love.graphics.newImage("res/cloud01.gif"),
        cloud2          = love.graphics.newImage("res/cloud02.gif"),
        player_stand    = love.graphics.newImage("res/player_stand.gif"),
        player_run      = love.graphics.newImage("res/player_run.gif"),
        player_jump     = love.graphics.newImage("res/player_jump.gif"),
        tree            = love.graphics.newImage("res/plant01.gif"),
        flower_dead     = love.graphics.newImage("res/plant03.gif"),
        flower_alive    = love.graphics.newImage("res/plant02.gif"),
        flower_sleep    = love.graphics.newImage("res/plant04.gif"),
        flower_bomb     = love.graphics.newImage("res/plant05.gif"),
        flower_bomb2    = love.graphics.newImage("res/plant05b.gif"),
        flower_bomb3    = love.graphics.newImage("res/plant05c.gif"),
        explosion       = love.graphics.newImage("res/plant05d.gif"),
        seed1           = love.graphics.newImage("res/seed01.gif"),
        seed2           = love.graphics.newImage("res/seed02.gif"),
        seed3           = love.graphics.newImage("res/seed03.gif"),
        seed4           = love.graphics.newImage("res/seed04.gif"),
        title           = love.graphics.newImage("res/title.gif"),
        stage1          = love.graphics.newImage("res/stage1.gif"),
        stage2          = love.graphics.newImage("res/stage2.gif"),
        stage3          = love.graphics.newImage("res/stage3.gif"),
        stage4          = love.graphics.newImage("res/stage4.gif"),
        ending          = love.graphics.newImage("res/ending.gif"),
        gameover        = love.graphics.newImage("res/game over.gif"),
        spike1          = love.graphics.newImage("res/spike.gif"),
        spike2          = love.graphics.newImage("res/spike2.gif"),
        enemy           = love.graphics.newImage("res/enemy.gif"),
        shooter         = love.graphics.newImage("res/shooter.gif"),
        breakable       = love.graphics.newImage("res/breakable.gif"),
        fly             = love.graphics.newImage("res/fly.gif"),
		instructions	= love.graphics.newImage("res/instructions.gif"),
        -- sounds
        music           = love.audio.newSource("res/music.mp3"),
        coin            = love.audio.newSource("res/coin.mp3"),
        jump            = love.audio.newSource("res/jump.mp3"),
        -- maps
        map1            = "res/title.tmx",
        map2            = "res/map2.tmx",
        map3            = "res/map3.tmx",
        map4            = "res/map4.tmx",
        map5            = "res/map5.tmx",
        -- fonts
        font            = love.graphics.newImageFont("res/font.png",
                                             " abcdefghijklmnopqrstuvwxyz" ..
                                             "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
                                             "123456789.,!?-+/():;%&`'*#=[]\"")
    }
    
    -- set font
    love.graphics.setFont(Assets.font)
    
    -- set music
    Assets.music:setLooping(true)
    Assets.music:setVolume(0.5)
    love.audio.play(Assets.music)
    
    -- initialize systems
    UpdateSystems = { 
        -- require "systems.start",
        require "systems.tiledmap",
        require "systems.input",
        require "systems.gamestate",
        require "systems.playerstate",
        require "systems.ai",
        require "systems.physics",
        require "systems.collision",
        require "systems.camera",
    }
    RenderSystems = {
        require "systems.draw",
    }
    
    -- initialize start screen entities
    local e = Entities.newTitle(WINDOW_WIDTH/2, WINDOW_HEIGHT/4, Assets.title)
    Entities.newTitle(WINDOW_WIDTH/2+8, WINDOW_HEIGHT-32, Assets.instructions)
	Entities.newPlayer(32,32)
    Entities.newMap(Assets.map1)
    Entities.newCamera()
    
end

------------------------------------------------------------------ UPDATE LOOPS

function love.update(dt)
    wakeUpWaitingThreads(dt)
    for i,system in ipairs(UpdateSystems) do system(dt) end
end

function love.draw()
    for i,system in ipairs(RenderSystems) do system() end
end
