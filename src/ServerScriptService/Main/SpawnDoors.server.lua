--| Services |--
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local SSS = game:GetService("ServerScriptService")

--| Modules |--
local Server = require(SSS:WaitForChild("Main").Server)
local Zone = require(SSS:WaitForChild("APIs").Zone)

--| Variables |--
local JoinAttacker = workspace:WaitForChild("DevStuff").JoinAttacker
local Zone1 = Zone.new(JoinAttacker)
local JoinDefender = workspace:WaitForChild("DevStuff").JoinDefender
local Zone2 = Zone.new(JoinDefender)
local DefendersDoor = "DefendersDoor"
local AttackersDoor = "AttackersDoor"
local Attackers = "Attackers"
local Defenders = "Defenders"

--Create 2 collision groups
PhysicsService:CreateCollisionGroup(DefendersDoor)
PhysicsService:CreateCollisionGroup(AttackersDoor)

--Set collision groups
PhysicsService:SetPartCollisionGroup(workspace.DevStuff.DefendersDoor,DefendersDoor)
PhysicsService:SetPartCollisionGroup(workspace.DevStuff.AttackersDoor,AttackersDoor)

--Create collision
PhysicsService:CreateCollisionGroup(Attackers)
PhysicsService:CreateCollisionGroup(Defenders)

PhysicsService:CollisionGroupSetCollidable(Defenders,DefendersDoor,false)
PhysicsService:CollisionGroupSetCollidable(Attackers,AttackersDoor,false)

local function SetCollisionGroup(Character,GroupName)
	for _,Child in ipairs(Character:GetChildren()) do
		if Child:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(Child,GroupName)
		end
	end
	Character.DescendantAdded:Connect(function(Descendant)
		if Descendant:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(Descendant,GroupName)
		end
	end)
end

--All this is for the team changing parts (TEMP CODE)
local function RemoveFromTable(ThingToRemove,Table)
	for i,v in pairs(Table) do
		if v.Name == ThingToRemove.Name then
			table.remove(Server.Attackers,i)
		end
	end
end

--This function will check which table the player is in, remove them from it and add them to the new one
local function TeamChange(Player,Table,Team) 
	if not table.find(Server.Attackers,Player.Name) and not table.find(Server.Defenders,Player.Name) then
		table.insert(Table,Player.Name)
		SetCollisionGroup(Player.Character,Team)
	elseif Table == Server.Defenders and not table.find(Server.Defenders,Player.Name) and table.find(Server.Attackers,Player.Name) then
		RemoveFromTable(Player.Name,Server.Attackers)
		table.insert(Server.Defenders,Player.Name)
		SetCollisionGroup(Player.Character,Defenders)
	elseif Table == Server.Attackers and not table.find(Server.Attackers,Player.Name) and table.find(Server.Defenders,Player.Name) then
		RemoveFromTable(Player.Name,Server.Defenders)
		table.insert(Server.Attackers,Player.Name)
		SetCollisionGroup(Player.Character,Attackers)
	end
end

Zone1.playerEntered:Connect(function(Player)
	TeamChange(Player,Server.Attackers,"Attackers")
end)

Zone2.playerEntered:Connect(function(Player)
	TeamChange(Player,Server.Defenders,"Defenders")
end)



