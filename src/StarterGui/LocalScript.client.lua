--| Services |--
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

--| Constants |--
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = PlayerGui.ScreenGui

--| Variable |--
local CaptureProgress = RepStorage.GameValues:WaitForChild("CaptureProgress")
local CaptureBar = ScreenGui.Frame.CaptureBackground.CaptureBar

CaptureProgress:GetPropertyChangedSignal("Value"):Connect(function()
	CaptureBar.Parent.Visible = true
	local Progress = math.clamp(CaptureProgress.Value/200,0,1)
	local Info = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,0)
	TS:Create(CaptureBar,Info,{Size = UDim2.fromScale(Progress,1)}):Play()
end)


