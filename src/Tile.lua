--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

local paletteColors = {
    -- 1, 7, 11, 17, 4, 8, 12, 16
    [1] = {
        ['r'] = 217,
        ['g'] = 160,
        ['b'] = 102
    },
    [7] = {
        ['r'] = 75,
        ['g'] = 105,
        ['b'] = 47
    },
    [11] = {
        ['r'] = 91,
        ['g'] = 110,
        ['b'] = 225
    },
    [17] = {
        ['r'] = 118,
        ['g'] = 66,
        ['b'] = 138
    },
    [4] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    [8] = {
        ['r'] = 107,
        ['g'] = 57,
        ['b'] = 49
    },
    [12] = {
        ['r'] = 223,
        ['g'] = 113,
        ['b'] = 38
    },
    [16] = {
        ['r'] = 105,
        ['g'] = 106,
        ['b'] = 106
    }
}

function Tile:init(x, y, color, variety, shiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety
    self.shiny = shiny or false

    self.score = 50 + (self.variety - 1) * 5
    self.extraScore = 50 + (self.variety - 1) * 50

    self.isVanishing = false

    self:initParticleSystem()
end

function Tile:initParticleSystem()
    -- particle system belonging to the brick, emitted on hit
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    -- various behavior-determining functions for the particle system
    -- https://love2d.org/wiki/ParticleSystem

    -- lasts between 0.5-1 seconds seconds
    self.psystem:setParticleLifetime(0.5, 1)

    -- give it an acceleration of anywhere between X1,Y1 and X2,Y2 (0, 0) and (80, 80) here
    -- gives generally downward 
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    -- spread of particles; normal looks more natural than uniform
    self.psystem:setEmissionArea('normal', 10, 10)
end

function Tile:copy(x, y, color, variety, shiny)
    return Tile(x or self.gridX, y or self.gridY, color or self.color, variety or self.variety, shiny or self.shiny)
end

function Tile:vanish()
    self.isVanishing = true
    self:emit()
end

function Tile:emit()
    -- set the particle system to interpolate between two colors; in this case, we give
    -- it our self.color but with varying alpha; brighter for higher tiers, fading to 0
    -- over the particle's lifetime (the second color)
    self.psystem:setColors(
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        55 * (self.variety + 1) / 255,
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        0
    )
    self.psystem:emit(64)
end

function Tile:update(dt)
    self.psystem:update(dt)
    if self.psystem:getCount() == 0 then
        self.isVanishing = false
    end
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.shiny then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1, 215/255, 0, 1)
        love.graphics.rectangle('line', self.x + (VIRTUAL_WIDTH - 272),
        self.y + 16, 32, 32, 4)
    end
end

function Tile:renderParticles(x, y)
    love.graphics.draw(self.psystem, self.x + x + 16, self.y + y + 16)
end