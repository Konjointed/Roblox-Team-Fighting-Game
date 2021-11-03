local ProfileModule = {}

local ProfileTemplate = {
	IsBanned = false,
	IsAdmin = false,
	Gold = 0,
}

--| Services |--
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local Server = require(SSS:WaitForChild("Main").Server)

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
	if Profile.Data.IsAdmin then
		warn(Server.SERVER_NAME..Player.Name.." is an admin (manually added)")
		table.insert(_G.ServerAdmins,Player.UserId)
	end
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
			--Player left before the profile loaded.
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
