local Array = require(script.Array)
local UIS = game:GetService("UserInputService")

-- Put settings before :Initialize
Array.Settings.Chams.Transparency = 0
Array:Initialize()

UIS.InputEnded:Connect(function(inp)
	if inp.KeyCode == Enum.KeyCode.V then
		Array:SetPlayerChams(not Array.Settings.Chams.State)
	end
end)
