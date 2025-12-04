local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Gui = PlayerGui:WaitForChild("InGame"):WaitForChild("HUD")
local HoverConfig = require(ReplicatedStorage.Configuration.HoverConfig)

type ButtonInstance = GuiButton

local HoverColor = HoverConfig.HoverColor
local HoverScale = HoverConfig.HoverScale
local HoverTweenTime = HoverConfig.HoverTweenTime
local PulseFactor = HoverConfig.PulseFactor
local PulseTime = HoverConfig.PulseTime
local PulseReturnTime = HoverConfig.PulseReturnTime

local HoverSoundId = HoverConfig.HoverSoundId
local HoverSoundVolume = HoverConfig.HoverSoundVolume
local HoverSoundPitch = HoverConfig.HoverSoundPitch

local HoverController = {}

local _original = {}
local _activeTween = {}

local function MultiplyUDim2(u: UDim2, f: number)
	return UDim2.new(u.X.Scale * f, u.X.Offset * f, u.Y.Scale * f, u.Y.Offset * f)
end

local function StopTweens(button)
	if _activeTween[button] then
		for _, tween in ipairs(_activeTween[button]) do
			if tween.PlaybackState == Enum.PlaybackState.Playing then
				tween:Cancel()
			end
		end
	end
	_activeTween[button] = {}
end

local function AddTween(button, tween)
	_activeTween[button] = _activeTween[button] or {}
	table.insert(_activeTween[button], tween)
end

local function PlayTweenTracked(button, inst, info, props)
	local tween = TweenService:Create(inst, info, props)
	AddTween(button, tween)
	tween:Play()
	return tween
end

local function PlayHoverSound(button)
	if not HoverSoundId or HoverSoundId == "" then
		return
	end

	local sound = button:FindFirstChild("_HoverSound")
	if not sound then
		sound = Instance.new("Sound")
		sound.Name = "_HoverSound"
		sound.Parent = button
		sound.Looped = false
		sound.PlaybackSpeed = HoverSoundPitch
		sound.Volume = HoverSoundVolume
	end

	if sound.SoundId ~= HoverSoundId then
		sound.SoundId = HoverSoundId
	end

	pcall(function()
		sound:Play()
	end)
end

local function EnsureScale(button)
	local ui = button:FindFirstChild("HoverScale")
	if not ui then
		ui = Instance.new("UIScale")
		ui.Name = "HoverScale"
		ui.Scale = 1
		ui.Parent = button
	end
	return ui
end

local function StoreOriginal(button, icon, label, scale)
	if not _original[button] then
		_original[button] = {
			IconSize = icon and icon.Size or nil,
			IconColor = icon and icon.ImageColor3 or nil,
			LabelColor = label and label.TextColor3 or nil,
			Scale = scale.Scale,
		}
	end
end

local function OnHoverEnter(button: ButtonInstance)
	local icon = button:FindFirstChild("Icon")
	local label = button:FindFirstChildWhichIsA("TextLabel")
	local scale = EnsureScale(button)

	if not icon and not label then
		return
	end

	StoreOriginal(button, icon, label, scale)
	local orig = _original[button]

	StopTweens(button)

	local overshoot = TweenInfo.new(PulseTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local settle = TweenInfo.new(PulseReturnTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	-- ICON
	if icon then
		local target = MultiplyUDim2(orig.IconSize, HoverScale)
		local pulse = MultiplyUDim2(orig.IconSize, HoverScale * PulseFactor)

		PlayTweenTracked(button, icon, overshoot, { Size = pulse })
		PlayTweenTracked(button, icon, settle, { Size = target, ImageColor3 = HoverColor })
	end

	-- LABEL SCALE
	if label then
		local targetScale = orig.Scale * HoverScale
		local pulseScale = orig.Scale * HoverScale * PulseFactor

		scale.Scale = orig.Scale

		PlayTweenTracked(button, scale, overshoot, { Scale = pulseScale })
		PlayTweenTracked(button, scale, settle, { Scale = targetScale })

		PlayTweenTracked(button, label, settle, { TextColor3 = HoverColor })
	end

	PlayHoverSound(button)
end

local function OnHoverLeave(button: ButtonInstance)
	local icon = button:FindFirstChild("Icon")
	local label = button:FindFirstChildWhichIsA("TextLabel")
	local scale = button:FindFirstChild("HoverScale")

	local orig = _original[button]
	if not orig then
		return
	end

	StopTweens(button)

	local info = TweenInfo.new(HoverTweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

	if icon then
		PlayTweenTracked(button, icon, info, { Size = orig.IconSize, ImageColor3 = orig.IconColor })
	end

	if label then
		PlayTweenTracked(button, label, info, { TextColor3 = orig.LabelColor })
	end

	if scale then
		PlayTweenTracked(button, scale, info, { Scale = orig.Scale })
	end
end

function HoverController.Start()
	for _, button in pairs(Gui:GetDescendants()) do
		if not button:IsA("GuiButton") or button.Name == "Shop" then
			continue
		end

		button.MouseEnter:Connect(function()
			OnHoverEnter(button)
		end)
		button.MouseLeave:Connect(function()
			OnHoverLeave(button)
		end)
	end
end

return HoverController
