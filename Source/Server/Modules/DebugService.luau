local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerProfiles = require(ServerScriptService.Modules.PlayerData.PlayerProfiles)
local AdminConfig = require(ServerScriptService.Configuration.AdminConfig)
local Blink = require(ReplicatedStorage.Remotes.Server.BlinkServer)

local DebugService = {}

function DebugService.Start()
	Blink.DebugIsAdmin.On(function(Player)
		return AdminConfig.IsAdmin(Player.UserId)
	end)

	Blink.DebugAddClicks.On(function(AdminPlayer, Amount, TargetPlayer)
		if not AdminConfig.IsAdmin(AdminPlayer.UserId) then
			return
		end

		if typeof(Amount) ~= "number" or Amount <= 0 then
			return
		end

		if TargetPlayer == nil then
			TargetPlayer = AdminPlayer
		end

		if typeof(TargetPlayer) ~= "Instance" or not TargetPlayer:IsA("Player") then
			return
		end

		local NewValue = PlayerProfiles.AdjustClicks(TargetPlayer, Amount)
		Blink.UpdateClicks.Fire(TargetPlayer, NewValue)
	end)
end

return DebugService
