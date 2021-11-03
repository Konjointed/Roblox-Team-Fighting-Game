local PayloadClass = {}
PayloadClass.__index = PayloadClass

--| Services |--
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

--| Modules |--
local Zone = require(SSS:WaitForChild("APIs").Zone)
local Server = require(SSS:WaitForChild("Main").Server)

function PayloadClass.new(PayloadModel)

    --weld for tweening
    for _,Part in pairs(PayloadModel:GetDescendants()) do
        if Part:IsA("Part") or Part:IsA("UnionOperation") then
            if Part.Name ~= "Primary" then
                local Weld = Instance.new("WeldConstraint")
                Weld.Part0 = Part
                Weld.Part1 = PayloadModel.PrimaryPart
                Weld.Parent = Part
    
                Part.Anchored = false
            end
        end
    end

    local newPayload = { --self?
        PayloadZone = Zone.new(PayloadModel.Radius),
        Model = PayloadModel,
        Moving = false,
        Backwards = false,
        Forwards = false,
        AttackersInZone = 0,
        DefendersInZone = 0,
        Map = workspace.TestMap1,
        CurrentNode = workspace.TestMap1.Node,
        CurrentDirection = nil,
        Speed = 10,
        Active = false,      
    }

    newPayload.PayloadZone.playerEntered:Connect(function(Player)
        PayloadClass:AmountOnPayload(newPayload,Player,1)
        PayloadClass:Logic(newPayload)    
    end)

    newPayload.PayloadZone.playerExited:Connect(function(Player)
        PayloadClass:AmountOnPayload(newPayload,Player,-1)
        PayloadClass:Logic(newPayload)
    end)

    return setmetatable(newPayload,PayloadClass)
end

--Tweens the payload forwards or backwards to whatever the current node is (very basic system)
function PayloadClass:Move(self,direction)
	self.Moving = true
	local ReachEnd = false
	while self.Moving and ReachEnd == false do
		--this probably isn't needed, but so far this seems to prevent an issue with having the payload moving backwards 
        --when it should be going forward
		if self.Backwards then
			if self.CurrentDirection ~= "backwards" then
				self.CurrentDirection = "backwards"
				if self.CurrentNode.Parent:IsA("Part") then
					self.CurrentNode = self.CurrentNode.Parent
				end					
			end
		elseif self.Forwards then
			if self.CurrentDirection ~= "forwards" then
				self.CurrentDirection = "forwards"
				if #self.CurrentNode:GetChildren() ~= 0 then
					self.CurrentNode = self.CurrentNode:GetChildren()[1]					
				end				
			end
		end

        --calculate how fast the payload should be moving
		local Distance = (self.Model.Primary.Position - self.CurrentNode.Position).Magnitude
		local Time = Distance/self.Speed

		local MovementInfo = TweenInfo.new(
			Time,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.Out
		)
		MovementTween = TS:Create(self.Model.PrimaryPart,MovementInfo,{CFrame = CFrame.new(self.CurrentNode.CFrame.X,self.Model.PrimaryPart.CFrame.Y,self.CurrentNode.CFrame.Z)})
		MovementTween:Play()
		MovementTween.Completed:Wait()

        --if the payload is still moving after the tween finishes then check for the next node to move to
		if self.Moving then
			local NextNode = self.CurrentNode:GetChildren()
			if #NextNode > 0 then
				if direction == "backwards" then
					if self.CurrentNode.Parent:IsA("Part") then
						self.CurrentNode = self.CurrentNode.Parent
					end
				elseif direction == "forward" then
					if NextNode[1] then
						self.CurrentNode = NextNode[1]
					end
				end
				warn(Server.SERVER_NAME.."Moving to: "..self.CurrentNode.Name)
			else
				warn(Server.SERVER_NAME.."Payload reached end")
				ReachEnd = true
			end
		end
	end
end

--Stops moving the payload by canceling the tween
function PayloadClass:StopMoving(self)
    if self.Moving then
		self.Moving = false
		MovementTween:Cancel()
	end
end

--Checks what to do based on whos in the paylod radius
function PayloadClass:Logic(self)
    if self.Active then
        warn(Server.SERVER_NAME.."Attackers: "..self.AttackersInZone)
		warn(Server.SERVER_NAME.."Defenders: "..self.DefendersInZone)

        if self.AttackersInZone >= 1 and self.DefendersInZone == 0 then
			warn(Server.SERVER_NAME.."Moving payload forward")
			self.Forwards = true
			self.Backwards = false
			PayloadClass:StopMoving(self)
			PayloadClass:Move(self,"forward")	
		elseif self.AttackersInZone == 0 and self.DefendersInZone >= 1 then
			warn(Server.SERVER_NAME.."Moving payload backwards")
			self.Forwards = false
			self.Backwards = true
			PayloadClass:StopMoving(self)
			PayloadClass:Move(self,"backward")
		else
			warn(Server.SERVER_NAME.."Attackers and defenders are in the zone / no one is in zone")
			self.Forwards = false
			self.Backwards = false
			PayloadClass:StopMoving(self)
		end
	else
		warn(Server.SERVER_NAME.." Payload is not active yet")   
    end
end

--Adds or removes a number to either of the zones count (used to determine how many are in the radius)
function PayloadClass:AmountOnPayload(self,Player,Number)
	if table.find(Server.Attackers,Player.Name) then
		self.AttackersInZone += Number
	elseif table.find(Server.Defenders,Player.Name) then
		self.DefendersInZone += Number
    else
        warn(Server.SERVER_NAME.."Not on a team")
	end
end

return PayloadClass