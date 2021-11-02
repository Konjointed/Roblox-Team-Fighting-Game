--| Services |--
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local SSS = game:GetService("ServerScriptService")

--| Modules |--
local Server = require(SSS:WaitForChild("Main").Server)

local DefendersDoor = "DefendersDoor"
local AttackersDoor = "AttackersDoor"

PhysicsService:CreateCollisionGroup(DefendersDoor)
PhysicsService:CreateCollisionGroup(AttackersDoor)

PhysicsService:SetPartCollisionGroup(workspace.DevStuff.DefendersDoor,DefendersDoor)
PhysicsService:SetPartCollisionGroup(workspace.DevStuff.AttackersDoor,AttackersDoor)

local Attackers = "Attackers"
local Defenders = "Defenders"

PhysicsService:CreateCollisionGroup(Attackers)
PhysicsService:CreateCollisionGroup(Defenders)

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

local function PlayerAdded(Player)
	local function CharacterAdded(Character)
		SetCollisionGroup(Character,Defenders)
	end
	Player.CharacterAdded:Connect(CharacterAdded)
end

Players.PlayerAdded:Connect(PlayerAdded)

PhysicsService:CollisionGroupSetCollidable(Defenders,DefendersDoor,false)
PhysicsService:CollisionGroupSetCollidable(Attackers,AttackersDoor,false)

