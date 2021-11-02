--| Services |--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--| Modules |--
local PayloadLogic = require(SSS:WaitForChild("Main").Payload)
local Server = require(SSS:WaitForChild("Main").Server)
local Zone = require(SSS:WaitForChild("APIs").Zone)
local PointLogic = require(SSS:WaitForChild("Main").Point)
local Data = require(SSS:WaitForChild("Main").Profile)

--| Variables (TEMP ) |--
local JoinAttacker = workspace:WaitForChild("DevStuff").JoinAttacker
local Zone1 = Zone.new(JoinAttacker)
local JoinDefender = workspace:WaitForChild("DevStuff").JoinDefender
local Zone2 = Zone.new(JoinDefender)

Players.PlayerAdded:Connect(function(Player)
	warn(Server.SERVER_NAME.."Player joined the game")
	Player.CharacterAdded:Connect(function(Character)
		warn(Server.SERVER_NAME.."Character loaded")
	end)
end)

--FOR TEAM CHANGING (TEMP CODE)
local function RemoveFromTable(ThingToRemove,Table)
	for i,v in pairs(Table) do
		if v.Name == ThingToRemove.Name then
			table.remove(Server.Attackers,i)
		end
	end
end

local function TeamChange(Player,Table) 
	if not table.find(Server.Attackers,Player.Name) and not table.find(Server.Defenders,Player.Name) then
		table.insert(Table,Player.Name)
	elseif Table == Server.Defenders and not table.find(Server.Defenders,Player.Name) and table.find(Server.Attackers,Player.Name) then
		RemoveFromTable(Player.Name,Server.Attackers)
		table.insert(Server.Defenders,Player.Name)
	elseif Table == Server.Attackers and not table.find(Server.Attackers,Player.Name) and table.find(Server.Defenders,Player.Name) then
		RemoveFromTable(Player.Name,Server.Defenders)
		table.insert(Server.Attackers,Player.Name)
	end
end

Zone1.playerEntered:Connect(function(Player)
	TeamChange(Player,Server.Attackers)
end)

Zone2.playerEntered:Connect(function(Player)
	TeamChange(Player,Server.Defenders)
end)


