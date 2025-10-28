--[[


 █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗███████╗ █████╗ ██╗     ██╗     ██╗███╗   ██╗ ██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔════╝██╔════╝██╔════╝██╔══██╗██║     ██║     ██║████╗  ██║██╔════╝     ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
███████║██║  ██║██║   ██║███████║██╔██╗ ██║██║     █████╗  █████╗  ███████║██║     ██║     ██║██╔██╗ ██║██║  ███╗       ██║   █████╗  ███████║██╔████╔██║
██╔══██║██║  ██║╚██╗ ██╔╝██╔══██║██║╚██╗██║██║     ██╔══╝  ██╔══╝  ██╔══██║██║     ██║     ██║██║╚██╗██║██║   ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
██║  ██║██████╔╝ ╚████╔╝ ██║  ██║██║ ╚████║╚██████╗███████╗██║     ██║  ██║███████╗███████╗██║██║ ╚████║╚██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
                                                                                                                                                        
]] --
-- AdvanceFalling Team

--[[
- This is still work in progress(W.I.P).
]]--


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cache = {}
local connections = {}

local bones_r15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "LowerTorso"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local bones_r6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Left Arm", "Left Leg"},
    {"Torso", "Right Arm"},
    {"Right Arm", "Right Leg"}
}

local ESP_SETTINGS = {
    box = {
        outline_color = Color3.new(0, 0, 0),
        color = Color3.new(1, 1, 1),
        enabled = true,
        show = true,
        type = "3D",
        outline_thickness = 2,
        transparency = 0.9,
        corner_length = 0.25
    },
    name = {
        color = Color3.new(1, 1, 1),
        show = true,
        font_size = 12,
        font = 2,
        transparency = 1,
        outline = true
    },
    health = {
        outline_color = Color3.new(0, 0, 0),
        high_color = Color3.new(0, 1, 0),
        low_color = Color3.new(1, 0, 0),
        show = true,
        bar_thickness = 3,
        transparency = 0.8
    },
    distance = {
        show = true,
        color = Color3.new(1, 1, 1),
        font_size = 11,
        font = 2,
        transparency = 0.9,
        max_distance = math.huge
    },
    skeletons = {
        show = true,
        color = Color3.new(1, 1, 1),
        thickness = 1,
        transparency = 0.7
    },
    tracer = {
        show = true,
        color = Color3.new(1, 1, 1),
        thickness = 2,
        position = "Bottom",
        transparency = 0.6
    },
    offscreen = {
        show = true,
        color = Color3.new(1, 1, 1),
        size = 25,
        thickness = 2,
        transparency = 0.9
    },
    chams = {
        show = true,
        color = Color3.new(1, 1, 1),
        outline_color = Color3.new(0, 0, 0),
        fill_transparency = 0.4,
        outline = true
    },
    lookat = {
        show = true,
        color = Color3.new(1, 1, 1),
        length = 8,
        thickness = 1,
        transparency = 0.8
    },
    head_circle = {
        show = true,
        color = Color3.new(1, 1, 1),
        radius = 1.2,
        sides = 16,
        thickness = 1,
        transparency = 0.8
    },
    general = {
        teamcheck = false,
        wallcheck = false,
        enabled = true
    }
}

local Drawing = getgenv().Drawing
if not Drawing or not Drawing.new then
    error("Drawing Library not found for this executor")
end

local function create(class, properties)
    local drawing = Drawing.new(class)
    for property, value in pairs(properties) do
        drawing[property] = value
    end
    return drawing
end

local function recursive_remove(drawing)
    if type(drawing) == "userdata" and drawing.Remove then
        pcall(drawing.Remove, drawing)
    elseif type(drawing) == "table" then
        for _, item in pairs(drawing) do
            recursive_remove(item)
        end
    end
end

local function recursive_hide(drawing, skip_cham)
    if type(drawing) == "userdata" then
        local success, vis = pcall(function() return drawing.Visible end)
        if success and vis ~= nil and drawing ~= skip_cham then
            pcall(function() drawing.Visible = false end)
        end
    elseif type(drawing) == "table" then
        for _, item in pairs(drawing) do
            recursive_hide(item, skip_cham)
        end
    end
end

local function cleanup()
    for player, esp in pairs(cache) do
        remove_esp(player)
    end
    cache = {}
    if connections.render then
        pcall(function() connections.render:Disconnect() end)
    end
end

local function create_esp(player)
    local esp = {
        box_outline = create("Square", {
            Color = ESP_SETTINGS.box.outline_color,
            Thickness = ESP_SETTINGS.box.outline_thickness,
            Filled = false,
            Visible = false,
            Transparency = ESP_SETTINGS.box.transparency
        }),
        box = create("Square", {
            Color = ESP_SETTINGS.box.color,
            Thickness = 1,
            Filled = false,
            Visible = false,
            Transparency = ESP_SETTINGS.box.transparency
        }),
        box_lines = {},
        box_3d_lines = {},
        name = create("Text", {
            Color = ESP_SETTINGS.name.color,
            Outline = ESP_SETTINGS.name.outline,
            Center = true,
            Size = ESP_SETTINGS.name.font_size,
            Font = ESP_SETTINGS.name.font,
            Visible = false,
            Transparency = ESP_SETTINGS.name.transparency
        }),
        health_outline = create("Line", {
            Thickness = ESP_SETTINGS.health.bar_thickness,
            Color = ESP_SETTINGS.health.outline_color,
            Visible = false,
            Transparency = ESP_SETTINGS.health.transparency
        }),
        health = create("Line", {
            Thickness = 2,
            Visible = false,
            Transparency = ESP_SETTINGS.health.transparency
        }),
        distance = create("Text", {
            Color = ESP_SETTINGS.distance.color,
            Size = ESP_SETTINGS.distance.font_size,
            Font = ESP_SETTINGS.distance.font,
            Outline = true,
            Center = true,
            Visible = false,
            Transparency = ESP_SETTINGS.distance.transparency
        }),
        tracer = create("Line", {
            Thickness = ESP_SETTINGS.tracer.thickness,
            Color = ESP_SETTINGS.tracer.color,
            Transparency = ESP_SETTINGS.tracer.transparency,
            Visible = false
        }),
        skeleton_lines = {},
        arrow_outline = create("Quad", {
            Color = ESP_SETTINGS.offscreen.color,
            Thickness = 2,
            Filled = false,
            Visible = false,
            Transparency = ESP_SETTINGS.offscreen.transparency
        }),
        arrow = create("Quad", {
            Color = ESP_SETTINGS.offscreen.color,
            Thickness = 0,
            Filled = true,
            Visible = false,
            Transparency = ESP_SETTINGS.offscreen.transparency
        }),
        lookat_line = create("Line", {
            Thickness = ESP_SETTINGS.lookat.thickness,
            Color = ESP_SETTINGS.lookat.color,
            Visible = false,
            Transparency = ESP_SETTINGS.lookat.transparency
        }),
        head_circle_lines = {},
        cham = Instance.new("Highlight")
    }

    esp.cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    esp.cham.FillTransparency = ESP_SETTINGS.chams.fill_transparency
    esp.cham.OutlineTransparency = ESP_SETTINGS.chams.outline and 0 or 1
    esp.cham.FillColor = ESP_SETTINGS.chams.color
    esp.cham.OutlineColor = ESP_SETTINGS.chams.outline_color
    esp.cham.Enabled = false

    for i = 1, 8 do
        table.insert(esp.box_lines, create("Line", {
            Thickness = 1.5,
            Color = ESP_SETTINGS.box.color,
            Visible = false,
            Transparency = ESP_SETTINGS.box.transparency
        }))
    end

    for i = 1, 12 do
        table.insert(esp.box_3d_lines, create("Line", {
            Thickness = 1,
            Color = ESP_SETTINGS.box.color,
            Visible = false,
            Transparency = ESP_SETTINGS.box.transparency
        }))
    end

    for i = 1, ESP_SETTINGS.head_circle.sides do
        table.insert(esp.head_circle_lines, create("Line", {
            Thickness = ESP_SETTINGS.head_circle.thickness,
            Color = ESP_SETTINGS.head_circle.color,
            Visible = false,
            Transparency = ESP_SETTINGS.head_circle.transparency
        }))
    end

    cache[player] = esp
end

local function is_player_behind_wall(player)
    local character = player.Character
    if not character then return false end
    local root_part = character:FindFirstChild("HumanoidRootPart")
    if not root_part then return false end
    local ray = Ray.new(camera.CFrame.Position, (root_part.Position - camera.CFrame.Position).Unit * (root_part.Position - camera.CFrame.Position).Magnitude)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, character})
    return hit and hit:IsA("Part")
end

local function remove_esp(player)
    local esp = cache[player]
    if not esp then return end
    
    recursive_hide(esp, nil)
    
    if esp.cham then
        esp.cham.Parent = nil
        esp.cham.Enabled = false
        pcall(function() esp.cham:Destroy() end)
    end
    
    for key, drawing in pairs(esp) do
        recursive_remove(drawing)
    end
    
    cache[player] = nil
end

local function get_bones(character)
    if character:FindFirstChild("UpperTorso") then
        return bones_r15
    else
        return bones_r6
    end
end

local function get_3d_box_points(root_part)
    local cf = root_part.CFrame
    local size = Vector3.new(5, 7, 2)
    local corners = {
        cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
        cf * CFrame.new( size.X/2, -size.Y/2, -size.Z/2),
        cf * CFrame.new( size.X/2,  size.Y/2, -size.Z/2),
        cf * CFrame.new(-size.X/2,  size.Y/2, -size.Z/2),
        cf * CFrame.new(-size.X/2, -size.Y/2,  size.Z/2),
        cf * CFrame.new( size.X/2, -size.Y/2,  size.Z/2),
        cf * CFrame.new( size.X/2,  size.Y/2,  size.Z/2),
        cf * CFrame.new(-size.X/2,  size.Y/2,  size.Z/2)
    }
    return corners
end

local function update_esp()
    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if player ~= localPlayer then
            local esp = cache[player]
            if not esp then
                create_esp(player)
                esp = cache[player]
            end
            
            local character = player.Character
            local team = player.Team
            if character and (not ESP_SETTINGS.general.teamcheck or (team and team ~= localPlayer.Team)) then
                local root_part = character:FindFirstChild("HumanoidRootPart")
                local head = character:FindFirstChild("Head")
                local humanoid = character:FindFirstChild("Humanoid")
                local foot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg")
                local is_behind_wall = ESP_SETTINGS.general.wallcheck and is_player_behind_wall(player)
                local should_show = not is_behind_wall and ESP_SETTINGS.general.enabled

                if root_part and head and humanoid and foot and should_show then
                    local distance = (camera.CFrame.Position - root_part.Position).Magnitude
                    if distance > ESP_SETTINGS.distance.max_distance then
                        recursive_hide(esp, esp.cham)
                        esp.cham.Parent = nil
                        esp.cham.Enabled = false
                        continue
                    end
                    
                    local position, on_screen = camera:WorldToViewportPoint(root_part.Position)
                    local head_pos, _ = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local foot_pos, _ = camera:WorldToViewportPoint(foot.Position - Vector3.new(0, 0.5, 0))
                    local lookat_end, _ = camera:WorldToViewportPoint(head.Position + head.CFrame.LookVector * ESP_SETTINGS.lookat.length)
                    
                    local box_height = math.abs(head_pos.Y - foot_pos.Y)
                    local box_width = box_height * 0.5
                    local box_size = Vector2.new(math.floor(box_width), math.floor(box_height))
                    local center_x = math.floor((head_pos.X + foot_pos.X) / 2)
                    local center_y = math.floor((head_pos.Y + foot_pos.Y) / 2)
                    local box_position = Vector2.new(center_x - box_size.X / 2, center_y - box_size.Y / 2)

                    if on_screen then
                        esp.arrow_outline.Visible = false
                        esp.arrow.Visible = false

                        if ESP_SETTINGS.chams.show then
                            esp.cham.Parent = character
                            esp.cham.FillColor = ESP_SETTINGS.chams.color
                            esp.cham.OutlineColor = ESP_SETTINGS.chams.outline_color
                            esp.cham.FillTransparency = ESP_SETTINGS.chams.fill_transparency
                            esp.cham.OutlineTransparency = ESP_SETTINGS.chams.outline and 0 or 1
                            esp.cham.Enabled = true
                        else
                            esp.cham.Parent = nil
                            esp.cham.Enabled = false
                        end

                        if ESP_SETTINGS.name.show then
                            esp.name.Visible = true
                            esp.name.Text = string.lower(player.Name)
                            esp.name.Position = Vector2.new(center_x, head_pos.Y - 18)
                            esp.name.Color = ESP_SETTINGS.name.color
                            esp.name.Size = ESP_SETTINGS.name.font_size
                            esp.name.Font = ESP_SETTINGS.name.font
                            esp.name.Transparency = ESP_SETTINGS.name.transparency
                        else
                            esp.name.Visible = false
                        end

                        if ESP_SETTINGS.box.show then
                            if ESP_SETTINGS.box.type == "2D" then
                                esp.box_outline.Size = box_size
                                esp.box_outline.Position = box_position
                                esp.box_outline.Visible = true
                                esp.box_outline.Transparency = ESP_SETTINGS.box.transparency
                                esp.box.Size = box_size
                                esp.box.Position = box_position
                                esp.box.Color = ESP_SETTINGS.box.color
                                esp.box.Visible = true
                                esp.box.Transparency = ESP_SETTINGS.box.transparency
                                for _, line in ipairs(esp.box_lines) do line.Visible = false end
                                for _, line in ipairs(esp.box_3d_lines) do line.Visible = false end
                                
                            elseif ESP_SETTINGS.box.type == "3D" then
                                local corners = get_3d_box_points(root_part)
                                local points_2d = {}
                                for i, corner in ipairs(corners) do
                                    local pos, _ = camera:WorldToViewportPoint(corner.Position)
                                    points_2d[i] = Vector2.new(pos.X, pos.Y)
                                end
                                
                                local edges = {
                                    {1,2},{2,3},{3,4},{4,1},
                                    {5,6},{6,7},{7,8},{8,5},
                                    {1,5},{2,6},{3,7},{4,8}
                                }
                                
                                for i, edge in ipairs(edges) do
                                    local line = esp.box_3d_lines[i]
                                    line.From = points_2d[edge[1]]
                                    line.To = points_2d[edge[2]]
                                    line.Color = ESP_SETTINGS.box.color
                                    line.Visible = true
                                    line.Transparency = ESP_SETTINGS.box.transparency
                                end
                                
                                esp.box_outline.Visible = false
                                esp.box.Visible = false
                                for _, line in ipairs(esp.box_lines) do line.Visible = false end
                                
                            else
                                local line_length = math.min(box_size.X, box_size.Y) * ESP_SETTINGS.box.corner_length
                                
                                local lines = {
                                    {box_position.X, box_position.Y, box_position.X + line_length, box_position.Y},
                                    {box_position.X, box_position.Y, box_position.X, box_position.Y + line_length},
                                    {box_position.X + box_size.X, box_position.Y, box_position.X + box_size.X - line_length, box_position.Y},
                                    {box_position.X + box_size.X, box_position.Y, box_position.X + box_size.X, box_position.Y + line_length},
                                    {box_position.X, box_position.Y + box_size.Y, box_position.X + line_length, box_position.Y + box_size.Y},
                                    {box_position.X, box_position.Y + box_size.Y, box_position.X, box_position.Y + box_size.Y - line_length},
                                    {box_position.X + box_size.X, box_position.Y + box_size.Y, box_position.X + box_size.X - line_length, box_position.Y + box_size.Y},
                                    {box_position.X + box_size.X, box_position.Y + box_size.Y, box_position.X + box_size.X, box_position.Y + box_size.Y - line_length}
                                }
                                
                                for i, line_data in ipairs(lines) do
                                    local line = esp.box_lines[i]
                                    line.From = Vector2.new(line_data[1], line_data[2])
                                    line.To = Vector2.new(line_data[3], line_data[4])
                                    line.Color = ESP_SETTINGS.box.color
                                    line.Visible = true
                                    line.Transparency = ESP_SETTINGS.box.transparency
                                end
                                
                                esp.box_outline.Visible = false
                                esp.box.Visible = false
                                for _, line in ipairs(esp.box_3d_lines) do line.Visible = false end
                            end
                        else
                            esp.box_outline.Visible = false
                            esp.box.Visible = false
                            for _, line in ipairs(esp.box_lines) do line.Visible = false end
                            for _, line in ipairs(esp.box_3d_lines) do line.Visible = false end
                        end

                        if ESP_SETTINGS.health.show then
                            esp.health_outline.Visible = true
                            esp.health_outline.From = Vector2.new(box_position.X - 6, head_pos.Y)
                            esp.health_outline.To = Vector2.new(esp.health_outline.From.X, foot_pos.Y)
                            esp.health_outline.Transparency = ESP_SETTINGS.health.transparency
                            esp.health.Visible = true
                            esp.health.From = Vector2.new(box_position.X - 4, foot_pos.Y)
                            esp.health.To = Vector2.new(esp.health.From.X, foot_pos.Y - (humanoid.Health / humanoid.MaxHealth * box_height))
                            esp.health.Color = ESP_SETTINGS.health.low_color:lerp(ESP_SETTINGS.health.high_color, humanoid.Health / humanoid.MaxHealth)
                            esp.health.Transparency = ESP_SETTINGS.health.transparency
                        else
                            esp.health_outline.Visible = false
                            esp.health.Visible = false
                        end

                        if ESP_SETTINGS.distance.show then
                            esp.distance.Text = string.format("%.0fm", distance)
                            esp.distance.Position = Vector2.new(center_x, foot_pos.Y + 6)
                            esp.distance.Visible = true
                            esp.distance.Color = ESP_SETTINGS.distance.color
                            esp.distance.Size = ESP_SETTINGS.distance.font_size
                            esp.distance.Font = ESP_SETTINGS.distance.font
                            esp.distance.Transparency = ESP_SETTINGS.distance.transparency
                        else
                            esp.distance.Visible = false
                        end

                        if ESP_SETTINGS.skeletons.show then
                            local bones = get_bones(character)
                            if #esp.skeleton_lines == 0 then
                                for _, bone_pair in ipairs(bones) do
                                    local parent_bone, child_bone = bone_pair[1], bone_pair[2]
                                    if character:FindFirstChild(parent_bone) and character:FindFirstChild(child_bone) then
                                        local skeleton_line = create("Line", {
                                            Thickness = ESP_SETTINGS.skeletons.thickness,
                                            Color = ESP_SETTINGS.skeletons.color,
                                            Transparency = ESP_SETTINGS.skeletons.transparency,
                                            Visible = false
                                        })
                                        table.insert(esp.skeleton_lines, {skeleton_line, parent_bone, child_bone})
                                    end
                                end
                            end

                            for _, line_data in ipairs(esp.skeleton_lines) do
                                local skeleton_line = line_data[1]
                                local parent_bone, child_bone = line_data[2], line_data[3]
                                if character:FindFirstChild(parent_bone) and character:FindFirstChild(child_bone) then
                                    local parent_pos = camera:WorldToViewportPoint(character[parent_bone].Position)
                                    local child_pos = camera:WorldToViewportPoint(character[child_bone].Position)
                                    skeleton_line.From = Vector2.new(parent_pos.X, parent_pos.Y)
                                    skeleton_line.To = Vector2.new(child_pos.X, child_pos.Y)
                                    skeleton_line.Color = ESP_SETTINGS.skeletons.color
                                    skeleton_line.Visible = true
                                    skeleton_line.Transparency = ESP_SETTINGS.skeletons.transparency
                                end
                            end
                        end
                        if not ESP_SETTINGS.skeletons.show then
                            for _, line_data in ipairs(esp.skeleton_lines) do
                                if line_data[1] then line_data[1].Visible = false end
                            end
                        end

                        if ESP_SETTINGS.tracer.show then
                            local tracer_y = camera.ViewportSize.Y
                            esp.tracer.Visible = true
                            esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, tracer_y)
                            esp.tracer.To = Vector2.new(center_x, center_y)
                            esp.tracer.Transparency = ESP_SETTINGS.tracer.transparency
                        else
                            esp.tracer.Visible = false
                        end

                        if ESP_SETTINGS.lookat.show then
                            esp.lookat_line.Visible = true
                            esp.lookat_line.From = Vector2.new(head_pos.X, head_pos.Y)
                            esp.lookat_line.To = Vector2.new(lookat_end.X, lookat_end.Y)
                            esp.lookat_line.Transparency = ESP_SETTINGS.lookat.transparency
                        else
                            esp.lookat_line.Visible = false
                        end

                        if ESP_SETTINGS.head_circle.show then
                            local radius_2d = (camera:WorldToViewportPoint(head.Position + head.CFrame.RightVector * ESP_SETTINGS.head_circle.radius)).X - head_pos.X
                            local angle_step = 2 * math.pi / ESP_SETTINGS.head_circle.sides
                            for i = 1, ESP_SETTINGS.head_circle.sides do
                                local angle1 = (i - 1) * angle_step
                                local angle2 = i * angle_step
                                local p1 = Vector2.new(head_pos.X + math.cos(angle1) * radius_2d, head_pos.Y + math.sin(angle1) * radius_2d)
                                local p2 = Vector2.new(head_pos.X + math.cos(angle2) * radius_2d, head_pos.Y + math.sin(angle2) * radius_2d)
                                local line = esp.head_circle_lines[i]
                                line.From = p1
                                line.To = p2
                                line.Visible = true
                                line.Transparency = ESP_SETTINGS.head_circle.transparency
                            end
                        else
                            for _, line in ipairs(esp.head_circle_lines) do line.Visible = false end
                        end

                    else
                        if ESP_SETTINGS.offscreen.show then
                            local screen_center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                            local direction = (Vector2.new(position.X, position.Y) - screen_center).Unit
                            local angle = math.atan2(direction.Y, direction.X)
                            local clamped_pos = screen_center + direction * math.min(ESP_SETTINGS.offscreen.size * 4, 120)
                            
                            local arrow_size = ESP_SETTINGS.offscreen.size
                            local base_points = {
                                Vector2.new(0, 0),
                                Vector2.new(-arrow_size * 0.3, arrow_size * 0.8),
                                Vector2.new(arrow_size * 0.3, arrow_size * 0.8)
                            }
                            
                            local rotated_points = {}
                            for _, p in ipairs(base_points) do
                                local cos_a = math.cos(angle + math.pi / 2)
                                local sin_a = math.sin(angle + math.pi / 2)
                                local dx = p.X * cos_a - p.Y * sin_a
                                local dy = p.X * sin_a + p.Y * cos_a
                                table.insert(rotated_points, clamped_pos + Vector2.new(dx, dy))
                            end
                            
                            esp.arrow_outline.PointA = rotated_points[1]
                            esp.arrow_outline.PointB = rotated_points[2]
                            esp.arrow_outline.PointC = rotated_points[3]
                            esp.arrow_outline.PointD = rotated_points[1]
                            esp.arrow_outline.Color = ESP_SETTINGS.offscreen.color
                            esp.arrow_outline.Transparency = ESP_SETTINGS.offscreen.transparency
                            esp.arrow_outline.Visible = true
                            
                            esp.arrow.PointA = rotated_points[1]
                            esp.arrow.PointB = rotated_points[2]
                            esp.arrow.PointC = rotated_points[3]
                            esp.arrow.PointD = rotated_points[1]
                            esp.arrow.Color = ESP_SETTINGS.offscreen.color
                            esp.arrow.Transparency = ESP_SETTINGS.offscreen.transparency
                            esp.arrow.Visible = true
                        else
                            esp.arrow_outline.Visible = false
                            esp.arrow.Visible = false
                        end

                        esp.box_outline.Visible = false
                        esp.box.Visible = false
                        esp.name.Visible = false
                        esp.health_outline.Visible = false
                        esp.health.Visible = false
                        esp.distance.Visible = false
                        esp.tracer.Visible = false
                        esp.lookat_line.Visible = false
                        for _, line in ipairs(esp.box_lines) do line.Visible = false end
                        for _, line in ipairs(esp.box_3d_lines) do line.Visible = false end
                        for _, line in ipairs(esp.head_circle_lines) do line.Visible = false end
                        for _, line_data in ipairs(esp.skeleton_lines) do
                            if line_data[1] then line_data[1].Visible = false end
                        end
                        esp.cham.Parent = nil
                        esp.cham.Enabled = false
                    end
                else
                    recursive_hide(esp, esp.cham)
                    esp.cham.Parent = nil
                    esp.cham.Enabled = false
                end
            else
                local esp = cache[player]
                if esp then
                    recursive_hide(esp, esp.cham)
                    esp.cham.Parent = nil
                    esp.cham.Enabled = false
                end
            end
        end
    end
end

cleanup()

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        create_esp(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        create_esp(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    remove_esp(player)
end)

connections.render = RunService.RenderStepped:Connect(update_esp)

print("RMonnesy Esp Library V1.1 Working - AdvanceFalling Team")
return ESP_SETTINGS
