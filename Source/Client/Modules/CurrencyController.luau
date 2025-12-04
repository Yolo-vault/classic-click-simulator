local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FormatNumber = require(ReplicatedStorage.Packages.FormatNumber)
local Blink = require(ReplicatedStorage.Remotes.Client.BlinkClient)
local Player = Players.LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")
local Gui = PlayerGui:WaitForChild("InGame"):WaitForChild("HUD")
local LeftPanel = Gui:WaitForChild("LEFT_PANEL")
local CurrencyFrame = LeftPanel:WaitForChild("CurrencyFrame")
local ClicksFrame = CurrencyFrame:WaitForChild("ClicksFrame")
local ClicksAmount = ClicksFrame:WaitForChild("Amount")
local ClicksPerSecond = ClicksFrame:WaitForChild("ClicksPerSecond")
local GemsFrame = CurrencyFrame:WaitForChild("GemsFrame")
local GemsAmount = GemsFrame:WaitForChild("Amount")

local ClicksDuringSeconds = 0
local PreviousClicksAmount = 0

local CLICKS_PER_SECOND_STRING_TEMPLATE = "+AMOUNT/sec"

local CurrencyController = {}

local function UpdateClicksPerSecond(amount: number)
	local amountOfClicks = amount - PreviousClicksAmount
	PreviousClicksAmount = amount
	if amountOfClicks <= 0 then
		return
	end

	ClicksDuringSeconds += amountOfClicks
	ClicksPerSecond.Text = string.gsub(
		CLICKS_PER_SECOND_STRING_TEMPLATE,
		"AMOUNT",
		tostring(FormatNumber.Simple.FormatCompact(ClicksDuringSeconds))
	)
	ClicksPerSecond.Visible = true

	task.delay(1, function()
		ClicksDuringSeconds -= amountOfClicks
		ClicksPerSecond.Text = string.gsub(
			CLICKS_PER_SECOND_STRING_TEMPLATE,
			"AMOUNT",
			tostring(FormatNumber.Simple.FormatCompact(ClicksDuringSeconds))
		)
		ClicksPerSecond.Visible = ClicksDuringSeconds > 0
	end)
end

local function UpdateCurrencyDisplay(currency: "Clicks" | "Gems", amount: number)
	if currency == "Clicks" then
		UpdateClicksPerSecond(amount)
		ClicksAmount.Text = tostring(FormatNumber.Simple.FormatCompact(amount))
	elseif currency == "Gems" then
		GemsAmount.Text = tostring(FormatNumber.Simple.FormatCompact(amount))
	end
end

function CurrencyController.Start()
	task.spawn(function()
		local success, initialClicks = pcall(function()
			return Blink.GetData.Invoke("Clicks")
		end)

		if success and typeof(initialClicks) == "number" then
			UpdateCurrencyDisplay("Clicks", initialClicks)
		else
			warn("Falha ao obter dados iniciais de clicks")
		end
	end)

	Blink.UpdateClicks.On(function(amount)
		UpdateCurrencyDisplay("Clicks", amount)
	end)
end

return CurrencyController
