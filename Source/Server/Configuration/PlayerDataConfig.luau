local DEFAULT_AUTO_INFO = {
	Active = false,
	Duration = 0,
}

local function cloneAutoInfo()
	return {
		Active = DEFAULT_AUTO_INFO.Active,
		Duration = DEFAULT_AUTO_INFO.Duration,
	}
end

local PlayerDataConfig = {
	Clicks = 0,
	Gems = 0,
	Auto = {
		Fast = cloneAutoInfo(),
		Regular = cloneAutoInfo(),
	},
}

return PlayerDataConfig
