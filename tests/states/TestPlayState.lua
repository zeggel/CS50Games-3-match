local lu = require 'lib/luaunit'

TestPlayState = {}

function TestPlayState:testCalculateMatchScore_simpleTiles()
    local simpleVarietyTile = Tile(1, 1, 1, 1)
    local match = {simpleVarietyTile, simpleVarietyTile, simpleVarietyTile}

    local result = PlayState.calculateMatchScore(match)

    lu.assertEquals(result, 150)
end

function TestPlayState:testCalculateMatchScore_differentVarietyTiles()
    local match = {Tile(1, 1, 1, 1), Tile(1, 1, 1, 2), Tile(1, 1, 1, 3), Tile(1, 1, 1, 4), Tile(1, 1, 1, 5), Tile(1, 1, 1, 6)}

    local result = PlayState.calculateMatchScore(match)

    local expected = 300 + 0 + 5 + 10 + 15 + 20 + 25
    lu.assertEquals(result, expected)
end

function TestPlayState:testCalculateMatchScore_sameVariety2()
    local match = {Tile(1, 1, 1, 2), Tile(1, 1, 1, 2), Tile(1, 1, 1, 2)}

    local result = PlayState.calculateMatchScore(match)

    lu.assertEquals(result, 150 + 150)
end

function TestPlayState:testCalculateMatchScore_sameVariety3()
    local match = {Tile(1, 1, 1, 3), Tile(1, 1, 1, 3), Tile(1, 1, 1, 3)}

    local result = PlayState.calculateMatchScore(match)

    lu.assertEquals(result, 150 + 300)
end