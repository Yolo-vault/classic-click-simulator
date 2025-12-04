local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Iris = require(ReplicatedStorage.Packages.Iris)
local Blink = require(ReplicatedStorage.Remotes.Client.BlinkClient)

local DebugPanel = {}

local SelectedUserId: any = nil
local ShowActions: any = nil
local AmountState: any = nil
local IsStarted = false

local function IsAdmin(): boolean
	local Ok, Result = pcall(function()
		return Blink.DebugIsAdmin.Invoke()
	end)
	return Ok and Result == true
end

function DebugPanel.Start()
	if IsStarted then
		return
	end

	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then
		LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	end

	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
	if not PlayerGui then
		return
	end

	local Gui = PlayerGui:FindFirstChild("DEBUG")
	if not Gui then
		Gui = Instance.new("ScreenGui")
		Gui.Name = "DEBUG"
		Gui.Parent = PlayerGui
	end

	if not IsAdmin() then
		return
	end

	if SelectedUserId == nil then
		SelectedUserId = Iris.State(0)
		ShowActions = Iris.State(false)
		AmountState = Iris.State(1)
	end

	Iris.Init(Gui)

	Iris:Connect(function()
		local Ok = pcall(function()
			Iris.Window({ "Players Online" })
			Iris.Text({ "Clique em um jogador para ver ações disponíveis" })

			Iris.Separator()

			for _, Player in ipairs(Players:GetPlayers()) do
				local Label = Player.Name .. " | " .. tostring(Player.UserId)
				if Iris.Button({ Label }).clicked() then
					SelectedUserId:set(Player.UserId)
					ShowActions:set(true)
				end
			end

			Iris.Separator()
			Iris.Text({ "AdminId: " .. tostring(LocalPlayer and LocalPlayer.UserId or 0) })

			if ShowActions:get() then
				local UserId = SelectedUserId:get()
				local TargetPlayer = UserId ~= 0 and Players:GetPlayerByUserId(UserId) or nil

				local Header = "Ações – " .. (TargetPlayer and TargetPlayer.Name or "Desconhecido")
				Iris.Separator()
				Iris.Text({ Header })

				if TargetPlayer then
					Iris.Text({ "Jogador: " .. TargetPlayer.Name })
					Iris.InputNum({ "Quantidade de Clicks" }, { number = AmountState })

					if Iris.Button({ "Adicionar Clicks" }).clicked() then
						local Amt = AmountState:get()
						task.defer(function()
							Blink.DebugAddClicks.Fire(Amt)
						end)
					end

					if Iris.Button({ "Fechar" }).clicked() then
						ShowActions:set(false)
						SelectedUserId:set(0)
					end
				else
					Iris.Text({ "Jogador não encontrado (pode ter saído)." })
					if Iris.Button({ "Fechar" }).clicked() then
						ShowActions:set(false)
						SelectedUserId:set(0)
					end
				end
			end

			Iris.End()
		end)

		if not Ok then
			if Iris and Iris.Internal and Iris.Internal._stackIndex then
				local Attempts = 0
				while Iris.Internal._stackIndex > 1 and Attempts < 10 do
					local Ok2 = pcall(function()
						Iris.End()
					end)
					if not Ok2 then
						break
					end
					Attempts = Attempts + 1
				end
			end
		end
	end)

	IsStarted = true
end

return DebugPanel
