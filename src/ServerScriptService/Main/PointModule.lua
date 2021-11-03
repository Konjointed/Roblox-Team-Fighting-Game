local PointModule = {}

--| Services |--
local SSS = game:GetService("ServerScriptService")

--| Modules |--
local PointClass = require(SSS:WaitForChild("Classes").PointClass)

--| Variables |--
PointModule.Point = PointClass.new(workspace:WaitForChild("Point"),true,10)

return PointModule