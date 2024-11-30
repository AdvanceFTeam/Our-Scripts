-- Wait you deobfuscated my script omg damn you pro welp now share the source code to the exploiting community :)
-- because you work hard to deobfuscated.
--[[


 █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗███████╗ █████╗ ██╗     ██╗     ██╗███╗   ██╗ ██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔════╝██╔════╝██╔════╝██╔══██╗██║     ██║     ██║████╗  ██║██╔════╝     ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
███████║██║  ██║██║   ██║███████║██╔██╗ ██║██║     █████╗  █████╗  ███████║██║     ██║     ██║██╔██╗ ██║██║  ███╗       ██║   █████╗  ███████║██╔████╔██║
██╔══██║██║  ██║╚██╗ ██╔╝██╔══██║██║╚██╗██║██║     ██╔══╝  ██╔══╝  ██╔══██║██║     ██║     ██║██║╚██╗██║██║   ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
██║  ██║██████╔╝ ╚████╔╝ ██║  ██║██║ ╚████║╚██████╗███████╗██║     ██║  ██║███████╗███████╗██║██║ ╚████║╚██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
                                                                                                                                                        
]] --
-- AdvanceFalling Team





local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()
local win = lib:Window("AdvanceTech | REALISTIC HOOD Testing | v1.1 ", Color3.fromRGB(44, 120, 224), Enum.KeyCode.P)

local tab = win:Tab("Main")

-- -------------------------------------
-- Hitbox Settings
-- -------------------------------------
tab:Label("> Hitbox")

local hitboxEnabled = false
local noCollisionEnabled = false
local originalProperties = {}
local hitboxSize = 21
local hitboxTransparency = 6  -- Default to 0.6 (6/10)
local teamCheck = "FFA"  -- Default to Free For All

local defaultBodyParts = {
    "UpperTorso",
    "Head",
    "HumanoidRootPart"
}


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
local WarningText = Instance.new("TextLabel", ScreenGui)

WarningText.Size = UDim2.new(0, 200, 0, 50)
WarningText.TextSize = 16
WarningText.Position = UDim2.new(0.5, -150, 0, 0)
WarningText.Text = "Warning: There may be a bug that causes collisions."
WarningText.TextColor3 = Color3.new(1, 0, 0)
WarningText.BackgroundTransparency = 1
WarningText.Visible = false


-- -------------------------------------
-- Utility Functions
-- -------------------------------------
local function saveOriginalProperties(player, part)
    if not originalProperties[player] then
        originalProperties[player] = {}
    end
    if not originalProperties[player][part.Name] then
        originalProperties[player][part.Name] = {
            CanCollide = part.CanCollide,
            Transparency = part.Transparency,
            Size = part.Size
        }
    end
end

local function restoreOriginalProperties(player)
    if originalProperties[player] then
        for partName, properties in pairs(originalProperties[player]) do
            local part = player.Character and player.Character:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.CanCollide = properties.CanCollide
                part.Transparency = properties.Transparency
                part.Size = properties.Size
            end
        end
    end
end

local function findClosestPart(player, partName)
    if not player.Character then return nil end
    local characterParts = player.Character:GetChildren()
    for _, part in ipairs(characterParts) do
        if part:IsA("BasePart") and part.Name:lower():match(partName:lower()) then
            return part
        end
    end
    return nil
end

-- -------------------------------------
-- Hitbox Functions
-- -------------------------------------
local function extendHitbox(player)
    for _, partName in ipairs(defaultBodyParts) do
        local part = player.Character and (player.Character:FindFirstChild(partName) or findClosestPart(player, partName))
        if part and part:IsA("BasePart") then
            saveOriginalProperties(player, part)
            part.CanCollide = not noCollisionEnabled
            part.Transparency = hitboxTransparency / 10
            part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        end
    end
end

local function isEnemy(player)
    if teamCheck == "FFA" or teamCheck == "Everyone" then
        return true
    end
    local localPlayerTeam = game.Players.LocalPlayer.Team
    return player.Team ~= localPlayerTeam
end

local function shouldExtendHitbox(player)
    if teamCheck == "Everyone" then
        return true
    elseif teamCheck == "Team-Based" then
        return isEnemy(player)
    else
        return isEnemy(player)
    end
end

local function updateHitboxes()
    local players = game:GetService("Players")
    local plr = players.LocalPlayer

    for _, v in ipairs(players:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if shouldExtendHitbox(v) then
                extendHitbox(v)
            else
                restoreOriginalProperties(v)
            end
        end
    end
end

-- -------------------------------------
-- Event Handlers
-- -------------------------------------
local function onCharacterAdded(character)
    wait(0.1)
    if hitboxEnabled then
        updateHitboxes()
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function onPlayerRemoving(player)
    restoreOriginalProperties(player)
    originalProperties[player] = nil
end

local function checkForDeadPlayers()
    for player, properties in pairs(originalProperties) do
        if not player.Parent or not player.Character or not player.Character:IsDescendantOf(game) then
            restoreOriginalProperties(player)
            originalProperties[player] = nil
        end
    end
end


tab:Button("[CLICK THIS FIRST] Enable Hitbox", function()
    local players = game:GetService("Players")
    --local plr = players.LocalPlayer

    players.PlayerAdded:Connect(onPlayerAdded)
    players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in ipairs(players:GetPlayers()) do
        onPlayerAdded(player)
    end

    coroutine.wrap(function()
        while true do
            if hitboxEnabled then
                updateHitboxes()
                checkForDeadPlayers()
            end
            wait(0.1)
        end
    end)()
end)

tab:Toggle("Enable Hitbox", false, function(enabled)
    hitboxEnabled = enabled
    if not enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            restoreOriginalProperties(player)
        end
        originalProperties = {}
    else
        updateHitboxes()
    end
end)

tab:Slider("Hitbox Size", 1, 50, 21, function(value)
    hitboxSize = value
    if hitboxEnabled then
        updateHitboxes()
    end
end)

tab:Slider("Hitbox Transparency", 1, 10, 6, function(value)
    hitboxTransparency = value
    if hitboxEnabled then
        updateHitboxes()
    end
end)

tab:Dropdown("Team Check", {"FFA", "Team-Based", "Everyone"}, function(value)
    teamCheck = value
    if hitboxEnabled then
        updateHitboxes()
    end
end)

tab:Toggle("No Collision", false, function(enabled)
    noCollisionEnabled = enabled
    WarningText.Visible = enabled
    coroutine.wrap(function()
        while noCollisionEnabled do
            if hitboxEnabled then
                updateHitboxes()
            end
            wait(0.01)
        end
        if hitboxEnabled then
            updateHitboxes()
        end
    end)()
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterRemoving:Connect(function()
        restoreOriginalProperties(player)
        originalProperties[player] = nil
    end)
end)



local player = game:GetService("Players").LocalPlayer
-- Player Tab
local tab3 = win:Tab("Player")

local settings = {WalkSpeed = 16}
local isWalkSpeedEnabled = false
local warningThreshold = 100

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local warn = Instance.new("TextLabel", screenGui)
warn.Size = UDim2.new(0, 455, 0, 50)
warn.Position = UDim2.new(0.5, -200, 0, 10)
warn.Text = ""
warn.TextColor3 = Color3.new(1, 0, 0)
warn.BackgroundTransparency = 1
warn.Visible = false
warn.TextScaled = true
warn.Font = Enum.Font.SourceSansBold

tab3:Toggle("Enable Custom WalkSpeed", false, function(enabled) 
    isWalkSpeedEnabled = enabled 
end)

local walkMethods = {"Velocity", "Vector", "CFrame"}
local selectedWalkMethod = walkMethods[1]

tab3:Dropdown("Walk Method", walkMethods, function(selected) 
    selectedWalkMethod = selected 
end)

local function displayWarning(walkSpeed)
    if walkSpeed > warningThreshold then
        warn.Text = "Warning: Guns can BREAK if you put a really high WalkSpeed"
        warn.Visible = true
    else
        warn.Visible = false
    end
end

tab3:Slider("Walkspeed Power", 16, 500, 16, function(value)
    settings.WalkSpeed = value
    displayWarning(settings.WalkSpeed)
end)

local function adjustWalkSpeed(player, deltaTime)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        local VectorSpeed = humanoid.MoveDirection * settings.WalkSpeed
        if selectedWalkMethod == "Velocity" then
            rootPart.Velocity = Vector3.new(VectorSpeed.X, rootPart.Velocity.Y,
                                            VectorSpeed.Z)
        elseif selectedWalkMethod == "Vector" then
            local scaleFactor = 0.001
            rootPart.CFrame = rootPart.CFrame +
                                  (VectorSpeed * deltaTime * scaleFactor)
        elseif selectedWalkMethod == "CFrame" then
            local scaleFactor = 0.001
            rootPart.CFrame = rootPart.CFrame +
                                  (humanoid.MoveDirection * settings.WalkSpeed *
                                      deltaTime * scaleFactor)
        else
            humanoid.WalkSpeed = settings.WalkSpeed
        end
    end
end

game:GetService("RunService").Stepped:Connect(function(deltaTime)
    if isWalkSpeedEnabled then
        local player = game:GetService("Players").LocalPlayer
        if player and player.Character and
            player.Character:FindFirstChild("HumanoidRootPart") then
            adjustWalkSpeed(player, deltaTime)
        end
    end
end)

local IJ = false
tab3:Toggle("Infinite Jump", false, function(state)
    IJ = state
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if IJ then
            game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
        end
    end)
end)

local isJumpPowerEnabled = false

tab3:Toggle("Enable Custom JumpPower", false, function(enabled) 
    isJumpPowerEnabled = enabled 
end)

local jumpMethods = {"Velocity", "Vector", "CFrame"}
local selectedJumpMethod = jumpMethods[1] -- Default method

tab3:Dropdown("Jump Method", jumpMethods,function(selected) 
    selectedJumpMethod = selected 
end)

tab3:Slider("Change JumpPower", 50, 500, 100, function(value)
    local player = game:GetService("Players").LocalPlayer
    local humanoid = player.Character:WaitForChild("Humanoid")
    humanoid.UseJumpPower = true
    humanoid.Jumping:Connect(function(isActive)
        if isJumpPowerEnabled and isActive then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                if selectedJumpMethod == "Velocity" then
                    rootPart.Velocity =
                        rootPart.Velocity * Vector3.new(1, 0, 1) +
                            Vector3.new(0, value, 0)
                elseif selectedJumpMethod == "Vector" then
                    rootPart.Velocity = Vector3.new(0, value, 0)
                elseif selectedJumpMethod == "CFrame" then
                    player.Character:SetPrimaryPartCFrame(
                        player.Character:GetPrimaryPartCFrame() +
                            Vector3.new(0, value, 0))
                end
            end
        end
    end)
end)

local Visual = win:Tab("Visuals")
Visual:Label("> ESP")
--no made by Us
local aj = loadstring(game:HttpGet("https://rawscript.vercel.app/api/raw/esp_1"))()

Visual:Toggle("Enable Esp", false, function(K)
    aj:Toggle(K)
    aj.Players = K
end)

Visual:Toggle("[Enabled This For REALISTIC HOOD] Teammates", false, function(L) 
    aj.TeamMates = L 
end)

Visual:Toggle("Tracers Esp", false, function(K) 
    aj.Tracers = K 
end)

Visual:Toggle("Name Esp", false, function(K) 
    aj.Names = K 
end)

Visual:Toggle("Boxes Esp", false, function(K) 
    aj.Boxes = K 
end)

Visual:Toggle("TeamColor", false, function(L) 
    aj.TeamColor = L 
end)

Visual:Colorpicker("ESP Color", Color3.fromRGB(0, 0, 255), function(P) 
    aj.Color = P 
end)

local changeclr = win:Tab("Mics")

changeclr:Toggle("Full Bright", false, function(enabled)
if not _G.FullBrightExecuted then

	_G.FullBrightEnabled = enabled

	_G.NormalLightingSettings = {
		Brightness = game:GetService("Lighting").Brightness,
		ClockTime = game:GetService("Lighting").ClockTime,
		FogEnd = game:GetService("Lighting").FogEnd,
		GlobalShadows = game:GetService("Lighting").GlobalShadows,
		Ambient = game:GetService("Lighting").Ambient
	}

	game:GetService("Lighting"):GetPropertyChangedSignal("Brightness"):Connect(function()
		if game:GetService("Lighting").Brightness ~= 1 and game:GetService("Lighting").Brightness ~= _G.NormalLightingSettings.Brightness then
			_G.NormalLightingSettings.Brightness = game:GetService("Lighting").Brightness
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").Brightness = 1
		end
	end)

	game:GetService("Lighting"):GetPropertyChangedSignal("ClockTime"):Connect(function()
		if game:GetService("Lighting").ClockTime ~= 12 and game:GetService("Lighting").ClockTime ~= _G.NormalLightingSettings.ClockTime then
			_G.NormalLightingSettings.ClockTime = game:GetService("Lighting").ClockTime
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").ClockTime = 12
		end
	end)

	game:GetService("Lighting"):GetPropertyChangedSignal("FogEnd"):Connect(function()
		if game:GetService("Lighting").FogEnd ~= 786543 and game:GetService("Lighting").FogEnd ~= _G.NormalLightingSettings.FogEnd then
			_G.NormalLightingSettings.FogEnd = game:GetService("Lighting").FogEnd
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").FogEnd = 786543
		end
	end)

	game:GetService("Lighting"):GetPropertyChangedSignal("GlobalShadows"):Connect(function()
		if game:GetService("Lighting").GlobalShadows ~= false and game:GetService("Lighting").GlobalShadows ~= _G.NormalLightingSettings.GlobalShadows then
			_G.NormalLightingSettings.GlobalShadows = game:GetService("Lighting").GlobalShadows
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").GlobalShadows = false
		end
	end)

	game:GetService("Lighting"):GetPropertyChangedSignal("Ambient"):Connect(function()
		if game:GetService("Lighting").Ambient ~= Color3.fromRGB(178, 178, 178) and game:GetService("Lighting").Ambient ~= _G.NormalLightingSettings.Ambient then
			_G.NormalLightingSettings.Ambient = game:GetService("Lighting").Ambient
			if not _G.FullBrightEnabled then
				repeat
					wait()
				until _G.FullBrightEnabled
			end
			game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)
		end
	end)

	game:GetService("Lighting").Brightness = 1
	game:GetService("Lighting").ClockTime = 12
	game:GetService("Lighting").FogEnd = 786543
	game:GetService("Lighting").GlobalShadows = false
	game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)

	local LatestValue = true
	spawn(function()
		repeat
			wait()
		until _G.FullBrightEnabled
		while wait() do
			if _G.FullBrightEnabled ~= LatestValue then
				if not _G.FullBrightEnabled then
					game:GetService("Lighting").Brightness = _G.NormalLightingSettings.Brightness
					game:GetService("Lighting").ClockTime = _G.NormalLightingSettings.ClockTime
					game:GetService("Lighting").FogEnd = _G.NormalLightingSettings.FogEnd
					game:GetService("Lighting").GlobalShadows = _G.NormalLightingSettings.GlobalShadows
					game:GetService("Lighting").Ambient = _G.NormalLightingSettings.Ambient
				else
					game:GetService("Lighting").Brightness = 1
					game:GetService("Lighting").ClockTime = 12
					game:GetService("Lighting").FogEnd = 786543
					game:GetService("Lighting").GlobalShadows = false
					game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)
				end
				LatestValue = not LatestValue
			end
		end
	end)
end

_G.FullBrightExecuted = true
_G.FullBrightEnabled = not _G.FullBrightEnabled
end)

changeclr:Colorpicker("Change UI Color", Color3.fromRGB(44, 120, 224), function(t)
    lib:ChangePresetColor(Color3.fromRGB(t.R * 255, t.G * 255, t.B * 255))
end)

local Credit = win:Tab("Credits")
Credit:Label("Credits")
Credit:Label("Script Developed by: AdvanceFalling Team")
Credit:Dropdown("Developers", {"YellowGreg", "WspBoy12", "MMSVon", "ShadowClark", "Frostbite"}, function(currentDeveloper)
    local creations = {
        YellowGreg = "Owner",
        WspBoy12 = "Head Developer",
        MMSVon = "Head Developer",
        ShadowClark = "Developer",
        Frostbite = "Head Developer"
    }
    print(currentDeveloper .. " created " .. creations[currentDeveloper])
end)
Credit:Label("UI Framework: Vape.")
Credit:Label("Report Non-Functional Bugs Scripts on Discord")
Credit:Button("Copy Discord Link",function() 
    setclipboard("https://discord.gg/FuZCM5X8TW") 
end)
