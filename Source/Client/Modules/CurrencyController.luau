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
local GemsFrame = CurrencyFrame:WaitForChild("GemsFrame")
local GemsAmount = GemsFrame:WaitForChild("Amount")

local CurrencyController = {}

local function UpdateCurrencyDisplay(currency: "Clicks" | "Gems", amount: number)
	amount = FormatNumber.Simple.FormatCompact(amount)

	if currency == "Clicks" then
		ClicksAmount.Text = tostring(amount)
	elseif currency == "Gems" then
		GemsAmount.Text = tostring(amount)
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
