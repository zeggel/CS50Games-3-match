local lu = require 'lib/luaunit'

local function mapToTable(map)
    local result = {}
    for mapRow in string.gmatch(map, '[^\n]+') do
        local row = {}
        for rawElement in string.gmatch(mapRow, '[^%s]+') do
            local element = rawElement:gsub('%s+', '')
            table.insert(row, element)
        end
        table.insert(result, row)
    end
    return result
end

local function valuesToTiles(values)
    local tiles = {}
    for y, row in pairs(values) do
        local tilesRow = {}
        for x, val in pairs(row) do
            local shiny = false
            if val:find('*') ~= nil then
                shiny = true
            end
            local color = tonumber(val:gsub('*', ''), 10)
            local tile = Tile(x, y, color, 1)
            tile.shiny = shiny
            table.insert(tilesRow, tile)
        end
        table.insert(tiles, tilesRow)
    end
    return tiles
end

local function createBoard(map)
    local board = Board(0, 0, 1)
    board.tiles = valuesToTiles(mapToTable(map))
    return board
end


TestBoard = {}

function TestBoard:test_calculateMatches_noMatches()
    local map = [[
        1 2 3 4 5 6 7 8
        2 3 4 5 6 7 8 1
        3 4 5 6 7 8 1 2
        4 5 6 7 8 1 2 3
        5 6 7 8 1 2 3 4
        6 7 8 1 2 3 4 5
        7 8 1 2 3 4 5 6
        8 1 2 3 4 5 6 7
    ]]
    local board = createBoard(map)

    local result = board:calculateMatches()

    lu.assertEquals(result, false)
end

function TestBoard:test_calculateMatches_simpleHorizontalMatches()
    local map = [[
        1 1 1 4 5 7 7 8
        2 3 4 4 4 7 8 1
        3 4 5 6 5 5 5 5
        4 5 6 7 8 1 2 3
        5 6 7 8 1 2 3 4
        6 7 8 1 2 3 4 5
        7 8 1 2 3 4 5 6
        8 1 2 3 4 5 6 7
    ]]
    local board = createBoard(map)
    
    local result = board:calculateMatches()

    local expected = {{
        Tile(3, 1, 1, 1),
        Tile(2, 1, 1, 1),
        Tile(1, 1, 1, 1)
    },{
        Tile(5, 2, 4, 1),
        Tile(4, 2, 4, 1),
        Tile(3, 2, 4, 1)
    },{
        Tile(8, 3, 5, 1),
        Tile(7, 3, 5, 1),
        Tile(6, 3, 5, 1),
        Tile(5, 3, 5, 1),
    }}
    lu.assertEquals(result, expected)
end

-- TODO case with 2 matches with shiny in one row
