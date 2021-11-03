local Fruit = require(game.ServerScriptService.OOPTesting.Fruit)

local Apple = setmetatable({}, Fruit)
Apple.__index = Apple

function Apple.new()
    local newApple = Fruit.new("Apple")
    return setmetatable(newApple,Apple)
end

return Fruit