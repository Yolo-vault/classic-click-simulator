local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blink = require(ReplicatedStorage.Remotes.Client.BlinkClient)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Gui = PlayerGui:WaitForChild("InGame"):WaitForChild("HUD")
local ClickButtonsFrame = Gui.CLICK_BUTTONS
local AutoClickFrame = ClickButtonsFrame.AutoClickFrame
local ClickOptionsFrame = AutoClickFrame.ClickerOptions

local FastButton = ClickOptionsFrame.FastAutoClickButton
local RegularButton = ClickOptionsFrame.RegularAutoClickButton
local MainClickButton = AutoClickFrame.MainClickButton

local BUTTON_OFF_COLOR = Color3.fromRGB(30, 31, 32)
local TEXT_OFF_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_ON_COLOR = Color3.fromRGB(30, 31, 32)
local BUTTON_ON_COLOR = Color3.fromRGB(78, 204, 90)

local AutoclickController = {}

local function UpdateButton(buttonType, isActive)
	local button = (buttonType == "Regular") and RegularButton or FastButton
	local bg = isActive and BUTTON_ON_COLOR or BUTTON_OFF_COLOR
	local text = isActive and TEXT_ON_COLOR or TEXT_OFF_COLOR

	button.TextLabel.BackgroundColor3 = bg
	button.TextLabel.TextColor3 = text
end

function AutoclickController.Start()
	MainClickButton.MouseButton1Click:Connect(function()
		Blink.Click.Fire(1, os.clock())
	end)

	FastButton.MouseButton1Click:Connect(function()
		local isActive = Blink.GetAutoClickMode.Invoke("Fast")
		Blink.UpdateAutoClicker.Fire(isActive and 4 or 3)
	end)

	RegularButton.MouseButton1Click:Connect(function()
		local isActive = Blink.GetAutoClickMode.Invoke("Regular")
		Blink.UpdateAutoClicker.Fire(isActive and 2 or 1)
	end)

	local handlers = {
		[1] = function()
			UpdateButton("Regular", true)
			UpdateButton("Fast", false)
		end,
		[2] = function()
			UpdateButton("Regular", false)
		end,
		[3] = function()
			UpdateButton("Fast", true)
			UpdateButton("Regular", false)
		end,
		[4] = function()
			UpdateButton("Fast", false)
		end,
	}

	Blink.AutoClickModeChanged.On(function(code)
		local fn = handlers[code]
		if fn then
			fn()
		end
	end)

	UpdateButton("Regular", Blink.GetAutoClickMode.Invoke("Regular"))
	UpdateButton("Fast", Blink.GetAutoClickMode.Invoke("Fast"))
end

return AutoclickController
