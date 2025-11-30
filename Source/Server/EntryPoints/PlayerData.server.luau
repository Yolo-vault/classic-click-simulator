local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Modules.PlayerData.PlayerDataService)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerDataService.LoadProfile, player)
end

Players.PlayerAdded:Connect(PlayerDataService.LoadProfile)
Players.PlayerRemoving:Connect(PlayerDataService.ReleaseProfile)
