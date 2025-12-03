local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blink = require(ReplicatedStorage.Remotes.Server.BlinkServer)

local PlayerProfiles = {}
PlayerProfiles.Profiles = {}

local function safeNumber(value)
	if typeof(value) == "number" then
		return value
	end
	return nil
end

function PlayerProfiles.AdjustClicks(player, amount)
	if typeof(amount) ~= "number" then
		warn("[AdjustClicks] Tentou adicionar valor inválido:", amount)
		return 0
	end

	local profile = PlayerProfiles.Profiles[player]
	if not profile then
		return 0
	end

	local current = safeNumber(profile.Data.Clicks) or 0
	local new = current + amount
	profile.Data.Clicks = new

	local leaderstats = player:FindFirstChild("leaderstats")
	local clicksValue = leaderstats and leaderstats:FindFirstChild("Clicks")
	if clicksValue then
		clicksValue.Value = new
	end

	Blink.UpdateClicks.Fire(player, new)

	return new
end

Blink.GetData.On(function(player, key)
	local profile = PlayerProfiles.Profiles[player]
	if not profile then
		return 0
	end

	local value = profile.Data[key]

	if typeof(value) == "number" then
		return value
	end

	if value == nil then
		warn("[GetData] Chave não encontrada:", key)
		return 0
	end

	return tonumber(value) or 0
end)

Blink.GetAutoClickMode.On(function(player, buttonType: "Regular" | "Fast")
	local profile = PlayerProfiles.Profiles[player]
	if not profile then
		return false
	end

	local auto = profile.Data.Auto[buttonType]
	if not auto then
		return false
	end

	return auto.Active == true
end)

return PlayerProfiles
