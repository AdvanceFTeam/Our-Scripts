--// Welcome To RTriggerbot

--// Made by AdvanceFalling Team
--// Special thanks to Frostbite for developing the 'distance' code.

--[[ 
    -- Triggerbot Developers -- 

    Owner: YellowGreg
    Developer: Wspboy12
    Developer: MMSVon
    Developer: Frostbite
]]--

local RTriggerbot_Settings = {
    Enabled_RTriggerbot = false,
    Enabled = {
        Toggle_Keybind = false,
        Hold = false,
        Distance = false,
    },
    Keybind = {
        Toggle_Key = Enum.KeyCode.Q,
        Hold_Key = Enum.KeyCode.LeftShift,
    },
    Character_Part = false,
    Part = {
        'Head',
        -- 'Torso',
        -- 'LeftArm',
        -- 'RightArm',
        -- 'LeftLeg',
        -- 'RightLeg',
        -- 'HumanoidRootPart',
    },
    Distance = {
        Show_Area = true,
        Area_Streamable = true,
        Area_Position = 'Bottom',
        Thickness = 1,
        Range = 100,
        Area_Rainbow = false,
        Area_Color = Color3.fromRGB(255, 255, 255),
    },
    Delay = 0.1,
    TeamCheck = true,
}


-- function to check if a player is on the same team
local function isTeammate(player)
    return player.Team == game.Players.LocalPlayer.Team
end

-- function to check if a player is within the triggerbot's range
local function isCloseEnough(player)
    local character = player.Character
    local myCharacter = game.Players.LocalPlayer.Character
    if character and myCharacter then
        local playerPosition = character.PrimaryPart.Position
        local myPosition = myCharacter.PrimaryPart.Position
        local distance = (playerPosition - myPosition).magnitude
        return distance <= RTriggerbot_Settings.Distance.Range
    end
    return false
end

-- function to check if a part is one of the specific character part
local function isCharacterPart(partName)
    if RTriggerbot_Settings.Character_Part then
        return true
    end
    for _, part in ipairs(RTriggerbot_Settings.Part) do
        if partName == part then
            return true
        end
    end
    return false
end

-- function to execute the triggerbot action
local function triggerbot()
    if RTriggerbot_Settings.Enabled_RTriggerbot then
        local target = nil
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character then
                local character = player.Character
                for _, part in ipairs(character:GetDescendants()) do
                    if isCharacterPart(part.Name) and not isTeammate(player) and isCloseEnough(player) then
                        target = part
                        break
                    end
                end
                if target then
                    break
                end
            end
        end
        if target then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame
            wait(RTriggerbot_Settings.Delay)
            local success = false
            if game:GetService("ReplicatedStorage"):FindFirstChild("ShootEvent") then
                game:GetService("ReplicatedStorage").ShootEvent:FireServer()
                success = true
            elseif game:GetService("ReplicatedStorage"):FindFirstChild("ShootRemote") then
                game:GetService("ReplicatedStorage").ShootRemote:InvokeServer()
                success = true
            end
            if not success then
                mouse1press()
            end
        end
    end
end

-- function to toggle the triggerbot on/off
local function toggleTriggerbot()
    RTriggerbot_Settings.Enabled_RTriggerbot = not RTriggerbot_Settings.Enabled_RTriggerbot
end

-- function to activate the triggerbot when a keybind is held
local function holdTriggerbot()
    RTriggerbot_Settings.Enabled_RTriggerbot = true
    while RTriggerbot_Settings.Enabled_RTriggerbot do
        triggerbot()
        wait()
    end
end

local userInputService = game:GetService("UserInputService")

-- Keybind listener for toggling the triggerbot
if RTriggerbot_Settings.Enabled.Toggle_Keybind then
    userInputService.InputBegan:Connect(function(input)
        if input.KeyCode == RTriggerbot_Settings.Keybind.Toggle_Key then
            toggleTriggerbot()
        end
    end)
end

-- Keybind listener for holding to activate the triggerbot
if RTriggerbot_Settings.Enabled.Hold then
    userInputService.InputBegan:Connect(function(input)
        if input.KeyCode == RTriggerbot_Settings.Keybind.Hold_Key then
            holdTriggerbot()
        end
    end)
    userInputService.InputEnded:Connect(function(input)
        if input.KeyCode == RTriggerbot_Settings.Keybind.Hold_Key then
            RTriggerbot_Settings.Enabled_RTriggerbot = false
        end
    end)
end

-- function to create and update the distance circle
if RTriggerbot_Settings.Enabled.Distance then
    local distanceCircle = Instance.new("Part")
    distanceCircle.Anchored = true
    distanceCircle.Size = Vector3.new(2 * RTriggerbot_Settings.Distance.Range, 0.1,
        2 * RTriggerbot_Settings.Distance.Range)
    distanceCircle.Color = RTriggerbot_Settings.Distance.Area_Color
    distanceCircle.Transparency = 0.5
    distanceCircle.CanCollide = false
    distanceCircle.Shape = Enum.PartType.Cylinder
    distanceCircle.Parent = workspace

    local function updateDistanceCircle()
        if RTriggerbot_Settings.Distance.Show_Area then
            distanceCircle.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position +
            Vector3.new(0, 0.1, 0)
            distanceCircle.Size = Vector3.new(2 * RTriggerbot_Settings.Distance.Range, 0.1,
                2 * RTriggerbot_Settings.Distance.Range)
            distanceCircle.Color = RTriggerbot_Settings.Distance.Area_Color
            distanceCircle.Transparency = RTriggerbot_Settings.Distance.Area_Streamable and 1 or 0.5
        else
            distanceCircle:Destroy()
        end
    end

    userInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDistanceCircle()
        end
    end)

    game:GetService("RunService").Stepped:Connect(function()
        updateDistanceCircle()
    end)
end

-- function to mouse click if other methods fail
function mouse1press()
    local mouse = game.Players.LocalPlayer:GetMouse()
    mouse1down = mouse.Button1Down:Connect(function()
        if RTriggerbot_Settings.Enabled_RTriggerbot then
            triggerbot()
        end
    end)
    mouse1up = mouse.Button1Up:Connect(function()
        if mouse1down then
            mouse1down:Disconnect()
        end
        if mouse1up then
            mouse1up:Disconnect()
        end
    end)
end
