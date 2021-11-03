local Fruit = {}
Fruit.__index = Fruit

function Fruit.new(fruit)
    return setmetatable({
        Type = fruit,
        Fresh = true
    }, Fruit)
end

function  Fruit:Rot()
    self.Fresh = false
end

return Fruit