local Point = {}
Point.__index = Point

--| Services |--
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local RepStorage = game:GetService("ReplicatedStorage")

--| Modules |--
local Zone = require(SSS:WaitForChild("APIs").Zone)
local Server = require(SSS:WaitForChild("Main").Server)
local PayloadClass = require(SSS:WaitForChild("Classes").PayloadClass)
local PayloadModule = require(SSS:WaitForChild("Main").PayloadModule)

--| Variables |--
local CaptureProgress = RepStorage.GameValues:WaitForChild("CaptureProgress")

function Point.new(PointModel,Active,Max)
	local NewPoint = {
		PointZone = Zone.new(PointModel.Zone),
		Max = Max,
		AttackersInZone = 0,
		DefendersInZone = 0,
        Active = Active,	
	}

	NewPoint.PointZone.playerEntered:Connect(function(Player)
		Point:AmountOnPoint(NewPoint,Player,1)
		Point:Logic(NewPoint)
	end)
	
	NewPoint.PointZone.playerExited:Connect(function(Player)
		Point:AmountOnPoint(NewPoint,Player,-1)
		Point:Logic(NewPoint)
	end)

    return setmetatable(NewPoint,Point)
end

function Point:IsActive()
	return self.Active
end

--Increases the capture progress value
function Point:Logic(self)
	if self.Active then
		if self.AttackersInZone >= 1 and self.DefendersInZone == 0 then
			Point:EnableCaptureFrame(true)
			while (self.AttackersInZone >= 1) and (self.DefendersInZone == 0) and (CaptureProgress.Value) ~= self.Max do
				CaptureProgress.Value += 5
				print(CaptureProgress.Value.."/"..self.Max)
				task.wait(0.5)
			end
		end

		if CaptureProgress.Value == self.Max then
			PayloadModule.Payload.Active = true --Activate payload so it can be pushed
			Point:EnableCaptureFrame(false) --Disable everyones capture gui
		else
			while CaptureProgress.Value ~= 0 do
				CaptureProgress.Value -= 5
				print(CaptureProgress.Value.."/"..self.Max)
				task.wait(0.5)
			end
			Point:EnableCaptureFrame(false)
		end
	else
		warn(Server.SERVER_NAME.."Point is not active yet")
	end
end

--Enable the frame for all players
function Point:EnableCaptureFrame(bool)
	for _,Player in pairs(Players:GetChildren()) do
		Player.PlayerGui.ScreenGui.Frame.CaptureBackground.Visible = bool
	end
end

function Point:AmountOnPoint(self,Player,Number)
	if table.find(Server.Attackers,Player.Name) then
		self.AttackersInZone += Number
	elseif table.find(Server.Defenders,Player.Name) then
		self.DefendersInZone += Number
    else
        warn(Server.SERVER_NAME.."Not on a team")
	end
end

return Point