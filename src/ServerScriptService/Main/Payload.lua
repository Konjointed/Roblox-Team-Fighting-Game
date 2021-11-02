--| Services |--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TS = game:GetService("TweenService")

--| Modules |--
local Zone = require(SSS:WaitForChild("APIs").Zone)
local Server = require(SSS:WaitForChild("Main").Server)

--| Constants |--
local PAYLOAD = workspace:WaitForChild("Payload")
local PAYLOAD_MODEL = PAYLOAD.Model
local PAYLOAD_RADIUS = PAYLOAD.Radius
local PAYLOAD_ZONE = Zone.new(PAYLOAD_RADIUS)

--| Variables |--
local Moving = false
local Map = workspace.TestMap1
local AttackersInZone = 0
local DefendersInZone = 0
local Backwards = false
local Forwards = false

--| Payload Settings |--
local Speed = 10
local RotationSpeed = 1

local Payload = {}

Payload.Active = false

--Weld the payload so I can tween it
for _,Part in pairs(PAYLOAD:GetDescendants()) do
	if Part:IsA("Part") or Part:IsA("UnionOperation") then
		if Part.Name ~= "Primary" then
			local Weld = Instance.new("WeldConstraint")
			Weld.Part0 = Part
			Weld.Part1 = PAYLOAD.PrimaryPart
			Weld.Parent = Part

			Part.Anchored = false
		end
	end
end

--[[
I sometimes can't wrap my brain around all of this
but basically move the payload to the next node and then get the child of the node a.k.a the next node and move to it
however if the payload is being pushed backwards we wanna go to the previous node a.k.a the parent of the current.
--]]
local RachedNodes = {}
local CurrentNode = Map.Node
local PreviousNode
local PreviousDirection
local CurrentDirection
function MovePayload(direction)
	Moving = true
	local ReachEnd = false
	while Moving and ReachEnd == false do
		if Backwards then
			if CurrentDirection ~= "backwards" then
				CurrentDirection = "backwards"
				if CurrentNode.Parent:IsA("Part") then
					CurrentNode = CurrentNode.Parent
				end					
			end
		elseif Forwards then
			if CurrentDirection ~= "forwards" then
				CurrentDirection = "forwards"
				if #CurrentNode:GetChildren() ~= 0 then
					CurrentNode = CurrentNode:GetChildren()[1]					
				end				
			end
		end

		local Distance = (PAYLOAD.Primary.Position - CurrentNode.Position).Magnitude
		local Time = Distance/Speed
		--Move
		local MovementInfo = TweenInfo.new(
			Time,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		)
		MovementTween = TS:Create(PAYLOAD.PrimaryPart,MovementInfo,{CFrame = CFrame.new(CurrentNode.CFrame.X,PAYLOAD.PrimaryPart.CFrame.Y,CurrentNode.CFrame.Z)})
		MovementTween:Play()
		MovementTween.Completed:Wait()

		if Moving then
			local NextNode = CurrentNode:GetChildren()
			if #NextNode > 0 then
				if direction == "backwards" then
					if CurrentNode.Parent:IsA("Part") then
						CurrentNode = CurrentNode.Parent
					end
				elseif direction == "forward" then
					CurrentNode = NextNode[1]
				end
				warn(Server.SERVER_NAME.."Current Node: "..CurrentNode.Name)
			else
				warn(Server.SERVER_NAME.."Payload reached end")
				ReachEnd = true
			end
		end
	end
end

function StopPayload()
	if Moving then
		Moving = false
		MovementTween:Cancel()
	end
end

--This funciton handles checking what to do with the payload (moving it or not) when a player enters or leaves
function Logic()
	if Payload.Active then
		warn(Server.SERVER_NAME.."Attackers: "..AttackersInZone)
		warn(Server.SERVER_NAME.."Defenders: "..DefendersInZone)

		if AttackersInZone >= 1 and DefendersInZone == 0 then
			warn(Server.SERVER_NAME.."Moving payload forward")
			Forwards = true
			Backwards = false
			StopPayload()
			MovePayload("forward")	
		elseif AttackersInZone == 0 and DefendersInZone >= 1 then
			warn(Server.SERVER_NAME.."Moving payload backwards")
			Forwards = false
			Backwards = true
			StopPayload()
			MovePayload("backwards")	
		else
			warn(Server.SERVER_NAME.."Attackers and defenders are in the zone / no one is in zone")
			Forwards = false
			Backwards = false
			StopPayload()
		end
	else
		warn(Server.SERVER_NAME.." Payload is not active yet")
	end
end

function TeamCheck(Player,Number)
	if table.find(Server.Attackers,Player.Name) then
		AttackersInZone += Number
	elseif table.find(Server.Defenders,Player.Name) then
		DefendersInZone += Number
	end
	Logic() 
end

--TEMP CODE BECAUSE I DONT HAVE A SECOND PLAYER TO TEST WITH
PAYLOAD_ZONE.itemEntered:Connect(function(npc)
	warn(Server.SERVER_NAME.."NPC entered zone")
	DefendersInZone += 1
	Logic()
end)

PAYLOAD_ZONE.itemExited:Connect(function(npc)
	warn(Server.SERVER_NAME.."NPC left zone")
	DefendersInZone -= 1
	Logic()
end)

PAYLOAD_ZONE:trackItem(workspace.R6)
--

--When a player enters the zone add 1 to AttackersInZone/DefendersInZone
PAYLOAD_ZONE.playerEntered:Connect(function(Player)
	TeamCheck(Player,1)
end)

--When a player enters the zone remove 1 from AttackersInZone/DefendersInZone
PAYLOAD_ZONE.playerExited:Connect(function(Player)
	TeamCheck(Player,-1)
end)


return Payload
