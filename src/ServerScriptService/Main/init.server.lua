--| Services |--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--| Modules |--
local PayloadModule = require(SSS:WaitForChild("Main").PayloadModule)
local PointModule = require(SSS:WaitForChild("Main").PointModule)
local Server = require(SSS:WaitForChild("Main").Server)
local Zone = require(SSS:WaitForChild("APIs").Zone)
local Data = require(SSS:WaitForChild("Main").Profile)

Players.PlayerAdded:Connect(function(Player)
	warn(Server.SERVER_NAME.."Player joined the game")
	Player.CharacterAdded:Connect(function(Character)
		warn(Server.SERVER_NAME.."Character loaded")
	end)
end)
