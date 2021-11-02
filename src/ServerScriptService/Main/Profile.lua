local ProfileModule = {}

local ProfileTemplate = {
	IsBanned = false,
	LogInTimes = 0,
	Gold = 0,
}

--| Services |--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--| Modules |--
local PS = require(SSS:WaitForChild("APIs").ProfileService)

--| Vaiables |--
ProfileModule.ProfileStore = PS.GetProfileStore(
	"PlayerData",
	ProfileTemplate
)

ProfileModule.Profiles = {}

function ProfileModule:GiveCash(Profile,Amount)
	if Profile.Data.Cash == nil then
		Profile.Data.Cash = 0
	end

	Profile.Data.Cash += Amount
end

local function LoadedProfile(Player,Profile)
	Profile.Data.LogInTimes += 1
	warn(Player.Name.." has logged in "..tostring(Profile.Data.LogInTimes).." time(s)")
	ProfileModule:GiveCash(Profile,100)
	print(Player.Name.." owns "..tostring(Profile.Data.Cash).." now!")
end

local function PlayerAdded(Player)
	local Profile = ProfileModule.ProfileStore:LoadProfileAsync("Player_"..Player.UserId)
	if Profile ~= nil then
		Profile:Reconcile() --Fill in missing variables from template (optional)
		Profile:ListenToRelease(function()
			ProfileModule.Profiles[Player] = nil
			Player:Kick()
		end)
		if Player:IsDescendantOf(Players) == true then
			ProfileModule.Profiles[Player] = Profile
			--A profile has been successfully loaded:
			LoadedProfile(Player,Profile)
		else
			--Player left before the profile loaded
			Profile:Release()
		end
	else
		Player:Kick()		
	end
end

--In case Players have joined the server earlier than this script ran
for _,Player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded,Player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(Player)
	local Profile = ProfileModule.Profiles[Player]
	if Profile ~= nil then
		Profile:Release()
	end
end)

return ProfileModule
