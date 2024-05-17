--// Welcome To RAim
--// Made by AdvanceFalling Team

local RAim_Settings = {
    Enabled = true,
    Smooth = 1.0, -- max is 5.0

    -- Note: Disable 'Enabled' in RAim_Settings to use FULL_AIMLOCK; otherwise, it may cause crashes
    FULL_AIMLOCK = false, -- Locks onto every enemy through walls with max FOV.

    Device = 'PC', -- 'Mobile' or 'PC' 
    Keybind = Enum.KeyCode.Q,

    Aim_Part = "Head", -- HumanoidRootPart, Body, Head, etc.
    Randomize_Aim_Part = false, -- Aims at the closest part of a character near the crosshair for legit aim
    Character = 'Both', -- R6, R15, or Both

    WallCheck = true,
    TeamCheck = true,

    Enabled_Distance = false,
    Show_Distance_Area = true, -- Show the area as a circle indicating the aimbot range
    Distance_Area_Position = 'Bottom', -- 'Bottom', 'Center', 'Top'
    Distance = 100, -- max 1000

    Select_Player = false, -- Select a players to aimlock to (disable teamcheck to include your team)
    Player = {'Player1', 'Player2'},

    Custom_Crosshair = {
        CH_Enabled = false,
        CH_Shape = 'Default', -- Dot, Default(A Cross) 
        CH_Size = 15, -- max size 50
        CH_Transparent = 0.3,
        CH_Rainbow = false,
        CH_Color = Color3.fromRGB(255, 255, 255)
    },
    
    FOV_SETTINGS = {
        FOV_Enabled = true,
        FOV_Shape = 'Circle', -- Box, Triangle, etc.
        FOV_Transparent = 0.5,
        FOV_Size = 120, -- 120 is basic, max is 500
        FOV_Rainbow = false,
        FOV_Color = Color3.fromRGB(255, 255, 255),
        FOV_Side = "Top", -- "Top", "Bottom", "Left", "Right"
        FOV_Filled = false,
        FOV_NumSides = 50, -- Number of sides for the FOV shape (used for Circle)
    },
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = game:GetService("Workspace").CurrentCamera

-- Custom Crosshair
local function createCustomCrosshair()
    if not RAim_Settings.Custom_Crosshair.CH_Enabled then return end
    
    local crosshair = Drawing.new("Line")
    crosshair.Thickness = 2
    crosshair.Transparency = RAim_Settings.Custom_Crosshair.CH_Transparent
    crosshair.Color = RAim_Settings.Custom_Crosshair.CH_Color
    crosshair.From = Vector2.new(Camera.ViewportSize.X / 2 - RAim_Settings.Custom_Crosshair.CH_Size, Camera.ViewportSize.Y / 2)
    crosshair.To = Vector2.new(Camera.ViewportSize.X / 2 + RAim_Settings.Custom_Crosshair.CH_Size, Camera.ViewportSize.Y / 2)
    crosshair.Visible = true

    local crosshair2 = Drawing.new("Line")
    crosshair2.Thickness = 2
    crosshair2.Transparency = RAim_Settings.Custom_Crosshair.CH_Transparent
    crosshair2.Color = RAim_Settings.Custom_Crosshair.CH_Color
    crosshair2.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 - RAim_Settings.Custom_Crosshair.CH_Size)
    crosshair2.To = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + RAim_Settings.Custom_Crosshair.CH_Size)
    crosshair2.Visible = true
end

-- FOV Circle
local fovCircle
local function createFovCircle()
    if not RAim_Settings.FOV_SETTINGS.FOV_Enabled then return end

    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.Transparency = RAim_Settings.FOV_SETTINGS.FOV_Transparent
    fovCircle.Color = RAim_Settings.FOV_SETTINGS.FOV_Color
    fovCircle.Radius = RAim_Settings.FOV_SETTINGS.FOV_Size
    fovCircle.NumSides = RAim_Settings.FOV_SETTINGS.FOV_NumSides
    fovCircle.Filled = RAim_Settings.FOV_SETTINGS.FOV_Filled
    fovCircle.Visible = true
end

local function updateFovCircle()
    if fovCircle then
        local mousePos = UserInputService:GetMouseLocation()
        local position = Vector2.new(mousePos.X, mousePos.Y)
        if RAim_Settings.FOV_SETTINGS.FOV_Side == "Top" then
            position = Vector2.new(mousePos.X, mousePos.Y - fovCircle.Radius)
        elseif RAim_Settings.FOV_SETTINGS.FOV_Side == "Bottom" then
            position = Vector2.new(mousePos.X, mousePos.Y + fovCircle.Radius)
        elseif RAim_Settings.FOV_SETTINGS.FOV_Side == "Left" then
            position = Vector2.new(mousePos.X - fovCircle.Radius, mousePos.Y)
        elseif RAim_Settings.FOV_SETTINGS.FOV_Side == "Right" then
            position = Vector2.new(mousePos.X + fovCircle.Radius, mousePos.Y)
        end
        fovCircle.Position = position
    end
end

local function getDistanceFromCursor(partPosition)
    local screenPoint = Camera:WorldToViewportPoint(partPosition)
    local mousePos = UserInputService:GetMouseLocation()
    return (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).magnitude
end

local function isPartVisible(part)
    local origin = Camera.CFrame.p
    local direction = (part.Position - origin).unit * (part.Position - origin).magnitude
    local ray = Ray.new(origin, direction)
    local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {Players.LocalPlayer.Character})
    return hitPart and hitPart:IsDescendantOf(part.Parent)
end

local function isTeammate(player)
    local localPlayer = Players.LocalPlayer
    if localPlayer.Team then
        return player.Team == localPlayer.Team
    else
        return player.TeamColor == localPlayer.TeamColor
    end
end

local function aimAt(targetPart)
    local camera = workspace.CurrentCamera
    local smoothness = RAim_Settings.Smooth
    local targetPos = targetPart.Position
    local cameraPos = camera.CFrame.p
    local direction = (targetPos - cameraPos).unit

    local newCFrame = CFrame.new(cameraPos, cameraPos + direction)
    camera.CFrame = camera.CFrame:Lerp(newCFrame, smoothness * RunService.RenderStepped:Wait())
end

local function getClosestPart(character)
    local closestPart = nil
    local shortestDistance = math.huge

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local distance = getDistanceFromCursor(part.Position)
            if distance < shortestDistance then
                closestPart = part
                shortestDistance = distance
            end
        end
    end

    return closestPart
end

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and (not RAim_Settings.TeamCheck or not isTeammate(player)) then
            local character = player.Character
            if character then
                local part
                if RAim_Settings.Randomize_Aim_Part then
                    part = getClosestPart(character)
                else
                    part = character:FindFirstChild(RAim_Settings.Aim_Part)
                end
                if part and (not RAim_Settings.WallCheck or isPartVisible(part)) then
                    local distance = getDistanceFromCursor(part.Position)
                    if distance < shortestDistance and distance <= RAim_Settings.FOV_SETTINGS.FOV_Size then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end

    return closestPlayer
end

local function handleAimbot()
    if not RAim_Settings.Enabled then return end
    local targetPlayer = getClosestPlayer()
    if targetPlayer then
        local targetPart
        if RAim_Settings.Randomize_Aim_Part then
            targetPart = getClosestPart(targetPlayer.Character)
        else
            targetPart = targetPlayer.Character and targetPlayer.Character:FindFirstChild(RAim_Settings.Aim_Part)
        end
        if targetPart then
            aimAt(targetPart)
        end
    end
end

local function detectDevice()
    if UserInputService.TouchEnabled then
        RAim_Settings.Device = 'Mobile'
    else
        RAim_Settings.Device = 'PC'
    end
end

local function createDistanceCircle()
    if not RAim_Settings.Enabled_Distance then return end

    local distanceCircle = Drawing.new("Circle")
    distanceCircle.Thickness = 2
    distanceCircle.Transparency = 1
    distanceCircle.Color = Color3.new(1, 1, 1)
    distanceCircle.Radius = RAim_Settings.Distance
    distanceCircle.NumSides = 50
    distanceCircle.Filled = false
    distanceCircle.Visible = true

    return distanceCircle
end

local distanceCircle = createDistanceCircle()

local function updateDistanceCircle()
    if distanceCircle then
        local mousePos = UserInputService:GetMouseLocation()
        distanceCircle.Position = mousePos
    end
end

detectDevice()
createCustomCrosshair()
createFovCircle()

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == RAim_Settings.Keybind then
        RAim_Settings.Enabled = not RAim_Settings.Enabled
    end
end)

RunService.RenderStepped:Connect(function()
    if RAim_Settings.FOV_SETTINGS.FOV_Enabled then
        updateFovCircle()
    end
    if RAim_Settings.Enabled_Distance then
        updateDistanceCircle()
    end
    handleAimbot()
end)
