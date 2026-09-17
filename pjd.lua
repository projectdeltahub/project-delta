--[[
	Miko Hub - Project Delta
	Obsidian UI
	Build: 2026-08-17bn (credits Made by Vp4q)
]]

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local UI_CACHE_FOLDER = "Miko Hub"

local function Fetch(url)
	if typeof(url) ~= "string" then
		error("Fetch expected string url, got " .. typeof(url), 2)
	end

	local function tryString(result)
		if typeof(result) == "string" and result ~= "" then
			return result
		end
		return nil
	end

	if typeof(HttpGet) == "function" then
		local ok, result = pcall(HttpGet, url)
		local body = ok and tryString(result) or nil
		if body then
			return body
		end
	end

	if typeof(game.HttpGet) == "function" then
		local ok, result = pcall(function()
			return game:HttpGet(url)
		end)
		local body = ok and tryString(result) or nil
		if body then
			return body
		end

		ok, result = pcall(function()
			return game:HttpGet(url, true)
		end)
		body = ok and tryString(result) or nil
		if body then
			return body
		end
	end

	if typeof(http_request) == "function" then
		local ok, result = pcall(http_request, {
			Url = url,
			Method = "GET",
		})
		if ok and typeof(result) == "table" then
			local body = tryString(result.Body)
			if body then
				return body
			end
		end
	end

	if typeof(request) == "function" then
		local ok, result = pcall(request, {
			Url = url,
			Method = "GET",
		})
		if ok and typeof(result) == "table" then
			local body = tryString(result.Body)
			if body then
				return body
			end
		end
	end

	if syn and typeof(syn.request) == "function" then
		local ok, result = pcall(syn.request, {
			Url = url,
			Method = "GET",
		})
		if ok and typeof(result) == "table" then
			local body = tryString(result.Body)
			if body then
				return body
			end
		end
	end

	error("HTTP GET failed for " .. url)
end

local function EnsureCacheFolders()
	if typeof(makefolder) ~= "function" then
		return
	end
	pcall(makefolder, "Miko Hub")
	pcall(makefolder, UI_CACHE_FOLDER)
end

local function CacheFileName(url)
	local name = tostring(url):match("([^/]+)$") or "file.lua"
	return UI_CACHE_FOLDER .. "/" .. name
end

local function ReadCache(path)
	if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
		return nil
	end
	local ok, exists = pcall(isfile, path)
	if not ok or not exists then
		return nil
	end
	local okRead, body = pcall(readfile, path)
	if okRead and typeof(body) == "string" and body ~= "" then
		return body
	end
	return nil
end

local function WriteCache(path, body)
	if typeof(writefile) ~= "function" or typeof(body) ~= "string" or body == "" then
		return
	end
	EnsureCacheFolders()
	pcall(writefile, path, body)
end

local function CompileSource(source, label)
	local compile = loadstring or load
	local fn, err = compile(source)
	if not fn then
		error("Failed to compile " .. tostring(label) .. ": " .. tostring(err), 2)
	end
	return fn()
end

-- Fast path: disk cache. First run downloads all UI files in parallel.
local function LoadUiModules(urls)
	local sources = {}
	local missing = {}

	for i, url in ipairs(urls) do
		local cached = ReadCache(CacheFileName(url))
		if cached then
			sources[i] = cached
		else
			missing[#missing + 1] = i
		end
	end

	if #missing > 0 then
		local done = 0
		local total = #missing
		local errors = {}

		for _, index in ipairs(missing) do
			task.spawn(function()
				local ok, body = pcall(Fetch, urls[index])
				if ok and typeof(body) == "string" and body ~= "" then
					sources[index] = body
					WriteCache(CacheFileName(urls[index]), body)
				else
					errors[index] = tostring(body)
				end
				done += 1
			end)
		end

		local started = os.clock()
		while done < total do
			if os.clock() - started > 45 then
				error("UI download timed out")
			end
			task.wait()
		end

		for _, index in ipairs(missing) do
			if not sources[index] then
				error("HTTP GET failed for " .. urls[index] .. " (" .. tostring(errors[index]) .. ")")
			end
		end
	end

	local modules = {}
	for i, source in ipairs(sources) do
		modules[i] = CompileSource(source, urls[i])
	end
	return table.unpack(modules, 1, #urls)
end

local Library, ThemeManager, SaveManager = LoadUiModules({
	repo .. "Library.lua",
	repo .. "addons/ThemeManager.lua",
	repo .. "addons/SaveManager.lua",
})

-- Kill Obsidian notify sounds (no load ding)
pcall(function()
	Library.Notify = function() end
end)
pcall(function()
	if Library.NotifySound ~= nil then
		Library.NotifySound = false
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local function MuteObsidianSounds(root)
	if not root then
		return
	end
	for _, desc in root:GetDescendants() do
		if desc:IsA("Sound") then
			desc.Volume = 0
			pcall(function()
				desc:Stop()
			end)
		end
	end
	root.DescendantAdded:Connect(function(desc)
		if desc:IsA("Sound") then
			desc.Volume = 0
			pcall(function()
				desc:Stop()
			end)
		end
	end)
end

local function SilenceLibraryAudio()
	pcall(function()
		Library.Notify = function() end
	end)
	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
	for _, parent in { CoreGui, playerGui } do
		if parent then
			for _, child in parent:GetChildren() do
				local name = child.Name:lower()
				if name:find("obsidian", 1, true)
					or name:find("wallhack", 1, true)
					or name:find("library", 1, true)
					or name:find("linoria", 1, true)
				then
					MuteObsidianSounds(child)
				end
			end
		end
	end
end

SilenceLibraryAudio()
pcall(function()
	CoreGui.ChildAdded:Connect(function(child)
		local name = child.Name:lower()
		if name:find("obsidian", 1, true)
			or name:find("wallhack", 1, true)
			or name:find("library", 1, true)
			or name:find("linoria", 1, true)
		then
			task.defer(MuteObsidianSounds, child)
		end
	end)
end)
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function AttachOverlayGui(gui)
	if not gui then
		return false
	end

	if gui.Parent then
		return true
	end

	local targets = { CoreGui }

	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		table.insert(targets, playerGui)
	end

	if gethui then
		local ok, hui = pcall(gethui)
		if ok and hui then
			table.insert(targets, hui)
		end
	end

	for _, target in targets do
		local attached = false
		pcall(function()
			gui.Parent = target
			attached = gui.Parent == target
		end)
		if attached then
			return true
		end
	end

	return false
end

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
	Title = "Miko Hub",
	Footer = "Project Delta",
	Size = UDim2.fromOffset(560, 480),
	NotifySide = "Right",
	ShowCustomCursor = false,
	AutoShow = true,
	Center = true,
})

task.defer(SilenceLibraryAudio)
local Tabs = {
	Aimbot = Window:AddTab("Aimbot", "crosshair"),
	Visuals = Window:AddTab("Visuals", "eye"),
	WorldESP = Window:AddTab("World ESP", "globe"),
	Misc = Window:AddTab("Misc", "wrench"),
	Settings = Window:AddTab("Settings", "settings"),
	Credits = Window:AddTab("Credits", "user"),
}

----------------------------------------------------------------
-- Aimbot
----------------------------------------------------------------
local Aimbot = {
	Enabled = false,
	ShowFOV = false,
	FilledFOV = false,
	FOV = 120,
	Smoothness = 40,
	Method = "Mouse Aim",
	FOVColor = Color3.fromRGB(255, 255, 255),
	FilledFOVColor = Color3.fromRGB(255, 80, 80),
	Holding = false,
}

local SilentAim = {
	Enabled = false,
	ShowFOV = false,
	FOV = 600,
	HitPart = "Head",
	Prediction = true,
}

local SilentHitPartValues = { "Head", "Torso", "Upper Torso" }

local function ResolveSilentHitPart(value)
	local name = value
	if type(value) == "number" then
		name = SilentHitPartValues[value] or "Head"
	end
	if name == "Torso" then
		return "HumanoidRootPart"
	end
	if name == "Upper Torso" then
		return "UpperTorso"
	end
	return "Head"
end

local InitSilentAim, SyncSilentAimFromUI

local Misc
local RestoreMovementSounds
local UpdateFastWalk, UpdateFreeCam, UpdateScriptUserESP
local InitGunMods, ApplyAmmoGunMods

local TriggerBot = {
	Enabled = false,
	Delay = 50,
}

local TriggerBotTarget = nil
local TriggerBotReadyAt = 0

local AimbotMethodValues = { "Mouse Aim", "Camera Aim" }

local function ResolveAimbotMethod(value)
	if type(value) == "number" then
		return AimbotMethodValues[value] or "Mouse Aim"
	end
	if value == "Camera Aim" or value == "Mouse Aim" then
		return value
	end
	return "Mouse Aim"
end

local UpdateTriggerBot, SyncTriggerBotFromUI, SyncAimbotFromUI, AimMouse, AimCamera, GetClosestTarget, UpdateFOV, UpdateAimbot

(function()
local TriggerRayParams = RaycastParams.new()
TriggerRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function GetMouseMoveRel()
	if typeof(mousemoverel) == "function" then
		return mousemoverel
	end
	if syn and typeof(syn.mousemoverel) == "function" then
		return syn.mousemoverel
	end
	if fluxus and typeof(fluxus.mousemoverel) == "function" then
		return fluxus.mousemoverel
	end
	if krnl and typeof(krnl.mousemoverel) == "function" then
		return krnl.mousemoverel
	end
	return nil
end

local MouseMoveRel = GetMouseMoveRel()

local function MoveMouseRelative(dx, dy)
	if MouseMoveRel then
		local ok = pcall(MouseMoveRel, dx, dy)
		if ok then
			return true
		end
	end

	local ok = pcall(function()
		local pos = UserInputService:GetMouseLocation()
		VirtualInputManager:SendMouseMoveEvent(pos.X + dx, pos.Y + dy, game)
	end)
	return ok
end

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "WallhackFOV"
FOVGui.IgnoreGuiInset = true
FOVGui.ResetOnSpawn = false
FOVGui.DisplayOrder = 999999
AttachOverlayGui(FOVGui)

local FilledFOVFrame = Instance.new("Frame")
FilledFOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FilledFOVFrame.BackgroundTransparency = 0.65
FilledFOVFrame.BorderSizePixel = 0
FilledFOVFrame.Visible = false
FilledFOVFrame.ZIndex = 1
FilledFOVFrame.Parent = FOVGui
Instance.new("UICorner", FilledFOVFrame).CornerRadius = UDim.new(1, 0)

local OutlineFOVFrame = Instance.new("Frame")
OutlineFOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
OutlineFOVFrame.BackgroundTransparency = 1
OutlineFOVFrame.BorderSizePixel = 0
OutlineFOVFrame.Visible = false
OutlineFOVFrame.ZIndex = 2
OutlineFOVFrame.Parent = FOVGui
Instance.new("UICorner", OutlineFOVFrame).CornerRadius = UDim.new(1, 0)

local OutlineStroke = Instance.new("UIStroke")
OutlineStroke.Thickness = 2
OutlineStroke.Parent = OutlineFOVFrame

local SilentFOVFrame = Instance.new("Frame")
SilentFOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
SilentFOVFrame.BackgroundTransparency = 1
SilentFOVFrame.BorderSizePixel = 0
SilentFOVFrame.Visible = false
SilentFOVFrame.ZIndex = 3
SilentFOVFrame.Parent = FOVGui
Instance.new("UICorner", SilentFOVFrame).CornerRadius = UDim.new(1, 0)

local SilentFOVStroke = Instance.new("UIStroke")
SilentFOVStroke.Thickness = 2
SilentFOVStroke.Color = Color3.fromRGB(160, 80, 255)
SilentFOVStroke.Parent = SilentFOVFrame

local function GetAimPart(character)
	return character:FindFirstChild("Head", true)
		or character:FindFirstChild("HumanoidRootPart", true)
		or character:FindFirstChild("UpperTorso", true)
		or character:FindFirstChild("Torso", true)
		or character:FindFirstChild("LowerTorso", true)
end

local function GetScreenCenter()
	return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

GetClosestTarget = function()
	if not Camera then
		return nil
	end

	local closestPart = nil
	local closestDistance = math.huge
	local center = GetScreenCenter()
	local maxFov = math.max(Aimbot.FOV, 1)

	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer then
			local character = player.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					local part = GetAimPart(character)
					if part then
						local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
						if screenPos.Z > 0 then
							local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
							if distance <= maxFov and distance < closestDistance then
								closestPart = part
								closestDistance = distance
							end
						end
					end
				end
			end
		end
	end

	return closestPart
end

SyncAimbotFromUI = function()
	local enabledToggle = Toggles.AimbotEnabled
	if enabledToggle then
		Aimbot.Enabled = enabledToggle.Value
	end

	local showFovToggle = Toggles.ShowFOV
	if showFovToggle then
		Aimbot.ShowFOV = showFovToggle.Value
	end

	local filledFovToggle = Toggles.FilledFOV
	if filledFovToggle then
		Aimbot.FilledFOV = filledFovToggle.Value
	end

	local fovOption = Options.AimbotFOVSize
	if fovOption then
		Aimbot.FOV = fovOption.Value
	end

	local smoothOption = Options.AimbotSmoothness
	if smoothOption then
		Aimbot.Smoothness = smoothOption.Value
	end

	local methodOption = Options.AimbotMethod
	if methodOption then
		Aimbot.Method = ResolveAimbotMethod(methodOption.Value)
	end

	local fovColorOption = Options.FOVColor
	if fovColorOption then
		Aimbot.FOVColor = fovColorOption.Value
	end

	local filledFovColorOption = Options.FilledFOVColor
	if filledFovColorOption then
		Aimbot.FilledFOVColor = filledFovColorOption.Value
	end
end

SyncTriggerBotFromUI = function()
	local toggle = Toggles.TriggerBotEnabled
	if toggle then
		TriggerBot.Enabled = toggle.Value
	end

	local delayOption = Options.TriggerBotDelay
	if delayOption then
		TriggerBot.Delay = delayOption.Value
	end
end

local function GetTriggerTarget()
	if not Camera then
		return nil
	end

	local character = LocalPlayer.Character
	if not character then
		return nil
	end

	local viewport = Camera.ViewportSize
	local ray = Camera:ViewportPointToRay(viewport.X / 2, viewport.Y / 2)
	TriggerRayParams.FilterDescendantsInstances = { character }

	local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, TriggerRayParams)
	if not result then
		return nil
	end

	local targetCharacter = result.Instance:FindFirstAncestorOfClass("Model")
	if not targetCharacter or not result.Instance:IsDescendantOf(targetCharacter) then
		return nil
	end

	local player = Players:GetPlayerFromCharacter(targetCharacter)
	if not player or player == LocalPlayer then
		return nil
	end

	local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end

	return targetCharacter
end

local function FireTriggerClick()
	local viewport = Camera.ViewportSize
	local x = viewport.X / 2
	local y = viewport.Y / 2
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

UpdateTriggerBot = function()
	SyncTriggerBotFromUI()

	if not TriggerBot.Enabled then
		TriggerBotTarget = nil
		return
	end

	local targetCharacter = GetTriggerTarget()
	if not targetCharacter then
		TriggerBotTarget = nil
		return
	end

	local now = tick()
	if TriggerBotTarget ~= targetCharacter then
		TriggerBotTarget = targetCharacter
		TriggerBotReadyAt = now + (TriggerBot.Delay / 1000)
		return
	end

	if now >= TriggerBotReadyAt then
		FireTriggerClick()
		TriggerBotReadyAt = now + (TriggerBot.Delay / 1000)
	end
end

AimCamera = function(part)
	if not Camera or not part then
		return
	end

	local smooth = math.clamp(Aimbot.Smoothness, 1, 100)
	local alpha = math.clamp(1 / smooth * 3, 0.08, 1)
	local target = CFrame.new(Camera.CFrame.Position, part.Position)
	Camera.CFrame = Camera.CFrame:Lerp(target, alpha)
end

AimMouse = function(part)
	if not Camera or not part then
		return
	end

	AimCamera(part)

	if not MouseMoveRel then
		return
	end

	local screenPos = Camera:WorldToViewportPoint(part.Position)
	if screenPos.Z <= 0 then
		return
	end

	local center = GetScreenCenter()
	local delta = Vector2.new(screenPos.X - center.X, screenPos.Y - center.Y)
	if delta.Magnitude < 1 then
		return
	end

	local smooth = math.clamp(Aimbot.Smoothness, 1, 100)
	local strength = 1 / (smooth * 1.1)
	local moveX = math.clamp(delta.X * strength, -18, 18)
	local moveY = math.clamp(delta.Y * strength, -18, 18)
	pcall(MouseMoveRel, moveX, moveY)
end

UpdateAimbot = function()
	SyncAimbotFromUI()
	Camera = workspace.CurrentCamera
	if not Camera then
		return
	end

	local keybind = Options.AimbotKeybind
	if keybind and typeof(keybind.GetState) == "function" then
		Aimbot.Holding = keybind:GetState()
	else
		Aimbot.Holding = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	end

	if not Aimbot.Enabled or not Aimbot.Holding then
		return
	end

	local target = GetClosestTarget()
	if not target then
		return
	end

	if ResolveAimbotMethod(Aimbot.Method) == "Camera Aim" then
		AimCamera(target)
	else
		AimMouse(target)
	end
end

UpdateFOV = function()
	if not Camera then
		return
	end

	local center = GetScreenCenter()
	local size = Aimbot.FOV * 2

	FilledFOVFrame.Position = UDim2.fromOffset(center.X, center.Y)
	FilledFOVFrame.Size = UDim2.fromOffset(size, size)
	FilledFOVFrame.BackgroundColor3 = Aimbot.FilledFOVColor
	FilledFOVFrame.Visible = Aimbot.ShowFOV and Aimbot.FilledFOV

	OutlineFOVFrame.Position = UDim2.fromOffset(center.X, center.Y)
	OutlineFOVFrame.Size = UDim2.fromOffset(size, size)
	OutlineStroke.Color = Aimbot.FOVColor
	OutlineFOVFrame.Visible = Aimbot.ShowFOV

	local mousePos = UserInputService:GetMouseLocation()
	local silentSize = SilentAim.FOV * 2
	SilentFOVFrame.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
	SilentFOVFrame.Size = UDim2.fromOffset(silentSize, silentSize)
	SilentFOVFrame.Visible = SilentAim.Enabled and SilentAim.ShowFOV
end

RunService:BindToRenderStep("WallhackAimbot", Enum.RenderPriority.Last.Value, function()
	local ok, err = pcall(UpdateAimbot)
	if not ok then
		warn("[Wallhack.gg] Aimbot", err)
	end
end)

do
local BulletModule
local oldCreateBullet
local AiZones = workspace:FindFirstChild("AiZones")

pcall(function()
	BulletModule = require(ReplicatedStorage.Modules.FPS.Bullet)
end)

local function IsSilentAlive(character)
	if not character then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return root and humanoid and humanoid.Health > 0
end

local function GetAiCharacters()
	local ai = {}

	if not AiZones then
		return ai
	end

	for _, zone in AiZones:GetChildren() do
		for _, character in zone:GetChildren() do
			ai[#ai + 1] = character
		end
	end

	return ai
end

local function GetSilentTarget(...)
	local closestTarget = nil
	local closestDistance = SilentAim.FOV

	if not Camera then
		return nil
	end

	local center = GetScreenCenter()
	local hitPartName = ResolveSilentHitPart(SilentAim.HitPart)

	local function considerCharacter(character)
		if not IsSilentAlive(character) then
			return
		end

		local hitPart = character:FindFirstChild(hitPartName)
		if not hitPart then
			return
		end

		local screenPosition, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
		if not onScreen or screenPosition.Z <= 0 then
			return
		end

		local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - center).Magnitude
		if distance < closestDistance then
			closestDistance = distance
			closestTarget = hitPart
		end
	end

	for _, character in GetAiCharacters() do
		considerCharacter(character)
	end

	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer then
			considerCharacter(player.Character)
		end
	end

	return closestTarget
end

local function SolveQuadratic(a, b, c)
	local discriminant = b * b - 4 * a * c
	if discriminant < 0 then
		return nil, nil
	end

	local discRoot = math.sqrt(discriminant)
	return (-b - discRoot) / (2 * a), (-b + discRoot) / (2 * a)
end

local function GetBallisticFlightTime(direction, gravity, projectileSpeed)
	local root1, root2 = SolveQuadratic(
		gravity:Dot(gravity) / 4,
		gravity:Dot(direction) - projectileSpeed * projectileSpeed,
		direction:Dot(direction)
	)

	if root1 and root2 then
		if root1 > 0 and root1 < root2 then
			return math.sqrt(root1)
		elseif root2 > 0 and root2 < root1 then
			return math.sqrt(root2)
		end
	end

	return 0
end

local function ProjectileDrop(origin, target, projectileSpeed, acceleration)
	local gravity = Vector3.yAxis * (acceleration * 2)
	local time = GetBallisticFlightTime(target - origin, gravity, projectileSpeed)
	return 0.5 * gravity * time * time
end

local function PredictTarget(target, origin, projectileSpeed, acceleration)
	local gravity = Vector3.yAxis * (acceleration * 2)
	local time = GetBallisticFlightTime(target.Position - origin, gravity, projectileSpeed)
	return target.Position + (target.Velocity * time)
end

local function GetAimOrigin(aimPart)
	if typeof(aimPart) == "table" and aimPart.CFrame then
		return aimPart.CFrame.Position
	end

	if typeof(aimPart) == "Instance" then
		return aimPart.Position
	end

	return nil
end

local function GetAimLook(aimPart)
	if typeof(aimPart) == "table" and aimPart.CFrame then
		return aimPart.CFrame.LookVector
	end

	if typeof(aimPart) == "Instance" and aimPart:IsA("BasePart") then
		return aimPart.CFrame.LookVector
	end

	if Camera then
		return Camera.CFrame.LookVector
	end

	return Vector3.new(0, 0, -1)
end

local function ForceAmmoPenetration(ammo)
	if not ammo then
		return
	end

	local names = {
		"Penetration",
		"PenetrationPower",
		"PenetrationDepth",
		"ArmorPenetration",
		"WallPenetration",
		"MaxPenetration",
		"Pen",
		"PenPower",
		"MaterialPenetration",
	}

	for _, name in names do
		pcall(function()
			ammo:SetAttribute(name, 9999)
		end)
		local child = ammo:FindFirstChild(name)
		if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
			pcall(function()
				child.Value = 9999
			end)
		end
	end

	for attr, value in pairs(ammo:GetAttributes()) do
		if typeof(value) == "number" and tostring(attr):lower():find("pen", 1, true) then
			pcall(function()
				ammo:SetAttribute(attr, 9999)
			end)
		end
	end

	for _, child in ammo:GetDescendants() do
		if (child:IsA("NumberValue") or child:IsA("IntValue")) and child.Name:lower():find("pen", 1, true) then
			pcall(function()
				child.Value = 9999
			end)
		end
	end
end

local function BoostLoadedAmmoPenetration()
	local ammoFolder = ReplicatedStorage:FindFirstChild("AmmoTypes")
	if not ammoFolder then
		return
	end
	for _, ammo in ammoFolder:GetChildren() do
		ForceAmmoPenetration(ammo)
	end
end

local WallbangRayParams = RaycastParams.new()
WallbangRayParams.FilterType = Enum.RaycastFilterType.Exclude

local function IsHumanoidPart(part)
	if not part then
		return false
	end
	local model = part:FindFirstAncestorOfClass("Model")
	return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function IsWorldWallPart(part)
	if not part or not part:IsA("BasePart") or part:IsA("Terrain") then
		return false
	end
	local character = LocalPlayer.Character
	if character and part:IsDescendantOf(character) then
		return false
	end
	if Camera and part:IsDescendantOf(Camera) then
		return false
	end
	return not IsHumanoidPart(part)
end

-- Move bullet origin past walls so the shot has clear LoS (real damage, not fake client hits)
local function ResolveWallbangAim(aimPart, forcedTargetPos)
	local origin = GetAimOrigin(aimPart)
	if not origin and Camera then
		origin = Camera.CFrame.Position
	end
	if not origin then
		return aimPart
	end

	local look = GetAimLook(aimPart)
	if look.Magnitude < 1e-4 then
		return aimPart
	end
	look = look.Unit

	local ignore = {}
	if LocalPlayer.Character then
		ignore[#ignore + 1] = LocalPlayer.Character
	end
	if Camera then
		ignore[#ignore + 1] = Camera
	end
	WallbangRayParams.FilterDescendantsInstances = ignore

	local current = origin
	local traveled = 0
	local maxDistance = 2000
	local lastClearOrigin = nil
	local hitPos = forcedTargetPos

	for _ = 1, 48 do
		local remaining = maxDistance - traveled
		if remaining <= 0 then
			break
		end

		local result = workspace:Raycast(current, look * remaining, WallbangRayParams)
		if not result then
			break
		end

		if IsHumanoidPart(result.Instance) then
			hitPos = result.Position
			break
		end

		if IsWorldWallPart(result.Instance) then
			-- Spawn just past this wall surface
			lastClearOrigin = result.Position + look * 0.2
		end

		local step = (result.Position - current).Magnitude + 0.05
		traveled += step
		current = result.Position + look * 0.05
	end

	if forcedTargetPos then
		hitPos = forcedTargetPos
	end

	if lastClearOrigin and hitPos then
		return {
			CFrame = CFrame.new(lastClearOrigin, hitPos),
		}
	end

	return aimPart
end

SyncSilentAimFromUI = function()
	local enabledToggle = Toggles.SilentAimEnabled
	if enabledToggle then
		SilentAim.Enabled = enabledToggle.Value
	end

	local showFovToggle = Toggles.SilentAimShowFOV
	if showFovToggle then
		SilentAim.ShowFOV = showFovToggle.Value
	end

	local fovOption = Options.SilentAimFOV
	if fovOption then
		SilentAim.FOV = fovOption.Value
	end

	local hitPartOption = Options.SilentAimHitPart
	if hitPartOption then
		SilentAim.HitPart = ResolveSilentHitPart(hitPartOption.Value)
	end

	local predictionToggle = Toggles.SilentAimPrediction
	if predictionToggle then
		SilentAim.Prediction = predictionToggle.Value
	end
end

InitSilentAim = function()
	if oldCreateBullet or not BulletModule or typeof(hookfunction) ~= "function" then
		return
	end

	oldCreateBullet = hookfunction(BulletModule.CreateBullet, function(idk, model, model2, model3, aimPart, idk2, ammoType, tick, recoilPattern)
		SyncSilentAimFromUI()

		local ammoFolder = ReplicatedStorage:FindFirstChild("AmmoTypes")
		local ammo = ammoFolder and ammoType and ammoFolder:FindFirstChild(ammoType)

		if Misc and Misc.WallPenetration then
			ForceAmmoPenetration(ammo)
		end

		if Misc and Misc.NoRecoil then
			-- Zero recoil values but keep pattern length (empty table can break full-auto)
			if type(recoilPattern) == "table" then
				local function zeroRecoil(tbl, depth)
					if depth > 5 then
						return
					end
					for key, value in pairs(tbl) do
						local t = typeof(value)
						if t == "number" then
							tbl[key] = 0
						elseif t == "Vector2" or t == "Vector3" then
							tbl[key] = value * 0
						elseif t == "CFrame" then
							tbl[key] = CFrame.new()
						elseif t == "table" then
							zeroRecoil(value, depth + 1)
						end
					end
				end
				zeroRecoil(recoilPattern, 0)
			else
				recoilPattern = { 0, 0, 0, 0 }
			end

			-- Project Delta camera climb uses RecoilStrength / related AmmoTypes attrs
			if ammo then
				for _, attrName in {
					"RecoilStrength",
					"Recoil",
					"RecoilX",
					"RecoilY",
					"VerticalRecoil",
					"HorizontalRecoil",
					"CameraRecoil",
					"ViewmodelRecoil",
					"Kick",
					"KickStrength",
					"RecoilMultiplier",
					"RecoilScale",
				} do
					pcall(function()
						if ammo:GetAttribute(attrName) ~= nil then
							ammo:SetAttribute(attrName, 0)
						end
					end)
				end
			end
		end

		if Misc and Misc.NoSpread and ammo then
			for _, attrName in {
				"Spread",
				"MaxSpread",
				"MinSpread",
				"HipSpread",
				"AimSpread",
				"SpreadMultiplier",
				"SpreadScale",
				"Accuracy",
				"Bloom",
				"BloomMax",
			} do
				pcall(function()
					if ammo:GetAttribute(attrName) ~= nil then
						ammo:SetAttribute(attrName, 0)
					end
				end)
			end

			for attr, value in pairs(ammo:GetAttributes()) do
				if typeof(value) == "number" then
					local lower = tostring(attr):lower()
					if lower:find("spread", 1, true)
						or lower:find("bloom", 1, true)
						or lower:find("accuracy", 1, true)
						or lower:find("deviation", 1, true)
					then
						pcall(function()
							ammo:SetAttribute(attr, 0)
						end)
					end
				end
			end
		end

		if (Misc and Misc.NoRecoil) or (Misc and Misc.NoSpread) then
			pcall(ApplyAmmoGunMods, false)
		end

		local finalAim = aimPart

		if SilentAim.Enabled then
			local target = GetSilentTarget(model, model2, model3, aimPart)
			if target and ammo then
				local origin = GetAimOrigin(aimPart)
				if origin then
					local acceleration = ammo:GetAttribute("ProjectileDrop") or 0
					local projectileSpeed = ammo:GetAttribute("MuzzleVelocity") or 1000
					ammo:SetAttribute("Drag", 0)

					local targetPosition = SilentAim.Prediction
						and PredictTarget(target, origin, projectileSpeed, acceleration)
						or target.Position
					local vertical = ProjectileDrop(origin, targetPosition, projectileSpeed, acceleration)
					finalAim = {
						CFrame = CFrame.new(origin, targetPosition + vertical),
					}

					if Misc and Misc.WallPenetration then
						finalAim = ResolveWallbangAim(finalAim, targetPosition + vertical)
					end

					return oldCreateBullet(idk, model, model2, model3, finalAim, idk2, ammoType, tick, recoilPattern)
				end
			end
		end

		-- Wallbang without silent aim: fire from past walls along aim line
		if Misc and Misc.WallPenetration then
			finalAim = ResolveWallbangAim(aimPart, nil)
		end

		return oldCreateBullet(idk, model, model2, model3, finalAim, idk2, ammoType, tick, recoilPattern)
	end)
end

end

end)();

local AimbotBox = Tabs.Aimbot:AddLeftGroupbox("Aimbot")

AimbotBox:AddToggle("AimbotEnabled", {
	Text = "Aimbot",
	Default = false,
	Callback = function(value)
		Aimbot.Enabled = value
	end,
}):AddKeyPicker("AimbotKeybind", {
	Default = "MB2",
	Mode = "Hold",
	Text = "Aimbot",
	SyncToggleState = false,
})

AimbotBox:AddToggle("ShowFOV", {
	Text = "Show FOV",
	Default = false,
	Callback = function(value)
		Aimbot.ShowFOV = value
		UpdateFOV()
	end,
}):AddColorPicker("FOVColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "FOV Color",
	Callback = function(value)
		Aimbot.FOVColor = value
		UpdateFOV()
	end,
})

AimbotBox:AddToggle("FilledFOV", {
	Text = "Filled FOV",
	Default = false,
	Callback = function(value)
		Aimbot.FilledFOV = value
		UpdateFOV()
	end,
}):AddColorPicker("FilledFOVColor", {
	Default = Color3.fromRGB(255, 80, 80),
	Title = "Filled FOV Color",
	Callback = function(value)
		Aimbot.FilledFOVColor = value
		UpdateFOV()
	end,
})

AimbotBox:AddSlider("AimbotSmoothness", {
	Text = "Smoothness",
	Default = 40,
	Min = 1,
	Max = 100,
	Rounding = 0,
	Callback = function(value)
		Aimbot.Smoothness = value
	end,
})

AimbotBox:AddSlider("AimbotFOVSize", {
	Text = "FOV",
	Default = 120,
	Min = 1,
	Max = 360,
	Rounding = 0,
	Suffix = " deg",
	Callback = function(value)
		Aimbot.FOV = value
		UpdateFOV()
	end,
})

local MethodBox = Tabs.Aimbot:AddRightGroupbox("Aimbot Methods")

MethodBox:AddDropdown("AimbotMethod", {
	Text = "Method",
	Values = { "Mouse Aim", "Camera Aim" },
	Default = 1,
	Callback = function(value)
		Aimbot.Method = ResolveAimbotMethod(value)
	end,
})

local TriggerBox = Tabs.Aimbot:AddRightGroupbox("Trigger bot")

TriggerBox:AddToggle("TriggerBotEnabled", {
	Text = "Trigger Bot",
	Default = false,
	Callback = function(value)
		TriggerBot.Enabled = value
		if not value then
			TriggerBotTarget = nil
		end
	end,
})

TriggerBox:AddSlider("TriggerBotDelay", {
	Text = "Delay",
	Default = 50,
	Min = 0,
	Max = 500,
	Rounding = 0,
	Suffix = "ms",
	Callback = function(value)
		TriggerBot.Delay = value
	end,
})

TriggerBox:AddLabel("Visibility check is always on")

local SilentAimBox = Tabs.Aimbot:AddRightGroupbox("Silent Aim")

SilentAimBox:AddToggle("SilentAimEnabled", {
	Text = "Silent Aim",
	Default = false,
	Callback = function(value)
		SilentAim.Enabled = value
	end,
})

SilentAimBox:AddToggle("SilentAimShowFOV", {
	Text = "Show FOV",
	Default = false,
	Callback = function(value)
		SilentAim.ShowFOV = value
		UpdateFOV()
	end,
})

SilentAimBox:AddSlider("SilentAimFOV", {
	Text = "FOV Radius",
	Default = 600,
	Min = 1,
	Max = 1200,
	Rounding = 0,
	Callback = function(value)
		SilentAim.FOV = value
		UpdateFOV()
	end,
})

SilentAimBox:AddDropdown("SilentAimHitPart", {
	Text = "Hit Part",
	Values = SilentHitPartValues,
	Default = 1,
	Callback = function(value)
		SilentAim.HitPart = ResolveSilentHitPart(value)
	end,
})

SilentAimBox:AddToggle("SilentAimPrediction", {
	Text = "Prediction",
	Default = true,
	Callback = function(value)
		SilentAim.Prediction = value
	end,
})

----------------------------------------------------------------
-- Visuals / ESP (ScreenGui lines â€” works without Drawing API)
----------------------------------------------------------------
local ESP = {
	Bone = false,
	Box = false,
	Chams = false,
	Tracer = false,
	Name = false,
	Distance = false,
	HeadDot = false,
	ChineseHat = false,
	Health = false,
	HealthText = false,
	Self = false,
	BulletTracer = false,
	GunCham = false,
	BoxType = "Normal",
	ChamsStyle = "Filled",
	TracerOrigin = "Bottom",
	HeadDotStyle = "Filled",
	HealthStyle = "Gradient Health",
	SkeletonThickness = 2,
	MaxDistance = 5000,
	BoneColor = Color3.fromRGB(255, 255, 255),
	OccludedColor = Color3.fromRGB(255, 60, 60),
	VisibilityCheck = false,
	BoxColor = Color3.fromRGB(255, 255, 255),
	ChamsColor = Color3.fromRGB(255, 80, 80),
	TracerColor = Color3.fromRGB(255, 255, 255),
	NameColor = Color3.fromRGB(255, 255, 255),
	DistanceColor = Color3.fromRGB(255, 255, 255),
	HeadDotColor = Color3.fromRGB(255, 80, 80),
	ChineseHatColor = Color3.fromRGB(255, 215, 0),
	HealthTextColor = Color3.fromRGB(255, 255, 255),
	BulletTracerColor = Color3.fromRGB(255, 220, 100),
	BulletTracerThickness = 0.12,
	BulletTracerDuration = 0.45,
	BulletTracerRange = 2500,
	GunChamColor = Color3.fromRGB(255, 0, 255),
}

local NpcESP = {
	Enabled = false,
	Bone = false,
	Box = false,
	Chams = false,
	Tracer = false,
	Name = false,
	Distance = false,
	HeadDot = false,
	ChineseHat = false,
	Health = false,
	HealthText = false,
	BoxType = "Normal",
	ChamsStyle = "Filled",
	TracerOrigin = "Bottom",
	HeadDotStyle = "Filled",
	HealthStyle = "Gradient Health",
	SkeletonThickness = 2,
	MaxDistance = 5000,
	BoneColor = Color3.fromRGB(255, 180, 80),
	BoxColor = Color3.fromRGB(255, 180, 80),
	ChamsColor = Color3.fromRGB(255, 140, 40),
	TracerColor = Color3.fromRGB(255, 200, 120),
	NameColor = Color3.fromRGB(255, 220, 160),
	DistanceColor = Color3.fromRGB(255, 200, 120),
	HeadDotColor = Color3.fromRGB(255, 140, 40),
	ChineseHatColor = Color3.fromRGB(255, 200, 80),
	HealthTextColor = Color3.fromRGB(255, 255, 255),
}

local WorldESP = {
	Crates = false,
	CrateName = true,
	CrateDistance = true,
	Landmines = false,
	Extractions = false,
	MaxDistance = 500,
	LandmineMaxDistance = 800,
	ExtractionMaxDistance = 5000,
	CrateColor = Color3.fromRGB(255, 200, 80),
	LandmineColor = Color3.fromRGB(255, 60, 60),
	ExtractionColor = Color3.fromRGB(90, 255, 130),
	LandmineNameColor = Color3.fromRGB(255, 255, 255),
	NameColor = Color3.fromRGB(255, 255, 255),
	DistanceColor = Color3.fromRGB(200, 200, 200),
	PurpleSky = false,
	PurpleSkyColor = Color3.fromRGB(150, 0, 230),
}

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "WallhackESP"
ESPGui.IgnoreGuiInset = true
ESPGui.ResetOnSpawn = false
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ESPGui.DisplayOrder = 999999
ESPGui.Enabled = true
AttachOverlayGui(ESPGui)

local ESPGuiAttachFailed = false

local function EnsureESPGuiAttached()
	if ESPGui.Parent then
		ESPGuiAttachFailed = false
		return true
	end

	if ESPGuiAttachFailed then
		return false
	end

	if AttachOverlayGui(ESPGui) then
		return true
	end

	ESPGuiAttachFailed = true
	warn("[Wallhack.gg] ESP overlay could not attach to CoreGui")
	return false
end

local ESPCache = {}
local NpcCache = {}
local NpcList = {}
local LastNpcScan = 0
local NpcScanInterval = 2
local CrateCache = {}
local LandmineCache = {}
local ExtractionCache = {}
local CrateList = {}
local LandmineList = {}
local ExtractionList = {}
local LastCrateScan = 0
local LastLandmineScan = 0
local LastExtractionScan = 0
local LastCrateLabelRefresh = 0
local CrateScanInterval = 4
local LandmineScanInterval = 2
local CrateLabelRefreshInterval = 0.15
local ExtractionScanInterval = 0.75
local ExtractionDescendantHook = false
local LandmineDescendantHook = false

local TracerFolder = Instance.new("Folder")
TracerFolder.Name = "WallhackBulletTracers"
TracerFolder.Parent = workspace

local ActiveBulletTracers = {}
local LastBulletTracerShot = 0
local LastBulletMouseDown = false
local BulletTracerRayParams = RaycastParams.new()
BulletTracerRayParams.FilterType = Enum.RaycastFilterType.Exclude

local BulletPartKeywords = {
	"bullet",
	"tracer",
	"projectile",
	"round",
	"shell",
	"shot",
}

local SkeletonBones = {
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local HatSegments = 10
local HatLineCount = HatSegments * 2

local function NewGuiLine()
	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BorderSizePixel = 0
	line.BackgroundColor3 = Color3.new(1, 1, 1)
	line.Visible = false
	line.ZIndex = 20
	line.Parent = ESPGui
	return line
end

local function SetGuiLine(line, from, to, color, thickness)
	if not line then
		return
	end

	local delta = to - from
	local length = delta.Magnitude
	if length < 1 then
		line.Visible = false
		return
	end

	line.Size = UDim2.fromOffset(length, thickness or 2)
	line.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
	line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	line.BackgroundColor3 = color
	line.Visible = true
end

local function HideGuiLines(lines)
	if not lines then
		return
	end
	for _, line in lines do
		if line then
			line.Visible = false
		end
	end
end

local function NewTextLabel()
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromOffset(220, 18)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 13
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Visible = false
	label.ZIndex = 15
	label.Parent = ESPGui
	return label
end

local function NewGuiDot()
	local dot = Instance.new("Frame")
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(8, 8)
	dot.BorderSizePixel = 0
	dot.Visible = false
	dot.ZIndex = 16
	dot.Parent = ESPGui
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	return dot
end

local function GetTracerOriginFor(cfg)
	local vp = Camera.ViewportSize
	if cfg.TracerOrigin == "Top" then
		return Vector2.new(vp.X / 2, 0)
	elseif cfg.TracerOrigin == "Middle" then
		return Vector2.new(vp.X / 2, vp.Y / 2)
	end
	return Vector2.new(vp.X / 2, vp.Y)
end

local function GetStudDistance(fromPos, toPos)
	return (fromPos - toPos).Magnitude
end

local function GetLocalRoot()
	local char = LocalPlayer.Character
	if not char then
		return nil
	end
	return char:FindFirstChild("HumanoidRootPart", true)
		or char:FindFirstChild("RootPart", true)
		or char:FindFirstChild("UpperTorso", true)
		or char:FindFirstChild("Torso", true)
		or char:FindFirstChild("LowerTorso", true)
end

local function GetCharacterRoot(character)
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart", true)
		or character:FindFirstChild("RootPart", true)
		or character:FindFirstChild("UpperTorso", true)
		or character:FindFirstChild("Torso", true)
		or character:FindFirstChild("LowerTorso", true)
		or character:FindFirstChild("Head", true)
end

local function ResolveDropdown(value, values, fallback)
	if type(value) == "number" then
		return values[value] or fallback
	end
	return value or fallback
end

local function SyncESPFromUI()
	local function toggle(name, key)
		local t = Toggles[name]
		if t then
			ESP[key] = t.Value
		end
	end

	local function option(name, key)
		local o = Options[name]
		if o then
			ESP[key] = o.Value
		end
	end

	toggle("BoneESP", "Bone")
	toggle("VisibilityCheck", "VisibilityCheck")
	toggle("BoxESP", "Box")
	toggle("ChamsESP", "Chams")
	toggle("TracerESP", "Tracer")
	toggle("NameESP", "Name")
	toggle("DistanceESP", "Distance")
	toggle("HeadDotESP", "HeadDot")
	toggle("ChineseHatESP", "ChineseHat")
	toggle("HealthESP", "Health")
	toggle("HealthBarTextESP", "HealthText")
	toggle("SelfESP", "Self")
	toggle("BulletTracerESP", "BulletTracer")
	toggle("GunChamESP", "GunCham")

	option("BoneColor", "BoneColor")
	option("OccludedColor", "OccludedColor")
	option("BoxColor", "BoxColor")
	option("ChamsColor", "ChamsColor")
	option("TracerColor", "TracerColor")
	option("NameESPColor", "NameColor")
	option("DistanceESPColor", "DistanceColor")
	option("HeadDotColor", "HeadDotColor")
	option("ChineseHatColor", "ChineseHatColor")
	option("HealthTextColor", "HealthTextColor")
	option("BulletTracerColor", "BulletTracerColor")
	option("BulletTracerThickness", "BulletTracerThickness")
	option("BulletTracerDuration", "BulletTracerDuration")
	option("GunChamColor", "GunChamColor")
	option("SkeletonThickness", "SkeletonThickness")

	if Options.BoxType then
		ESP.BoxType = ResolveDropdown(Options.BoxType.Value, { "Normal", "Cornered", "3D" }, ESP.BoxType)
	end
	if Options.ChamsStyle then
		ESP.ChamsStyle = ResolveDropdown(Options.ChamsStyle.Value, { "Filled", "WireFrame" }, ESP.ChamsStyle)
	end
	if Options.TracerOrigin then
		ESP.TracerOrigin = ResolveDropdown(Options.TracerOrigin.Value, { "Bottom", "Middle", "Top" }, ESP.TracerOrigin)
	end
	if Options.HeadDotStyle then
		ESP.HeadDotStyle = ResolveDropdown(Options.HeadDotStyle.Value, { "Filled", "Hollow" }, ESP.HeadDotStyle)
	end
	if Options.HealthStyle then
		ESP.HealthStyle = ResolveDropdown(
			Options.HealthStyle.Value,
			{ "Normal Health", "Gradient Health" },
			ESP.HealthStyle
		)
	end
end

local function SyncNpcESPFromUI()
	local function toggle(name, key)
		local t = Toggles[name]
		if t then
			NpcESP[key] = t.Value
		end
	end

	local function option(name, key)
		local o = Options[name]
		if o then
			NpcESP[key] = o.Value
		end
	end

	toggle("NpcESPEnabled", "Enabled")
	toggle("NpcBoneESP", "Bone")
	toggle("NpcBoxESP", "Box")
	toggle("NpcChamsESP", "Chams")
	toggle("NpcTracerESP", "Tracer")
	toggle("NpcNameESP", "Name")
	toggle("NpcDistanceESP", "Distance")
	toggle("NpcHeadDotESP", "HeadDot")
	toggle("NpcChineseHatESP", "ChineseHat")
	toggle("NpcHealthESP", "Health")
	toggle("NpcHealthBarTextESP", "HealthText")

	option("NpcBoneColor", "BoneColor")
	option("NpcBoxColor", "BoxColor")
	option("NpcChamsColor", "ChamsColor")
	option("NpcTracerColor", "TracerColor")
	option("NpcNameESPColor", "NameColor")
	option("NpcDistanceESPColor", "DistanceColor")
	option("NpcHeadDotColor", "HeadDotColor")
	option("NpcChineseHatColor", "ChineseHatColor")
	option("NpcHealthTextColor", "HealthTextColor")
	option("NpcSkeletonThickness", "SkeletonThickness")

	if Options.NpcBoxType then
		NpcESP.BoxType = ResolveDropdown(Options.NpcBoxType.Value, { "Normal", "Cornered", "3D" }, NpcESP.BoxType)
	end
	if Options.NpcChamsStyle then
		NpcESP.ChamsStyle = ResolveDropdown(Options.NpcChamsStyle.Value, { "Filled", "WireFrame" }, NpcESP.ChamsStyle)
	end
	if Options.NpcTracerOrigin then
		NpcESP.TracerOrigin = ResolveDropdown(
			Options.NpcTracerOrigin.Value,
			{ "Bottom", "Middle", "Top" },
			NpcESP.TracerOrigin
		)
	end
	if Options.NpcHeadDotStyle then
		NpcESP.HeadDotStyle = ResolveDropdown(Options.NpcHeadDotStyle.Value, { "Filled", "Hollow" }, NpcESP.HeadDotStyle)
	end
	if Options.NpcHealthStyle then
		NpcESP.HealthStyle = ResolveDropdown(
			Options.NpcHealthStyle.Value,
			{ "Normal Health", "Gradient Health" },
			NpcESP.HealthStyle
		)
	end
end

local function SyncWorldESPFromUI()
	local function toggle(name, key)
		local t = Toggles[name]
		if t then
			WorldESP[key] = t.Value
		end
	end

	local function option(name, key)
		local o = Options[name]
		if o then
			WorldESP[key] = o.Value
		end
	end

	toggle("CrateESP", "Crates")
	toggle("CrateNameESP", "CrateName")
	toggle("CrateDistanceESP", "CrateDistance")
	toggle("LandmineESP", "Landmines")
	toggle("ExtractionESP", "Extractions")
	toggle("PurpleSky", "PurpleSky")
	option("CrateHighlightColor", "CrateColor")
	option("ExtractionHighlightColor", "ExtractionColor")
	option("CrateNameColor", "NameColor")
	option("CrateDistanceColor", "DistanceColor")
	option("CrateMaxDistance", "MaxDistance")
	option("LandmineMaxDistance", "LandmineMaxDistance")
	option("LandmineHighlightColor", "LandmineColor")
	option("ExtractionMaxDistance", "ExtractionMaxDistance")
	option("PurpleSkyColor", "PurpleSkyColor")
end

local function IsWithinDistance(worldPos, maxDist)
	local root = GetLocalRoot()
	if not root then
		return true
	end
	return GetStudDistance(root.Position, worldPos) <= maxDist
end

local function GetEdgeScreenPosition(worldPos, margin)
	if not Camera then
		return Vector2.zero, false
	end

	margin = margin or 42
	local viewport = Camera.ViewportSize
	local center = viewport / 2
	local v = Camera:WorldToViewportPoint(worldPos)
	local screenPos = Vector2.new(v.X, v.Y)
	local onScreen = v.Z > 0
		and screenPos.X >= 0
		and screenPos.X <= viewport.X
		and screenPos.Y >= 0
		and screenPos.Y <= viewport.Y

	if onScreen then
		return screenPos, true
	end

	local dir = screenPos - center
	if v.Z <= 0 then
		dir = -dir
	end
	if dir.Magnitude < 1 then
		dir = Vector2.new(0, -1)
	else
		dir = dir.Unit
	end

	local half = viewport / 2 - Vector2.new(margin, margin)
	local scaleX = dir.X ~= 0 and (half.X / math.abs(dir.X)) or math.huge
	local scaleY = dir.Y ~= 0 and (half.Y / math.abs(dir.Y)) or math.huge
	return center + dir * math.min(scaleX, scaleY), false
end

local function DestroyChamsHighlight(data)
	if data and data.Highlight then
		data.Highlight:Destroy()
		data.Highlight = nil
	end
end

local function ClearWireAdornments(data)
	if not data then
		return
	end

	if data.WireChildConn then
		data.WireChildConn:Disconnect()
		data.WireChildConn = nil
	end

	if data.WireAdornments then
		for _, wire in pairs(data.WireAdornments) do
			if wire then
				wire:Destroy()
			end
		end
		data.WireAdornments = nil
	end

	if data.WireCharacter and data.WireCharacter.Parent then
		for _, child in data.WireCharacter:GetChildren() do
			if child:IsA("BasePart") then
				local wire = child:FindFirstChild("Wireframe")
				if wire then
					wire:Destroy()
				end
			end
		end
	end
	data.WireCharacter = nil
end

local function ClearWireframeChams(data)
	if not data then
		return
	end
	ClearWireAdornments(data)
end

----------------------------------------------------------------
-- WireFrame ESP — exact WireframeHandleAdornment method you provided
----------------------------------------------------------------
local function createWireframe(part, color, thickness)
	if not part:IsA("BasePart") then
		return nil
	end

	-- Skip invisible/helper parts
	if part.Transparency >= 1 then
		return nil
	end

	local existing = part:FindFirstChild("Wireframe")
	if existing and existing:IsA("WireframeHandleAdornment") then
		existing.Color3 = color
		existing.Thickness = thickness
		existing.AlwaysOnTop = true
		existing.Visible = true
		existing.Adornee = part
		return existing
	elseif existing then
		existing:Destroy()
	end

	local wire = Instance.new("WireframeHandleAdornment")
	wire.Name = "Wireframe"
	wire.Adornee = part
	wire.AlwaysOnTop = true
	wire.ZIndex = 10
	wire.Color3 = color
	wire.Thickness = thickness
	wire.Parent = part

	local half = part.Size / 2

	local p1 = Vector3.new(-half.X, -half.Y, -half.Z)
	local p2 = Vector3.new(half.X, -half.Y, -half.Z)
	local p3 = Vector3.new(half.X, half.Y, -half.Z)
	local p4 = Vector3.new(-half.X, half.Y, -half.Z)

	local p5 = Vector3.new(-half.X, -half.Y, half.Z)
	local p6 = Vector3.new(half.X, -half.Y, half.Z)
	local p7 = Vector3.new(half.X, half.Y, half.Z)
	local p8 = Vector3.new(-half.X, half.Y, half.Z)

	-- Outer edges
	wire:AddLine(p1, p2)
	wire:AddLine(p2, p3)
	wire:AddLine(p3, p4)
	wire:AddLine(p4, p1)

	wire:AddLine(p5, p6)
	wire:AddLine(p6, p7)
	wire:AddLine(p7, p8)
	wire:AddLine(p8, p5)

	wire:AddLine(p1, p5)
	wire:AddLine(p2, p6)
	wire:AddLine(p3, p7)
	wire:AddLine(p4, p8)

	-- A couple of diagonals for the triangular look
	wire:AddLine(p1, p3)
	wire:AddLine(p5, p7)

	return wire
end

local function ApplyWireframeChams(character, data, color)
	DestroyChamsHighlight(data)

	-- New character (respawn) — re-run setup like your CharacterAdded hook
	if data.WireCharacter and data.WireCharacter ~= character then
		ClearWireAdornments(data)
	end

	local thickness = 1
	data.WireAdornments = data.WireAdornments or {}
	data.WireCharacter = character

	-- Same as your setupCharacter: only direct BasePart children
	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("BasePart") then
			local wire = createWireframe(object, color, thickness)
			if wire then
				data.WireAdornments[object] = wire
			end
		end
	end

	-- Same as your ChildAdded hook (once per character)
	if not data.WireChildConn then
		data.WireChildConn = character.ChildAdded:Connect(function(object)
			if object:IsA("BasePart") then
				task.wait()
				if data.WireCharacter ~= character then
					return
				end
				local wire = createWireframe(object, color, thickness)
				if wire then
					data.WireAdornments = data.WireAdornments or {}
					data.WireAdornments[object] = wire
				end
			end
		end)
	else
		-- Keep color in sync while WireFrame stays on
		for part, wire in pairs(data.WireAdornments) do
			if wire and wire.Parent and part.Parent then
				wire.Color3 = color
				wire.Thickness = thickness
			end
		end
	end
end

local function ClearPlayerESP(player)
	local data = ESPCache[player]
	if not data then
		return
	end

	if data.Lines then
		for _, line in data.Lines do
			if line then
				line:Destroy()
			end
		end
	end

	if data.BoxLines then
		for _, line in data.BoxLines do
			if line then
				line:Destroy()
			end
		end
	end

	if data.HatLines then
		for _, line in data.HatLines do
			if line then
				line:Destroy()
			end
		end
	end

	if data.TracerLine then
		data.TracerLine:Destroy()
	end

	if data.NameLabel then
		data.NameLabel:Destroy()
	end

	if data.DistanceLabel then
		data.DistanceLabel:Destroy()
	end

	if data.HeadDotStroke then
		data.HeadDotStroke:Destroy()
	end

	if data.HeadDot then
		data.HeadDot:Destroy()
	end

	if data.HealthBG then
		data.HealthBG:Destroy()
	end

	if data.HealthFill then
		data.HealthFill:Destroy()
	end

	if data.HealthTextLabel then
		data.HealthTextLabel:Destroy()
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end

	ClearWireframeChams(data)

	ESPCache[player] = nil
end

local function ClearCrateESP(crate)
	local data = CrateCache[crate]
	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end
	if data.NameLabel then
		data.NameLabel:Destroy()
	end
	if data.DistanceLabel then
		data.DistanceLabel:Destroy()
	end

	CrateCache[crate] = nil
end

local function HideCrateESPVisuals(crate)
	local data = CrateCache[crate]
	if not data then
		return
	end

	if data.Highlight then
		data.Highlight.Enabled = false
	end
	if data.NameLabel then
		data.NameLabel.Visible = false
	end
	if data.DistanceLabel then
		data.DistanceLabel.Visible = false
	end
end

local function ClearLandmineESP(mine)
	local data = LandmineCache[mine]
	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end
	if data.NameLabel then
		data.NameLabel:Destroy()
	end

	LandmineCache[mine] = nil
end

local function ClearExtractionESP(extraction)
	local data = ExtractionCache[extraction]
	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end

	ExtractionCache[extraction] = nil
end

local function CreateCharacterESPData()
	local data = {
		Lines = {},
		BoxLines = {},
		HatLines = {},
		TracerLine = NewGuiLine(),
		NameLabel = NewTextLabel(),
		DistanceLabel = NewTextLabel(),
		HeadDot = NewGuiDot(),
		HeadDotStroke = nil,
		HealthBG = nil,
		HealthFill = nil,
		HealthTextLabel = NewTextLabel(),
		HealthGradient = nil,
		Highlight = nil,
	}

	for i = 1, #SkeletonBones do
		data.Lines[i] = NewGuiLine()
	end

	for i = 1, 16 do
		data.BoxLines[i] = NewGuiLine()
	end

	for i = 1, HatLineCount do
		data.HatLines[i] = NewGuiLine()
	end

	local healthBG = Instance.new("Frame")
	healthBG.BorderSizePixel = 0
	healthBG.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	healthBG.BackgroundTransparency = 0.25
	healthBG.ClipsDescendants = true
	healthBG.Visible = false
	healthBG.ZIndex = 14
	healthBG.Parent = ESPGui
	data.HealthBG = healthBG

	local healthFill = Instance.new("Frame")
	healthFill.BorderSizePixel = 0
	healthFill.BackgroundColor3 = Color3.new(1, 1, 1)
	healthFill.BackgroundTransparency = 0
	healthFill.AnchorPoint = Vector2.new(0, 0)
	healthFill.Position = UDim2.fromOffset(0, 0)
	healthFill.Size = UDim2.fromOffset(4, 0)
	healthFill.Visible = false
	healthFill.ZIndex = 15
	healthFill.Parent = healthBG
	data.HealthFill = healthFill

	local healthGradient = Instance.new("UIGradient")
	healthGradient.Name = "HealthGradient"
	healthGradient.Rotation = 90
	healthGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 140, 0)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0)),
	})
	healthGradient.Parent = healthFill
	data.HealthGradient = healthGradient

	return data
end

local function HideCharacterESP(data)
	if not data then
		return
	end

	HideGuiLines(data.Lines)
	HideGuiLines(data.BoxLines)
	HideGuiLines(data.HatLines)

	if data.TracerLine then
		data.TracerLine.Visible = false
	end
	if data.NameLabel then
		data.NameLabel.Visible = false
	end
	if data.DistanceLabel then
		data.DistanceLabel.Visible = false
	end
	if data.HeadDot then
		data.HeadDot.Visible = false
	end
	if data.HealthBG then
		data.HealthBG.Visible = false
	end
	if data.HealthTextLabel then
		data.HealthTextLabel.Visible = false
	end
	if data.Highlight then
		data.Highlight:Destroy()
		data.Highlight = nil
	end
	ClearWireframeChams(data)
end

local function ClearCharacterESPData(data)
	if not data then
		return
	end

	if data.Lines then
		for _, line in data.Lines do
			if line then
				line:Destroy()
			end
		end
	end

	if data.BoxLines then
		for _, line in data.BoxLines do
			if line then
				line:Destroy()
			end
		end
	end

	if data.HatLines then
		for _, line in data.HatLines do
			if line then
				line:Destroy()
			end
		end
	end

	if data.TracerLine then
		data.TracerLine:Destroy()
	end
	if data.NameLabel then
		data.NameLabel:Destroy()
	end
	if data.DistanceLabel then
		data.DistanceLabel:Destroy()
	end
	if data.HeadDotStroke then
		data.HeadDotStroke:Destroy()
	end
	if data.HeadDot then
		data.HeadDot:Destroy()
	end
	if data.HealthBG then
		data.HealthBG:Destroy()
	end
	if data.HealthFill then
		data.HealthFill:Destroy()
	end
	if data.HealthTextLabel then
		data.HealthTextLabel:Destroy()
	end
	if data.Highlight then
		data.Highlight:Destroy()
	end
	ClearWireframeChams(data)
end

local function HidePlayerESP(player)
	HideCharacterESP(ESPCache[player])
end

local function EnsurePlayerESP(player)
	if ESPCache[player] then
		local data = ESPCache[player]
		if not data.HealthTextLabel then
			data.HealthTextLabel = NewTextLabel()
		end
		if not data.HatLines then
			data.HatLines = {}
			for i = 1, HatLineCount do
				data.HatLines[i] = NewGuiLine()
			end
		end
		return data
	end

	local data = CreateCharacterESPData()
	ESPCache[player] = data
	return data
end

local function ClearNpcESP(npc)
	local data = NpcCache[npc]
	if not data then
		return
	end

	ClearCharacterESPData(data)
	NpcCache[npc] = nil
end

local function HideNpcESP(npc)
	HideCharacterESP(NpcCache[npc])
end

local function EnsureNpcESP(npc)
	if NpcCache[npc] then
		return NpcCache[npc]
	end

	local data = CreateCharacterESPData()
	NpcCache[npc] = data
	return data
end

local function EnsureCrateESP(crate)
	if CrateCache[crate] then
		return CrateCache[crate]
	end

	local data = {
		Highlight = nil,
		NameLabel = NewTextLabel(),
		DistanceLabel = NewTextLabel(),
	}

	data.NameLabel.TextSize = 14
	data.NameLabel.ZIndex = 20
	data.DistanceLabel.TextSize = 14
	data.DistanceLabel.ZIndex = 20

	CrateCache[crate] = data
	return data
end

local function NewExtractionIcon()
	local container = Instance.new("Frame")
	container.Name = "WallhackExtractionIcon"
	container.Size = UDim2.fromOffset(58, 72)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.ZIndex = 20
	container.Parent = ESPGui

	local ring = Instance.new("Frame")
	ring.Name = "Ring"
	ring.Size = UDim2.fromOffset(54, 54)
	ring.AnchorPoint = Vector2.new(0.5, 0)
	ring.Position = UDim2.new(0.5, 0, 0, 0)
	ring.BackgroundTransparency = 1
	ring.BorderSizePixel = 0
	ring.Parent = container
	Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

	local ringFill = Instance.new("Frame")
	ringFill.Name = "Fill"
	ringFill.Size = UDim2.fromScale(1, 1)
	ringFill.BackgroundColor3 = Color3.fromRGB(90, 255, 130)
	ringFill.BackgroundTransparency = 0.78
	ringFill.BorderSizePixel = 0
	ringFill.Parent = ring
	Instance.new("UICorner", ringFill).CornerRadius = UDim.new(1, 0)

	local ringStroke = Instance.new("UIStroke")
	ringStroke.Name = "Stroke"
	ringStroke.Thickness = 3
	ringStroke.Color = Color3.fromRGB(90, 255, 130)
	ringStroke.Parent = ring

	local arrow = Instance.new("TextLabel")
	arrow.Name = "Arrow"
	arrow.BackgroundTransparency = 1
	arrow.Size = UDim2.fromOffset(14, 22)
	arrow.Position = UDim2.fromOffset(9, 15)
	arrow.Font = Enum.Font.SourceSansBold
	arrow.TextSize = 20
	arrow.TextColor3 = Color3.fromRGB(90, 255, 130)
	arrow.TextStrokeTransparency = 0.45
	arrow.Text = ">"
	arrow.Parent = ring

	local doorGap = Instance.new("Frame")
	doorGap.Name = "DoorGap"
	doorGap.Size = UDim2.fromOffset(6, 24)
	doorGap.Position = UDim2.fromOffset(20, 14)
	doorGap.BackgroundColor3 = Color3.fromRGB(20, 60, 35)
	doorGap.BackgroundTransparency = 0.15
	doorGap.BorderSizePixel = 0
	doorGap.Parent = ring

	local door = Instance.new("Frame")
	door.Name = "Door"
	door.Size = UDim2.fromOffset(15, 24)
	door.Position = UDim2.fromOffset(26, 14)
	door.BackgroundColor3 = Color3.fromRGB(90, 255, 130)
	door.BorderSizePixel = 0
	door.Parent = ring

	local doorStroke = Instance.new("UIStroke")
	doorStroke.Color = Color3.fromRGB(30, 100, 55)
	doorStroke.Thickness = 1
	doorStroke.Parent = door

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "Distance"
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Size = UDim2.fromOffset(58, 16)
	distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
	distanceLabel.Position = UDim2.new(0.5, 0, 0, 56)
	distanceLabel.Font = Enum.Font.SourceSansBold
	distanceLabel.TextSize = 14
	distanceLabel.TextColor3 = Color3.fromRGB(90, 255, 130)
	distanceLabel.TextStrokeTransparency = 0.35
	distanceLabel.Text = "0m"
	distanceLabel.Parent = container

	return {
		Container = container,
		Ring = ring,
		RingFill = ringFill,
		RingStroke = ringStroke,
		Arrow = arrow,
		Door = door,
		DoorGap = doorGap,
		DistanceLabel = distanceLabel,
	}
end

local function SetExtractionIconColor(icon, color)
	if not icon then
		return
	end

	if icon.RingFill then
		icon.RingFill.BackgroundColor3 = color
	end
	if icon.RingStroke then
		icon.RingStroke.Color = color
	end
	if icon.Arrow then
		icon.Arrow.TextColor3 = color
	end
	if icon.Door then
		icon.Door.BackgroundColor3 = color
	end
	if icon.DistanceLabel then
		icon.DistanceLabel.TextColor3 = color
	end
end

local function EnsureExtractionESP(extraction)
	if ExtractionCache[extraction] then
		return ExtractionCache[extraction]
	end

	local data = {
		Highlight = nil,
	}

	ExtractionCache[extraction] = data
	return data
end

local function ProjectWorld(pos, requireOnScreen)
	if not Camera then
		return Vector2.zero, false, 0
	end

	local v, onScreen = Camera:WorldToViewportPoint(pos)
	local inFront = v.Z > 0
	local visible = inFront and (not requireOnScreen or onScreen)
	return Vector2.new(v.X, v.Y), visible, v.Z
end

local function WorldToScreen(pos)
	return ProjectWorld(pos, true)
end

local function WorldToScreenAny(pos)
	return ProjectWorld(pos, false)
end

local UpdateBulletTracers, ClearAllBulletTracers

(function()

local function ClearSingleBulletTracer(tracer)
	if tracer.Part then
		tracer.Part:Destroy()
	end
	if tracer.Line then
		tracer.Line:Destroy()
	end
end

ClearAllBulletTracers = function()
	for i = #ActiveBulletTracers, 1, -1 do
		ClearSingleBulletTracer(ActiveBulletTracers[i])
		ActiveBulletTracers[i] = nil
	end
end

local function GetBulletOrigin()
	local character = LocalPlayer.Character
	if not character or not Camera then
		return Camera and Camera.CFrame.Position or Vector3.zero
	end

	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		for _, name in { "Muzzle", "Barrel", "FirePoint", "GunMuzzle", "Flash", "MuzzleFlash", "Handle" } do
			local obj = tool:FindFirstChild(name, true)
			if obj and obj:IsA("Attachment") then
				return obj.WorldPosition
			end
			if obj and obj:IsA("BasePart") then
				return obj.Position
			end
		end
	end

	local head = character:FindFirstChild("Head")
	if head then
		return head.Position
	end

	return Camera.CFrame.Position
end

local function UpdateTracerVisual(tracer)
	local startPos = tracer.Start
	local endPos = tracer.EndPos
	local delta = endPos - startPos
	local length = delta.Magnitude
	if length < 0.2 then
		return
	end

	local thickness = math.clamp(ESP.BulletTracerThickness, 0.04, 0.5)
	if tracer.Part then
		tracer.Part.Size = Vector3.new(thickness, thickness, length)
		tracer.Part.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -length / 2)
		tracer.Part.Color = ESP.BulletTracerColor
	end

	local a, aOk = WorldToScreen(startPos)
	local b, bOk = WorldToScreen(endPos)
	if tracer.Line then
		if aOk and bOk then
			SetGuiLine(tracer.Line, a, b, ESP.BulletTracerColor, math.clamp(thickness * 50, 2, 6))
		else
			tracer.Line.Visible = false
		end
	end
end

local function AddBulletTracer(startPos, endPos, trackPart)
	local delta = endPos - startPos
	if delta.Magnitude < 0.2 then
		return
	end

	local part = Instance.new("Part")
	part.Name = "WallhackBulletTracer"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = ESP.BulletTracerColor
	part.Transparency = 0.1

	local ok = pcall(function()
		part.Parent = TracerFolder
	end)
	if not ok then
		part:Destroy()
		part = nil
	end

	local tracer = {
		Part = part,
		Line = NewGuiLine(),
		Start = startPos,
		EndPos = endPos,
		Created = tick(),
		TrackPart = trackPart,
	}

	UpdateTracerVisual(tracer)
	table.insert(ActiveBulletTracers, tracer)

	while #ActiveBulletTracers > 50 do
		ClearSingleBulletTracer(table.remove(ActiveBulletTracers, 1))
	end
end

local function FireLocalBulletTracer()
	SyncESPFromUI()

	if not ESP.BulletTracer then
		return
	end

	local now = tick()
	if now - LastBulletTracerShot < 0.03 then
		return
	end
	LastBulletTracerShot = now

	local character = LocalPlayer.Character
	if not character or not Camera then
		return
	end

	local origin = GetBulletOrigin()
	local direction = Camera.CFrame.LookVector
	BulletTracerRayParams.FilterDescendantsInstances = { character, TracerFolder }

	local result = workspace:Raycast(origin, direction * ESP.BulletTracerRange, BulletTracerRayParams)
	local endPos = result and result.Position or (origin + direction * ESP.BulletTracerRange)

	AddBulletTracer(origin, endPos)
end

local function IsLikelyBulletPart(part)
	if not part:IsA("BasePart") then
		return false
	end

	local name = part.Name:lower()
	for _, keyword in BulletPartKeywords do
		if name:find(keyword, 1, true) then
			return true
		end
	end

	return false
end

local function TrackGameBulletPart(part)
	if not ESP.BulletTracer or not part or not part.Parent then
		return
	end

	local character = LocalPlayer.Character
	if character and part:IsDescendantOf(character) then
		return
	end

	local startPos = part.Position
	task.delay(0.03, function()
		if part.Parent then
			AddBulletTracer(startPos, part.Position, part)
		end
	end)
end

UpdateBulletTracers = function()
	SyncESPFromUI()

	local mouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	if ESP.BulletTracer and mouseDown and not LastBulletMouseDown then
		FireLocalBulletTracer()
	end
	LastBulletMouseDown = mouseDown

	if not ESP.BulletTracer then
		ClearAllBulletTracers()
		return
	end

	local now = tick()
	local lifetime = math.clamp(ESP.BulletTracerDuration, 0.1, 2)

	for i = #ActiveBulletTracers, 1, -1 do
		local tracer = ActiveBulletTracers[i]
		local age = now - tracer.Created

		if tracer.TrackPart and tracer.TrackPart.Parent then
			tracer.EndPos = tracer.TrackPart.Position
		end

		if age >= lifetime then
			ClearSingleBulletTracer(tracer)
			table.remove(ActiveBulletTracers, i)
		else
			local fade = age / lifetime
			if tracer.Part then
				tracer.Part.Transparency = 0.1 + fade * 0.85
			end
			if tracer.Line then
				tracer.Line.BackgroundTransparency = fade * 0.65
			end
			UpdateTracerVisual(tracer)
		end
	end
end

local function HookBulletTracerTool(tool)
	if not tool:IsA("Tool") or tool:GetAttribute("WallhackBulletTracerHook") then
		return
	end

	tool:SetAttribute("WallhackBulletTracerHook", true)
	tool.Activated:Connect(function()
		FireLocalBulletTracer()
	end)
end

local function HookBulletTracerCharacter(character)
	if not character then
		return
	end

	for _, child in character:GetChildren() do
		HookBulletTracerTool(child)
	end

	character.ChildAdded:Connect(function(child)
		HookBulletTracerTool(child)
	end)
end

workspace.DescendantAdded:Connect(function(obj)
	if ESP.BulletTracer and IsLikelyBulletPart(obj) then
		TrackGameBulletPart(obj)
	end
end)

LocalPlayer.CharacterAdded:Connect(HookBulletTracerCharacter)
if LocalPlayer.Character then
	HookBulletTracerCharacter(LocalPlayer.Character)
end

end)();

local UpdateGunCham, ClearGunCham
local HasHumanoidModel, IsPlayerCharacterModel, IsLikelyNPC, IsExcludedWorldProp
local NameMatchesContainer, NameMatchesContainerModel

(function()

local GunChamHighlight = nil
local GunChamTarget = nil
local GunChamPartCache = {}

local GunChamFolder = Instance.new("Folder")
GunChamFolder.Name = "WallhackGunCham"
AttachOverlayGui(GunChamFolder)

local GunBodyPartNames = {
	Head = true,
	HumanoidRootPart = true,
	RootPart = true,
	UpperTorso = true,
	LowerTorso = true,
	Torso = true,
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	LeftUpperLeg = true,
	LeftLowerLeg = true,
	LeftFoot = true,
	RightUpperLeg = true,
	RightLowerLeg = true,
	RightFoot = true,
}

local GunNameKeywords = {
	"gun",
	"weapon",
	"rifle",
	"pistol",
	"smg",
	"shotgun",
	"carbine",
	"firearm",
	"barrel",
	"glock",
	"ak",
	"m4",
	"mp5",
	"svd",
	"mosin",
	"knife",
	"blade",
	"sword",
	"melee",
	"viewmodel",
	"view_model",
	"arms",
	"item",
	"equipped",
	"holdable",
}

local GunHelperPartNames = {
	aim = true,
	aimpart = true,
	["aim part"] = true,
	laser = true,
	flash = true,
	muzzleflash = true,
	light = true,
	beam = true,
	hitbox = true,
	collision = true,
	root = true,
	primarypart = true,
}

local CharacterBodyNames = {
	Head = true,
	HumanoidRootPart = true,
	UpperTorso = true,
	LowerTorso = true,
	Torso = true,
}

local function NameLooksLikeGun(name)
	name = name:lower()
	for _, keyword in GunNameKeywords do
		if name:find(keyword, 1, true) then
			return true
		end
	end
	return false
end

local function ModelHasHumanoid(model)
	return model and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function ModelHasWeaponPart(model)
	for _, desc in model:GetDescendants() do
		if desc:IsA("Attachment") then
			local partName = desc.Name:lower()
			if partName:find("muzzle", 1, true)
				or partName:find("barrel", 1, true)
				or partName:find("firepoint", 1, true)
			then
				return true
			end
		end
		if desc:IsA("BasePart") then
			local partName = desc.Name:lower()
			if partName:find("muzzle", 1, true)
				or partName:find("barrel", 1, true)
				or partName:find("handle", 1, true)
				or partName:find("slide", 1, true)
			then
				return true
			end
		end
	end
	return false
end

local function IsLikelyHeldWeapon(instance)
	if not instance then
		return false
	end
	if instance:IsA("Tool") then
		return true
	end
	if not instance:IsA("Model") or ModelHasHumanoid(instance) then
		return false
	end
	if NameLooksLikeGun(instance.Name) or ModelHasWeaponPart(instance) then
		return true
	end
	return false
end

local function IsCharacterBodyModel(model)
	if not model:IsA("Model") then
		return false
	end
	if ModelHasHumanoid(model) then
		return true
	end
	if CharacterBodyNames[model.Name] then
		return true
	end
	local name = model.Name:lower()
	if name:find("arm", 1, true) and not NameLooksLikeGun(name) then
		return true
	end
	return false
end

local function IsGunBodyPart(part)
	if not part:IsA("BasePart") then
		return false
	end
	if GunBodyPartNames[part.Name] then
		return true
	end
	local partName = part.Name:lower()
	return partName:find("arm", 1, true)
		or partName:find("hand", 1, true)
		or partName:find("finger", 1, true)
		or partName:find("sleeve", 1, true)
		or partName:find("glove", 1, true)
end

local function IsExcludedGunPart(part)
	if not part:IsA("BasePart") then
		return true
	end

	if IsGunBodyPart(part) then
		return true
	end

	local partName = part.Name:lower()
	if GunHelperPartNames[partName] or partName:find("aim", 1, true) or partName:find("laser", 1, true) then
		return true
	end

	if part.Transparency >= 0.85 then
		return true
	end

	local size = part.Size
	if math.min(size.X, size.Y, size.Z) <= 0.08 then
		return true
	end

	return false
end

local function CountGunParts(model)
	local count = 0
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and not IsExcludedGunPart(part) then
			count += 1
		end
	end
	return count
end

local function FindWeaponModelInContainer(container)
	if not container then
		return nil
	end

	local best = nil
	local bestScore = 0

	for _, desc in container:GetDescendants() do
		if desc:IsA("Model") and not ModelHasHumanoid(desc) and not IsCharacterBodyModel(desc) then
			if not ModelHasWeaponPart(desc) then
				continue
			end

			local score = 0
			local name = desc.Name:lower()

			score += 40
			if NameLooksLikeGun(name) then
				score += 25
			end
			if name:find("arm", 1, true) or name:find("hand", 1, true) or name:find("sleeve", 1, true) then
				score -= 60
			end

			local partCount = CountGunParts(desc)

			if partCount >= 1 and partCount <= 35 then
				score += math.min(partCount, 12)
			else
				continue
			end

			if score > bestScore then
				bestScore = score
				best = desc
			end
		end
	end

	if best and bestScore >= 20 then
		return best
	end

	return nil
end

local function GetGunRootFromInstance(inst)
	local camera = workspace.CurrentCamera
	if not camera or not inst or not inst:IsDescendantOf(camera) then
		return nil
	end

	local current = inst.Parent
	while current and current ~= camera do
		if current:IsA("Model") and not ModelHasHumanoid(current) and not IsCharacterBodyModel(current) then
			return current
		end
		current = current.Parent
	end

	return nil
end

local function FindWeaponByMuzzle(root)
	if not root then
		return nil
	end

	for _, desc in root:GetDescendants() do
		if desc:IsA("Attachment") then
			local name = desc.Name:lower()
			if name:find("muzzle", 1, true)
				or name:find("barrel", 1, true)
				or name:find("firepoint", 1, true)
				or name:find("fire", 1, true)
				or name:find("flash", 1, true)
			then
				local gunRoot = GetGunRootFromInstance(desc)
				if gunRoot then
					return gunRoot
				end
			end
		end
	end

	return nil
end

local function IsValidGunTarget(gun, character)
	if not gun or not gun.Parent then
		return false
	end

	local camera = workspace.CurrentCamera
	if camera and gun:IsDescendantOf(camera) then
		return true
	end

	if gun:IsA("Tool") and character and gun:IsDescendantOf(character) then
		return true
	end

	if character and gun:IsDescendantOf(character) then
		return ModelHasWeaponPart(gun) or NameLooksLikeGun(gun.Name)
	end

	return ModelHasWeaponPart(gun) or NameLooksLikeGun(gun.Name)
end

local function GetWeaponFromHands(character)
	if not character then
		return nil
	end

	local bodyParts = {}
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			bodyParts[part] = true
		end
	end

	for _, handName in { "RightHand", "LeftHand" } do
		local hand = character:FindFirstChild(handName, true)
		if hand and hand:IsA("BasePart") then
			local ok, connected = pcall(function()
				return hand:GetConnectedParts(true)
			end)
			if ok and connected then
				for _, part in connected do
					if not bodyParts[part] then
						local model = part:FindFirstAncestorOfClass("Model")
						if model and model ~= character and not ModelHasHumanoid(model) then
							return model
						end
						if part.Parent and part.Parent ~= character then
							return part.Parent:IsA("Model") and part.Parent or part
						end
					end
				end
			end
		end
	end

	return nil
end

local function FindGunInRoot(root, results, seen, preferViewModel)
	if not root then
		return
	end

	for _, desc in root:GetDescendants() do
		if seen[desc] then
			continue
		end

		if desc:IsA("Tool") then
			seen[desc] = true
			table.insert(results, { Object = desc, Score = preferViewModel and 30 or 20 })
		elseif desc:IsA("Model") and not ModelHasHumanoid(desc) and not IsCharacterBodyModel(desc) then
			local score = 0
			local name = desc.Name:lower()
			if preferViewModel then
				score += 25
			end
			if NameLooksLikeGun(name) then
				score += 15
			end
			if name:find("viewmodel", 1, true) or name:find("view_model", 1, true) or name:find("arms", 1, true) then
				score += 20
			end
			if ModelHasWeaponPart(desc) then
				score += 12
			end
			local partCount = 0
			for _, part in desc:GetDescendants() do
				if part:IsA("BasePart") then
					partCount += 1
				end
			end
			score += math.min(partCount, 8)
			if score >= 4 then
				seen[desc] = true
				table.insert(results, { Object = desc, Score = score })
			end
		end
	end
end

local function FindCameraGunModel(camera)
	if not camera then
		return nil
	end

	local best = nil
	local bestScore = 0

	for _, desc in camera:GetDescendants() do
		if desc:IsA("Tool") then
			return desc
		end

		if desc:IsA("Model") and not ModelHasHumanoid(desc) and not IsCharacterBodyModel(desc) then
			local name = desc.Name:lower()
			if (name:find("arm", 1, true) or name:find("hand", 1, true) or name:find("sleeve", 1, true))
				and not NameLooksLikeGun(name)
			then
				continue
			end

			local score = 0
			if ModelHasWeaponPart(desc) then
				score += 35
			end
			if NameLooksLikeGun(name) then
				score += 25
			end
			if name:find("viewmodel", 1, true) or name:find("view_model", 1, true) or name:find("item", 1, true) then
				score += 15
			end

			local partCount = CountGunParts(desc)
			if partCount >= 1 and partCount <= 45 then
				score += math.min(partCount, 12)
			else
				continue
			end

			if score > bestScore then
				bestScore = score
				best = desc
			end
		end
	end

	if best and bestScore >= 8 then
		return best
	end

	return nil
end

local function GetEquippedGun(character)
	local camera = workspace.CurrentCamera

	if camera then
		local muzzleWeapon = FindWeaponByMuzzle(camera)
		if muzzleWeapon and IsValidGunTarget(muzzleWeapon, character) then
			return muzzleWeapon
		end

		local cameraGun = FindCameraGunModel(camera)
		if cameraGun and IsValidGunTarget(cameraGun, character) then
			return cameraGun
		end

		local cameraWeapon = FindWeaponModelInContainer(camera)
		if cameraWeapon and IsValidGunTarget(cameraWeapon, character) then
			return cameraWeapon
		end
	end

	if character then
		local handGun = GetWeaponFromHands(character)
		if handGun and IsValidGunTarget(handGun, character) then
			return handGun
		end

		for _, child in character:GetChildren() do
			if child:IsA("Tool") then
				return child
			end
		end

		local results = {}
		local seen = {}
		FindGunInRoot(character, results, seen, false)

		local best = nil
		local bestScore = 0
		for _, entry in results do
			if entry.Score > bestScore then
				bestScore = entry.Score
				best = entry.Object
			end
		end

		if best and IsValidGunTarget(best, character) then
			return best
		end
	end

	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		local weapon = FindWeaponModelInContainer(playerGui)
		if weapon then
			return weapon
		end
	end

	return nil
end

local function RestoreGunChamParts()
	for part, saved in pairs(GunChamPartCache) do
		if part.Parent then
			part.Color = saved.Color
			part.Material = saved.Material
			if saved.LocalTransparencyModifier ~= nil then
				pcall(function()
					part.LocalTransparencyModifier = saved.LocalTransparencyModifier
				end)
			end
		end
		if part.Parent then
			local glow = part:FindFirstChild("WallhackGunGlow")
			if glow then
				glow:Destroy()
			end
		end
	end

	table.clear(GunChamPartCache)
end

ClearGunCham = function()
	RestoreGunChamParts()

	if GunChamHighlight then
		GunChamHighlight.Adornee = nil
		GunChamHighlight:Destroy()
		GunChamHighlight = nil
	end

	GunChamTarget = nil
end

local function EnsureGunGlowLight(part, color)
	local light = part:FindFirstChild("WallhackGunGlow")
	if not light or not light:IsA("PointLight") then
		if light then
			light:Destroy()
		end
		light = Instance.new("PointLight")
		light.Name = "WallhackGunGlow"
		light.Shadows = false
		light.Parent = part
	end
	light.Color = color
	light.Brightness = 4.5
	light.Range = 12
	return light
end

local function ApplyGunCham(gun)
	if not gun or not gun.Parent then
		ClearGunCham()
		return
	end

	local character = LocalPlayer.Character
	if not IsValidGunTarget(gun, character) then
		ClearGunCham()
		return
	end

	if GunChamTarget ~= gun then
		ClearGunCham()
		GunChamTarget = gun
	end

	local color = ESP.GunChamColor
	-- Punch the color brighter so Neon reads as a real glow
	local glowColor = Color3.new(
		math.clamp(color.R * 1.35 + 0.15, 0, 1),
		math.clamp(color.G * 1.35 + 0.15, 0, 1),
		math.clamp(color.B * 1.35 + 0.15, 0, 1)
	)
	local appliedParts = 0

	local function stylePart(part)
		if not part:IsA("BasePart") or IsExcludedGunPart(part) then
			return
		end
		if not GunChamPartCache[part] then
			GunChamPartCache[part] = {
				Color = part.Color,
				Material = part.Material,
				LocalTransparencyModifier = part.LocalTransparencyModifier,
			}
		end

		part.Material = Enum.Material.Neon
		part.Color = glowColor
		pcall(function()
			part.LocalTransparencyModifier = -0.35
		end)
		EnsureGunGlowLight(part, glowColor)
		appliedParts += 1
	end

	for _, part in gun:GetDescendants() do
		stylePart(part)
	end

	if gun:IsA("BasePart") then
		stylePart(gun)
	end

	if appliedParts == 0 and not gun:IsA("Tool") and not gun:IsA("Model") then
		ClearGunCham()
		return
	end

	if not GunChamHighlight or not GunChamHighlight.Parent then
		local highlight = Instance.new("Highlight")
		highlight.Name = "WallhackGunCham"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.05
		highlight.OutlineTransparency = 0
		highlight.Parent = GunChamFolder
		GunChamHighlight = highlight
	end

	GunChamHighlight.Adornee = gun
	GunChamHighlight.FillColor = glowColor
	GunChamHighlight.OutlineColor = Color3.new(1, 1, 1)
	GunChamHighlight.FillTransparency = 0.05
	GunChamHighlight.OutlineTransparency = 0
	GunChamHighlight.Enabled = true
end

UpdateGunCham = function()
	SyncESPFromUI()

	if not ESP.GunCham then
		ClearGunCham()
		return
	end

	local character = LocalPlayer.Character
	local gun = GetEquippedGun(character)
	if gun then
		ApplyGunCham(gun)
	else
		ClearGunCham()
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	ClearGunCham()
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	ClearGunCham()
end)

local ContainerKeywords = {
	"military box",
	"military crate",
	"shipping crate",
	"sports bag",
	"filing cabinet",
	"supply drop",
	"hidden cache",
	"cash register",
	"grenade crate",
	"satchel bag",
	"med bag",
	"abpopa box",
	"large military",
	"small military",
	"large shipping",
	"small shipping",
	"safe",
	"fridge",
	"toolbox",
	"stash",
	"locker",
	"wardrobe",
	"duffle",
	"duffel",
	"cabinet",
	"cache",
	"crate",
	"chest",
	"loot",
	"box",
	"drawer",
	"case",
	"trunk",
	"bag",
	"sack",
	"medical",
	"med",
	"ammo",
	"footlocker",
	"register",
	"pelican",
	"wooden",
	"metal",
	"lootable",
	"interactable",
	"footlocker",
	"supply",
	"duffle",
	"duffel",
}

local NPCKeywords = { "npc", "scav", "guard", "soldier", "bot", "enemy", "raider", "civilian", "trader" }

HasHumanoidModel = function(model)
	return model and model:FindFirstChildOfClass("Humanoid") ~= nil
end

IsPlayerCharacterModel = function(model)
	return model and Players:GetPlayerFromCharacter(model) ~= nil
end

IsLikelyNPC = function(name)
	name = name:lower()
	for _, keyword in NPCKeywords do
		if name:find(keyword, 1, true) then
			return true
		end
	end
	return false
end

IsExcludedWorldProp = function(name)
	name = name:lower()
	local excluded = {
		"rock",
		"stone",
		"boulder",
		"terrain",
		"cliff",
		"pebble",
		"rubble",
		"gravel",
		"mountain",
		"grass",
		"bush",
		"tree",
		"trunk",
		"branch",
		"leaf",
		"sand",
		"dirt",
		"mud",
		"road",
		"path",
		"wall",
		"floor",
		"ceiling",
		"roof",
		"pillar",
		"column",
		"beam",
		"plank",
		"debris",
		"decal",
		"mesh",
		"union",
	}
	for _, word in excluded do
		if name:find(word, 1, true) then
			return true
		end
	end
	return false
end

NameMatchesContainer = function(name)
	name = name:lower()
	for _, keyword in ContainerKeywords do
		if name:find(keyword, 1, true) then
			return true
		end
	end
	return false
end

local StrictContainerKeywords = {
	"military box",
	"military crate",
	"shipping crate",
	"sports bag",
	"filing cabinet",
	"supply drop",
	"hidden cache",
	"cash register",
	"grenade crate",
	"satchel bag",
	"med bag",
	"abpopa box",
	"large military",
	"small military",
	"large shipping",
	"small shipping",
	"footlocker",
	"lootable",
	"interactable",
}

local ContainerNameKeys = {
	"smallmilitarybox",
	"largemilitarybox",
	"militarycrate",
	"militarybox",
	"largeshippingcrate",
	"smallshippingcrate",
	"shippingcrate",
	"sportsbag",
	"filingcabinet",
	"supplydrop",
	"hiddencache",
	"cashregister",
	"grenadecrate",
	"satchelbag",
	"medbag",
	"medicalbag",
	"abpopabox",
	"largeabpopabox",
	"footlocker",
	"toolbox",
	"woodencrate",
	"pelican case",
	"pelicancase",
	"dufflebag",
	"duffelbag",
	"wardrobe",
	"locker",
	"stash",
	"register",
	"fridge",
	"safe",
	"drawer",
	"trunk",
	"lootcontainer",
}

local function NormalizeContainerName(name)
	return tostring(name or ""):lower():gsub("[%s_%-]", "")
end

NameMatchesContainerModel = function(name)
	local key = NormalizeContainerName(name)
	if key == "" then
		return false
	end

	for _, exact in ContainerNameKeys do
		local normalizedExact = exact:gsub("%s", "")
		if key == normalizedExact or key:find(normalizedExact, 1, true) then
			return true
		end
	end

	for _, keyword in StrictContainerKeywords do
		if key:find(keyword:gsub("%s", ""), 1, true) then
			return true
		end
	end

	for _, keyword in ContainerKeywords do
		local normalizedKeyword = keyword:gsub("%s", "")
		if normalizedKeyword ~= ""
			and #normalizedKeyword >= 4
			and key:find(normalizedKeyword, 1, true)
			and not IsExcludedWorldProp(name)
		then
			if normalizedKeyword:find("box", 1, true)
				or normalizedKeyword:find("crate", 1, true)
				or normalizedKeyword:find("cache", 1, true)
				or normalizedKeyword:find("bag", 1, true)
				or normalizedKeyword:find("cabinet", 1, true)
				or normalizedKeyword:find("safe", 1, true)
				or normalizedKeyword:find("fridge", 1, true)
				or normalizedKeyword:find("locker", 1, true)
				or normalizedKeyword:find("register", 1, true)
				or normalizedKeyword:find("military", 1, true)
				or normalizedKeyword:find("shipping", 1, true)
				or normalizedKeyword:find("footlocker", 1, true)
				or normalizedKeyword:find("toolbox", 1, true)
			then
				return true
			end
		end
	end

	return false
end

local function NameMatchesStrictContainer(name)
	return NameMatchesContainerModel(name)
end

end)();

local UpdateESP, UpdateNpcESP, UpdateCrateESP, UpdateLandmineESP, UpdateExtractionESP, EnsureExtractionDescendantHook
local DrawCharacterESP
local GetInstanceWorldPosition, PromptMatchesExtraction
local ExtractionTags, ExtractionKeywords, ExtractionFolderNames, ExtractionAttributeNames
local HasExtractionAttribute, NameMatchesExtraction, HasExtractionTag, TextMatchesExtraction
local HasExtractPrompt, IsLikelyExtractZonePart, IsInExtractionFolder, GetExtractionModel, GetExtractionDisplayName
local ScanExtractions

(function()

local function GetCharacterCorners(character)
	local hrp = GetCharacterRoot(character)
	local head = character:FindFirstChild("Head", true)
	if not hrp then
		return nil
	end

	local cf = hrp.CFrame
	local height = 5.5
	local width = 3.0
	local depth = 1.6

	if head then
		height = math.clamp(math.abs(hrp.Position.Y - head.Position.Y) * 2.0 + 1.5, 4.8, 7.0)
	end

	local half = Vector3.new(width / 2, height / 2, depth / 2)
	local corners = {}
	local offsets = {
		Vector3.new(-half.X, -half.Y, -half.Z),
		Vector3.new(half.X, -half.Y, -half.Z),
		Vector3.new(half.X, -half.Y, half.Z),
		Vector3.new(-half.X, -half.Y, half.Z),
		Vector3.new(-half.X, half.Y, -half.Z),
		Vector3.new(half.X, half.Y, -half.Z),
		Vector3.new(half.X, half.Y, half.Z),
		Vector3.new(-half.X, half.Y, half.Z),
	}

	for i, offset in ipairs(offsets) do
		corners[i] = (cf * CFrame.new(offset)).Position
	end

	return corners
end

local function GetScreenBounds(character)
	local corners3D = GetCharacterCorners(character)
	if not corners3D then
		return nil
	end

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local any = false

	for _, corner in ipairs(corners3D) do
		local p, ok = WorldToScreenAny(corner)
		if ok then
			any = true
			minX = math.min(minX, p.X)
			minY = math.min(minY, p.Y)
			maxX = math.max(maxX, p.X)
			maxY = math.max(maxY, p.Y)
		end
	end

	if not any then
		return nil
	end

	local padX = 4
	local padY = 6
	return {
		MinX = minX - padX,
		MaxX = maxX + padX,
		MinY = minY - padY,
		MaxY = maxY + padY,
		CenterX = (minX + maxX) / 2,
		CenterY = (minY + maxY) / 2,
	}
end

local function GetFallbackBounds(character)
	local root = GetCharacterRoot(character)
	if not root then
		return nil
	end

	local rootPos, rootOk = WorldToScreenAny(root.Position)
	if not rootOk then
		return nil
	end

	local topY = rootPos.Y - 32
	local head = character:FindFirstChild("Head", true)
	if head then
		local headPos, headOk = WorldToScreenAny(head.Position)
		if headOk then
			topY = headPos.Y - 16
		end
	end

	local bottomY = rootPos.Y + 32
	return {
		MinX = rootPos.X - 20,
		MaxX = rootPos.X + 20,
		MinY = topY,
		MaxY = bottomY,
		CenterX = rootPos.X,
		CenterY = (topY + bottomY) / 2,
	}
end

local function IsCharacterVisible(character)
	local camera = workspace.CurrentCamera
	if not camera or not character then
		return false
	end

	local target = character:FindFirstChild("Head", true) or GetCharacterRoot(character)
	if not target then
		return false
	end

	local ignore = { camera, character }
	local localChar = LocalPlayer.Character
	if localChar then
		ignore[#ignore + 1] = localChar
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore

	local origin = camera.CFrame.Position
	local goal = target.Position
	local delta = goal - origin
	if delta.Magnitude <= 0 then
		return true
	end

	local result = workspace:Raycast(origin, delta, params)
	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(character)
end

local function GetVisColor(cfg, character, visibleColor)
	if not cfg.VisibilityCheck then
		return visibleColor
	end
	if IsCharacterVisible(character) then
		return visibleColor
	end
	return cfg.OccludedColor or Color3.fromRGB(255, 60, 60)
end

local function UpdateBone(character, data, cfg)
	if not cfg.Bone then
		HideGuiLines(data.Lines)
		return
	end

	local boneColor = GetVisColor(cfg, character, cfg.BoneColor)

	for i, bone in ipairs(SkeletonBones) do
		local line = data.Lines[i]
		local p0 = character:FindFirstChild(bone[1], true)
		local p1 = character:FindFirstChild(bone[2], true)

		if line and p0 and p1 and p0:IsA("BasePart") and p1:IsA("BasePart") then
			local a, aOk = WorldToScreenAny(p0.Position)
			local b, bOk = WorldToScreenAny(p1.Position)
			if aOk and bOk then
				SetGuiLine(line, a, b, boneColor, cfg.SkeletonThickness)
			else
				line.Visible = false
			end
		elseif line then
			line.Visible = false
		end
	end
end

local function DrawBoundsBox(data, bounds, color, boxType)
	local minX, minY = bounds.MinX, bounds.MinY
	local maxX, maxY = bounds.MaxX, bounds.MaxY
	local tl = Vector2.new(minX, minY)
	local tr = Vector2.new(maxX, minY)
	local bl = Vector2.new(minX, maxY)
	local br = Vector2.new(maxX, maxY)

	HideGuiLines(data.BoxLines)

	if boxType == "Normal" then
		SetGuiLine(data.BoxLines[1], tl, tr, color, 2)
		SetGuiLine(data.BoxLines[2], tr, br, color, 2)
		SetGuiLine(data.BoxLines[3], br, bl, color, 2)
		SetGuiLine(data.BoxLines[4], bl, tl, color, 2)
	else
		local lenX = math.max((maxX - minX) * 0.25, 4)
		local lenY = math.max((maxY - minY) * 0.25, 4)

		SetGuiLine(data.BoxLines[1], tl, Vector2.new(minX + lenX, minY), color, 2)
		SetGuiLine(data.BoxLines[2], tl, Vector2.new(minX, minY + lenY), color, 2)
		SetGuiLine(data.BoxLines[3], tr, Vector2.new(maxX - lenX, minY), color, 2)
		SetGuiLine(data.BoxLines[4], tr, Vector2.new(maxX, minY + lenY), color, 2)
		SetGuiLine(data.BoxLines[5], bl, Vector2.new(minX + lenX, maxY), color, 2)
		SetGuiLine(data.BoxLines[6], bl, Vector2.new(minX, maxY - lenY), color, 2)
		SetGuiLine(data.BoxLines[7], br, Vector2.new(maxX - lenX, maxY), color, 2)
		SetGuiLine(data.BoxLines[8], br, Vector2.new(maxX, maxY - lenY), color, 2)
	end
end

local function UpdateBox(character, data, cfg)
	if not cfg.Box then
		HideGuiLines(data.BoxLines)
		return
	end

	local bounds = GetScreenBounds(character) or GetFallbackBounds(character)
	if bounds and cfg.BoxType ~= "3D" then
		DrawBoundsBox(data, bounds, GetVisColor(cfg, character, cfg.BoxColor), cfg.BoxType)
		return
	end

	local corners3D = GetCharacterCorners(character)
	if not corners3D then
		HideGuiLines(data.BoxLines)
		return
	end

	HideGuiLines(data.BoxLines)

	if cfg.BoxType == "3D" then
		local pts = {}
		for i, corner in ipairs(corners3D) do
			local p, ok = WorldToScreenAny(corner)
			if not ok then
				return
			end
			pts[i] = p
		end

		local edges = {
			{ 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 1 },
			{ 5, 6 }, { 6, 7 }, { 7, 8 }, { 8, 5 },
			{ 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 },
		}

		for i, edge in ipairs(edges) do
			SetGuiLine(data.BoxLines[i], pts[edge[1]], pts[edge[2]], GetVisColor(cfg, character, cfg.BoxColor), 2)
		end
		return
	end

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local any = false

	for _, corner in ipairs(corners3D) do
		local p, ok = WorldToScreenAny(corner)
		if ok then
			any = true
			minX = math.min(minX, p.X)
			minY = math.min(minY, p.Y)
			maxX = math.max(maxX, p.X)
			maxY = math.max(maxY, p.Y)
		end
	end

	if not any then
		return
	end

	DrawBoundsBox(data, {
		MinX = minX - 4,
		MaxX = maxX + 4,
		MinY = minY - 6,
		MaxY = maxY + 6,
	}, GetVisColor(cfg, character, cfg.BoxColor), cfg.BoxType)
end

local function UpdateChams(character, data, cfg)
	if not cfg.Chams then
		if data.Highlight then
			data.Highlight:Destroy()
			data.Highlight = nil
		end
		ClearWireframeChams(data)
		return
	end

	local style = ResolveDropdown(cfg.ChamsStyle, { "Filled", "WireFrame" }, "Filled")

	if style == "WireFrame" then
		ApplyWireframeChams(character, data, GetVisColor(cfg, character, cfg.ChamsColor))
		return
	end


	ClearWireframeChams(data)

	if not data.Highlight or not data.Highlight.Parent then
		local highlight = Instance.new("Highlight")
		highlight.Name = "WallhackChams"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.45
		highlight.OutlineTransparency = 0
		highlight.Parent = character
		data.Highlight = highlight
	end

	local chamsColor = GetVisColor(cfg, character, cfg.ChamsColor)
	data.Highlight.Adornee = character
	data.Highlight.FillColor = chamsColor
	data.Highlight.OutlineColor = chamsColor
	data.Highlight.FillTransparency = 0.45
	data.Highlight.OutlineTransparency = 0
	data.Highlight.Enabled = true
end

local function UpdateTracer(character, data, cfg)
	if not cfg.Tracer then
		if data.TracerLine then
			data.TracerLine.Visible = false
		end
		return
	end

	local root = GetCharacterRoot(character)
	if not root then
		data.TracerLine.Visible = false
		return
	end

	local target, ok = WorldToScreenAny(root.Position)
	if not ok then
		data.TracerLine.Visible = false
		return
	end

	SetGuiLine(data.TracerLine, GetTracerOriginFor(cfg), target, GetVisColor(cfg, character, cfg.TracerColor), 2)
end

local function UpdateName(displayName, character, data, bounds, cfg)
	if not cfg.Name or not bounds then
		if data.NameLabel then
			data.NameLabel.Visible = false
		end
		return
	end

	data.NameLabel.Text = displayName
	data.NameLabel.TextColor3 = GetVisColor(cfg, character, cfg.NameColor)
	data.NameLabel.Position = UDim2.fromOffset(bounds.CenterX, bounds.MinY - 12)
	data.NameLabel.Visible = true
end

local function UpdateDistance(character, data, bounds, cfg)
	if not cfg.Distance or not bounds then
		if data.DistanceLabel then
			data.DistanceLabel.Visible = false
		end
		return
	end

	local root = GetLocalRoot()
	local targetRoot = GetCharacterRoot(character)
	if not root or not targetRoot then
		data.DistanceLabel.Visible = false
		return
	end

	local dist = math.floor(GetStudDistance(root.Position, targetRoot.Position))
	data.DistanceLabel.Text = "{" .. dist .. "m}"
	data.DistanceLabel.TextColor3 = GetVisColor(cfg, character, cfg.DistanceColor)
	data.DistanceLabel.Position = UDim2.fromOffset(bounds.CenterX, bounds.MaxY + 12)
	data.DistanceLabel.Visible = true
end

local function UpdateHeadDot(character, data, cfg)
	if not cfg.HeadDot then
		if data.HeadDot then
			data.HeadDot.Visible = false
		end
		if data.HeadDotStroke then
			data.HeadDotStroke.Enabled = false
		end
		return
	end

	local head = character:FindFirstChild("Head", true)
	if not head then
		data.HeadDot.Visible = false
		return
	end

	local pos, ok = WorldToScreenAny(head.Position)
	if not ok then
		data.HeadDot.Visible = false
		return
	end

	data.HeadDot.Position = UDim2.fromOffset(pos.X, pos.Y)
	data.HeadDot.Size = UDim2.fromOffset(7, 7)

	local headColor = GetVisColor(cfg, character, cfg.HeadDotColor)

	if cfg.HeadDotStyle == "Hollow" then
		data.HeadDot.BackgroundTransparency = 1
		if not data.HeadDotStroke then
			data.HeadDotStroke = Instance.new("UIStroke")
			data.HeadDotStroke.Parent = data.HeadDot
		end
		data.HeadDotStroke.Color = headColor
		data.HeadDotStroke.Thickness = 1.5
		data.HeadDotStroke.Enabled = true
	else
		data.HeadDot.BackgroundTransparency = 0
		data.HeadDot.BackgroundColor3 = headColor
		if data.HeadDotStroke then
			data.HeadDotStroke.Enabled = false
		end
	end

	data.HeadDot.Visible = true
end

local function UpdateChineseHat(character, data, cfg)
	if not cfg.ChineseHat then
		HideGuiLines(data.HatLines)
		return
	end

	local head = character:FindFirstChild("Head", true)
	if not head then
		HideGuiLines(data.HatLines)
		return
	end

	local headCF = head.CFrame
	local peakPos = (headCF * CFrame.new(0, 1.35, 0)).Position
	local peakScreen, peakOk = WorldToScreenAny(peakPos)

	local brimHeight = 0.42
	local brimRadius = 1.7
	local brimScreens = {}
	local brimVisible = {}

	for i = 1, HatSegments do
		local angle = ((i - 1) / HatSegments) * math.pi * 2
		local offset = Vector3.new(math.cos(angle) * brimRadius, brimHeight, math.sin(angle) * brimRadius)
		local brimPos = (headCF * CFrame.new(offset)).Position
		local screen, ok = WorldToScreenAny(brimPos)
		brimScreens[i] = screen
		brimVisible[i] = ok
	end

	for i = 1, HatSegments do
		local line = data.HatLines[i]
		if line then
			if peakOk and brimVisible[i] then
				SetGuiLine(line, peakScreen, brimScreens[i], cfg.ChineseHatColor, 1)
			else
				line.Visible = false
			end
		end
	end

	for i = 1, HatSegments do
		local nextIndex = (i % HatSegments) + 1
		local line = data.HatLines[HatSegments + i]
		if line then
			if brimVisible[i] and brimVisible[nextIndex] then
				SetGuiLine(line, brimScreens[i], brimScreens[nextIndex], cfg.ChineseHatColor, 1)
			else
				line.Visible = false
			end
		end
	end
end

local function UpdateHealth(character, data, bounds, cfg)
	if not bounds then
		if data.HealthBG then
			data.HealthBG.Visible = false
		end
		if data.HealthTextLabel then
			data.HealthTextLabel.Visible = false
		end
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		if data.HealthBG then
			data.HealthBG.Visible = false
		end
		if data.HealthTextLabel then
			data.HealthTextLabel.Visible = false
		end
		return
	end

	if not cfg.Health and not cfg.HealthText then
		if data.HealthBG then
			data.HealthBG.Visible = false
		end
		if data.HealthTextLabel then
			data.HealthTextLabel.Visible = false
		end
		return
	end

	local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
	local barHeight = math.max(math.floor(bounds.MaxY - bounds.MinY), 10)
	local barWidth = 4
	local barX = math.floor(bounds.MinX - 8)
	local barY = math.floor(bounds.MinY)

	if cfg.Health then
		data.HealthBG.Position = UDim2.fromOffset(barX, barY)
		data.HealthBG.Size = UDim2.fromOffset(barWidth, barHeight)
		data.HealthBG.Visible = true

		if cfg.HealthStyle == "Gradient Health" then
			if data.HealthGradient then
				data.HealthGradient.Enabled = true
			end

			data.HealthFill.AnchorPoint = Vector2.new(0, 0)
			data.HealthFill.BackgroundColor3 = Color3.new(1, 1, 1)
			data.HealthFill.Position = UDim2.fromOffset(0, math.floor(barHeight * (1 - ratio)))
			data.HealthFill.Size = UDim2.fromOffset(barWidth, barHeight)
		else
			if data.HealthGradient then
				data.HealthGradient.Enabled = false
			end

			local fillHeight = math.max(math.floor(barHeight * ratio), ratio > 0 and 1 or 0)
			data.HealthFill.AnchorPoint = Vector2.new(0, 1)
			data.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 220, 0)
			data.HealthFill.Position = UDim2.fromOffset(0, barHeight)
			data.HealthFill.Size = UDim2.fromOffset(barWidth, fillHeight)
		end

		data.HealthFill.Visible = ratio > 0
	else
		if data.HealthBG then
			data.HealthBG.Visible = false
		end
	end

	if cfg.HealthText and data.HealthTextLabel then
		local healthValue = math.floor(humanoid.Health)
		data.HealthTextLabel.Text = tostring(healthValue)
		data.HealthTextLabel.TextColor3 = cfg.HealthTextColor
		data.HealthTextLabel.AnchorPoint = Vector2.new(1, 0.5)
		data.HealthTextLabel.Position = UDim2.fromOffset(barX - 4, barY + (barHeight / 2))
		data.HealthTextLabel.Visible = true
	elseif data.HealthTextLabel then
		data.HealthTextLabel.Visible = false
	end
end

DrawCharacterESP = function(cfg, displayName, character, data)
	local bounds = GetScreenBounds(character) or GetFallbackBounds(character)

	UpdateBone(character, data, cfg)
	UpdateBox(character, data, cfg)
	UpdateTracer(character, data, cfg)
	UpdateChams(character, data, cfg)
	UpdateName(displayName, character, data, bounds, cfg)
	UpdateDistance(character, data, bounds, cfg)
	UpdateHealth(character, data, bounds, cfg)
	UpdateHeadDot(character, data, cfg)
	UpdateChineseHat(character, data, cfg)
end

end)(); (function()

local function PlayerNeedsESP()
	return ESP.Self
		or ESP.Bone
		or ESP.Box
		or ESP.Chams
		or ESP.Tracer
		or ESP.Name
		or ESP.Distance
		or ESP.HeadDot
		or ESP.ChineseHat
		or ESP.Health
		or ESP.HealthText
end

local function DrawPlayerESP(player, character)
	local ok, err = pcall(function()
		DrawCharacterESP(ESP, player.DisplayName, character, EnsurePlayerESP(player))
	end)
	if not ok then
		warn("[Wallhack.gg ESP]", player.Name, err)
	end
end

UpdateESP = function()
	if not Camera then
		return
	end

	SyncESPFromUI()

	local hasESP = PlayerNeedsESP()

	for _, player in Players:GetPlayers() do
		if player ~= LocalPlayer then
			local character = player.Character
			local shouldDraw = hasESP and character ~= nil

			if shouldDraw then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health <= 0 then
					shouldDraw = false
				end
			end

			if shouldDraw then
				local root = GetCharacterRoot(character)
				if not root then
					shouldDraw = false
				end
			end

			if shouldDraw then
				DrawPlayerESP(player, character)
			else
				HidePlayerESP(player)
			end
		end
	end

	if ESP.Self then
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local alive = character and (not humanoid or humanoid.Health > 0)
		local root = character and GetCharacterRoot(character)

		if alive and root then
			DrawPlayerESP(LocalPlayer, character)
		else
			HidePlayerESP(LocalPlayer)
		end
	else
		HidePlayerESP(LocalPlayer)
	end
end

end)(); (function()

local function IsDescendantOfAnyPlayerCharacter(model)
	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character and (model == character or model:IsDescendantOf(character)) then
			return true
		end
	end
	return false
end

local function IsNpcCharacter(model)
	if not model or not model:IsA("Model") then
		return false
	end
	if IsDescendantOfAnyPlayerCharacter(model) then
		return false
	end
	if IsPlayerCharacterModel(model) then
		return false
	end

	local camera = workspace.CurrentCamera
	if camera and model:IsDescendantOf(camera) then
		return false
	end

	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui and model:IsDescendantOf(playerGui) then
		return false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	if not GetCharacterRoot(model) then
		return false
	end

	local aiZones = workspace:FindFirstChild("AiZones")
	if aiZones and model:IsDescendantOf(aiZones) then
		return true
	end

	return IsLikelyNPC(model.Name)
end

local function NpcNeedsESP()
	if not NpcESP.Enabled then
		return false
	end

	return NpcESP.Bone
		or NpcESP.Box
		or NpcESP.Chams
		or NpcESP.Tracer
		or NpcESP.Name
		or NpcESP.Distance
		or NpcESP.HeadDot
		or NpcESP.ChineseHat
		or NpcESP.Health
		or NpcESP.HealthText
end

local function ScanNPCs()
	local found = {}
	local aiZones = workspace:FindFirstChild("AiZones")

	if aiZones then
		for _, zone in aiZones:GetChildren() do
			for _, character in zone:GetChildren() do
				if character:IsA("Model") and IsNpcCharacter(character) then
					found[character] = {
						Instance = character,
						Name = character.Name:gsub("_", " "),
					}
				end
			end
		end
		return found
	end

	for _, obj in workspace:GetDescendants() do
		if obj:IsA("Model") and IsNpcCharacter(obj) then
			found[obj] = {
				Instance = obj,
				Name = obj.Name:gsub("_", " "),
			}
		end
	end

	return found
end

local function DrawNpcESP(npc, npcData)
	local ok, err = pcall(function()
		DrawCharacterESP(NpcESP, npcData.Name or npc.Name, npc, EnsureNpcESP(npc))
	end)
	if not ok then
		warn("[Wallhack.gg NPC ESP]", npc.Name, err)
	end
end

UpdateNpcESP = function()
	if not Camera then
		return
	end

	SyncNpcESPFromUI()

	if not NpcNeedsESP() then
		for npc in pairs(NpcCache) do
			ClearNpcESP(npc)
		end
		NpcList = {}
		return
	end

	local now = tick()
	if now - LastNpcScan >= NpcScanInterval then
		LastNpcScan = now
		local ok, result = pcall(ScanNPCs)
		if ok then
			NpcList = result
		end

		for npc in pairs(NpcCache) do
			if not NpcList[npc] or not npc.Parent then
				ClearNpcESP(npc)
			end
		end
	end

	for npc, npcData in pairs(NpcList) do
		if npc.Parent then
			local root = GetCharacterRoot(npc)
			if root and IsWithinDistance(root.Position, NpcESP.MaxDistance) then
				DrawNpcESP(npc, npcData)
			else
				HideNpcESP(npc)
			end
		else
			ClearNpcESP(npc)
		end
	end
end

end)(); (function()

local ContainerTags = { "Container", "LootContainer", "Lootable", "Interactable", "Loot", "Crate" }
local ContainerFolderNames = {
	"Containers",
	"Loot",
	"Lootables",
	"Interactables",
	"LootContainers",
	"Items",
	"Map",
	"Assets",
	"World",
}

local function GetContainerDisplayName(model, prompt)
	if prompt and prompt.ObjectText ~= "" then
		return prompt.ObjectText
	end
	if prompt and prompt.ActionText ~= "" then
		return prompt.ActionText
	end
	if model and model.Name ~= "" then
		return model.Name:gsub("_", " ")
	end
	return "Loot"
end

local function HasAnyProximityPrompt(model)
	return model and model:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil
end

local function GetContainerTargetFromPrompt(prompt)
	local current = prompt.Parent
	while current and current ~= workspace do
		if current:IsA("Attachment") then
			current = current.Parent
		elseif current:IsA("BasePart") then
			local model = GetContainerModel(current)
			if model and not HasHumanoidModel(model) and not IsPlayerCharacterModel(model) then
				return model
			end
			return current
		elseif current:IsA("Model") and not HasHumanoidModel(current) and not IsPlayerCharacterModel(current) then
			return current
		else
			current = current.Parent
		end
	end
	return nil
end

local function PromptMatchesLootContainer(prompt, targetName)
	if not prompt:IsA("ProximityPrompt") then
		return false
	end

	targetName = targetName or (prompt.Parent and prompt.Parent.Name) or ""
	local actionText = prompt.ActionText or ""
	local objectText = prompt.ObjectText or ""
	local text = (actionText .. " " .. objectText):lower()

	if text:find("extract", 1, true)
		or text:find("exit", 1, true)
		or text:find("evac", 1, true)
		or text:find("exfil", 1, true)
	then
		return false
	end

	if NameMatchesContainerModel(targetName)
		or NameMatchesContainerModel(objectText)
		or NameMatchesContainerModel(prompt.Parent and prompt.Parent.Name or "")
	then
		return true
	end

	return text:find("search", 1, true)
		or text:find("open", 1, true)
		or text:find("loot", 1, true)
		or text:find("inspect", 1, true)
		or text:find("take", 1, true)
		or text:find("pick", 1, true)
		or text:find("grab", 1, true)
		or text:find("hold", 1, true)
		or text:find("check", 1, true)
		or text:find("view", 1, true)
		or text:find("access", 1, true)
end

local function HasContainerTag(instance)
	for _, tag in ContainerTags do
		if CollectionService:HasTag(instance, tag) then
			return true
		end
	end
	return false
end

local function HasLootPrompt(model)
	for _, desc in model:GetDescendants() do
		if desc:IsA("ProximityPrompt") and PromptMatchesLootContainer(desc, model.Name) then
			return true
		end
	end
	return false
end

local function GetContainerModel(instance)
	if instance:IsA("Model") then
		return instance
	end
	return instance:FindFirstAncestorOfClass("Model")
end

local function TryAddContainerFromPrompt(found, prompt)
	local target = GetContainerTargetFromPrompt(prompt)
	if not target then
		if prompt.Parent and prompt.Parent:IsA("BasePart") then
			target = prompt.Parent
		else
			return
		end
	end

	if not PromptMatchesLootContainer(prompt, target.Name) then
		return
	end

	if HasHumanoidModel(target) or IsPlayerCharacterModel(target) or IsLikelyNPC(target.Name) then
		return
	end
	if IsExcludedWorldProp(target.Name) and not NameMatchesContainerModel(target.Name) then
		return
	end

	local posPart = nil
	if target:IsA("Model") then
		posPart = target.PrimaryPart
			or target:FindFirstChild("Hitbox", true)
			or target:FindFirstChild("Main", true)
			or target:FindFirstChildWhichIsA("BasePart", true)
	elseif target:IsA("BasePart") then
		posPart = target
	end

	if not posPart then
		return
	end

	local adornee = target:IsA("Model") and target or posPart
	if found[adornee] then
		return
	end

	found[adornee] = {
		Instance = adornee,
		PositionPart = posPart,
		Name = GetContainerDisplayName(target, prompt),
	}
end

local function TryAddContainer(found, model, prompt)
	if not model or found[model] then
		return
	end
	if not model:IsDescendantOf(workspace) then
		return
	end
	if HasHumanoidModel(model) or IsPlayerCharacterModel(model) or IsLikelyNPC(model.Name) then
		return
	end
	if IsExcludedWorldProp(model.Name) and not NameMatchesContainerModel(model.Name) then
		return
	end

	local isContainer = HasContainerTag(model)
		or HasLootPrompt(model)
		or (NameMatchesContainerModel(model.Name) and HasAnyProximityPrompt(model))
		or NameMatchesContainerModel(model.Name)

	if not isContainer then
		return
	end

	local posPart = model.PrimaryPart
		or model:FindFirstChild("Hitbox", true)
		or model:FindFirstChild("Main", true)
		or model:FindFirstChildWhichIsA("BasePart", true)
	if not posPart then
		return
	end

	found[model] = {
		Instance = model,
		PositionPart = posPart,
		Name = GetContainerDisplayName(model, prompt),
	}
end

local function WorldNeedsCrateESP()
	return WorldESP.Crates or WorldESP.CrateName or WorldESP.CrateDistance
end

local function GetCrateBounds(crate, crateData)
	if crate:IsA("Model") then
		local ok, packed = pcall(function()
			local cf, size = crate:GetBoundingBox()
			return { cf, size }
		end)
		if ok and packed and packed[1] and packed[2] then
			return packed[1], packed[2]
		end
	end

	local part = crateData.PositionPart
	if part and part.Parent then
		return part.CFrame, part.Size
	end

	return CFrame.new(part and part.Position or Vector3.zero), Vector3.new(3, 2, 3)
end

local function GetCrateScreenBounds(crate, crateData)
	local cf, size = GetCrateBounds(crate, crateData)
	local half = size / 2
	local corners = {
		(cf * CFrame.new(-half.X, -half.Y, -half.Z)).Position,
		(cf * CFrame.new(half.X, -half.Y, -half.Z)).Position,
		(cf * CFrame.new(half.X, -half.Y, half.Z)).Position,
		(cf * CFrame.new(-half.X, -half.Y, half.Z)).Position,
		(cf * CFrame.new(-half.X, half.Y, -half.Z)).Position,
		(cf * CFrame.new(half.X, half.Y, -half.Z)).Position,
		(cf * CFrame.new(half.X, half.Y, half.Z)).Position,
		(cf * CFrame.new(-half.X, half.Y, half.Z)).Position,
	}

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local any = false

	for _, corner in corners do
		local p, ok = WorldToScreenAny(corner)
		if ok then
			any = true
			minX = math.min(minX, p.X)
			minY = math.min(minY, p.Y)
			maxX = math.max(maxX, p.X)
			maxY = math.max(maxY, p.Y)
		end
	end

	if not any then
		local part = crateData.PositionPart
		if part and part.Parent then
			local p, ok = WorldToScreenAny(part.Position)
			if ok then
				return {
					MinX = p.X - 24,
					MaxX = p.X + 24,
					MinY = p.Y - 24,
					MaxY = p.Y + 24,
					CenterX = p.X,
					CenterY = p.Y,
				}
			end
		end
		return nil
	end

	return {
		MinX = minX,
		MaxX = maxX,
		MinY = minY,
		MaxY = maxY,
		CenterX = (minX + maxX) / 2,
		CenterY = (minY + maxY) / 2,
	}
end

local function ScanCrates()
	local found = {}

	for _, tag in ContainerTags do
		for _, obj in CollectionService:GetTagged(tag) do
			local model = GetContainerModel(obj)
			if model then
				TryAddContainer(found, model)
			end
		end
	end

	for _, folderName in ContainerFolderNames do
		local folder = workspace:FindFirstChild(folderName, true)
		if folder then
			for _, obj in folder:GetDescendants() do
				if obj:IsA("ProximityPrompt") then
					TryAddContainerFromPrompt(found, obj)
				elseif obj:IsA("Model") then
					TryAddContainer(found, obj)
				elseif obj:IsA("BasePart") and NameMatchesContainerModel(obj.Name) then
					local model = GetContainerModel(obj)
					if model then
						TryAddContainer(found, model)
					else
						found[obj] = {
							Instance = obj,
							PositionPart = obj,
							Name = GetContainerDisplayName(obj),
						}
					end
				end
			end
		end
	end

	for _, obj in workspace:GetDescendants() do
		if obj:IsA("ProximityPrompt") then
			TryAddContainerFromPrompt(found, obj)
		end
	end

	return found
end

local function GetCratePosition(crateData)
	local part = crateData.PositionPart
	if part and part.Parent then
		return part.Position
	end
	return nil
end

UpdateCrateESP = function()
	SyncWorldESPFromUI()

	if not WorldNeedsCrateESP() then
		for crate in pairs(CrateCache) do
			ClearCrateESP(crate)
		end
		return
	end

	if not EnsureESPGuiAttached() then
		return
	end

	local now = tick()
	if now - LastCrateScan >= CrateScanInterval then
		LastCrateScan = now
		local ok, result = pcall(ScanCrates)
		if ok and type(result) == "table" then
			CrateList = result
		end

		for crate in pairs(CrateCache) do
			if not CrateList[crate] or not crate.Parent then
				ClearCrateESP(crate)
			end
		end
	end

	local root = GetLocalRoot()

	for crate, crateData in pairs(CrateList) do
		if crate.Parent then
			local pos = GetCratePosition(crateData)
			if pos and IsWithinDistance(pos, WorldESP.MaxDistance) then
				local data = EnsureCrateESP(crate)
				local screenPos, onScreen = WorldToScreenAny(pos)

				if WorldESP.Crates then
					local highlightTarget = crateData.Instance or crate
					if not data.Highlight or not data.Highlight.Parent then
						local highlight = Instance.new("Highlight")
						highlight.Name = "WallhackCrateESP"
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.FillTransparency = 0.55
						highlight.OutlineTransparency = 0
						highlight.Parent = highlightTarget
						data.Highlight = highlight
					end

					data.Highlight.Enabled = true
					data.Highlight.Adornee = highlightTarget
					data.Highlight.FillColor = WorldESP.CrateColor
					data.Highlight.OutlineColor = WorldESP.CrateColor
				elseif data.Highlight then
					data.Highlight.Enabled = false
				end

				if onScreen then
					if WorldESP.CrateName then
						data.NameLabel.Text = crateData.Name or crate.Name
						data.NameLabel.TextColor3 = WorldESP.NameColor
						data.NameLabel.AnchorPoint = Vector2.new(0.5, 1)
						data.NameLabel.Position = UDim2.fromOffset(screenPos.X, screenPos.Y - 18)
						data.NameLabel.Visible = true
					else
						data.NameLabel.Visible = false
					end

					if WorldESP.CrateDistance and root then
						local dist = math.floor(GetStudDistance(root.Position, pos))
						data.DistanceLabel.Text = dist .. "m"
						data.DistanceLabel.TextColor3 = WorldESP.DistanceColor
						data.DistanceLabel.AnchorPoint = Vector2.new(0.5, 0)
						data.DistanceLabel.Position = UDim2.fromOffset(screenPos.X, screenPos.Y + 4)
						data.DistanceLabel.Visible = true
					else
						data.DistanceLabel.Visible = false
					end
				else
					data.NameLabel.Visible = false
					data.DistanceLabel.Visible = false
				end
			else
				HideCrateESPVisuals(crate)
			end
		else
			ClearCrateESP(crate)
		end
	end
end
end)(); (function()

ExtractionTags = { "Extraction", "Extract", "Exit", "EVAC", "Exfil", "ExtractionPoint", "ExtractPoint", "ExtractZone", "ExitPoint" }
ExtractionKeywords = {
	"extract",
	"extraction",
	"exit",
	"evac",
	"evacuation",
	"exfil",
	"exfiltrate",
	"extractpoint",
	"extractionpoint",
	"extractzone",
	"exitzone",
	"exitdoor",
	"extractdoor",
	"exfilpoint",
	"metro",
	"bunker",
	"airfield",
	"helicopter",
	"heli",
	"uno",
}
ExtractionFolderNames = {
	"Extractions",
	"ExtractionPoints",
	"Extraction",
	"Extracts",
	"Exits",
	"ExitPoints",
	"ExtractionZones",
	"ExtractZones",
	"ExtractPoints",
	"ExitZones",
}
ExtractionAttributeNames = {
	"Extraction",
	"Extract",
	"Exit",
	"EVAC",
	"Exfil",
	"IsExtract",
	"IsExtraction",
	"IsExit",
}

HasExtractionAttribute = function(instance)
	if not instance then
		return false
	end

	for _, attributeName in ExtractionAttributeNames do
		local value = instance:GetAttribute(attributeName)
		if value == true or value == "true" or value == 1 then
			return true
		end
	end

	return false
end

NameMatchesExtraction = function(name)
	name = name:lower()
	for _, keyword in ExtractionKeywords do
		if name:find(keyword, 1, true) then
			return true
		end
	end
	return false
end

HasExtractionTag = function(instance)
	for _, tag in ExtractionTags do
		if CollectionService:HasTag(instance, tag) then
			return true
		end
	end
	return false
end

PromptMatchesExtraction = function(prompt)
	local text = (prompt.ActionText .. " " .. prompt.ObjectText):lower()
	return text:find("extract", 1, true)
		or text:find("exit", 1, true)
		or text:find("evac", 1, true)
		or text:find("exfil", 1, true)
		or text:find("metro", 1, true)
		or text:find("leave", 1, true)
		or text:find("escape", 1, true)
		or text:find("return", 1, true)
		or text:find("wasteland", 1, true)
end

TextMatchesExtraction = function(text)
	text = text:lower()
	return text:find("extract", 1, true)
		or text:find("exit", 1, true)
		or text:find("evac", 1, true)
		or text:find("exfil", 1, true)
		or text:find("metro", 1, true)
end

GetInstanceWorldPosition = function(instance)
	if not instance then
		return nil
	end
	if instance:IsA("BasePart") then
		return instance.Position
	end
	if instance:IsA("Attachment") then
		return instance.WorldPosition
	end
	if instance:IsA("Model") then
		local part = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
		if part then
			return part.Position
		end
	end
	return nil
end

HasExtractPrompt = function(model)
	for _, desc in model:GetDescendants() do
		if desc:IsA("ProximityPrompt") and PromptMatchesExtraction(desc) then
			return true
		end
		if desc:IsA("BillboardGui") and desc.Enabled then
			local name = desc.Name:lower()
			if name:find("extract", 1, true) or name:find("exit", 1, true) or name:find("marker", 1, true) then
				return true
			end
			for _, child in desc:GetDescendants() do
				if child:IsA("TextLabel") and TextMatchesExtraction(child.Text) then
					return true
				end
			end
		end
		if desc:IsA("TextLabel") and TextMatchesExtraction(desc.Text) then
			return true
		end
	end
	return false
end

IsLikelyExtractZonePart = function(part)
	if not part:IsA("BasePart") then
		return false
	end

	local name = part.Name:lower()
	if NameMatchesExtraction(name) then
		return true
	end

	if name == "zone" or name == "pad" or name == "hitbox" or name == "trigger" then
		local model = part:FindFirstAncestorOfClass("Model")
		if model and (NameMatchesExtraction(model.Name) or HasExtractPrompt(model) or IsInExtractionFolder(model)) then
			return true
		end
		if part.Parent and (NameMatchesExtraction(part.Parent.Name) or IsInExtractionFolder(part.Parent)) then
			return true
		end
	end

	return false
end

IsInExtractionFolder = function(instance)
	local current = instance
	while current and current ~= workspace do
		local name = current.Name:lower()
		for _, folderName in ExtractionFolderNames do
			local folderLower = folderName:lower()
			if name == folderLower or name:find(folderLower, 1, true) then
				return true
			end
		end
		if name:find("extract", 1, true) or name:find("exfil", 1, true) or name:find("evac", 1, true) then
			return true
		end
		current = current.Parent
	end
	return false
end

GetExtractionModel = function(instance)
	if instance:IsA("Model") then
		return instance
	end
	return instance:FindFirstAncestorOfClass("Model")
end

GetExtractionDisplayName = function(target)
	local name = target.Name
	if NameMatchesExtraction(name) then
		return "Extract"
	end
	if target:FindFirstChild("Door", true) then
		return "Exit Door"
	end
	return "Extraction"
end

end)(); (function()

local function TryAddExtractionFromPrompt(found, prompt)
	if not prompt:IsA("ProximityPrompt") or not PromptMatchesExtraction(prompt) then
		return
	end

	local fallbackPos = GetInstanceWorldPosition(prompt.Parent)
	local model = GetExtractionModel(prompt.Parent)
	local target = model

	if not target then
		if prompt.Parent:IsA("BasePart") then
			target = prompt.Parent
		else
			return
		end
	end

	if HasHumanoidModel(target) or IsPlayerCharacterModel(target) then
		return
	end

	local posPart = nil
	if target:IsA("Model") then
		posPart = target:FindFirstChild("Door", true)
		if posPart and not posPart:IsA("BasePart") then
			posPart = nil
		end
		if not posPart then
			posPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
		end
	elseif target:IsA("BasePart") then
		posPart = target
	end

	local adornee = target:IsA("Model") and target or posPart
	if not adornee or found[adornee] then
		return
	end

	found[adornee] = {
		Instance = adornee,
		HighlightTarget = posPart or adornee,
		PositionPart = posPart,
		FallbackPosition = fallbackPos or GetInstanceWorldPosition(adornee),
		Name = "Extract",
	}
end

local function TryAddExtraction(found, instance)
	if not instance then
		return
	end

	local model = GetExtractionModel(instance)
	local target = model or instance

	if not target:IsDescendantOf(workspace) then
		return
	end
	if HasHumanoidModel(target) or IsPlayerCharacterModel(target) or IsLikelyNPC(target.Name) then
		return
	end
	if NameMatchesContainer(target.Name) and not NameMatchesExtraction(target.Name) then
		return
	end

	local isExtraction = HasExtractionTag(target)
		or HasExtractionTag(instance)
		or HasExtractionAttribute(target)
		or HasExtractionAttribute(instance)
		or NameMatchesExtraction(target.Name)
		or (instance:IsA("BasePart") and (NameMatchesExtraction(instance.Name) or IsLikelyExtractZonePart(instance)))
		or HasExtractPrompt(target)
		or IsInExtractionFolder(target)

	if not isExtraction then
		return
	end

	local posPart = nil
	if target:IsA("Model") then
		posPart = target:FindFirstChild("Door", true)
		if posPart and not posPart:IsA("BasePart") then
			posPart = nil
		end
		if not posPart then
			posPart = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
		end
	elseif target:IsA("BasePart") then
		posPart = target
	end

	local fallbackPos = GetInstanceWorldPosition(posPart or target)
	if not posPart and not fallbackPos then
		return
	end

	local highlightTarget = posPart or (target:IsA("BasePart") and target) or target
	local adornee = target:IsA("Model") and target or highlightTarget
	if found[adornee] then
		return
	end

	found[adornee] = {
		Instance = adornee,
		HighlightTarget = highlightTarget,
		PositionPart = posPart,
		FallbackPosition = fallbackPos,
		Name = GetExtractionDisplayName(target),
	}
end

local function ScanMapRoots()
	local roots = { workspace }
	for _, name in { "Map", "World", "Wasteland", "Environment", "Interactables", "Game", "Assets" } do
		local root = workspace:FindFirstChild(name, true)
		if root and root:IsA("Instance") then
			table.insert(roots, root)
		end
	end
	return roots
end

ScanExtractions = function()
	local found = {}

	for _, obj in workspace:GetDescendants() do
		if obj:IsA("ProximityPrompt") then
			TryAddExtractionFromPrompt(found, obj)
		end
	end

	for _, tag in ExtractionTags do
		for _, obj in CollectionService:GetTagged(tag) do
			TryAddExtraction(found, obj)
		end
	end

	for _, folderName in ExtractionFolderNames do
		local folder = workspace:FindFirstChild(folderName, true)
		if folder then
			for _, obj in folder:GetDescendants() do
				if obj:IsA("Model") or obj:IsA("BasePart") then
					TryAddExtraction(found, obj)
				end
			end
		end
	end

	for _, obj in workspace:GetDescendants() do
		if obj:IsA("BillboardGui") then
			local name = obj.Name:lower()
			if name:find("extract", 1, true) or name:find("exit", 1, true) or name:find("marker", 1, true) then
				TryAddExtraction(found, obj.Parent)
			else
				for _, child in obj:GetDescendants() do
					if child:IsA("TextLabel") and TextMatchesExtraction(child.Text) then
						TryAddExtraction(found, obj.Parent)
						break
					end
				end
			end
		elseif obj:IsA("TextLabel") and TextMatchesExtraction(obj.Text) then
			TryAddExtraction(found, obj.Parent)
		elseif obj:IsA("Model") or obj:IsA("BasePart") then
			TryAddExtraction(found, obj)
		end
	end

	for _, root in ScanMapRoots() do
		for _, obj in root:GetDescendants() do
			if obj:IsA("BasePart") and HasExtractionAttribute(obj) then
				TryAddExtraction(found, obj)
			end
		end
	end

	return found
end

end)(); (function()

local function GetExtractionPosition(extractionData)
	local part = extractionData.PositionPart
	if part and part.Parent then
		return part.Position
	end
	if extractionData.FallbackPosition then
		return extractionData.FallbackPosition
	end
	return nil
end

local function GetExtractionScreenPosition(worldPos)
	return GetEdgeScreenPosition(worldPos, 36)
end

EnsureExtractionDescendantHook = function()
	if ExtractionDescendantHook then
		return
	end

	ExtractionDescendantHook = true
	workspace.DescendantAdded:Connect(function(obj)
		if not WorldESP.Extractions then
			return
		end
		if obj:IsA("ProximityPrompt") or obj:IsA("BillboardGui") or obj:IsA("TextLabel") then
			LastExtractionScan = 0
		end
	end)
end

UpdateExtractionESP = function()
	SyncWorldESPFromUI()

	if not WorldESP.Extractions then
		for extraction in pairs(ExtractionCache) do
			ClearExtractionESP(extraction)
		end
		return
	end

	EnsureExtractionDescendantHook()

	local now = tick()
	if now - LastExtractionScan >= ExtractionScanInterval then
		LastExtractionScan = now
		local ok, result = pcall(ScanExtractions)
		if ok then
			ExtractionList = result
		end

		for extraction in pairs(ExtractionCache) do
			if not ExtractionList[extraction] or not extraction.Parent then
				ClearExtractionESP(extraction)
			end
		end
	end

	local root = GetLocalRoot()
	local maxDistance = WorldESP.ExtractionMaxDistance or 5000

	for extraction, extractionData in pairs(ExtractionList) do
		if extraction.Parent then
			local pos = GetExtractionPosition(extractionData)
			if pos and IsWithinDistance(pos, maxDistance) then
				local data = EnsureExtractionESP(extraction)
				local highlightTarget = extractionData.HighlightTarget or extraction

				if not data.Highlight or not data.Highlight.Parent then
					local highlight = Instance.new("Highlight")
					highlight.Name = "WallhackExtractionESP"
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillTransparency = 0.55
					highlight.OutlineTransparency = 0
					highlight.Parent = highlightTarget
					data.Highlight = highlight
				end

				data.Highlight.Adornee = highlightTarget
				data.Highlight.FillColor = WorldESP.ExtractionColor
				data.Highlight.OutlineColor = WorldESP.ExtractionColor
			else
				ClearExtractionESP(extraction)
			end
		else
			ClearExtractionESP(extraction)
		end
	end
end

end)(); (function()

local LandmineTags = { "Landmine", "Mine", "Explosive", "Trap", "Boom", "PMN2", "PMN-2", "MON-50", "Deployable", "F1Trap", "F1 Trap", "APMine", "PressureMine" }
local DeployableFolderNames = { "Deployables", "DeployablesFolder", "Traps", "Trap", "Mines", "Deployable", "Effects", "Debris", "Projectiles", "World", "Ignore", "Thrown", "Dropped" }

local LandmineDisplayNames = {
	pmn2 = "PMN2",
	pmn = "PMN2",
	mon50 = "MON-50",
	f1trap = "F1 Trap",
	tm62 = "TM-62",
	m18claymore = "M18 Claymore",
	boom = "Land Mine",
	landmine = "Land Mine",
	apmine = "Land Mine",
	pressuremine = "Land Mine",
}

local LandmineNameKeywords = {
	"pmn",
	"mon50",
	"mon-50",
	"f1trap",
	"f1 trap",
	"claymore",
	"landmine",
	"land mine",
	"apmine",
	"ap mine",
	"pressuremine",
	"pressure mine",
	"antipersonnel",
	"anti personnel",
	"tm62",
	"tm-62",
	"m18",
	"boom",
	"mine",
}

local function NormalizeLandmineKey(name)
	return tostring(name or ""):lower():gsub("[%s_%-]", "")
end

local function HasLandmineTag(instance)
	if not instance then
		return false
	end
	for _, tag in LandmineTags do
		if CollectionService:HasTag(instance, tag) then
			return true
		end
	end
	return false
end

local function GetLandmineModel(instance)
	if instance:IsA("Model") then
		return instance
	end
	return instance:FindFirstAncestorOfClass("Model")
end

local function IsInDeployablesFolder(instance)
	local current = instance
	while current and current ~= workspace do
		local name = current.Name:lower()
		for _, folderName in DeployableFolderNames do
			if name == folderName:lower() then
				return true
			end
		end
		current = current.Parent
	end
	return false
end

local function NameLooksLikeLandmine(name)
	local lower = tostring(name or ""):lower()
	local key = NormalizeLandmineKey(lower)
	if key ~= "" and LandmineDisplayNames[key] then
		return true
	end
	for _, word in LandmineNameKeywords do
		if lower:find(word, 1, true) then
			return true
		end
	end
	return false
end

local function GetLandmineDisplayName(target)
	local key = NormalizeLandmineKey(target and target.Name)
	if LandmineDisplayNames[key] then
		return LandmineDisplayNames[key]
	end
	local lower = tostring(target and target.Name or ""):lower()
	if lower:find("pmn", 1, true) then
		return "PMN2"
	end
	if lower:find("mon", 1, true) and lower:find("50", 1, true) then
		return "MON-50"
	end
	if lower:find("f1", 1, true) and lower:find("trap", 1, true) then
		return "F1 Trap"
	end
	if lower:find("claymore", 1, true) or lower:find("m18", 1, true) then
		return "Claymore"
	end
	if lower:find("boom", 1, true) or lower:find("landmine", 1, true) or lower:find("mine", 1, true) then
		return "Land Mine"
	end
	return "Land Mine"
end

local function PartLooksOliveMineGreen(part)
	if not part or not part:IsA("BasePart") then
		return false
	end
	local c = part.Color
	-- Olive / military green disc (PMN2-style) — not bright neon grass
	local isGreen = c.G > c.R + 0.05 and c.G > c.B + 0.05 and c.G >= 0.28 and c.G <= 0.72
	local muted = c.R <= 0.55 and c.B <= 0.45
	return isGreen and muted
end

local function LooksLikeDiscMinePart(part)
	if not part or not part:IsA("BasePart") then
		return false
	end
	if part:IsA("Terrain") then
		return false
	end

	local size = part.Size
	local flat = size.Y <= 1.35 and size.X >= 1.0 and size.Z >= 1.0
	local roundish = math.abs(size.X - size.Z) <= 1.25
	local compact = size.X <= 5.5 and size.Z <= 5.5 and size.Magnitude <= 9
	if not (flat and roundish and compact) then
		return false
	end

	-- Skip huge floors / terrain-looking slabs
	if size.X >= 4.5 and size.Z >= 4.5 and size.Y <= 0.4 then
		return false
	end

	-- Prefer olive disc mines; still allow unnamed grey/dark pressure plates in deployables
	if PartLooksOliveMineGreen(part) then
		return true
	end

	local c = part.Color
	local darkPlate = c.R <= 0.35 and c.G <= 0.35 and c.B <= 0.35
	return darkPlate and size.Y <= 0.85
end

local function ModelLooksLikeDiscMine(model)
	if not model or not model:IsA("Model") then
		return false
	end
	if model:FindFirstChildOfClass("Humanoid") then
		return false
	end

	local ok, packed = pcall(function()
		local _, size = model:GetBoundingBox()
		return size
	end)
	if ok and typeof(packed) == "Vector3" then
		local size = packed
		local flat = size.Y <= 2.0 and size.X >= 1.0 and size.Z >= 1.0
		local roundish = math.abs(size.X - size.Z) <= 1.5
		local compact = size.X <= 6 and size.Z <= 6
		if flat and roundish and compact then
			return true
		end
	end

	for _, desc in model:GetDescendants() do
		if LooksLikeDiscMinePart(desc) then
			return true
		end
	end
	return false
end

local function HasLandmineAttribute(inst)
	if not inst then
		return false
	end
	for _, attr in {
		"Landmine",
		"IsLandmine",
		"IsMine",
		"Mine",
		"Trap",
		"Explosive",
		"PMN2",
		"DeployableType",
		"ItemName",
		"WeaponName",
	} do
		local value = inst:GetAttribute(attr)
		if value ~= nil then
			if typeof(value) == "boolean" and value then
				return true
			end
			if typeof(value) == "string" and NameLooksLikeLandmine(value) then
				return true
			end
		end
	end
	return false
end

local function IsProjectDeltaLandmine(target, instance)
	if not target then
		return false
	end

	if HasLandmineTag(target) or HasLandmineTag(instance) then
		return true
	end
	if HasLandmineAttribute(target) or HasLandmineAttribute(instance) then
		return true
	end

	if NameLooksLikeLandmine(target.Name) or NameLooksLikeLandmine(instance and instance.Name) then
		return true
	end

	-- Check nested part names (pressure plate / hitbox / mesh)
	if target:IsA("Model") then
		for _, child in target:GetChildren() do
			if NameLooksLikeLandmine(child.Name) or HasLandmineAttribute(child) then
				return true
			end
		end
	end

	if IsInDeployablesFolder(target) then
		if target:IsA("Model") and ModelLooksLikeDiscMine(target) then
			return true
		end
		if LooksLikeDiscMinePart(target) or LooksLikeDiscMinePart(instance) then
			return true
		end
		-- Any small deployable model in those folders is likely a trap/mine
		if target:IsA("Model") then
			local part = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
			if part and part.Size.Magnitude <= 10 then
				return true
			end
		end
	end

	-- Shape fallback: flat green disc mines like PMN2 in the open world
	if target:IsA("Model") and ModelLooksLikeDiscMine(target) then
		return true
	end
	if LooksLikeDiscMinePart(target) or LooksLikeDiscMinePart(instance) then
		return true
	end

	return false
end

local function TryAddLandmine(found, instance)
	if not instance then
		return
	end

	local model = GetLandmineModel(instance)
	local target = model or instance

	if not target:IsDescendantOf(workspace) then
		return
	end
	if HasHumanoidModel(target) or IsPlayerCharacterModel(target) then
		return
	end

	if not IsProjectDeltaLandmine(target, instance) then
		return
	end

	-- Skip obvious loot containers, but never block named/shaped mines
	if NameMatchesContainer(target.Name)
		and not NameLooksLikeLandmine(target.Name)
		and not ModelLooksLikeDiscMine(target)
		and not LooksLikeDiscMinePart(target)
	then
		return
	end

	local posPart = nil
	if target:IsA("Model") then
		posPart = target.PrimaryPart
			or target:FindFirstChild("Hitbox", true)
			or target:FindFirstChild("Main", true)
			or target:FindFirstChild("Handle", true)
			or target:FindFirstChildWhichIsA("BasePart", true)
	elseif target:IsA("BasePart") then
		posPart = target
	end

	if not posPart then
		return
	end

	local adornee = target:IsA("Model") and target or posPart
	if found[adornee] then
		return
	end

	found[adornee] = {
		Instance = adornee,
		PositionPart = posPart,
		Name = GetLandmineDisplayName(target),
	}
end

local function ScanLandmines()
	local found = {}

	for _, tag in LandmineTags do
		for _, obj in CollectionService:GetTagged(tag) do
			TryAddLandmine(found, obj)
		end
	end

	for _, folderName in DeployableFolderNames do
		local folder = workspace:FindFirstChild(folderName, true)
		if folder then
			for _, obj in folder:GetDescendants() do
				if obj:IsA("Model") or obj:IsA("BasePart") then
					TryAddLandmine(found, obj)
				end
			end
		end
	end

	-- Full workspace scan for mines (name + flat disc shape like your screenshot)
	for _, obj in workspace:GetDescendants() do
		if obj:IsA("Model") then
			if NameLooksLikeLandmine(obj.Name) or ModelLooksLikeDiscMine(obj) or HasLandmineAttribute(obj) or HasLandmineTag(obj) then
				TryAddLandmine(found, obj)
			end
		elseif obj:IsA("BasePart") then
			if NameLooksLikeLandmine(obj.Name) or LooksLikeDiscMinePart(obj) or HasLandmineAttribute(obj) or HasLandmineTag(obj) then
				TryAddLandmine(found, obj)
			end
		end
	end

	return found
end

local function EnsureLandmineDescendantHook()
	if LandmineDescendantHook then
		return
	end

	LandmineDescendantHook = true
	workspace.DescendantAdded:Connect(function(obj)
		if not WorldESP.Landmines then
			return
		end

		if obj:IsA("Model") or obj:IsA("BasePart") then
			local name = obj.Name:lower()
			if NameLooksLikeLandmine(name)
				or name:find("hitbox", 1, true)
				or name:find("pressure", 1, true)
				or LooksLikeDiscMinePart(obj)
			then
				LastLandmineScan = 0
			end
		end
	end)
end

local function RefreshLandmineListIfNeeded(force)
	local now = tick()
	if not force and now - LastLandmineScan < LandmineScanInterval then
		return
	end

	LastLandmineScan = now
	local ok, result = pcall(ScanLandmines)
	if ok and type(result) == "table" then
		LandmineList = result
	end
end

local function GetLandminePosition(mineData)
	local part = mineData.PositionPart
	if part and part.Parent then
		return part.Position
	end
	return nil
end

local function EnsureLandmineESP(mine)
	if LandmineCache[mine] then
		return LandmineCache[mine]
	end

	local data = {
		Highlight = nil,
		NameLabel = NewTextLabel(),
	}

	LandmineCache[mine] = data
	return data
end

UpdateLandmineESP = function()
	SyncWorldESPFromUI()

	if not WorldESP.Landmines then
		for mine in pairs(LandmineCache) do
			ClearLandmineESP(mine)
		end
		return
	end

	EnsureLandmineDescendantHook()
	RefreshLandmineListIfNeeded(false)

	for mine in pairs(LandmineCache) do
		if not LandmineList[mine] or not mine.Parent then
			ClearLandmineESP(mine)
		end
	end

	local maxDist = WorldESP.LandmineMaxDistance or WorldESP.MaxDistance or 800

	for mine, mineData in pairs(LandmineList) do
		if mine.Parent then
			local pos = GetLandminePosition(mineData)
			if pos and IsWithinDistance(pos, maxDist) then
				local data = EnsureLandmineESP(mine)

				local highlightTarget = mineData.Instance or mine
				if not data.Highlight or not data.Highlight.Parent then
					local highlight = Instance.new("Highlight")
					highlight.Name = "WallhackLandmineESP"
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillTransparency = 0.5
					highlight.OutlineTransparency = 0
					highlight.Parent = highlightTarget
					data.Highlight = highlight
				end

				data.Highlight.Adornee = highlightTarget
				data.Highlight.FillColor = WorldESP.LandmineColor
				data.Highlight.OutlineColor = WorldESP.LandmineColor

				local screenPos, onScreen = WorldToScreenAny(pos)
				if onScreen then
					data.NameLabel.Text = mineData.Name
					data.NameLabel.TextColor3 = WorldESP.LandmineNameColor
					data.NameLabel.AnchorPoint = Vector2.new(0.5, 1)
					data.NameLabel.Position = UDim2.fromOffset(screenPos.X, screenPos.Y - 4)
					data.NameLabel.Visible = true
				else
					data.NameLabel.Visible = false
				end
			else
				ClearLandmineESP(mine)
			end
		else
			ClearLandmineESP(mine)
		end
	end
end

Players.PlayerRemoving:Connect(ClearPlayerESP)

local VisualsLeft = Tabs.Visuals:AddLeftGroupbox("Player ESP")

VisualsLeft:AddToggle("SelfESP", {
	Text = "Self ESP",
	Default = false,
	Callback = function(value)
		ESP.Self = value
		if not value then
			HidePlayerESP(LocalPlayer)
		end
	end,
})

VisualsLeft:AddDivider()

VisualsLeft:AddToggle("BoneESP", {
	Text = "Bone ESP",
	Default = false,
	Callback = function(value)
		ESP.Bone = value
	end,
}):AddColorPicker("BoneColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Bone Color",
	Callback = function(value)
		ESP.BoneColor = value
	end,
})

VisualsLeft:AddToggle("VisibilityCheck", {
	Text = "Visibility Check",
	Default = false,
	Callback = function(value)
		ESP.VisibilityCheck = value
	end,
}):AddColorPicker("OccludedColor", {
	Default = Color3.fromRGB(255, 60, 60),
	Title = "Behind Wall Color",
	Callback = function(value)
		ESP.OccludedColor = value
	end,
})

VisualsLeft:AddSlider("SkeletonThickness", {
	Text = "Bone Thickness",
	Default = 2,
	Min = 1,
	Max = 15,
	Rounding = 0,
	Callback = function(value)
		ESP.SkeletonThickness = value
	end,
})

VisualsLeft:AddToggle("BoxESP", {
	Text = "Box ESP",
	Default = false,
	Callback = function(value)
		ESP.Box = value
	end,
}):AddColorPicker("BoxColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Box Color",
	Callback = function(value)
		ESP.BoxColor = value
	end,
})

VisualsLeft:AddDropdown("BoxType", {
	Text = "Box Type",
	Values = { "Normal", "Cornered", "3D" },
	Default = 1,
	Callback = function(value)
		ESP.BoxType = value
	end,
})

VisualsLeft:AddToggle("TracerESP", {
	Text = "Tracer ESP",
	Default = false,
	Callback = function(value)
		ESP.Tracer = value
	end,
}):AddColorPicker("TracerColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Tracer Color",
	Callback = function(value)
		ESP.TracerColor = value
	end,
})

VisualsLeft:AddDropdown("TracerOrigin", {
	Text = "Tracer Origin",
	Values = { "Bottom", "Middle", "Top" },
	Default = 1,
	Callback = function(value)
		ESP.TracerOrigin = value
	end,
})

VisualsLeft:AddToggle("ChamsESP", {
	Text = "Chams ESP",
	Default = false,
	Callback = function(value)
		ESP.Chams = value
	end,
}):AddColorPicker("ChamsColor", {
	Default = Color3.fromRGB(255, 80, 80),
	Title = "Chams Color",
	Callback = function(value)
		ESP.ChamsColor = value
	end,
})

VisualsLeft:AddDropdown("ChamsStyle", {
	Text = "Chams Style",
	Values = { "Filled", "WireFrame" },
	Default = 1,
	Callback = function(value)
		ESP.ChamsStyle = ResolveDropdown(value, { "Filled", "WireFrame" }, ESP.ChamsStyle)
	end,
})

VisualsLeft:AddToggle("NameESP", {
	Text = "Name ESP",
	Default = false,
	Callback = function(value)
		ESP.Name = value
	end,
}):AddColorPicker("NameESPColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Name Color",
	Callback = function(value)
		ESP.NameColor = value
	end,
})

VisualsLeft:AddToggle("DistanceESP", {
	Text = "Distance ESP",
	Default = false,
	Callback = function(value)
		ESP.Distance = value
	end,
}):AddColorPicker("DistanceESPColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Distance Color",
	Callback = function(value)
		ESP.DistanceColor = value
	end,
})

VisualsLeft:AddToggle("HealthESP", {
	Text = "Healthbar",
	Default = false,
	Callback = function(value)
		ESP.Health = value
	end,
})

VisualsLeft:AddDropdown("HealthStyle", {
	Text = "Health Style",
	Values = { "Normal Health", "Gradient Health" },
	Default = 2,
	Callback = function(value)
		ESP.HealthStyle = value
	end,
})

VisualsLeft:AddToggle("HealthBarTextESP", {
	Text = "Health Bar Text",
	Default = false,
	Callback = function(value)
		ESP.HealthText = value
	end,
}):AddColorPicker("HealthTextColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Health Text Color",
	Callback = function(value)
		ESP.HealthTextColor = value
	end,
})

VisualsLeft:AddToggle("HeadDotESP", {
	Text = "Head Dot ESP",
	Default = false,
	Callback = function(value)
		ESP.HeadDot = value
	end,
}):AddColorPicker("HeadDotColor", {
	Default = Color3.fromRGB(255, 80, 80),
	Title = "Head Dot Color",
	Callback = function(value)
		ESP.HeadDotColor = value
	end,
})

VisualsLeft:AddDropdown("HeadDotStyle", {
	Text = "Head Dot Style",
	Values = { "Filled", "Hollow" },
	Default = 1,
	Callback = function(value)
		ESP.HeadDotStyle = value
	end,
})

VisualsLeft:AddToggle("ChineseHatESP", {
	Text = "Chinese Hat ESP",
	Default = false,
	Callback = function(value)
		ESP.ChineseHat = value
	end,
}):AddColorPicker("ChineseHatColor", {
	Default = Color3.fromRGB(255, 215, 0),
	Title = "Chinese Hat Color",
	Callback = function(value)
		ESP.ChineseHatColor = value
	end,
})

VisualsLeft:AddDivider()

VisualsLeft:AddToggle("BulletTracerESP", {
	Text = "Bullet Tracer",
	Default = false,
	Callback = function(value)
		ESP.BulletTracer = value
		if not value then
			ClearAllBulletTracers()
		end
	end,
}):AddColorPicker("BulletTracerColor", {
	Default = Color3.fromRGB(255, 220, 100),
	Title = "Bullet Tracer Color",
	Callback = function(value)
		ESP.BulletTracerColor = value
	end,
})

VisualsLeft:AddSlider("BulletTracerThickness", {
	Text = "Tracer Thickness",
	Default = 0.12,
	Min = 0.04,
	Max = 0.35,
	Rounding = 2,
	Callback = function(value)
		ESP.BulletTracerThickness = value
	end,
})

VisualsLeft:AddSlider("BulletTracerDuration", {
	Text = "Tracer Duration",
	Default = 0.45,
	Min = 0.1,
	Max = 1.5,
	Rounding = 2,
	Suffix = "s",
	Callback = function(value)
		ESP.BulletTracerDuration = value
	end,
})

VisualsLeft:AddToggle("GunChamESP", {
	Text = "Gun Cham",
	Default = false,
	Callback = function(value)
		ESP.GunCham = value
		if not value then
			ClearGunCham()
		end
	end,
}):AddColorPicker("GunChamColor", {
	Default = Color3.fromRGB(255, 0, 255),
	Title = "Gun Cham Color",
	Callback = function(value)
		ESP.GunChamColor = value
	end,
})

local VisualsRight = Tabs.Visuals:AddRightGroupbox("Npc ESP")

VisualsRight:AddToggle("NpcESPEnabled", {
	Text = "NPC ESP",
	Default = false,
	Callback = function(value)
		NpcESP.Enabled = value
		if not value then
			for npc in pairs(NpcCache) do
				ClearNpcESP(npc)
			end
			NpcList = {}
		end
	end,
})

VisualsRight:AddDivider()

VisualsRight:AddToggle("NpcBoneESP", {
	Text = "Bone ESP",
	Default = false,
	Callback = function(value)
		NpcESP.Bone = value
	end,
}):AddColorPicker("NpcBoneColor", {
	Default = Color3.fromRGB(255, 180, 80),
	Title = "Bone Color",
	Callback = function(value)
		NpcESP.BoneColor = value
	end,
})

VisualsRight:AddSlider("NpcSkeletonThickness", {
	Text = "Bone Thickness",
	Default = 2,
	Min = 1,
	Max = 15,
	Rounding = 0,
	Callback = function(value)
		NpcESP.SkeletonThickness = value
	end,
})

VisualsRight:AddToggle("NpcBoxESP", {
	Text = "Box ESP",
	Default = false,
	Callback = function(value)
		NpcESP.Box = value
	end,
}):AddColorPicker("NpcBoxColor", {
	Default = Color3.fromRGB(255, 180, 80),
	Title = "Box Color",
	Callback = function(value)
		NpcESP.BoxColor = value
	end,
})

VisualsRight:AddDropdown("NpcBoxType", {
	Text = "Box Type",
	Values = { "Normal", "Cornered", "3D" },
	Default = 1,
	Callback = function(value)
		NpcESP.BoxType = ResolveDropdown(value, { "Normal", "Cornered", "3D" }, NpcESP.BoxType)
	end,
})

VisualsRight:AddToggle("NpcTracerESP", {
	Text = "Tracer ESP",
	Default = false,
	Callback = function(value)
		NpcESP.Tracer = value
	end,
}):AddColorPicker("NpcTracerColor", {
	Default = Color3.fromRGB(255, 200, 120),
	Title = "Tracer Color",
	Callback = function(value)
		NpcESP.TracerColor = value
	end,
})

VisualsRight:AddDropdown("NpcTracerOrigin", {
	Text = "Tracer Origin",
	Values = { "Bottom", "Middle", "Top" },
	Default = 1,
	Callback = function(value)
		NpcESP.TracerOrigin = ResolveDropdown(value, { "Bottom", "Middle", "Top" }, NpcESP.TracerOrigin)
	end,
})

VisualsRight:AddToggle("NpcChamsESP", {
	Text = "Chams ESP",
	Default = false,
	Callback = function(value)
		NpcESP.Chams = value
	end,
}):AddColorPicker("NpcChamsColor", {
	Default = Color3.fromRGB(255, 140, 40),
	Title = "Chams Color",
	Callback = function(value)
		NpcESP.ChamsColor = value
	end,
})

VisualsRight:AddDropdown("NpcChamsStyle", {
	Text = "Chams Style",
	Values = { "Filled", "WireFrame" },
	Default = 1,
	Callback = function(value)
		NpcESP.ChamsStyle = ResolveDropdown(value, { "Filled", "WireFrame" }, NpcESP.ChamsStyle)
	end,
})

VisualsRight:AddToggle("NpcNameESP", {
	Text = "Name ESP",
	Default = false,
	Callback = function(value)
		NpcESP.Name = value
	end,
}):AddColorPicker("NpcNameESPColor", {
	Default = Color3.fromRGB(255, 220, 160),
	Title = "Name Color",
	Callback = function(value)
		NpcESP.NameColor = value
	end,
})

VisualsRight:AddToggle("NpcDistanceESP", {
	Text = "Distance ESP",
	Default = false,
	Callback = function(value)
		NpcESP.Distance = value
	end,
}):AddColorPicker("NpcDistanceESPColor", {
	Default = Color3.fromRGB(255, 200, 120),
	Title = "Distance Color",
	Callback = function(value)
		NpcESP.DistanceColor = value
	end,
})

VisualsRight:AddToggle("NpcHealthESP", {
	Text = "Healthbar",
	Default = false,
	Callback = function(value)
		NpcESP.Health = value
	end,
})

VisualsRight:AddDropdown("NpcHealthStyle", {
	Text = "Health Style",
	Values = { "Normal Health", "Gradient Health" },
	Default = 2,
	Callback = function(value)
		NpcESP.HealthStyle = ResolveDropdown(value, { "Normal Health", "Gradient Health" }, NpcESP.HealthStyle)
	end,
})

VisualsRight:AddToggle("NpcHealthBarTextESP", {
	Text = "Health Bar Text",
	Default = false,
	Callback = function(value)
		NpcESP.HealthText = value
	end,
}):AddColorPicker("NpcHealthTextColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Health Text Color",
	Callback = function(value)
		NpcESP.HealthTextColor = value
	end,
})

VisualsRight:AddToggle("NpcHeadDotESP", {
	Text = "Head Dot ESP",
	Default = false,
	Callback = function(value)
		NpcESP.HeadDot = value
	end,
}):AddColorPicker("NpcHeadDotColor", {
	Default = Color3.fromRGB(255, 140, 40),
	Title = "Head Dot Color",
	Callback = function(value)
		NpcESP.HeadDotColor = value
	end,
})

VisualsRight:AddDropdown("NpcHeadDotStyle", {
	Text = "Head Dot Style",
	Values = { "Filled", "Hollow" },
	Default = 1,
	Callback = function(value)
		NpcESP.HeadDotStyle = ResolveDropdown(value, { "Filled", "Hollow" }, NpcESP.HeadDotStyle)
	end,
})

VisualsRight:AddToggle("NpcChineseHatESP", {
	Text = "Chinese Hat ESP",
	Default = false,
	Callback = function(value)
		NpcESP.ChineseHat = value
	end,
}):AddColorPicker("NpcChineseHatColor", {
	Default = Color3.fromRGB(255, 200, 80),
	Title = "Chinese Hat Color",
	Callback = function(value)
		NpcESP.ChineseHatColor = value
	end,
})

----------------------------------------------------------------
-- World ESP
----------------------------------------------------------------
local WorldBox = Tabs.WorldESP:AddLeftGroupbox("In World ESP")

WorldBox:AddToggle("CrateESP", {
	Text = "Crate ESP",
	Default = false,
	Callback = function(value)
		WorldESP.Crates = value
		LastCrateScan = 0
		if not value and not WorldESP.CrateName and not WorldESP.CrateDistance then
			for crate in pairs(CrateCache) do
				ClearCrateESP(crate)
			end
		end
	end,
}):AddColorPicker("CrateHighlightColor", {
	Default = Color3.fromRGB(255, 200, 80),
	Title = "Crate Highlight Color",
	Callback = function(value)
		WorldESP.CrateColor = value
	end,
})

WorldBox:AddToggle("CrateNameESP", {
	Text = "Crate Name ESP",
	Default = true,
	Callback = function(value)
		WorldESP.CrateName = value
		LastCrateScan = 0
	end,
}):AddColorPicker("CrateNameColor", {
	Default = Color3.fromRGB(255, 255, 255),
	Title = "Crate Name Color",
	Callback = function(value)
		WorldESP.NameColor = value
	end,
})

WorldBox:AddToggle("CrateDistanceESP", {
	Text = "Crate Distance ESP",
	Default = true,
	Callback = function(value)
		WorldESP.CrateDistance = value
		LastCrateScan = 0
	end,
}):AddColorPicker("CrateDistanceColor", {
	Default = Color3.fromRGB(200, 200, 200),
	Title = "Crate Distance Color",
	Callback = function(value)
		WorldESP.DistanceColor = value
	end,
})

WorldBox:AddSlider("CrateMaxDistance", {
	Text = "Crate Distance",
	Default = 500,
	Min = 50,
	Max = 3000,
	Rounding = 0,
	Suffix = "m",
	Callback = function(value)
		WorldESP.MaxDistance = value
	end,
})

WorldBox:AddDivider()

WorldBox:AddLabel("Environment")

WorldBox:AddToggle("PurpleSky", {
	Text = "Purple Sky",
	Default = false,
	Callback = function(value)
		WorldESP.PurpleSky = value
		if value then
			Misc.FullBright = false
			pcall(function()
				if Toggles.FullBright then
					Toggles.FullBright:SetValue(false)
				end
			end)
			if SaveLightingDefaults then
				SaveLightingDefaults()
			end
			if SaveAtmosphereDefaults then
				SaveAtmosphereDefaults()
			end
		else
			if ClearPurpleSkyEffects then
				ClearPurpleSkyEffects()
			end
			if RestoreLightingDefaults then
				RestoreLightingDefaults()
			end
		end
	end,
}):AddColorPicker("PurpleSkyColor", {
	Default = Color3.fromRGB(150, 0, 230),
	Title = "Purple Sky Color",
	Callback = function(value)
		WorldESP.PurpleSkyColor = value
		if WorldESP.PurpleSky and UpdatePurpleSky then
			UpdatePurpleSky()
		end
	end,
})

WorldBox:AddToggle("LandmineESP", {
	Text = "Land Mine ESP",
	Default = false,
	Callback = function(value)
		WorldESP.Landmines = value
		LastLandmineScan = 0
		if not value then
			for mine in pairs(LandmineCache) do
				ClearLandmineESP(mine)
			end
		else
			RefreshLandmineListIfNeeded(true)
		end
	end,
}):AddColorPicker("LandmineHighlightColor", {
	Default = Color3.fromRGB(255, 60, 60),
	Title = "Land Mine Color",
	Callback = function(value)
		WorldESP.LandmineColor = value
	end,
})

WorldBox:AddSlider("LandmineMaxDistance", {
	Text = "Land Mine Distance",
	Default = 800,
	Min = 50,
	Max = 3000,
	Rounding = 0,
	Suffix = "m",
	Callback = function(value)
		WorldESP.LandmineMaxDistance = value
	end,
})

WorldBox:AddToggle("ExtractionESP", {
	Text = "Extraction ESP",
	Default = false,
	Callback = function(value)
		WorldESP.Extractions = value
		if value then
			LastExtractionScan = 0
			EnsureExtractionDescendantHook()
		else
			for extraction in pairs(ExtractionCache) do
				ClearExtractionESP(extraction)
			end
		end
	end,
}):AddColorPicker("ExtractionHighlightColor", {
	Default = Color3.fromRGB(90, 255, 130),
	Title = "Extraction Color",
	Callback = function(value)
		WorldESP.ExtractionColor = value
	end,
})

WorldBox:AddSlider("ExtractionMaxDistance", {
	Text = "Extraction Distance",
	Default = 5000,
	Min = 250,
	Max = 10000,
	Rounding = 0,
	Suffix = "m",
	Callback = function(value)
		WorldESP.ExtractionMaxDistance = value
	end,
})

end)();

----------------------------------------------------------------
-- Misc (wrapped to avoid main-chunk 200 local register limit)
----------------------------------------------------------------
(function()
local DefaultCameraFOV = 70
local FOVSaved = false
local LightingDefaults
local SpinbotSaved = { Active = false }
local ThirdPersonSaved = { Active = false }
local UpdateMisc, SyncMiscFromUI, ClearWaterPlatform, UpdateLighting
local UpdateFullBright, UpdateSpinbot, UpdateThirdPerson
local ClearFullBrightEffects
local InitWallPenetration, UpdateWallTransparency, RestoreWallTransparency
-- Lighting helpers used by World ESP UI must be globals (assigned below)

Misc = {
	Spinbot = false,
	SpinSpeed = 20,
	ThirdPerson = false,
	FOVChanger = false,
	CameraFOV = 70,
	WalkOnWater = false,
	FullBright = false,
	WallPenetration = false,
	NoRecoil = false,
	NoSpread = false,
	FastWalk = false,
	FreeCam = false,
	FreeCamSpeed = 60,
}

task.defer(function()
	local cam = workspace.CurrentCamera
	if cam then
		DefaultCameraFOV = cam.FieldOfView
		Misc.CameraFOV = DefaultCameraFOV
	end
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local cam = workspace.CurrentCamera
	if cam and not FOVSaved then
		DefaultCameraFOV = cam.FieldOfView
	end
	if Misc.FOVChanger and cam then
		cam.FieldOfView = Misc.CameraFOV
	end
end)

SyncMiscFromUI = function()
	local function toggle(name, key)
		local t = Toggles[name]
		if t then
			Misc[key] = t.Value
		end
	end

	local function option(name, key)
		local o = Options[name]
		if o then
			Misc[key] = o.Value
		end
	end

	toggle("Spinbot", "Spinbot")
	toggle("ThirdPerson", "ThirdPerson")
	toggle("FOVChanger", "FOVChanger")
	toggle("WalkOnWater", "WalkOnWater")
	toggle("FullBright", "FullBright")
	toggle("WallPenetration", "WallPenetration")
	toggle("NoRecoil", "NoRecoil")
	toggle("NoSpread", "NoSpread")
	toggle("FastWalk", "FastWalk")
	toggle("FreeCam", "FreeCam")
	option("SpinSpeed", "SpinSpeed")
	option("CameraFOV", "CameraFOV")
	option("FreeCamSpeed", "FreeCamSpeed")
end

local GunModsInstalled = false
local SilentWalkSounds = {}
local SilentWalkConn = nil
local SilentWalkNetInstalled = false
local SilentWalkAnimConns = {}
local SilentWalkModulesPatched = false
local SilentWalkSaved = {
	Active = false,
	WalkSpeed = nil,
}

local function IsFootstepKeyword(text)
	text = tostring(text or ""):lower()
	if text == "" then
		return false
	end
	return text:find("foot", 1, true)
		or text:find("step", 1, true)
		or text:find("run", 1, true)
		or text:find("walk", 1, true)
		or text:find("sprint", 1, true)
		or text:find("land", 1, true)
		or text:find("jump", 1, true)
		or text:find("cloth", 1, true)
		or text:find("movement", 1, true)
		or text:find("grass", 1, true)
		or text:find("dirt", 1, true)
		or text:find("concrete", 1, true)
		or text:find("gravel", 1, true)
		or text:find("sand", 1, true)
		or text:find("snow", 1, true)
		or text:find("splash", 1, true)
		or text:find("surface", 1, true)
		or text:find("materialsound", 1, true)
		or text:find("charsound", 1, true)
		or text:find("character sound", 1, true)
end

local function IsMovementSound(sound)
	if not sound or not sound:IsA("Sound") then
		return false
	end
	if IsFootstepKeyword(sound.Name) then
		return true
	end
	local ok, id = pcall(function()
		return sound.SoundId
	end)
	return ok and IsFootstepKeyword(id)
end

local function IsLocalCharacterSound(sound)
	local character = LocalPlayer.Character
	return character ~= nil and sound:IsDescendantOf(character)
end

local function MuteMovementSound(sound)
	if not sound then
		return
	end
	if not SilentWalkSounds[sound] then
		SilentWalkSounds[sound] = {
			Volume = sound.Volume,
			RollOffMaxDistance = sound.RollOffMaxDistance,
		}
	end
	sound.Volume = 0
	pcall(function()
		sound.RollOffMaxDistance = 0
	end)
	pcall(function()
		if sound.Playing then
			sound:Stop()
		end
	end)
end

RestoreMovementSounds = function()
	for sound, saved in pairs(SilentWalkSounds) do
		if sound and sound.Parent then
			sound.Volume = saved.Volume
			pcall(function()
				sound.RollOffMaxDistance = saved.RollOffMaxDistance
			end)
		end
		SilentWalkSounds[sound] = nil
	end
end

local function RestoreSilentWalkMovement()
	if not SilentWalkSaved.Active then
		return
	end
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and typeof(SilentWalkSaved.WalkSpeed) == "number" then
		humanoid.WalkSpeed = SilentWalkSaved.WalkSpeed
	end
	SilentWalkSaved.Active = false
	SilentWalkSaved.WalkSpeed = nil
end

local function IsLocoAnimTrack(track)
	if not track then
		return false
	end
	local names = { track.Name }
	pcall(function()
		if track.Animation then
			names[#names + 1] = track.Animation.Name
			names[#names + 1] = track.Animation.AnimationId
		end
	end)
	for _, name in names do
		local lower = tostring(name):lower()
		if lower:find("walk", 1, true)
			or lower:find("run", 1, true)
			or lower:find("sprint", 1, true)
			or lower:find("jog", 1, true)
			or lower:find("loco", 1, true)
			or lower:find("move", 1, true)
		then
			return true
		end
	end
	return false
end

local function StopLocoAnimations(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and (humanoid:FindFirstChildOfClass("Animator") or humanoid:FindFirstChild("Animator", true))
	if not animator then
		return
	end
	for _, track in animator:GetPlayingAnimationTracks() do
		if IsLocoAnimTrack(track) then
			pcall(function()
				track:Stop(0)
			end)
		end
	end
end

local function GetSilentWalkMoveVector()
	local camera = workspace.CurrentCamera
	if not camera then
		return Vector3.zero
	end

	local localMove = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		localMove += Vector3.new(0, 0, -1)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		localMove += Vector3.new(0, 0, 1)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		localMove += Vector3.new(-1, 0, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		localMove += Vector3.new(1, 0, 0)
	end

	if localMove.Magnitude < 0.01 then
		return Vector3.zero
	end

	local look = camera.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	if flatLook.Magnitude < 0.01 then
		flatLook = Vector3.new(0, 0, -1)
	else
		flatLook = flatLook.Unit
	end
	local right = Vector3.new(flatLook.Z, 0, -flatLook.X)
	local world = (flatLook * -localMove.Z) + (right * localMove.X)
	if world.Magnitude < 0.01 then
		return Vector3.zero
	end
	return world.Unit
end

local function SilenceAnimationFootsteps(character)
	if not character then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		return
	end

	local function hookTrack(track)
		if not track or SilentWalkAnimConns[track] then
			return
		end
		SilentWalkAnimConns[track] = true

		pcall(function()
			if typeof(getconnections) == "function" then
				for _, markerName in { "Footstep", "FootStep", "Step", "Run", "Walk", "Land", "Jump", "Cloth" } do
					local okSignal, signal = pcall(function()
						return track:GetMarkerReachedSignal(markerName)
					end)
					if okSignal and signal then
						for _, conn in getconnections(signal) do
							pcall(function()
								conn:Disable()
							end)
						end
					end
				end
			end
		end)
	end

	for _, track in animator:GetPlayingAnimationTracks() do
		hookTrack(track)
	end

	if not animator:GetAttribute("WallhackSilentWalkAnim") then
		animator:SetAttribute("WallhackSilentWalkAnim", true)
		animator.AnimationPlayed:Connect(function(track)
			if Misc.FastWalk then
				hookTrack(track)
				if IsLocoAnimTrack(track) then
					pcall(function()
						track:Stop(0)
					end)
				end
			end
		end)
	end
end

local function PatchFootstepModules()
	if SilentWalkModulesPatched then
		return
	end
	SilentWalkModulesPatched = true

	pcall(function()
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		if not modules then
			return
		end
		for _, child in modules:GetDescendants() do
			if child:IsA("ModuleScript") then
				local name = child.Name:lower()
				if IsFootstepKeyword(name) or name:find("audio", 1, true) or name:find("sound", 1, true) then
					local ok, mod = pcall(require, child)
					if ok and type(mod) == "table" then
						for key, value in pairs(mod) do
							if type(value) == "function" and IsFootstepKeyword(key) then
								pcall(function()
									mod[key] = function() end
								end)
							end
						end
					end
				end
			end
		end
	end)

	pcall(function()
		local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
		if not scripts then
			return
		end
		for _, child in scripts:GetDescendants() do
			if child:IsA("LocalScript") or child:IsA("Script") then
				local name = child.Name:lower()
				if name:find("character", 1, true) and name:find("sound", 1, true) then
					child.Disabled = true
				elseif IsFootstepKeyword(name) then
					child.Disabled = true
				end
			end
		end
	end)
end

local function IsFootstepRemoteName(text)
	text = tostring(text or ""):lower()
	if text == "" then
		return false
	end
	return text:find("footstep", 1, true)
		or text:find("foot_step", 1, true)
		or text:find("foot step", 1, true)
		or text:find("charsound", 1, true)
		or text:find("character sound", 1, true)
		or text:find("materialsound", 1, true)
		or text:find("surfacesound", 1, true)
		or text:find("movesound", 1, true)
		or text:find("walksound", 1, true)
		or text:find("runsound", 1, true)
		or (text:find("sound", 1, true) and (text:find("foot", 1, true) or text:find("step", 1, true) or text:find("cloth", 1, true)))
		or (text:find("audio", 1, true) and (text:find("foot", 1, true) or text:find("step", 1, true) or text:find("move", 1, true)))
end

local function ArgsLookLikeFootstep(...)
	local packed = table.pack(...)
	for i = 1, packed.n do
		local value = packed[i]
		local t = typeof(value)
		if t == "string" and IsFootstepRemoteName(value) then
			return true
		end
		if t == "Instance" then
			if value:IsA("Sound") and IsMovementSound(value) then
				return true
			end
			if IsFootstepRemoteName(value.Name) then
				return true
			end
		end
		if t == "table" then
			for key, nested in pairs(value) do
				if IsFootstepRemoteName(key) or IsFootstepRemoteName(nested) then
					return true
				end
			end
		end
	end
	return false
end

local function EnsureSilentWalkNetwork()
	if SilentWalkNetInstalled then
		return
	end
	if typeof(hookmetamethod) ~= "function" or typeof(getnamecallmethod) ~= "function" then
		return
	end

	local wrap = typeof(newcclosure) == "function" and newcclosure or function(fn)
		return fn
	end

	pcall(function()
		local oldNamecall
		oldNamecall = hookmetamethod(game, "__namecall", wrap(function(self, ...)
			local method = getnamecallmethod()
			if Misc and Misc.FastWalk then
				if method == "FireServer" or method == "InvokeServer" or method == "Fire" or method == "Invoke" then
					local remoteName = ""
					pcall(function()
						remoteName = self.Name
					end)
					if IsFootstepRemoteName(remoteName) or ArgsLookLikeFootstep(...) then
						if method == "InvokeServer" or method == "Invoke" then
							return nil
						end
						return
					end
				end

				if method == "Play" and typeof(self) == "Instance" and self:IsA("Sound") then
					if IsLocalCharacterSound(self) and IsMovementSound(self) then
						MuteMovementSound(self)
						return
					end
				end

				if method == "PlayLocalSound" then
					local sound = ...
					if typeof(sound) == "Instance" and sound:IsA("Sound") and IsMovementSound(sound) then
						MuteMovementSound(sound)
						return
					end
				end
			end
			return oldNamecall(self, ...)
		end))
	end)

	SilentWalkNetInstalled = true
end

local function ApplySilentWalkToCharacter(character)
	if not character then
		return
	end
	for _, desc in character:GetDescendants() do
		if IsMovementSound(desc) then
			MuteMovementSound(desc)
		end
	end

	SilenceAnimationFootsteps(character)
	StopLocoAnimations(character)

	if not character:GetAttribute("WallhackSilentWalkHook") then
		character:SetAttribute("WallhackSilentWalkHook", true)
		character.DescendantAdded:Connect(function(desc)
			if not Misc.FastWalk then
				return
			end
			if IsMovementSound(desc) then
				MuteMovementSound(desc)
			end
		end)
	end
end

local function EnsureSilentWalkHook()
	if SilentWalkConn then
		return
	end
	SilentWalkConn = LocalPlayer.CharacterAdded:Connect(function(character)
		if Misc.FastWalk then
			SilentWalkSaved.Active = false
			SilentWalkSaved.WalkSpeed = nil
			task.defer(function()
				EnsureSilentWalkNetwork()
				PatchFootstepModules()
				ApplySilentWalkToCharacter(character)
			end)
		end
	end)
end

UpdateFastWalk = function(deltaTime)
	deltaTime = typeof(deltaTime) == "number" and deltaTime or 0.016
	if deltaTime <= 0 then
		deltaTime = 0.016
	elseif deltaTime > 0.1 then
		deltaTime = 0.1
	end

	if not Misc.FastWalk then
		RestoreSilentWalkMovement()
		RestoreMovementSounds()
		return
	end

	EnsureSilentWalkNetwork()
	EnsureSilentWalkHook()
	PatchFootstepModules()

	local character = LocalPlayer.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	if not humanoid or not root then
		return
	end

	if not SilentWalkSaved.Active then
		SilentWalkSaved.Active = true
		SilentWalkSaved.WalkSpeed = humanoid.WalkSpeed
	end

	-- Humanoid walk creates audible footsteps for other clients — move with CFrame instead
	if humanoid.WalkSpeed ~= 0 then
		SilentWalkSaved.WalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 0
	end

	ApplySilentWalkToCharacter(character)
	StopLocoAnimations(character)

	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		humanoid.Jump = true
	end

	local move = GetSilentWalkMoveVector()
	if move.Magnitude > 0.01 then
		local sprinting = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		local baseSpeed = typeof(SilentWalkSaved.WalkSpeed) == "number" and SilentWalkSaved.WalkSpeed or 16
		if baseSpeed < 8 then
			baseSpeed = 16
		end
		-- Fast Walk: much faster CFrame move
		local speed = sprinting and (baseSpeed * 3.4) or (baseSpeed * 2.6)
		local nextPos = root.Position + move * speed * deltaTime
		root.CFrame = CFrame.new(nextPos, nextPos + move)
	end

	-- Kill horizontal velocity so other clients' footstep checks see you as idle
	local velocity = root.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
	pcall(function()
		root.AssemblyAngularVelocity = Vector3.zero
	end)

	pcall(function()
		local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
		if not scripts then
			return
		end
		for _, desc in scripts:GetDescendants() do
			if IsMovementSound(desc) then
				MuteMovementSound(desc)
			end
		end
	end)
end

local FreeCamSaved = {
	Active = false,
	CameraType = nil,
	CameraSubject = nil,
	MouseBehavior = nil,
	Position = nil,
	Yaw = 0,
	Pitch = 0,
}

local function StopFreeCam()
	if not FreeCamSaved.Active then
		return
	end

	FreeCamSaved.Active = false
	local cam = workspace.CurrentCamera
	if cam then
		if FreeCamSaved.CameraType ~= nil then
			cam.CameraType = FreeCamSaved.CameraType
		end
		if FreeCamSaved.CameraSubject ~= nil then
			cam.CameraSubject = FreeCamSaved.CameraSubject
		end
	end
	if FreeCamSaved.MouseBehavior ~= nil then
		UserInputService.MouseBehavior = FreeCamSaved.MouseBehavior
	end
	FreeCamSaved.Position = nil
end

local function FreeCamLookCFrame()
	-- Yaw around world up, then pitch around local right — never rolls upside down
	return CFrame.new(FreeCamSaved.Position)
		* CFrame.Angles(0, FreeCamSaved.Yaw, 0)
		* CFrame.Angles(FreeCamSaved.Pitch, 0, 0)
end

UpdateFreeCam = function(deltaTime)
	deltaTime = typeof(deltaTime) == "number" and deltaTime or 0.016
	if deltaTime <= 0 then
		deltaTime = 0.016
	elseif deltaTime > 0.1 then
		deltaTime = 0.1
	end

	if not Misc.FreeCam then
		StopFreeCam()
		return
	end

	local keybind = Options.FreeCamKeybind
	local active = false
	if keybind and typeof(keybind.GetState) == "function" then
		active = keybind:GetState()
	else
		active = UserInputService:IsKeyDown(Enum.KeyCode.V)
	end

	if not active then
		StopFreeCam()
		return
	end

	local cam = workspace.CurrentCamera
	if not cam then
		return
	end

	if not FreeCamSaved.Active then
		FreeCamSaved.Active = true
		FreeCamSaved.CameraType = cam.CameraType
		FreeCamSaved.CameraSubject = cam.CameraSubject
		FreeCamSaved.MouseBehavior = UserInputService.MouseBehavior
		FreeCamSaved.Position = cam.CFrame.Position

		local look = cam.CFrame.LookVector
		FreeCamSaved.Yaw = math.atan2(-look.X, -look.Z)
		FreeCamSaved.Pitch = math.asin(math.clamp(look.Y, -1, 1))

		cam.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end

	local mouseDelta = UserInputService:GetMouseDelta()
	local sens = 0.0035
	FreeCamSaved.Yaw -= mouseDelta.X * sens
	FreeCamSaved.Pitch = math.clamp(FreeCamSaved.Pitch - mouseDelta.Y * sens, math.rad(-89), math.rad(89))

	local cf = FreeCamLookCFrame()
	local flatLook = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
	if flatLook.Magnitude > 1e-3 then
		flatLook = flatLook.Unit
	else
		flatLook = Vector3.new(0, 0, -1)
	end
	local right = Vector3.new(flatLook.Z, 0, -flatLook.X)

	local move = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		move += flatLook
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		move -= flatLook
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		move -= right
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		move += right
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		move += Vector3.yAxis
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		move -= Vector3.yAxis
	end

	local speed = typeof(Misc.FreeCamSpeed) == "number" and Misc.FreeCamSpeed or 60
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		speed *= 2.2
	end

	if move.Magnitude > 0 then
		FreeCamSaved.Position += move.Unit * speed * deltaTime
	end

	cam.CFrame = FreeCamLookCFrame()
end

UpdateScriptUserESP = function()
	-- Script-user nametags removed
end

local AmmoGunModCache = {
	Recoil = {},
	Spread = {},
}
local LastAmmoGunModApply = 0

local RecoilAttributeNames = {
	"RecoilStrength",
	"Recoil",
	"RecoilX",
	"RecoilY",
	"VerticalRecoil",
	"HorizontalRecoil",
	"CameraRecoil",
	"ViewmodelRecoil",
	"Kick",
	"KickStrength",
	"RecoilMultiplier",
	"RecoilScale",
}

local SpreadAttributeNames = {
	"Spread",
	"MaxSpread",
	"MinSpread",
	"HipSpread",
	"AimSpread",
	"SpreadMultiplier",
	"SpreadScale",
	"Accuracy",
	"Bloom",
	"BloomMax",
}

local function CacheAndZeroAmmoAttributes(ammo, attrNames, cacheBucket, enabled)
	if not ammo then
		return
	end

	for _, attrName in attrNames do
		local ok, value = pcall(function()
			return ammo:GetAttribute(attrName)
		end)
		if ok and typeof(value) == "number" then
			local key = ammo.Name .. "::" .. attrName
			if enabled then
				if cacheBucket[key] == nil then
					cacheBucket[key] = value
				end
				pcall(function()
					ammo:SetAttribute(attrName, 0)
				end)
			elseif cacheBucket[key] ~= nil then
				pcall(function()
					ammo:SetAttribute(attrName, cacheBucket[key])
				end)
				cacheBucket[key] = nil
			end
		end
	end

	-- Also zero matching NumberValue / IntValue children
	for _, child in ammo:GetDescendants() do
		if child:IsA("NumberValue") or child:IsA("IntValue") then
			local lower = child.Name:lower()
			local isRecoil = lower:find("recoil", 1, true) or lower:find("kick", 1, true)
			local isSpread = lower:find("spread", 1, true)
				or lower:find("bloom", 1, true)
				or lower:find("accuracy", 1, true)
			local match = (enabled and cacheBucket == AmmoGunModCache.Recoil and isRecoil)
				or (enabled and cacheBucket == AmmoGunModCache.Spread and isSpread)
			local restore = (not enabled) and cacheBucket[ammo.Name .. "::child::" .. child:GetFullName()] ~= nil

			if match then
				local key = ammo.Name .. "::child::" .. child:GetFullName()
				if cacheBucket[key] == nil then
					cacheBucket[key] = child.Value
				end
				child.Value = 0
			elseif restore then
				local key = ammo.Name .. "::child::" .. child:GetFullName()
				child.Value = cacheBucket[key]
				cacheBucket[key] = nil
			end
		end
	end
end

ApplyAmmoGunMods = function(force)
	local now = tick()
	if not force and (now - LastAmmoGunModApply) < 0.15 then
		return
	end
	LastAmmoGunModApply = now

	local ammoFolder = ReplicatedStorage:FindFirstChild("AmmoTypes")
	if not ammoFolder then
		return
	end

	local wantRecoil = Misc and Misc.NoRecoil
	local wantSpread = Misc and Misc.NoSpread

	for _, ammo in ammoFolder:GetChildren() do
		CacheAndZeroAmmoAttributes(ammo, RecoilAttributeNames, AmmoGunModCache.Recoil, wantRecoil)
		CacheAndZeroAmmoAttributes(ammo, SpreadAttributeNames, AmmoGunModCache.Spread, wantSpread)
	end
end

InitGunMods = function()
	if GunModsInstalled then
		ApplyAmmoGunMods(true)
		return
	end

	-- Safe path only: do NOT hook FPS fire / gun modules (that broke full-auto).
	-- Recoil climb is RecoilStrength on AmmoTypes + VFX camera kick.
	local wrap = typeof(newcclosure) == "function" and newcclosure or function(fn)
		return fn
	end

	pcall(function()
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		local vfx = modules and modules:FindFirstChild("VFX")
		if not vfx then
			return
		end
		local ok, mod = pcall(require, vfx)
		if not ok or type(mod) ~= "table" then
			return
		end
		for key, value in pairs(mod) do
			if type(value) == "function" then
				local name = tostring(key):lower()
				local isCameraOnly = name:find("camerashake", 1, true)
					or name:find("screenshake", 1, true)
					or name:find("viewmodelrecoil", 1, true)
					or name:find("recoilcamera", 1, true)
					or name:find("camerarecoil", 1, true)
					or name:find("weaponkick", 1, true)
					or name:find("weaponrecoil", 1, true)
					or name == "recoil"
					or name == "shake"
					or name == "kick"
				if isCameraOnly then
					pcall(function()
						local old = value
						mod[key] = wrap(function(...)
							if Misc.NoRecoil then
								return
							end
							return old(...)
						end)
					end)
				end
			end
		end
	end)

	ApplyAmmoGunMods(true)
	GunModsInstalled = true
end
(function()
	local SavedAtmospheres = {}

	SaveAtmosphereDefaults = function()
		if next(SavedAtmospheres) then
			return
		end

		for _, child in Lighting:GetChildren() do
			if child:IsA("Atmosphere") and child.Name ~= "WallhackPurpleAtmosphere" then
				SavedAtmospheres[child] = {
					Density = child.Density,
					Offset = child.Offset,
					Color = child.Color,
					Decay = child.Decay,
					Glare = child.Glare,
					Haze = child.Haze,
				}
			end
		end
	end

	RestoreAtmosphereDefaults = function()
		for inst, props in SavedAtmospheres do
			if inst.Parent then
				for key, val in props do
					inst[key] = val
				end
			end
		end
	end

	SaveLightingDefaults = function()
		if LightingDefaults then
			return
		end

		LightingDefaults = {
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			TimeOfDay = Lighting.TimeOfDay,
			FogStart = Lighting.FogStart,
			FogEnd = Lighting.FogEnd,
			FogColor = Lighting.FogColor,
			GlobalShadows = Lighting.GlobalShadows,
			Ambient = Lighting.Ambient,
			OutdoorAmbient = Lighting.OutdoorAmbient,
		}
	end

	ClearPurpleSkyEffects = function()
		local purpleAtmosphere = Lighting:FindFirstChild("WallhackPurpleAtmosphere")
		if purpleAtmosphere then
			purpleAtmosphere:Destroy()
		end
		local purpleCC = Lighting:FindFirstChild("WallhackPurpleColorCorrection")
		if purpleCC then
			purpleCC:Destroy()
		end
	end

	ClearFullBrightEffects = function()
		local fullBrightCC = Lighting:FindFirstChild("WallhackFullBrightCC")
		if fullBrightCC then
			fullBrightCC:Destroy()
		end
	end

	RestoreLightingDefaults = function()
		if not LightingDefaults then
			return
		end

		Lighting.Brightness = LightingDefaults.Brightness
		Lighting.ClockTime = LightingDefaults.ClockTime
		Lighting.TimeOfDay = LightingDefaults.TimeOfDay
		Lighting.FogStart = LightingDefaults.FogStart
		Lighting.FogEnd = LightingDefaults.FogEnd
		Lighting.FogColor = LightingDefaults.FogColor
		Lighting.GlobalShadows = LightingDefaults.GlobalShadows
		Lighting.Ambient = LightingDefaults.Ambient
		Lighting.OutdoorAmbient = LightingDefaults.OutdoorAmbient
		ClearPurpleSkyEffects()
		ClearFullBrightEffects()
		RestoreAtmosphereDefaults()
	end

	UpdateFullBright = function()
		if not Misc.FullBright then
			return
		end

		SaveLightingDefaults()
		Lighting.ClockTime = 12
		Lighting.TimeOfDay = "12:00:00"
		Lighting.Brightness = 3
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
		Lighting.FogColor = Color3.fromRGB(255, 255, 255)
		Lighting.GlobalShadows = false
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

		ClearPurpleSkyEffects()

		for _, child in Lighting:GetChildren() do
			if child:IsA("Atmosphere") then
				child.Density = 0
				child.Haze = 0
			end
		end

		local cc = Lighting:FindFirstChild("WallhackFullBrightCC")
		if not cc then
			cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "WallhackFullBrightCC"
			cc.Parent = Lighting
		end
		cc.Brightness = 0.25
		cc.Contrast = -0.05
		cc.Saturation = -0.15
		cc.TintColor = Color3.fromRGB(255, 255, 255)
	end

	UpdatePurpleSky = function()
		if not WorldESP.PurpleSky then
			return
		end

		SyncWorldESPFromUI()
		SaveLightingDefaults()
		SaveAtmosphereDefaults()
		ClearFullBrightEffects()

		local sky = WorldESP.PurpleSkyColor
		local dark = sky:Lerp(Color3.new(0, 0, 0), 0.45)
		local bright = sky:Lerp(Color3.new(1, 1, 1), 0.2)

		Lighting.ClockTime = 0
		Lighting.TimeOfDay = "00:00:00"
		Lighting.Brightness = 0.6
		Lighting.Ambient = dark
		Lighting.OutdoorAmbient = bright
		Lighting.FogColor = sky:Lerp(Color3.new(0, 0, 0), 0.55)
		Lighting.FogStart = 0
		Lighting.FogEnd = 2500
		Lighting.GlobalShadows = true

		local atmosphere = Lighting:FindFirstChild("WallhackPurpleAtmosphere")
		if not atmosphere then
			atmosphere = Instance.new("Atmosphere")
			atmosphere.Name = "WallhackPurpleAtmosphere"
			atmosphere.Parent = Lighting
		end
		atmosphere.Color = sky
		atmosphere.Decay = dark
		atmosphere.Density = 0.38
		atmosphere.Glare = 0.55
		atmosphere.Haze = 2.2
		atmosphere.Offset = 0.3

		local cc = Lighting:FindFirstChild("WallhackPurpleColorCorrection")
		if not cc then
			cc = Instance.new("ColorCorrectionEffect")
			cc.Name = "WallhackPurpleColorCorrection"
			cc.Parent = Lighting
		end
		cc.TintColor = bright
		cc.Saturation = 0.35
		cc.Brightness = 0.02
		cc.Contrast = 0.08

		for _, child in Lighting:GetChildren() do
			if child:IsA("Atmosphere") and child.Name ~= "WallhackPurpleAtmosphere" then
				child.Density = 0
			end
		end
	end

	UpdateLighting = function()
		if not Misc.FullBright and not WorldESP.PurpleSky then
			RestoreLightingDefaults()
		end
	end

	task.defer(function()
		SaveLightingDefaults()
		SaveAtmosphereDefaults()
	end)
end)(); (function()
	local WaterPlatform = nil
	local WaterRayParams = RaycastParams.new()
WaterRayParams.FilterType = Enum.RaycastFilterType.Exclude
local LastWaterPartScan = 0
local CachedWaterParts = {}

local function IsWaterHit(hit)
	if not hit then
		return false
	end

	if hit.Material == Enum.Material.Water then
		return true
	end

	local name = hit.Instance.Name:lower()
	if name:find("water", 1, true) or name:find("ocean", 1, true) or name:find("sea", 1, true) or name:find("lake", 1, true) then
		return true
	end

	if hit.Instance:IsA("Terrain") then
		return hit.Material == Enum.Material.Water
	end

	return false
end

local function FindWaterSurfaceY(root)
	local character = LocalPlayer.Character
	WaterRayParams.FilterDescendantsInstances = { character, WaterPlatform }

	local casts = {
		root.Position + Vector3.new(0, 6, 0),
		root.Position + Vector3.new(0, 30, 0),
		root.Position + Vector3.new(0, 80, 0),
	}

	for _, origin in casts do
		local hit = workspace:Raycast(origin, Vector3.new(0, -200, 0), WaterRayParams)
		if IsWaterHit(hit) then
			return hit.Position.Y
		end
	end

	local now = tick()
	if now - LastWaterPartScan >= 1 then
		LastWaterPartScan = now
		CachedWaterParts = {}
		for _, obj in workspace:GetDescendants() do
			if obj:IsA("BasePart") then
				local isWater = obj.Material == Enum.Material.Water
					or obj.Name:lower():find("water", 1, true)
					or obj.Name:lower():find("ocean", 1, true)
				if isWater then
					table.insert(CachedWaterParts, obj)
				end
			end
		end
	end

	for _, obj in CachedWaterParts do
		if obj.Parent then
			local topY = obj.Position.Y + (obj.Size.Y / 2)
			local flatDist = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(obj.Position.X, obj.Position.Z)).Magnitude
			local reach = math.max(obj.Size.X, obj.Size.Z) / 2 + 8
			if flatDist <= reach and root.Position.Y <= topY + 12 then
				return topY
			end
		end
	end

	return nil
end

local function EnsureWaterPlatform()
	if WaterPlatform and WaterPlatform.Parent then
		return WaterPlatform
	end

	local platform = Instance.new("Part")
	platform.Name = "WallhackWaterPlatform"
	platform.Anchored = true
	platform.CanCollide = true
	platform.CanQuery = false
	platform.CanTouch = false
	platform.Transparency = 1
	platform.CastShadow = false
	platform.Size = Vector3.new(14, 0.5, 14)
	platform.Material = Enum.Material.SmoothPlastic
	platform.Parent = workspace

	WaterPlatform = platform
	return platform
end

ClearWaterPlatform = function()
	if WaterPlatform then
		WaterPlatform:Destroy()
		WaterPlatform = nil
	end
end

local function UpdateWalkOnWater()
	if not Misc.WalkOnWater then
		ClearWaterPlatform()
		return
	end

	local root = GetLocalRoot()
	if not root then
		ClearWaterPlatform()
		return
	end

	local waterY = FindWaterSurfaceY(root)
	if not waterY or root.Position.Y > waterY + 14 then
		if WaterPlatform then
			WaterPlatform.Parent = nil
		end
		return
	end

	local platform = EnsureWaterPlatform()
	platform.CFrame = CFrame.new(root.Position.X, waterY + 0.15, root.Position.Z)
	platform.Parent = workspace
end

UpdateThirdPerson = function()
	if Misc.ThirdPerson then
		if not ThirdPersonSaved.Active then
			ThirdPersonSaved.Active = true
			ThirdPersonSaved.CameraMin = LocalPlayer.CameraMinZoomDistance
			ThirdPersonSaved.CameraMax = LocalPlayer.CameraMaxZoomDistance
			ThirdPersonSaved.CameraMode = LocalPlayer.CameraMode
		end

		LocalPlayer.CameraMode = Enum.CameraMode.Classic
		LocalPlayer.CameraMinZoomDistance = 8
		LocalPlayer.CameraMaxZoomDistance = 12
	elseif ThirdPersonSaved.Active then
		ThirdPersonSaved.Active = false

		if ThirdPersonSaved.CameraMin then
			LocalPlayer.CameraMinZoomDistance = ThirdPersonSaved.CameraMin
			LocalPlayer.CameraMaxZoomDistance = ThirdPersonSaved.CameraMax
		end

		if ThirdPersonSaved.CameraMode then
			LocalPlayer.CameraMode = ThirdPersonSaved.CameraMode
		end
	end
end

UpdateSpinbot = function(deltaTime)
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and GetCharacterRoot(character)

	if Misc.Spinbot then
		if not SpinbotSaved.Active then
			SpinbotSaved.Active = true
			SpinbotSaved.AutoRotate = humanoid and humanoid.AutoRotate
		end

		if humanoid then
			humanoid.AutoRotate = false
		end

		if root then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Misc.SpinSpeed * deltaTime * 60), 0)
		end
	elseif SpinbotSaved.Active then
		SpinbotSaved.Active = false

		if humanoid and SpinbotSaved.AutoRotate ~= nil then
			humanoid.AutoRotate = SpinbotSaved.AutoRotate
		end
	end
end

UpdateMisc = function(deltaTime)
	SyncMiscFromUI()
	UpdateThirdPerson()
	UpdateSpinbot(deltaTime)
	UpdateWalkOnWater()
	UpdateFastWalk(deltaTime)
	UpdateFreeCam(deltaTime)
	if Misc.NoRecoil or Misc.NoSpread then
		ApplyAmmoGunMods(false)
	elseif next(AmmoGunModCache.Recoil) or next(AmmoGunModCache.Spread) then
		ApplyAmmoGunMods(true)
	end
	if Misc.WallPenetration and UpdateWallTransparency then
		UpdateWallTransparency()
	elseif not Misc.WallPenetration and RestoreWallTransparency then
		RestoreWallTransparency()
	end
end

end)(); (function()
local MiscBox = Tabs.Misc:AddLeftGroupbox("Misc")

MiscBox:AddToggle("Spinbot", {
	Text = "Spinbot",
	Default = false,
	Callback = function(value)
		Misc.Spinbot = value
		if not value then
			UpdateSpinbot(0)
		end
	end,
})

MiscBox:AddSlider("SpinSpeed", {
	Text = "Spin Speed",
	Default = 20,
	Min = 1,
	Max = 50,
	Rounding = 0,
	Callback = function(value)
		Misc.SpinSpeed = value
	end,
})

MiscBox:AddToggle("ThirdPerson", {
	Text = "3rd Person",
	Default = false,
	Callback = function(value)
		Misc.ThirdPerson = value
		if not value then
			UpdateThirdPerson()
		end
	end,
})

MiscBox:AddToggle("WalkOnWater", {
	Text = "Walk On Water",
	Default = false,
	Callback = function(value)
		Misc.WalkOnWater = value
		if not value then
			ClearWaterPlatform()
		end
	end,
})

MiscBox:AddToggle("WallPenetration", {
	Text = "Shoot Through Walls",
	Default = false,
	Callback = function(value)
		Misc.WallPenetration = value
		if value then
			task.defer(function()
				pcall(InitSilentAim)
				pcall(InitWallPenetration)
				pcall(function()
					local ammoFolder = ReplicatedStorage:FindFirstChild("AmmoTypes")
					if not ammoFolder then
						return
					end
					for _, ammo in ammoFolder:GetChildren() do
						for _, name in {
							"Penetration",
							"PenetrationPower",
							"PenetrationDepth",
							"ArmorPenetration",
							"WallPenetration",
							"MaxPenetration",
							"Pen",
						} do
							pcall(function()
								ammo:SetAttribute(name, 9999)
							end)
							local child = ammo:FindFirstChild(name)
							if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
								child.Value = 9999
							end
						end
					end
				end)
			end)
		elseif RestoreWallTransparency then
			RestoreWallTransparency()
		end
	end,
})

MiscBox:AddToggle("NoRecoil", {
	Text = "No Recoil",
	Default = false,
	Callback = function(value)
		Misc.NoRecoil = value
		task.defer(function()
			pcall(InitGunMods)
			pcall(ApplyAmmoGunMods, true)
		end)
	end,
})

MiscBox:AddToggle("NoSpread", {
	Text = "No Spread",
	Default = false,
	Callback = function(value)
		Misc.NoSpread = value
		task.defer(function()
			pcall(InitGunMods)
			pcall(ApplyAmmoGunMods, true)
		end)
	end,
})

MiscBox:AddToggle("FastWalk", {
	Text = "Fast Walk",
	Default = false,
	Callback = function(value)
		Misc.FastWalk = value
		UpdateFastWalk(0)
	end,
})

MiscBox:AddToggle("FreeCam", {
	Text = "Free Cam",
	Default = false,
	Callback = function(value)
		Misc.FreeCam = value
		if not value then
			UpdateFreeCam(0)
		end
	end,
}):AddKeyPicker("FreeCamKeybind", {
	Default = "V",
	Mode = "Hold",
	Text = "Free Cam",
	SyncToggleState = false,
})

MiscBox:AddSlider("FreeCamSpeed", {
	Text = "Free Cam Speed",
	Default = 60,
	Min = 10,
	Max = 200,
	Rounding = 0,
	Callback = function(value)
		if typeof(value) == "number" then
			Misc.FreeCamSpeed = value
		end
	end,
})

MiscBox:AddToggle("FullBright", {
	Text = "Full Bright",
	Default = false,
	Callback = function(value)
		Misc.FullBright = value
		if value then
			WorldESP.PurpleSky = false
			pcall(function()
				if Toggles.PurpleSky then
					Toggles.PurpleSky:SetValue(false)
				end
			end)
			SaveLightingDefaults()
		else
			UpdateLighting()
		end
	end,
})

MiscBox:AddToggle("FOVChanger", {
	Text = "FOV Changer",
	Default = false,
	Callback = function(value)
		Misc.FOVChanger = value
		FOVSaved = value
		if value and workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = Misc.CameraFOV
		elseif not value and workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = DefaultCameraFOV
			FOVSaved = false
		end
	end,
})

MiscBox:AddSlider("CameraFOV", {
	Text = "Camera FOV",
	Default = 70,
	Min = 30,
	Max = 120,
	Rounding = 0,
	Suffix = " FOV",
	Callback = function(value)
		if typeof(value) == "number" then
			Misc.CameraFOV = value
		end
	end,
})

LocalPlayer.CharacterAdded:Connect(function()
	SpinbotSaved.Active = false
	ThirdPersonSaved.Active = false
end)

----------------------------------------------------------------
-- Settings (default Obsidian menu stuff)
----------------------------------------------------------------
local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = false,
	Text = "Open Keybind Menu",
	Callback = function(value)
		if Library.KeybindFrame then
			Library.KeybindFrame.Visible = value
		end
	end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(value)
		Library.ShowCustomCursor = value
	end,
})

MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(value)
		Library:SetNotifySide(value)
	end,
})

MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Callback = function(value)
		local dpi = tonumber((value:gsub("%%", "")))
		if dpi then
			Library:SetDPIScale(dpi)
		end
	end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind",
})

MenuGroup:AddButton("Unload", function()
	for player in pairs(ESPCache) do
		ClearPlayerESP(player)
	end
	for npc in pairs(NpcCache) do
		ClearNpcESP(npc)
	end
	for crate in pairs(CrateCache) do
		ClearCrateESP(crate)
	end
	for mine in pairs(LandmineCache) do
		ClearLandmineESP(mine)
	end
	for extraction in pairs(ExtractionCache) do
		ClearExtractionESP(extraction)
	end
	Misc.Spinbot = false
	Misc.ThirdPerson = false
	Misc.WalkOnWater = false
	Misc.FullBright = false
	Misc.WallPenetration = false
	Misc.NoRecoil = false
	Misc.NoSpread = false
	Misc.FastWalk = false
	Misc.FreeCam = false
	WorldESP.PurpleSky = false
	if RestoreWallTransparency then
		RestoreWallTransparency()
	end
	UpdateFastWalk(0)
	UpdateFreeCam(0)
	RestoreMovementSounds()
	ClearWaterPlatform()
	RestoreLightingDefaults()
	UpdateSpinbot(0)
	UpdateThirdPerson()
	HidePlayerESP(LocalPlayer)
	if Camera then
		Camera.FieldOfView = DefaultCameraFOV
	end
	RunService:UnbindFromRenderStep("WallhackFOVChanger")
	RunService:UnbindFromRenderStep("WallhackLighting")
	RunService:UnbindFromRenderStep("WallhackAimbot")
	if FOVGui then
		FOVGui:Destroy()
	end
	if ESPGui then
		ESPGui:Destroy()
	end
	ClearAllBulletTracers()
	ClearGunCham()
	if TracerFolder then
		TracerFolder:Destroy()
	end
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Wallhack.gg")
SaveManager:SetFolder("Wallhack.gg/ProjectDelta")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

----------------------------------------------------------------
-- Credits
----------------------------------------------------------------
local function CopyDiscordInvite()
	local link = "https://discord.gg/XnQ6XmQgFb"
	local copied = false
	if typeof(setclipboard) == "function" then
		copied = pcall(setclipboard, link)
	elseif typeof(toclipboard) == "function" then
		copied = pcall(toclipboard, link)
	elseif typeof(Clipboard) == "table" and typeof(Clipboard.set) == "function" then
		copied = pcall(Clipboard.set, link)
	end
	return copied, link
end

local CreditsMade = Tabs.Credits:AddLeftGroupbox("Made by")
CreditsMade:AddLabel("Made by Vp4q")
CreditsMade:AddLabel("If you paid for this script, you got scammed.")
CreditsMade:AddLabel("This is a long project — it took 6 days of full work.")

local CreditsThanks = Tabs.Credits:AddLeftGroupbox("Special thanks")
CreditsThanks:AddLabel("Thanks to 224 aka (224lolv2)")
CreditsThanks:AddLabel("for the ideas, helping decide what to add,")
CreditsThanks:AddLabel("and testing the script out for me.")

local CreditsJoin = Tabs.Credits:AddRightGroupbox("Join us")
CreditsJoin:AddLabel("Discord server")
CreditsJoin:AddButton("Copy our Discord invite link", function()
	local ok, link = CopyDiscordInvite()
	if not ok then
		warn("[Wallhack.gg] Could not copy invite. Link:", link or "https://discord.gg/XnQ6XmQgFb")
	end
end)
CreditsJoin:AddLabel("https://discord.gg/XnQ6XmQgFb")

----------------------------------------------------------------
-- Loop
----------------------------------------------------------------
local LastFrameTime = tick()

RunService.RenderStepped:Connect(function()
	local now = tick()
	local deltaTime = now - LastFrameTime
	LastFrameTime = now

	Camera = workspace.CurrentCamera
	if not Camera then
		return
	end

	UpdateFOV()
	EnsureESPGuiAttached()

	local function runStep(label, fn, ...)
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("[Wallhack.gg]", label, err)
		end
	end

	runStep("ESP", UpdateESP)
	runStep("NpcESP", UpdateNpcESP)
	runStep("BulletTracer", UpdateBulletTracers)
	runStep("GunCham", UpdateGunCham)
	runStep("CrateESP", UpdateCrateESP)
	runStep("LandmineESP", UpdateLandmineESP)
	runStep("ExtractionESP", UpdateExtractionESP)
	runStep("Misc", UpdateMisc, deltaTime)
	runStep("TriggerBot", UpdateTriggerBot)
end)

end)();

InitWallPenetration = function()
	if UpdateWallTransparency then
		return
	end

	local detectingWalls = false
	local transparentCache = {}
	local wallRayParams = RaycastParams.new()
	wallRayParams.FilterType = Enum.RaycastFilterType.Exclude

	local function shouldStop(part)
		if not part then
			return false
		end
		local character = LocalPlayer.Character
		if character and part:IsDescendantOf(character) then
			return false
		end
		local camera = workspace.CurrentCamera
		if camera and part:IsDescendantOf(camera) then
			return false
		end
		local model = part:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			return true
		end
		return false
	end

	local function isWallPart(part)
		if not part or not part:IsA("BasePart") then
			return false
		end
		if part.Transparency >= 1 or part:IsA("Terrain") then
			return false
		end
		local character = LocalPlayer.Character
		if character and part:IsDescendantOf(character) then
			return false
		end
		local camera = workspace.CurrentCamera
		if camera and part:IsDescendantOf(camera) then
			return false
		end
		local model = part:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			return false
		end
		return true
	end

	local function restorePart(part)
		local saved = transparentCache[part]
		if not saved then
			return
		end
		if part.Parent then
			part.Transparency = saved.Transparency
			part.LocalTransparencyModifier = saved.LocalTransparencyModifier
		end
		transparentCache[part] = nil
	end

	RestoreWallTransparency = function()
		for part in pairs(transparentCache) do
			restorePart(part)
		end
	end

	local function setPartTransparent(part, amount)
		if not transparentCache[part] then
			transparentCache[part] = {
				Transparency = part.Transparency,
				LocalTransparencyModifier = part.LocalTransparencyModifier,
			}
		end
		-- Visual only — do NOT touch CanQuery (that caused hitmarkers with 0 damage)
		part.LocalTransparencyModifier = math.clamp(amount, 0, 0.95)
	end

	UpdateWallTransparency = function()
		if not Misc.WallPenetration then
			RestoreWallTransparency()
			return
		end

		local camera = workspace.CurrentCamera
		local character = LocalPlayer.Character
		if not camera or not character then
			RestoreWallTransparency()
			return
		end

		wallRayParams.FilterDescendantsInstances = { character, camera }
		local origin = camera.CFrame.Position
		local directionUnit = camera.CFrame.LookVector
		local maxDistance = 1000
		local currentOrigin = origin
		local traveled = 0
		local activeParts = {}

		detectingWalls = true
		for _ = 1, 40 do
			local remaining = maxDistance - traveled
			if remaining <= 0 then
				break
			end
			local result = workspace:Raycast(currentOrigin, directionUnit * remaining, wallRayParams)
			if not result then
				break
			end
			if shouldStop(result.Instance) then
				break
			end
			if isWallPart(result.Instance) then
				activeParts[result.Instance] = true
				setPartTransparent(result.Instance, 0.85)
			end
			local step = (result.Position - currentOrigin).Magnitude + 0.05
			traveled += step
			currentOrigin = result.Position + directionUnit * 0.05
		end
		detectingWalls = false

		for part in pairs(transparentCache) do
			if not activeParts[part] or not part.Parent then
				restorePart(part)
			end
		end
	end
end

pcall(function()
	task.defer(function()
		SaveManager:LoadAutoloadConfig()
	end)
end)

-- Fix bad saved slider values that crash Obsidian TweenInfo.new
pcall(function()
	for name, option in pairs(Options) do
		if option and option.Type == "Slider" and typeof(option.Value) ~= "number" then
			local fallback = typeof(option.Default) == "number" and option.Default or 0
			pcall(function()
				option:SetValue(fallback)
			end)
		end
	end
	if Options.CameraFOV and typeof(Options.CameraFOV.Value) ~= "number" then
		Options.CameraFOV:SetValue(70)
	end
end)

local function SafeSync()
	pcall(SyncAimbotFromUI)
	pcall(SyncSilentAimFromUI)
	pcall(SyncESPFromUI)
	pcall(SyncNpcESPFromUI)
	pcall(SyncWorldESPFromUI)
	pcall(SyncMiscFromUI)
	pcall(SyncTriggerBotFromUI)
end

SafeSync()
task.defer(function()
	pcall(InitSilentAim)
	pcall(function()
		if Library and Library.Toggle then
			Library:Toggle(true)
		end
	end)
end)

LocalPlayer.CharacterAdded:Connect(function()
	task.defer(function()
		Camera = workspace.CurrentCamera
		LastExtractionScan = 0
		LastCrateScan = 0
		LastLandmineScan = 0
		LastNpcScan = 0
		ESPGuiAttachFailed = false
		EnsureESPGuiAttached()
		SyncAimbotFromUI()
		SyncSilentAimFromUI()
		SyncESPFromUI()
		SyncNpcESPFromUI()
		SyncWorldESPFromUI()
		SyncMiscFromUI()
		SyncTriggerBotFromUI()
	end)
end)

pcall(function()
	RunService:UnbindFromRenderStep("WallhackFOVChanger")
end)

pcall(function()
	RunService:BindToRenderStep("WallhackFOVChanger", 2147483646, function()
		if Misc.FOVChanger and workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = Misc.CameraFOV
		end
	end)
end)

pcall(function()
	RunService:UnbindFromRenderStep("WallhackLighting")
end)

pcall(function()
	RunService:BindToRenderStep("WallhackLighting", 2147483647, function()
		SyncMiscFromUI()

		if Misc.FullBright then
			UpdateFullBright()
		elseif WorldESP.PurpleSky then
			UpdatePurpleSky()
		elseif Lighting:FindFirstChild("WallhackPurpleAtmosphere") or Lighting:FindFirstChild("WallhackPurpleColorCorrection") then
			ClearPurpleSkyEffects()
			RestoreLightingDefaults()
		end
	end)
end)

end)()
