local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Blink = require(ReplicatedStorage.Remotes.Server.BlinkServer)
local PlayerProfiles = require(ServerScriptService.Modules.PlayerData.PlayerProfiles)

local AutoclickService = {}

local CODE_TO_TYPE = {
	[1] = "Regular",
	[2] = "Regular",
	[3] = "Fast",
	[4] = "Fast",
}

local function SendMode(player, buttonType, isActive)
	local code

	if buttonType == "Regular" then
		code = isActive and 1 or 2
	else
		code = isActive and 3 or 4
	end

	Blink.AutoClickModeChanged.Fire(player, code)
end

local function UpdateAutoClicker(player, code)
	local buttonType = CODE_TO_TYPE[code]
	if not buttonType then
		return
	end

	local profile = PlayerProfiles.Profiles[player]
	if not profile then
		return
	end

	local data = profile.Data.Auto[buttonType]
	local otherType = (buttonType == "Regular") and "Fast" or "Regular"
	local otherData = profile.Data.Auto[otherType]

	if data.Active then
		data.Active = false
		SendMode(player, buttonType, false)
		return
	end

	if (data.Duration or 0) > 0 then
		data.Active = true
		SendMode(player, buttonType, true)

		if otherData.Active then
			otherData.Active = false
			SendMode(player, otherType, false)
		end
	end
end

function AutoclickService.Start()
	Blink.UpdateAutoClicker.On(UpdateAutoClicker)

	local isSecond = false

	while true do
		isSecond = not isSecond

		for _, player in Players:GetPlayers() do
			local profile = PlayerProfiles.Profiles[player]
			if not profile then
				continue
			end

			local auto = profile.Data.Auto

			-- FAST: 0.5s click, 1s perde duration
			if auto.Fast.Active then
				PlayerProfiles.AdjustClicks(player, 1)
				Blink.UpdateClicks.Fire(player, profile.Data.Clicks)

				if isSecond then
					auto.Fast.Duration = math.max(0, auto.Fast.Duration - 1)

					if auto.Fast.Duration == 0 then
						auto.Fast.Active = false
						SendMode(player, "Fast", false)
					end
				end
			end

			-- REGULAR: click a cada 1s
			if isSecond and auto.Regular.Active then
				PlayerProfiles.AdjustClicks(player, 1)
				Blink.UpdateClicks.Fire(player, profile.Data.Clicks)
				auto.Regular.Duration = math.max(0, auto.Regular.Duration - 1)

				if auto.Regular.Duration == 0 then
					auto.Regular.Active = false
					SendMode(player, "Regular", false)
				end
			end
		end

		task.wait(0.5)
	end
end

return AutoclickService
