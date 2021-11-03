--| Services |--
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
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
local AttackersInZone = 0
local DefendersInZone = 0

local function AmountInZone(Player,Number)
	if table.find(Server.Attackers,Player.Name) then
		AttackersInZone += Number
	elseif table.find(Server.Defenders,Player.Name) then
		DefendersInZone += Number
	end
end

local function EnableCaptureFrame(bool)
	for _,Player in pairs(Players:GetChildren()) do
		Player.PlayerGui.ScreenGui.Frame.CaptureBackground.Visible = bool
	end
end

local function Logic()
	if Point.Active then
		if AttackersInZone >= 1 and DefendersInZone == 0 then
			EnableCaptureFrame(true)
			while (AttackersInZone >= 1) and (DefendersInZone == 0) and (CaptureProgress.Value) ~= Max do
				CaptureProgress.Value += 5
				print(CaptureProgress.Value.."/"..Max)
				task.wait(0.5)
			end
		end

		if CaptureProgress.Value == Max then
			PayloadLogic.Active = true --Activate payload so it can be pushed
			EnableCaptureFrame(false) --Disable everyones capture gui
		else
			while CaptureProgress.Value ~= 0 do
				CaptureProgress.Value -= 5
				print(CaptureProgress.Value.."/"..Max)
				task.wait(0.5)
			end
			EnableCaptureFrame(false)
		end
	else
		warn(Server.SERVER_NAME.."Point is not active yet")
	end
end

POINT_ZONE.playerEntered:Connect(function(Player)
	AmountInZone(Player,1)
	Logic()
end)

POINT_ZONE.playerExited:Connect(function(Player)
	AmountInZone(Player,-1)
end)

return Point
