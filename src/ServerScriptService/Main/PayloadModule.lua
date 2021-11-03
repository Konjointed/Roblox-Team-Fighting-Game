local PayloadModule = {}

--| Services |--
local SSS = game:GetService("ServerScriptService")

--| Modules |--
local PayloadClass = require(SSS:WaitForChild("Classes").PayloadClass)

--| Variables |--
PayloadModule.Payload2 = PayloadClass.new(workspace:WaitForChild("Payload2"))
PayloadModule.Payload = PayloadClass.new(workspace:WaitForChild("Payload"))

return PayloadModule