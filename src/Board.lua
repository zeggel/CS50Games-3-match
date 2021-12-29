--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

local availableColors = {1, 7, 11, 17, 4, 8, 12, 16}

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.level = level
    self.matches = {}

    self:initializeTiles()
end

function Board:createTile(x, y)

    local function isShiny()
        return math.random(100) < 10
    end

    local function getRandomColor()
        return availableColors[math.random(#availableColors)]
    end

    local newTile = Tile(x, y, getRandomColor(), math.random(math.min(self.level, 6)))
    newTile.shiny = isShiny()

    return newTile
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], self:createTile(tileX, tileY))
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles()
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    ---Find matches in rows
    ---@param tiles table Tiles of the Board to find
    ---@return table
    local function findMatches(tiles)
        local matches = {}

        -- how many of the same color blocks in a row we've found
        local matchNum = 1

        local hasShinyTile = false

        -- horizontal matches first
        for y = 1, 8 do
            local colorToMatch = tiles[y][1].color

            matchNum = 1
            hasShinyTile = tiles[y][1].shiny
            
            -- every horizontal tile
            for x = 2, 8 do
                
                -- if this is the same color as the one we're trying to match...
                if tiles[y][x].color == colorToMatch then
                    matchNum = matchNum + 1
                    hasShinyTile = hasShinyTile or tiles[y][x].shiny
                else
                    
                    -- set this as the new color we want to watch for
                    colorToMatch = tiles[y][x].color

                    -- if we have a match of 3 or more up to now, add it to our matches table
                    if matchNum >= 3 then
                        local match = {}

                        if hasShinyTile then
                            -- with shiny tile gets all row as match
                            for x2 = 1, 8 do
                                table.insert(match, tiles[y][x2])
                            end
                        else
                            -- go backwards from here by matchNum
                            for x2 = x - 1, x - matchNum, -1 do
                                
                                -- add each tile to the match that's in that match
                                table.insert(match, tiles[y][x2])
                            end
                        end

                        -- add this match to our total matches table
                        table.insert(matches, match)
                        if hasShinyTile then
                            matchNum = 1
                            hasShinyTile = false
                            break
                        end
                    end

                    matchNum = 1
                    hasShinyTile = false

                    -- don't need to check last two if they won't be in a match
                    if x >= 7 then
                        break
                    end
                end
            end

            -- account for the last row ending with a match
            if matchNum >= 3 then
                local match = {}
                
                if hasShinyTile then
                    -- with shiny tile gets all row as match
                    for x = 1, 8 do
                        table.insert(match, tiles[y][x])
                    end
                else
                    -- go backwards from end of last row by matchNum
                    for x = 8, 8 - matchNum + 1, -1 do
                        table.insert(match, tiles[y][x])
                    end
                end

                table.insert(matches, match)
            end
        end

        return matches
    end

    ---Create new table with columns as rows
    ---@param tiles table
    ---@return table
    local function transponeTiles(tiles)
        local transponed = {}
        for x = 1, 8 do
            local row = {}
            for y = 1, 8 do
                table.insert(row, tiles[y][x])
            end
            table.insert(transponed, row)
        end
        return transponed
    end

    ---Create new table with elements of arguments tables
    ---@param one table
    ---@param other table
    ---@return table
    local function concatTiles(one, other)
        local result = {}
        for _, row in pairs(one) do
            table.insert(result, row)
        end
        for _, row in pairs(other) do
            table.insert(result, row)
        end
        return result
    end

    local rowMatches = findMatches(self.tiles)
    local columnMatches = findMatches(transponeTiles(self.tiles))

    -- store matches for later reference
    self.matches = concatTiles(rowMatches, columnMatches)

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = self:createTile(x, y)
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:swapTiles(fromX, fromY, toX, toY)
    local from = self.tiles[fromY][fromX]
    local to = self.tiles[toY][toX]

    from.gridX = toX
    from.gridY = toY
    to.gridX = fromX
    to.gridY = fromY

    self.tiles[fromY][fromX] = to
    self.tiles[toY][toX] = from

    return {
        [from] = {x = to.x, y = to.y},
        [to] = {x = from.x, y = from.y}
    }
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end