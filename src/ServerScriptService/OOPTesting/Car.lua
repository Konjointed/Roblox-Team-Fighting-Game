local Car = {}
Car.__index = Car

function Car.new(brand,color)
    local newCar = {
        Brand = brand or "EpicBrand",
        Color = color or "Blue",
        Speed = 0,
        Driving = false
    }
    return setmetatable(newCar,Car)
end

function Car:Drive()
    self.Driving = true
end

function Car:SetSpeed(value) 
    self.Speed = value
end

function Car:Stop()
    self:SetSpeed(0)
    self.Driving = false
end

function Car:GetColor()
    return self.Color
end

return Car