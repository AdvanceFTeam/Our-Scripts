local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer
local cam = Workspace.CurrentCamera

local config = {
    aimbot = false,
    aimmode = "Hold",
    aimmethod = "CFrame",
    targetlogic = "TeamBase",
    wallcheck = true,
    part = "Random",
    stickyaim = false,
    stickytime = 0.2,
    aimshake = 0,
    smooth3d = 0.53,
    smooth2d = 0.25,
    threshold2d = 50,
    fov = true,
    fovangle = 48,
    fovthick = 2,
    fovtrans = 0.5,
    fovcolor = Color3.fromRGB(255, 255, 255),
    maxdist = 500,
    prediction = 0,
    bind = "MB2",
    togglekey = Enum.KeyCode.P,
    fly = false,
    flymethod = "CFrame",
    flyspeed = 100,
    flysmooth = 0.3,
    spin = false,
    spinmethod = "CFrame",
    spinspeed = 30,
}

local player = {
    ws_on = false,
    ws_value = 16,
    default_walk = 16,
    ws_method = "Vector",
    ws_methods = {"Vector", "CFrame", "BodyVelocity", "AlignPosition"},
    ws_conn = nil,
    ws_bv = nil,
    ws_align = nil,
}

local esp = {
    enabled = false,
    boxes = false,
    names = true,
    tracers = true,
    health = true,
    targetlogic = "TeamBase",
    maxdist = 300,
    thickness = 1,
    boxcolor = Color3.fromRGB(140, 170, 220),
    namecolor = Color3.fromRGB(220, 220, 220),
    tracercolor = Color3.fromRGB(140, 170, 220),
    healthcolor = Color3.fromRGB(130, 200, 140),
    objects = {},
}

local cross = {
    on = true,
    size = 12,
    gap = 8,
    dotsize = 1,
    color = Color3.fromRGB(255, 255, 255),
    outline = false,
    outlinecolor = Color3.fromRGB(255, 255, 255),
}

local fovcircle = Drawing.new("Circle")
fovcircle.Thickness = config.fovthick
fovcircle.Transparency = config.fovtrans
fovcircle.Filled = false
fovcircle.Visible = false
fovcircle.Color = config.fovcolor

local chlines = {
    top = Drawing.new("Line"),
    bottom = Drawing.new("Line"),
    left = Drawing.new("Line"),
    right = Drawing.new("Line"),
}
local chdot = Drawing.new("Circle")
local choutline = {
    top = Drawing.new("Line"),
    bottom = Drawing.new("Line"),
    left = Drawing.new("Line"),
    right = Drawing.new("Line"),
}

local aim_target = nil
local targettime = 0
local fovradius = 0

local function getcolor(plr)
    return esp.boxcolor
end

local function hide(o)
    if o.box then o.box.Visible = false end
    if o.name then o.name.Visible = false end
    if o.dist then o.dist.Visible = false end
    if o.tracer then o.tracer.Visible = false end
    if o.health then o.health.Visible = false end
end

local function remove(plr)
    local o = esp.objects[plr]
    if o then
        if o.box then o.box:Remove() end
        if o.name then o.name:Remove() end
        if o.dist then o.dist:Remove() end
        if o.tracer then o.tracer:Remove() end
        if o.health then o.health:Remove() end
        esp.objects[plr] = nil
    end
end

local function add(plr)
    if plr == lp or esp.objects[plr] then return end

    local box = Drawing.new("Quad")
    box.Thickness = esp.thickness
    box.Color = esp.boxcolor
    box.Transparency = 1
    box.Filled = false
    box.Visible = false

    local name = Drawing.new("Text")
    name.Color = esp.namecolor
    name.Center = true
    name.Outline = true
    name.Size = 14
    name.Visible = false

    local dist = Drawing.new("Text")
    dist.Color = esp.namecolor
    dist.Center = true
    dist.Outline = true
    dist.Size = 14
    dist.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = esp.thickness
    tracer.Color = esp.tracercolor
    tracer.Transparency = 1
    tracer.Visible = false

    local health = Drawing.new("Text")
    health.Color = esp.healthcolor
    health.Center = true
    health.Outline = true
    health.Size = 12
    health.Visible = false

    esp.objects[plr] = {box = box, name = name, dist = dist, tracer = tracer, health = health}
end

local function isenemy(plr)
    if esp.targetlogic == "Everyone" or esp.targetlogic == "FFA" then
        return true
    elseif esp.targetlogic == "TeamBase" then
        if lp.Team and plr.Team and lp.Team == plr.Team then
            return false
        end
        if lp.TeamColor and plr.TeamColor and lp.TeamColor == plr.TeamColor and lp.TeamColor.Name ~= "White" then
            return false
        end
        local lpTeamAttr = lp:GetAttribute("Team")
        local plrTeamAttr = plr:GetAttribute("Team")
        if lpTeamAttr and plrTeamAttr and lpTeamAttr == plrTeamAttr then
            return false
        end
        return true
    end
    return true
end

local function updateesp(plr, o)
    local char = plr.Character
    if not char then return hide(o) end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not head or not hum or hum.Health <= 0 then return hide(o) end
    if not isenemy(plr) then return hide(o) end

    local d = (cam.CFrame.Position - head.Position).Magnitude
    if d > esp.maxdist then return hide(o) end

    local cf = hrp.CFrame * CFrame.new(0, -1.5, 0)
    local size = Vector3.new(4, 6, 0)
    local tl = cf * CFrame.new(size.X / 2, size.Y / 2, 0)
    local tr = cf * CFrame.new(-size.X / 2, size.Y / 2, 0)
    local bl = cf * CFrame.new(size.X / 2, -size.Y / 2, 0)
    local br = cf * CFrame.new(-size.X / 2, -size.Y / 2, 0)
    local tag = cf * CFrame.new(0, size.Y / 2, 0)
    local torso = cf
    local c = getcolor(plr)

    local tlp, v1 = cam:WorldToViewportPoint(tl.Position)
    local trp, v2 = cam:WorldToViewportPoint(tr.Position)
    local blp, v3 = cam:WorldToViewportPoint(bl.Position)
    local brp, v4 = cam:WorldToViewportPoint(br.Position)

    if esp.boxes and (v1 or v2 or v3 or v4) then
        o.box.Visible = true
        o.box.PointA = Vector2.new(trp.X, trp.Y)
        o.box.PointB = Vector2.new(tlp.X, tlp.Y)
        o.box.PointC = Vector2.new(blp.X, blp.Y)
        o.box.PointD = Vector2.new(brp.X, brp.Y)
        o.box.Color = c
    else
        o.box.Visible = false
    end

    local tp, v5 = cam:WorldToViewportPoint(tag.Position)
    if esp.names and v5 then
        o.name.Visible = true
        o.name.Text = plr.Name
        o.name.Position = Vector2.new(tp.X, tp.Y)
        o.dist.Visible = true
        o.dist.Text = math.floor(d) .. "m"
        o.dist.Position = Vector2.new(tp.X, tp.Y + 14)
    else
        o.name.Visible = false
        o.dist.Visible = false
    end

    if esp.health and v5 then
        o.health.Visible = true
        o.health.Text = math.floor(hum.Health) .. " HP"
        o.health.Position = Vector2.new(tp.X, tp.Y - 16)
    else
        o.health.Visible = false
    end

    local top, v6 = cam:WorldToViewportPoint(torso.Position)
    if esp.tracers and v6 then
        o.tracer.Visible = true
        o.tracer.From = Vector2.new(top.X, top.Y)
        o.tracer.To = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
    else
        o.tracer.Visible = false
    end
end

local function loop()
    if esp.enabled then
        for plr, o in pairs(esp.objects) do
            local ok = pcall(updateesp, plr, o)
            if not ok then hide(o) end
        end
    else
        for _, o in pairs(esp.objects) do hide(o) end
    end
end

local function playeradded(plr)
    if plr == lp then return end
    add(plr)
    plr.CharacterAdded:Connect(function() add(plr) end)
    plr.CharacterRemoving:Connect(function()
        local o = esp.objects[plr]
        if o then hide(o) end
    end)
end

Players.PlayerAdded:Connect(playeradded)
Players.PlayerRemoving:Connect(remove)
for _, p in pairs(Players:GetPlayers()) do playeradded(p) end

local function drawfov()
    fovradius = math.tan(math.rad(config.fovangle / 2)) * (cam.ViewportSize.Y / 2)
    fovcircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    fovcircle.Radius = fovradius
end

local function drawcross()
    if cross.on then
        local ss = cam.ViewportSize
        local cx, cy = ss.X / 2, ss.Y / 2
        local s, g = cross.size, cross.gap

        if cross.outline then
            choutline.top.From = Vector2.new(cx + 1, cy - g + 1)
            choutline.top.To = Vector2.new(cx + 1, cy - g - s + 1)
            choutline.top.Color = cross.outlinecolor
            choutline.top.Thickness = 3
            choutline.top.Visible = true

            choutline.bottom.From = Vector2.new(cx + 1, cy + g + 1)
            choutline.bottom.To = Vector2.new(cx + 1, cy + g + s + 1)
            choutline.bottom.Color = cross.outlinecolor
            choutline.bottom.Thickness = 3
            choutline.bottom.Visible = true

            choutline.left.From = Vector2.new(cx - g + 1, cy + 1)
            choutline.left.To = Vector2.new(cx - g - s + 1, cy + 1)
            choutline.left.Color = cross.outlinecolor
            choutline.left.Thickness = 3
            choutline.left.Visible = true

            choutline.right.From = Vector2.new(cx + g + 1, cy + 1)
            choutline.right.To = Vector2.new(cx + g + s + 1, cy + 1)
            choutline.right.Color = cross.outlinecolor
            choutline.right.Thickness = 3
            choutline.right.Visible = true
        else
            for _, l in pairs(choutline) do l.Visible = false end
        end

        chlines.top.From = Vector2.new(cx, cy - g)
        chlines.top.To = Vector2.new(cx, cy - g - s)
        chlines.top.Color = cross.color
        chlines.top.Thickness = 1
        chlines.top.Visible = true

        chlines.bottom.From = Vector2.new(cx, cy + g)
        chlines.bottom.To = Vector2.new(cx, cy + g + s)
        chlines.bottom.Color = cross.color
        chlines.bottom.Thickness = 1
        chlines.bottom.Visible = true

        chlines.left.From = Vector2.new(cx - g, cy)
        chlines.left.To = Vector2.new(cx - g - s, cy)
        chlines.left.Color = cross.color
        chlines.left.Thickness = 1
        chlines.left.Visible = true

        chlines.right.From = Vector2.new(cx + g, cy)
        chlines.right.To = Vector2.new(cx + g + s, cy)
        chlines.right.Color = cross.color
        chlines.right.Thickness = 1
        chlines.right.Visible = true

        chdot.Position = Vector2.new(cx, cy)
        chdot.Radius = cross.dotsize
        chdot.Color = cross.color
        chdot.Filled = true
        chdot.Visible = true
    else
        for _, l in pairs(chlines) do l.Visible = false end
        for _, l in pairs(choutline) do l.Visible = false end
        chdot.Visible = false
    end
end

local function canhit(plr)
    if plr == lp then return false end
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    if config.targetlogic == "TeamBase" then
        if lp.Team and plr.Team and lp.Team == plr.Team then
            return false
        end
        if lp.TeamColor and plr.TeamColor and lp.TeamColor == plr.TeamColor and lp.TeamColor.Name ~= "White" then
            return false
        end
        local lpTeamAttr = lp:GetAttribute("Team")
        local plrTeamAttr = plr:GetAttribute("Team")
        if lpTeamAttr and plrTeamAttr and lpTeamAttr == plrTeamAttr then
            return false
        end
    end

    return true
end

local function wallchecks(targetpart, char)
    if not config.wallcheck then return true end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lp.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local origin = cam.CFrame.Position
    local dir = targetpart.Position - origin
    local res = Workspace:Raycast(origin, dir, params)
    if res and res.Instance and not res.Instance:IsDescendantOf(char) then
        return false
    end
    return true
end

local function closest(char)
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestdist = nil, math.huge
    local parts = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}
    for _, name in ipairs(parts) do
        local p = char:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            local spos, on = cam:WorldToViewportPoint(p.Position)
            if on then
                local d = (Vector2.new(spos.X, spos.Y) - center).Magnitude
                if d < bestdist then
                    bestdist = d
                    best = p
                end
            end
        end
    end
    return best
end

local function gettarget()
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local bestpart = nil
    local bestchar = nil
    local bestdist = math.huge

    for _, plr in pairs(Players:GetPlayers()) do
        if not canhit(plr) then continue end
        local char = plr.Character
        local part
        if config.part == "Random" then
            part = closest(char)
        else
            part = char:FindFirstChild(config.part)
        end
        if not part then continue end

        local screenpos, on = cam:WorldToViewportPoint(part.Position)
        if not on then continue end

        local worlddist = (part.Position - cam.CFrame.Position).Magnitude
        if worlddist > config.maxdist then continue end

        local screendist = (Vector2.new(screenpos.X, screenpos.Y) - center).Magnitude

        if config.fov and screendist > fovradius then continue end

        if not wallchecks(part, char) then continue end

        if screendist < bestdist then
            bestdist = screendist
            bestpart = part
            bestchar = char
        end
    end

    return bestpart, bestchar
end

local function predict(part, char)
    if config.prediction <= 0 then return part.Position end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    return part.Position + hrp.AssemblyLinearVelocity * config.prediction
end

local function shoot(part, char)
    local pos = predict(part, char)

    if config.aimshake > 0 then
        local shake = config.aimshake / 10
        pos = pos + Vector3.new(math.random(-shake, shake), math.random(-shake, shake), math.random(-shake, shake))
    end

    if config.aimmethod == "Mouse" then
        local screen, on = cam:WorldToViewportPoint(pos)
        if not on then return end

        local mouse = UserInputService:GetMouseLocation()
        local dir = Vector2.new(screen.X, screen.Y) - mouse
        local dist = dir.Magnitude

        if dist > 1 then
            local move = dir.Unit * (dist * config.smooth2d)
            local clampedX = math.clamp(move.X, -config.threshold2d, config.threshold2d)
            local clampedY = math.clamp(move.Y, -config.threshold2d, config.threshold2d)

            if mousemoverel then
                mousemoverel(clampedX, clampedY)
            end
        end
    elseif config.aimmethod == "Instant" then
        cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
    elseif config.aimmethod == "Camera" then
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pos)
    else
        local look = CFrame.new(cam.CFrame.Position, pos)
        cam.CFrame = cam.CFrame:Lerp(look, config.smooth3d)
    end
end

local aiming = false
local toggled = false

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        if config.aimmode == "Hold" then
            aiming = true
        elseif config.aimmode == "Toggle" then
            toggled = not toggled
            aiming = toggled
        end
    end
    if input.KeyCode == config.togglekey then
        toggled = not toggled
        aiming = toggled
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        if config.aimmode == "Hold" then
            aiming = false
            toggled = false
        end
    end
end)

local function stopws()
    if player.ws_conn then
        player.ws_conn:Disconnect()
        player.ws_conn = nil
    end
    if player.ws_bv then
        player.ws_bv:Destroy()
        player.ws_bv = nil
    end
    if player.ws_align then
        player.ws_align:Destroy()
        player.ws_align = nil
    end
end

local function startws()
    stopws()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if player.ws_method == "Vector" then
        player.ws_conn = RunService.RenderStepped:Connect(function(dt)
            if not player.ws_on then return end
            local c = lp.Character
            if not c then return end
            local r = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if not r or not h then return end
            local dir = h.MoveDirection
            if dir.Magnitude > 0 then
                r.CFrame = r.CFrame + dir.Unit * player.ws_value * dt
            end
        end)
    elseif player.ws_method == "CFrame" then
        player.ws_conn = RunService.RenderStepped:Connect(function(dt)
            if not player.ws_on then return end
            local c = lp.Character
            if not c then return end
            local r = c:FindFirstChild("HumanoidRootPart")
            local h = c:FindFirstChildOfClass("Humanoid")
            if not r or not h then return end
            local dir = h.MoveDirection
            if dir.Magnitude > 0 then
                r.CFrame = r.CFrame:Lerp(r.CFrame + dir.Unit * player.ws_value * dt, 0.5)
            end
        end)
    elseif player.ws_method == "BodyVelocity" then
        player.ws_bv = Instance.new("BodyVelocity")
        player.ws_bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        player.ws_bv.Velocity = Vector3.zero
        player.ws_bv.Parent = root

        player.ws_conn = RunService.RenderStepped:Connect(function()
            if not player.ws_on or not player.ws_bv then return end
            local c = lp.Character
            if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            if not h then return end
            local dir = h.MoveDirection
            if dir.Magnitude > 0 then
                player.ws_bv.Velocity = dir.Unit * player.ws_value
            else
                player.ws_bv.Velocity = Vector3.zero
            end
        end)
    elseif player.ws_method == "AlignPosition" then
        local attach = Instance.new("Attachment", root)
        player.ws_align = Instance.new("AlignPosition")
        player.ws_align.Mode = Enum.PositionAlignmentMode.OneAttachment
        player.ws_align.Attachment0 = attach
        player.ws_align.MaxForce = math.huge
        player.ws_align.Responsiveness = 50
        player.ws_align.Parent = root

        player.ws_conn = RunService.RenderStepped:Connect(function()
            if not player.ws_on or not player.ws_align then return end
            local c = lp.Character
            if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            local r = c:FindFirstChild("HumanoidRootPart")
            if not h or not r then return end
            local dir = h.MoveDirection
            if dir.Magnitude > 0 then
                player.ws_align.Position = r.Position + dir.Unit * player.ws_value * 0.1
            else
                player.ws_align.Position = r.Position
            end
        end)
    end
end

local function applyws()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if player.ws_on then
        stopws()
        startws()
    else
        stopws()
        hum.WalkSpeed = player.default_walk
    end
end

local function charload(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    if player.ws_on then startws() else applyws() end
end

if lp.Character then charload(lp.Character) end
lp.CharacterAdded:Connect(charload)

local function startfly()
    local char = lp.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if config.flymethod == "BodyVelocity" then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = root

        local conn
        conn = RunService.RenderStepped:Connect(function(dt)
            if not config.fly then
                bv:Destroy()
                conn:Disconnect()
                return
            end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            bv.Velocity = dir * config.flyspeed
        end)

    elseif config.flymethod == "AlignPosition" then
        local attach = Instance.new("Attachment", root)
        local align = Instance.new("AlignPosition")
        align.Mode = Enum.PositionAlignmentMode.OneAttachment
        align.Attachment0 = attach
        align.MaxForce = math.huge
        align.Responsiveness = 50
        align.Position = root.Position
        align.Parent = root

        local conn
        conn = RunService.RenderStepped:Connect(function(dt)
            if not config.fly then
                align:Destroy()
                conn:Disconnect()
                return
            end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then dir = dir.Unit end

            local target = root.Position + (dir * config.flyspeed * dt)
            align.Position = target
        end)

    else
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:ChangeState(Enum.HumanoidStateType.Swimming)

        local pos = root.Position

        local conn
        conn = RunService.RenderStepped:Connect(function(dt)
            if not config.fly then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                conn:Disconnect()
                return
            end

            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)

            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            local target = pos + (dir * config.flyspeed * dt)
            root.CFrame = root.CFrame:Lerp(CFrame.new(target, target + cam.CFrame.LookVector), config.flysmooth)
            pos = root.Position
        end)
    end
end

local function spinloop()
    RunService.RenderStepped:Connect(function(dt)
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end

        local part = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
        if not part then return end

        if config.spin then
            if config.spinmethod == "BodyAngularVelocity" then
                local bav = part:FindFirstChild("SpinBAV")
                if not bav then
                    bav = Instance.new("BodyAngularVelocity")
                    bav.Name = "SpinBAV"
                    bav.AngularVelocity = Vector3.new(0, config.spinspeed, 0)
                    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    bav.Parent = part
                else
                    bav.AngularVelocity = Vector3.new(0, config.spinspeed, 0)
                end
            else
                local angle = math.rad(config.spinspeed) * dt
                part.CFrame = part.CFrame * CFrame.Angles(0, angle, 0)
            end
        else
            local bav = part:FindFirstChild("SpinBAV")
            if bav then bav:Destroy() end
        end
    end)
end
spinloop()

drawfov()

RunService.RenderStepped:Connect(function()
    if config.fov then
        fovcircle.Visible = true
        drawfov()
    else
        fovcircle.Visible = false
    end

    drawcross()
    loop()

    if aiming and config.aimbot then
        local part, char = gettarget()
        if part and char then
            shoot(part, char)
            if config.stickyaim then
                aim_target = char
                targettime = tick()
            end
        end
    elseif config.stickyaim and aim_target then
        if tick() - targettime < config.stickytime then
            local hum = aim_target:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = aim_target:FindFirstChild(config.part) or aim_target:FindFirstChild("Head")
                if part then
                    shoot(part, aim_target)
                end
            else
                aim_target = nil
            end
        else
            aim_target = nil
        end
    end
end)

local source = "https://raw.githubusercontent.com/YellowGregs/Spectrum/refs/heads/main/Spectrum.lua"
local body = game:HttpGet(source, true)
local chunk = loadstring(body, "Spectrum")
local ok, loaded = pcall(function() return chunk and chunk() end)
local Library = (ok and loaded) or nil
if not Library then
    local retry_ok, retry = pcall(loadstring, body .. "\nreturn S.library", "Spectrum")
    if retry_ok and retry then Library = retry() end
end
Library = Library or shared.Spectrum
if not Library then
    error("[RandomAssistV1.2] Library failed to load", 0)
end

local main = Library:Window("RandomAssistV1.2", { icon = "combat" })
local visual = Library:Window("Visuals", { icon = "eye" })
local player_win = Library:Window("Player", { icon = "user" })
local settings = Library:Window("Settings", { icon = "gear" })

main:section("Aimbot", "target")

main:toggle("Aimbot toggle", false, function(state)
    config.aimbot = state
end, { icon = "target" })

main:dropdown("Aim Mode", {"Hold", "Toggle"}, "Hold", function(picked)
    config.aimmode = picked
    if picked == "Hold" then toggled = false aiming = false end
end, false, "key")

main:dropdown("Aim Method", {"CFrame", "Mouse", "Instant", "Camera"}, "CFrame", function(picked)
    config.aimmethod = picked
end, false, "move")

main:dropdown("Target Logic", {"TeamBase", "FFA", "Everyone"}, "TeamBase", function(picked)
    config.targetlogic = picked
end, false, "shield")

main:toggle("WallCheck", true, function(state)
    config.wallcheck = state
end, { icon = "lock" })

main:toggle("Sticky Aim", false, function(state)
    config.stickyaim = state
end, { icon = "target" })

main:slider("Sticky Time", 0.1, 2, 0.2, function(val)
    config.stickytime = val
end, 0.1, "clock")

main:slider("Aim Shake", 0, 50, 0, function(val)
    config.aimshake = val
end, 1, "move")

main:slider("Max Distance", 50, 2000, 500, function(val)
    config.maxdist = val
end, 10, "globe")

main:slider("Prediction", 0, 0.5, 0, function(val)
    config.prediction = val
end, 0.01, "move")

main:dropdown("BodyPart", {"Random", "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm", "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot"}, "Random", function(picked)
    config.part = picked
end, false, "target")

main:keybind("Aimbot Key", "MB2", function(key, pressed)
    if pressed then
        if config.aimmode == "Toggle" then
            toggled = not toggled
            aiming = toggled
        elseif config.aimmode == "Hold" then
            aiming = true
        end
    else
        if config.aimmode == "Hold" then
            aiming = false
            toggled = false
        end
    end
end, "key")

main:section("Aimbot Smoothing", "sliders")

main:slider("CFrame Smoothness", 0.05, 0.9, 0.53, function(val)
    config.smooth3d = val
end, 0.01, "sliders")

main:slider("Mouse Smoothness", 0.05, 0.9, 0.25, function(val)
    config.smooth2d = val
end, 0.01, "sliders")

main:slider("Mouse Threshold", 10, 200, 50, function(val)
    config.threshold2d = val
end, 1, "sliders")

main:section("Field Of View", "eye")

main:toggle("FOV toggle", true, function(state)
    config.fov = state
end, { icon = "eye" })

main:slider("FOV Size", 10, 180, 48, function(val)
    config.fovangle = val
    drawfov()
end, 1, "globe")

main:slider("FOV Thickness", 1, 10, 2, function(val)
    config.fovthick = val
    fovcircle.Thickness = val
end, 1, "sliders")

main:slider("Transparency", 0, 100, 50, function(val)
    config.fovtrans = val / 100
    fovcircle.Transparency = config.fovtrans
end, 1, "sliders")

main:colorpicker("FOV Color", Color3.fromRGB(255, 255, 255), function(color)
    config.fovcolor = color
    fovcircle.Color = color
end, "palette")

visual:section("Esp", "eye")

visual:toggle("ESP toggle", false, function(state)
    esp.enabled = state
end, { icon = "eye" })

visual:dropdown("Target Logic", {"TeamBase", "FFA", "Everyone"}, "TeamBase", function(picked)
    esp.targetlogic = picked
end, false, "shield")

visual:toggle("Esp Box", false, function(state)
    esp.boxes = state
end, { icon = "target" })

visual:toggle("Names", true, function(state)
    esp.names = state
end, { icon = "user" })

visual:toggle("Health", true, function(state)
    esp.health = state
end, { icon = "check" })

visual:toggle("Tracers", true, function(state)
    esp.tracers = state
end, { icon = "crosshair" })

visual:section("Esp Settings", "sliders")

visual:slider("Thickness", 1, 10, 1, function(val)
    esp.thickness = val
end, 1, "sliders")

visual:slider("Max Distance", 50, 2000, 300, function(val)
    esp.maxdist = val
end, 10, "globe")

visual:colorpicker("Box Color", Color3.fromRGB(140, 170, 220), function(color)
    esp.boxcolor = color
end, "palette")

visual:colorpicker("Name Color", Color3.fromRGB(220, 220, 220), function(color)
    esp.namecolor = color
end, "palette")

visual:colorpicker("Tracer Color", Color3.fromRGB(140, 170, 220), function(color)
    esp.tracercolor = color
end, "palette")

visual:colorpicker("Health Color", Color3.fromRGB(130, 200, 140), function(color)
    esp.healthcolor = color
end, "palette")

visual:section("Crosshair", "crosshair")

visual:toggle("Crosshair", true, function(state)
    cross.on = state
    drawcross()
end, { icon = "crosshair" })

visual:slider("Crosshair Size", 2, 20, 12, function(val)
    cross.size = val
end, 1, "menu")

visual:slider("Crosshair Gap", 2, 20, 8, function(val)
    cross.gap = val
end, 1, "menu")

visual:slider("Dot Size", 1, 10, 1, function(val)
    cross.dotsize = val
end, 1, "target")

visual:toggle("Outline", false, function(state)
    cross.outline = state
end, { icon = "check" })

visual:colorpicker("Crosshair Color", Color3.fromRGB(255, 255, 255), function(color)
    cross.color = color
end, "palette")

visual:colorpicker("Outline Color", Color3.fromRGB(255, 255, 255), function(color)
    cross.outlinecolor = color
end, "palette")

player_win:section("WalkSpeed", "speed")

player_win:toggle("Enable WalkSpeed", false, function(state)
    player.ws_on = state
    applyws()
end, { icon = "bolt" })

player_win:dropdown("WS Method", player.ws_methods, "Vector", function(picked)
    player.ws_method = picked
    if player.ws_on then startws() end
end, false, "code")

player_win:slider("WalkSpeed Value", 16, 500, 16, function(val)
    player.ws_value = val
end, 1, "arrow")

player_win:section("Fly", "globe")

player_win:toggle("Enable Fly", false, function(state)
    config.fly = state
    if state then startfly() end
end, { icon = "globe" })

player_win:dropdown("Fly Method", {"CFrame", "BodyVelocity", "AlignPosition"}, "CFrame", function(picked)
    config.flymethod = picked
    if config.fly then startfly() end
end, false, "move")

player_win:slider("Fly Speed", 25, 500, 100, function(val)
    config.flyspeed = val
end, 5, "globe")

player_win:slider("Fly Smoothness", 0, 1, 0.3, function(val)
    config.flysmooth = val
end, 0.01, "sliders")

player_win:section("Spinbot", "refresh")

player_win:toggle("Enable Spinbot", false, function(state)
    config.spin = state
end, { icon = "refresh" })

player_win:dropdown("Spin Method", {"CFrame", "BodyAngularVelocity"}, "CFrame", function(picked)
    config.spinmethod = picked
end, false, "move")

player_win:slider("Spin Speed", 10, 360, 30, function(val)
    config.spinspeed = val
end, 1, "refresh")

settings:section("Configuration", "save")

settings:button("Save Config", function()
    Library:SaveConfig("default")
    Library:Notify("RandomAssistV1.2", "Saved default config.", 2, "good")
end, "save")

settings:button("Reset Theme", function()
    Library:Design(Library:GetDesign())
    Library:Notify("RandomAssistV1.2", "Theme reset.", 2, "info")
end, "palette")

if type(Library.SetAutoSave) == "function" and type(Library.GetAutoSave) == "function" then
    settings:toggle("Auto Save Config", true, function(state)
        Library:SetAutoSave(state)
    end, { icon = "save" })
    
    if Library:GetAutoSave() ~= true then
        Library:SetAutoSave(true)
    end
end

Library:Notify("RandomAssistV1.2", "Loaded successfully.", 3, "good")
