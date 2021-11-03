--Private
local secretNumber = 100

local Object = {}
Object.__index = Object

function Object.new(name)
    local newObject = {
        Name = name or "Object",
        _secret = 27
    }
    return setmetatable(newObject,Object)
end

function Object:GetSecret()
    return self._secret * secretNumber
end

return Object