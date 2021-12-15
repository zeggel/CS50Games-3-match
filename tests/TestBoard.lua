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

function TestBoard:test_calculateMatches_twoMatchesInOneRow()
    local map = [[
        1 2 3 4 5 6 7 8
        2 3 4 5 6 7 8 1
        3 3 3 6 7 7 7 2
        4 5 6 7 8 1 2 3
        5 6 7 8 1 2 3 4
        6 7 8 1 2 3 4 5
        7 8 1 2 3 4 5 6
        8 1 2 3 4 5 6 7
    ]]
    local board = createBoard(map)
    
    local result = board:calculateMatches()

    local expected = {{
        Tile(3, 3, 3, 1),
        Tile(2, 3, 3, 1),
        Tile(1, 3, 3, 1)
    },{
        Tile(7, 3, 7, 1),
        Tile(6, 3, 7, 1),
        Tile(5, 3, 7, 1)
    }}
    lu.assertEquals(result, expected)
end

function TestBoard:test_calculateMatches_oneRowWithOneShinyMatch()
    local map = [[
        1 2 3 4 5 6 7 8
        2 3 4 5 6 7 8 1
        3 4 5 6 7 8 1 2
        4 5 6 7 7* 7 2 3
        5 6 7 8 1 2 3 4
        6 7 8 1 2 3 4 5
        7 8 1 2 3 4 5 6
        8 1 2 3 4 5 6 7
    ]]
    local board = createBoard(map)

    local result = board:calculateMatches()

    local expected = {{
        Tile(1, 4, 4, 1),
        Tile(2, 4, 5, 1),
        Tile(3, 4, 6, 1),
        Tile(4, 4, 7, 1),
        Tile(5, 4, 7, 1, true),
        Tile(6, 4, 7, 1),
        Tile(7, 4, 2, 1),
        Tile(8, 4, 3, 1),
    }}
    lu.assertEquals(result, expected)
end

function TestBoard:test_calculateMatches_oneRowWithTwoMatchesBothWithShiny()
    local map = [[
        1 2 3 4 5 6 7 8
        2 3 4 5 6 7 8 1
        3 3* 3 6 7 2 2 2*
        4 5 6 7 8 1 2 3
        5 6 7 8 1 2 3 4
        6 7 8 1 2 3 4 5
        7 8 1 2 3 4 5 6
        8 1 2 3 4 5 6 7
    ]]
    local board = createBoard(map)

    local result = board:calculateMatches()

    local expected = {{
        Tile(1, 3, 3, 1),
        Tile(2, 3, 3, 1, true),
        Tile(3, 3, 3, 1),
        Tile(4, 3, 6, 1),
        Tile(5, 3, 7, 1),
        Tile(6, 3, 2, 1),
        Tile(7, 3, 2, 1),
        Tile(8, 3, 2, 1, true),
    }}
    lu.assertEquals(result, expected)
end
