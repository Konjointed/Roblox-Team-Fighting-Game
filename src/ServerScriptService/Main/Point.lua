--| Services |--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TS = game:GetService("TweenService")
local RepStorage = game:GetService("ReplicatedStorage")

--| Modules |--
local Zone = require(SSS:WaitForChild("APIs").Zone)
local Server = require(SSS:WaitForChild("Main").Server)
local PayloadLogic = require(SSS:WaitForChild("Main").Payload)

--| Constants |--
local POINT = workspace:WaitForChild("Point")
local POINT_ZONE = Zone.new(POINT.Zone)

local Point = {}

--| Variables |--
local CaptureProgress = RepStorage.GameValues:WaitForChild("CaptureProgress")
local Max = 200
Point.Active = false

POINT_ZONE.playerEntered:Connect(function(Player)
	if Point.Active then
		Player.PlayerGui.ScreenGui.Frame.CaptureBackground.Visible = true
		while #POINT_ZONE:getPlayers() >= 1 and CaptureProgress.Value ~= Max do
			CaptureProgress.Value += 5
			print(CaptureProgress.Value.."/"..Max)
			wait(0.5)
		end

		if CaptureProgress.Value == Max then
			PayloadLogic.Active = true
		else
			while #POINT_ZONE:getPlayers() ~= 1 and CaptureProgress.Value ~= 0 do
				CaptureProgress.Value -= 5
				print(CaptureProgress.Value.."/"..Max)
				wait(0.5)
			end
			Player.PlayerGui.ScreenGui.Frame.CaptureBackground.Visible = false
		end
	else
		warn(Server.SERVER_NAME.."Point is not active yet")
	end
end)

POINT_ZONE.playerExited:Connect(function(Player)

end)


return Point
