local Array = {
	Settings = {
		Chams = {
			State = false,
			Cache = {},
			Blacklist = {},
			Transparency = 0,
		},
		Connections = {}
	}
}

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
--local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local screenGui
local viewportFrame

--[[local function compareTags(tags1, tags2)
	if #tags1 ~= #tags2 then
		return false
	end

	local a = {}
	local b = {}

	for _, tag in ipairs(tags1) do
		a[tag] = true
	end
	for _, tag in ipairs(tags2) do
		b[tag] = true
	end

	for tag in pairs(a) do
		if not b[tag] then
			return false
		end
	end

	return true
end]]

local function getPartMap(model)
	local partMap = {}
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") or part:IsA("Accessory") then
			partMap[part.Name] = part
		end
	end
	return partMap
end

function Array:Initialize()
	screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ScreenInsets = Enum.ScreenInsets.None
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	viewportFrame = Instance.new("ViewportFrame", screenGui)
	viewportFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.CurrentCamera = Workspace.CurrentCamera
	viewportFrame.LightColor = Color3.new(1, 1, 1)
	viewportFrame.Ambient = Color3.new(1, 1, 1)
	viewportFrame.ImageTransparency = Array.Settings.Chams.Transparency
end

function Array:SetPlayerChams(State)
	assert(type(State) == "boolean", "Array.SetPlayerChams requires a boolean argument 'State'")
	assert(screenGui, "Array.SetPlayerChams missing dependency 'screenGui', did you Initialize?")
	assert(viewportFrame, "Array.SetPlayerChams missing dependency 'viewportFrame', did you Initialize?")
	Array.Settings.Chams.State = State

	self:Cleanup()

	if State then
		--local partTagsCache = {}

		for _, player in ipairs(Players:GetPlayers()) do
			if not Array.Settings.Chams.Blacklist[player] then
				local character = player.Character
				if character then
					if not character.Archivable then
						character.Archivable = true
					end
					local chamModel = character:Clone()
					chamModel.Parent = viewportFrame
					Array.Settings.Chams.Cache[player] = chamModel
					
					--[[for _, part in pairs(character:GetDescendants()) do
						part:AddTag(HttpService:GenerateGUID())
					end]]

					for _, part in pairs(chamModel:GetDescendants()) do
						--[[if part:IsA("BasePart") or part:IsA("Accessory") then
							partTagsCache[part] = part:GetTags()]]
						if part:IsA("BaseScript") then
							part:Destroy()
						end
					end
				end
			end
		end

		local connection = RunService.RenderStepped:Connect(function()
			for player, chamModel in pairs(Array.Settings.Chams.Cache) do
				local character = player.Character
				if character then
					local characterPartMap = getPartMap(character)
					local chamPartMap = getPartMap(chamModel)
					
					for partName, part in pairs(chamPartMap) do
						local correspondingPart = characterPartMap[partName]
						if correspondingPart then
							if part:IsA("BasePart") and correspondingPart:IsA("BasePart") then
								part.CFrame = correspondingPart.CFrame
							elseif part:IsA("Accessory") and correspondingPart:IsA("Accessory") then
								local chamHandle = part:FindFirstChild("Handle")
								local correspondingHandle = correspondingPart:FindFirstChild("Handle")
								if chamHandle and correspondingHandle then
									chamHandle.CFrame = correspondingHandle.CFrame
								end
							end
						end
					end
				end
			end
		end)
		
		table.insert(Array.Settings.Connections, connection)
	else
		self:Cleanup()
	end
end

function Array:Cleanup()
	for _, connection in ipairs(Array.Settings.Connections) do
		connection:Disconnect()
	end
	Array.Settings.Connections = {}

	for _, chamModel in pairs(Array.Settings.Chams.Cache) do
		chamModel:Destroy()
	end
	Array.Settings.Chams.Cache = {}
end

return Array
