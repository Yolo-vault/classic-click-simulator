local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Blink = require(ReplicatedStorage.Remotes.Server.BlinkServer)
local PlayerProfiles = require(ServerScriptService.Modules.PlayerData.PlayerProfiles)

local ClickService = {}
local Cooldown = {}
local CLICK_COOLDOWN = 0.5

function ClickService.Start()
	Blink.Click.On(function(player, amount)
		if Cooldown[player] then
			return
		end
		Cooldown[player] = true

		task.delay(CLICK_COOLDOWN, function()
			Cooldown[player] = nil
		end)

		local newTotal = PlayerProfiles.AdjustClicks(player, amount) or 0
		warn("newTotal:", newTotal)

		Blink.UpdateClicks.Fire(player, newTotal)
	end)
end

return ClickService
