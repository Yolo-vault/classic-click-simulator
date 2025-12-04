local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts

return function(parent: GuiObject)
	local Iris = require(ReplicatedStorage.Packages.Iris)
	local DebugPanel = require(StarterPlayerScripts.Modules.DebugPanel)

	-- Iniciar Iris
	Iris.Init(parent)

	-- Executa seu painel de debug REAL
	DebugPanel.Start()

	return function()
		Iris.Shutdown()
	end
end
