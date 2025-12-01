local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerProfiles = require(ServerScriptService.Modules.PlayerData.PlayerProfiles)
local SystemConfig = require(ServerScriptService.Configuration.SystemConfig)
local PlayerDataConfig = require(ServerScriptService.Configuration.PlayerDataConfig)
local ProfileService = require(ServerScriptService.Packages.ProfileService)
local Blink = require(ReplicatedStorage.Remotes.Server.BlinkServer)

local KICK_MESSAGE = SystemConfig.KICK_MESSAGE
local DATASTORE_NAME = RunService:IsStudio() and "Development_0.0.2" or "Production"

local PlayerDataService = {}
local ProfileStore = ProfileService.GetProfileStore(DATASTORE_NAME, PlayerDataConfig)

local function CreateLeaderstats(player, profile)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local clicks = Instance.new("NumberValue")
	clicks.Name = "Clicks"
	clicks.Value = profile.Data.Clicks or 0
	clicks.Parent = leaderstats

	local gems = Instance.new("NumberValue")
	gems.Name = "Gems"
	gems.Value = profile.Data.Gems or 0
	gems.Parent = leaderstats
end

function PlayerDataService.LoadProfile(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if not profile then
		player:Kick(KICK_MESSAGE)
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile()

	profile:ListenToRelease(function()
		PlayerProfiles.Profiles[player] = nil
		player:Kick(KICK_MESSAGE)
	end)

	if player.Parent == Players then
		-- Armazena e cria leaderstats
		PlayerProfiles.Profiles[player] = profile
		CreateLeaderstats(player, profile)

		-- envia dados iniciais ao cliente
		Blink.UpdateClicks.Fire(player, profile.Data.Clicks)
	else
		profile:Release()
	end
end

function PlayerDataService.ReleaseProfile(player)
	local profile = PlayerProfiles.Profiles[player]
	if profile then
		profile:Release()
	end
end

return PlayerDataService
