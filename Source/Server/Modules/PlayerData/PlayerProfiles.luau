local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blink = require(ReplicatedStorage.Remotes.Server.BlinkServer)

local PlayerProfiles = {}
PlayerProfiles.Profiles = {}

function PlayerProfiles.AdjustClicks(player, amount)
	local profile = PlayerProfiles.Profiles[player]
	if not profile then
		return 0
	end

	profile.Data.Clicks = (profile.Data.Clicks or 0) + amount

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("Clicks") then
		leaderstats.Clicks.Value = profile.Data.Clicks
	end

	return profile.Data.Clicks
end

Blink.GetData.On(function(player, key)
	local profile = PlayerProfiles.Profiles[player]
	if not profile then
		return nil
	end
	return profile.Data[key]
end)

return PlayerProfiles
