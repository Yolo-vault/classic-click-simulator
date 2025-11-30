local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Blink = require(ReplicatedStorage.Remotes.Client.BlinkClient)

local ClickController = {}

function ClickController.Start()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
			or input.KeyCode == Enum.KeyCode.ButtonR2
		then
			Blink.Click.Fire(1, os.clock())
		end
	end)
end

return ClickController
