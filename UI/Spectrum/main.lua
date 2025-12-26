for i, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "UiLib" then
        v:Destroy()
    end
end

local ui_lib = Instance.new("ScreenGui")
ui_lib.Name = "UiLib"
ui_lib.Parent = game:GetService("CoreGui")
ui_lib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui_lib.ResetOnSpawn = false

local user_input_service = game:GetService("UserInputService")
local is_mobile = user_input_service.TouchEnabled
local is_tablet = user_input_service.TouchEnabled and not user_input_service.MouseEnabled

local function get_next_window_pos()
    local biggest = 0
    local last_window = nil
    for _, v in pairs(ui_lib:GetChildren()) do
        if v:IsA("Frame") and v.Position.X.Offset > biggest then
            biggest = v.Position.X.Offset
            last_window = v
        end
    end
    if biggest == 0 then
        biggest = biggest + 15
    else
        biggest = biggest + last_window.Size.X.Offset + 10
    end
    return biggest
end

local Library = {}
local library = Library

function Library:Window(title)
    local base_width = is_mobile and 220 or 280
    local base_height = is_mobile and 35 or 40
    local content_height = is_mobile and 350 or 400
    
    local window_frame = Instance.new("Frame")
    local window_corner = Instance.new("UICorner")
    local container_scroll = Instance.new("ScrollingFrame")
    local container_layout = Instance.new("UIListLayout")
    local window_title = Instance.new("TextLabel")
    local close_button = Instance.new("TextButton")
    local window_shadow = Instance.new("ImageLabel")
    local window_background = Instance.new("Frame")
    local background_corner = Instance.new("UICorner")
    local resize_handle = Instance.new("TextButton")

    window_frame.Name = "WindowFrame"
    window_frame.Parent = ui_lib
    window_frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    window_frame.BorderSizePixel = 0
    window_frame.Position = UDim2.new(0, get_next_window_pos(), 0.01, 0)
    window_frame.Size = UDim2.new(0, base_width, 0, base_height)
    window_frame.Active = true
    window_frame.Draggable = true

    window_corner.CornerRadius = UDim.new(0, 8)
    window_corner.Parent = window_frame

    window_background.Name = "WindowBackground"
    window_background.Parent = window_frame
    window_background.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    window_background.BorderSizePixel = 0
    window_background.Size = UDim2.new(1, 0, 1, content_height)
    window_background.ZIndex = -1
    
    background_corner.CornerRadius = UDim.new(0, 8)
    background_corner.Parent = window_background

    window_shadow.Name = "WindowShadow"
    window_shadow.Parent = window_frame
    window_shadow.BackgroundTransparency = 1
    window_shadow.Position = UDim2.new(0, -15, 0, -15)
    window_shadow.Size = UDim2.new(1, 30, 1, content_height + 30)
    window_shadow.Image = "rbxassetid://5554236805"
    window_shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    window_shadow.ImageTransparency = 0.8
    window_shadow.ScaleType = Enum.ScaleType.Slice
    window_shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    window_shadow.ZIndex = -1

    container_scroll.Name = "ContainerScroll"
    container_scroll.Parent = window_frame
    container_scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    container_scroll.BackgroundTransparency = 1
    container_scroll.ClipsDescendants = true
    container_scroll.Position = UDim2.new(0, 0, 1, 0)
    container_scroll.Size = UDim2.new(1, 0, 0, content_height)
    container_scroll.ZIndex = 2
    container_scroll.ScrollBarThickness = is_mobile and 5 or 3
    container_scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    container_scroll.ScrollBarImageTransparency = 0.6
    container_scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    container_layout.Parent = container_scroll
    container_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    container_layout.SortOrder = Enum.SortOrder.LayoutOrder
    container_layout.Padding = UDim.new(0, is_mobile and 6 or 8)
    container_layout.VerticalAlignment = Enum.VerticalAlignment.Top

    window_title.Name = "WindowTitle"
    window_title.Parent = window_frame
    window_title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    window_title.BackgroundTransparency = 1
    window_title.Position = UDim2.new(0.05, 0, 0, 0)
    window_title.Size = UDim2.new(0.7, 0, 1, 0)
    window_title.Font = Enum.Font.GothamSemibold
    window_title.Text = title
    window_title.TextColor3 = Color3.fromRGB(240, 240, 240)
    window_title.TextSize = is_mobile and 13 or 15
    window_title.TextWrapped = true
    window_title.TextXAlignment = Enum.TextXAlignment.Left

    close_button.Name = "CloseButton"
    close_button.Parent = window_frame
    close_button.BackgroundTransparency = 1
    close_button.Position = UDim2.new(0.85, 0, 0.15, 0)
    close_button.Size = UDim2.new(0, is_mobile and 22 or 24, 0, is_mobile and 22 or 24)
    close_button.ZIndex = 2
    close_button.Font = Enum.Font.GothamBold
    close_button.Text = "−"
    close_button.TextColor3 = Color3.fromRGB(200, 200, 200)
    close_button.TextSize = is_mobile and 16 or 18
    close_button.AutoButtonColor = false

    local is_container_open = true

    local function toggle_container()
        is_container_open = not is_container_open
        if is_container_open then
            close_button.Text = "−"
            game:GetService("TweenService"):Create(close_button, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(200, 200, 200),
                Rotation = 0
            }):Play()
            container_scroll:TweenSize(UDim2.new(1, 0, 0, content_height), "Out", "Quad", 0.2, true)
            game:GetService("TweenService"):Create(window_background, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 1, content_height)
            }):Play()
            game:GetService("TweenService"):Create(window_shadow, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 30, 1, content_height + 30)
            }):Play()
        else
            close_button.Text = "+"
            game:GetService("TweenService"):Create(close_button, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(150, 150, 150),
                Rotation = 0
            }):Play()
            container_scroll:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
            game:GetService("TweenService"):Create(window_background, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 0, 1, 0)
            }):Play()
            game:GetService("TweenService"):Create(window_shadow, TweenInfo.new(0.2), {
                Size = UDim2.new(1, 30, 1, 30)
            }):Play()
        end
    end

    close_button.MouseButton1Click:Connect(toggle_container)
    close_button.TouchTap:Connect(toggle_container)

    container_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container_scroll.CanvasSize = UDim2.new(0, 0, 0, container_layout.AbsoluteContentSize.Y + 10)
    end)

    resize_handle.Name = "ResizeHandle"
    resize_handle.Parent = window_frame
    resize_handle.BackgroundTransparency = 1
    resize_handle.Position = UDim2.new(1, -15, 1, -15)
    resize_handle.Size = UDim2.new(0, 15, 0, 15)
    resize_handle.Text = ""
    resize_handle.ZIndex = 10

    local resize_icon = Instance.new("ImageLabel")
    resize_icon.Name = "ResizeIcon"
    resize_icon.Parent = resize_handle
    resize_icon.BackgroundTransparency = 1
    resize_icon.Size = UDim2.new(1, 0, 1, 0)
    resize_icon.Image = "rbxassetid://9753924245"
    resize_icon.ImageColor3 = Color3.fromRGB(100, 100, 100)
    resize_icon.ImageTransparency = 0.7

    local resizing = false
    local start_pos
    local start_size
    local min_width = is_mobile and 180 or 220
    local min_height = is_mobile and 100 or 150
    local max_width = 500
    local max_height = 600

    resize_handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            start_pos = input.Position
            start_size = window_frame.Size
            game:GetService("TweenService"):Create(resize_icon, TweenInfo.new(0.1), {
                ImageColor3 = Color3.fromRGB(200, 200, 200)
            }):Play()
        end
    end)

    resize_handle.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and resizing then
            resizing = false
            game:GetService("TweenService"):Create(resize_icon, TweenInfo.new(0.1), {
                ImageColor3 = Color3.fromRGB(100, 100, 100)
            }):Play()
        end
    end)

    user_input_service.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - start_pos
            local new_width = math.clamp(start_size.X.Offset + delta.X, min_width, max_width)
            local new_height = math.clamp(start_size.Y.Offset + delta.Y, min_height, max_height)
            
            window_frame.Size = UDim2.new(0, new_width, 0, new_height)
            
            if is_container_open then
                container_scroll.Size = UDim2.new(1, 0, 0, content_height)
                window_background.Size = UDim2.new(1, 0, 1, content_height)
                window_shadow.Size = UDim2.new(1, 30, 1, content_height + 30)
            end
        end
    end)

    local window_methods = {}

    function window_methods:button(name, callback)
        local button_height = is_mobile and 34 or 36
        
        local button_container = Instance.new("Frame")
        local button_corner = Instance.new("UICorner")
        local button = Instance.new("TextButton")
        local button_name = Instance.new("TextLabel")
        
        button_container.Name = "ButtonContainer"
        button_container.Parent = container_scroll
        button_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        button_container.BorderSizePixel = 0
        button_container.Size = UDim2.new(0.9, 0, 0, button_height)
        
        button_corner.CornerRadius = UDim.new(0, 6)
        button_corner.Parent = button_container
        
        button.Name = "Button"
        button.Parent = button_container
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundTransparency = 1
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Font = Enum.Font.SourceSans
        button.Text = ""
        button.TextColor3 = Color3.fromRGB(0, 0, 0)
        button.TextSize = 14
        button.AutoButtonColor = false
        
        button_name.Name = "ButtonName"
        button_name.Parent = button_container
        button_name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button_name.BackgroundTransparency = 1
        button_name.Size = UDim2.new(1, 0, 1, 0)
        button_name.Font = Enum.Font.Gotham
        button_name.Text = name
        button_name.TextColor3 = Color3.fromRGB(220, 220, 220)
        button_name.TextSize = is_mobile and 12 or 13
        
        local function on_hover()
            game:GetService("TweenService"):Create(button_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            }):Play()
        end
        
        local function off_hover()
            game:GetService("TweenService"):Create(button_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
        end
        
        button.MouseEnter:Connect(on_hover)
        button.MouseLeave:Connect(off_hover)
        
        local function on_click()
            game:GetService("TweenService"):Create(button_container, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            }):Play()
            task.wait(0.1)
            game:GetService("TweenService"):Create(button_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
            callback()
        end
        
        button.MouseButton1Click:Connect(on_click)
        button.TouchTap:Connect(on_click)
        
        button_container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                on_hover()
            end
        end)
        
        button_container.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                off_hover()
            end
        end)
    end
    
    function window_methods:toggle(name, callback)
        local toggle_height = is_mobile and 34 or 36
        
        local toggle_container = Instance.new("Frame")
        local toggle_corner = Instance.new("UICorner")
        local toggle_name = Instance.new("TextLabel")
        local toggle_button = Instance.new("TextButton")
        local toggle_button_corner = Instance.new("UICorner")
        local toggle_indicator = Instance.new("Frame")
        local indicator_corner = Instance.new("UICorner")
        
        toggle_container.Name = "ToggleContainer"
        toggle_container.Parent = container_scroll
        toggle_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        toggle_container.BorderSizePixel = 0
        toggle_container.Size = UDim2.new(0.9, 0, 0, toggle_height)
        
        toggle_corner.CornerRadius = UDim.new(0, 6)
        toggle_corner.Parent = toggle_container
        
        toggle_name.Name = "ToggleName"
        toggle_name.Parent = toggle_container
        toggle_name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggle_name.BackgroundTransparency = 1
        toggle_name.Position = UDim2.new(0.05, 0, 0, 0)
        toggle_name.Size = UDim2.new(0.65, 0, 1, 0)
        toggle_name.Font = Enum.Font.Gotham
        toggle_name.Text = name
        toggle_name.TextColor3 = Color3.fromRGB(220, 220, 220)
        toggle_name.TextSize = is_mobile and 12 or 13
        toggle_name.TextXAlignment = Enum.TextXAlignment.Left
        
        toggle_button.Name = "ToggleButton"
        toggle_button.Parent = toggle_container
        toggle_button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggle_button.Position = UDim2.new(0.78, 0, 0.22, 0)
        toggle_button.Size = UDim2.new(0, is_mobile and 36 or 40, 0, is_mobile and 18 or 20)
        toggle_button.AutoButtonColor = false
        toggle_button.Font = Enum.Font.SourceSans
        toggle_button.Text = ""
        toggle_button.TextColor3 = Color3.fromRGB(0, 0, 0)
        toggle_button.TextSize = 14
        
        toggle_button_corner.CornerRadius = UDim.new(1, 0)
        toggle_button_corner.Parent = toggle_button
        
        toggle_indicator.Name = "ToggleIndicator"
        toggle_indicator.Parent = toggle_button
        toggle_indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        toggle_indicator.BorderSizePixel = 0
        toggle_indicator.Position = UDim2.new(0.05, 0, 0.1, 0)
        toggle_indicator.Size = UDim2.new(0, is_mobile and 14 or 16, 0, is_mobile and 14 or 16)
        
        indicator_corner.CornerRadius = UDim.new(1, 0)
        indicator_corner.Parent = toggle_indicator
        
        local is_toggled = false
        
        local function toggle_state()
            is_toggled = not is_toggled
            if is_toggled then
                game:GetService("TweenService"):Create(toggle_indicator, TweenInfo.new(0.2), {
                    Position = UDim2.new(0.55, 0, 0.1, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 180, 255)
                }):Play()
                game:GetService("TweenService"):Create(toggle_button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(0, 100, 150)
                }):Play()
            else
                game:GetService("TweenService"):Create(toggle_indicator, TweenInfo.new(0.2), {
                    Position = UDim2.new(0.05, 0, 0.1, 0),
                    BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                }):Play()
                game:GetService("TweenService"):Create(toggle_button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                }):Play()
            end
            callback(is_toggled)
        end
        
        toggle_button.MouseButton1Click:Connect(toggle_state)
        toggle_button.TouchTap:Connect(toggle_state)
        
        toggle_container.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(toggle_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            }):Play()
        end)
        
        toggle_container.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(toggle_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
        end)
        
        toggle_container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                game:GetService("TweenService"):Create(toggle_container, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                }):Play()
            end
        end)
        
        toggle_container.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                game:GetService("TweenService"):Create(toggle_container, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                }):Play()
            end
        end)
    end
    
    function window_methods:slider(name, min_value, max_value, default_value, callback)
        local slider_height = is_mobile and 44 or 48
        
        local slider_container = Instance.new("Frame")
        local slider_corner = Instance.new("UICorner")
        local slider_name = Instance.new("TextLabel")
        local slider_value = Instance.new("TextLabel")
        local slider_track = Instance.new("Frame")
        local track_corner = Instance.new("UICorner")
        local slider_fill = Instance.new("Frame")
        local fill_corner = Instance.new("UICorner")
        local slider_button = Instance.new("TextButton")
        
        slider_container.Name = "SliderContainer"
        slider_container.Parent = container_scroll
        slider_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        slider_container.BorderSizePixel = 0
        slider_container.Size = UDim2.new(0.9, 0, 0, slider_height)
        
        slider_corner.CornerRadius = UDim.new(0, 6)
        slider_corner.Parent = slider_container
        
        slider_name.Name = "SliderName"
        slider_name.Parent = slider_container
        slider_name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        slider_name.BackgroundTransparency = 1
        slider_name.Position = UDim2.new(0.05, 0, 0, 0)
        slider_name.Size = UDim2.new(0.6, 0, 0, 20)
        slider_name.Font = Enum.Font.Gotham
        slider_name.Text = name
        slider_name.TextColor3 = Color3.fromRGB(220, 220, 220)
        slider_name.TextSize = is_mobile and 12 or 13
        slider_name.TextXAlignment = Enum.TextXAlignment.Left
        
        slider_value.Name = "SliderValue"
        slider_value.Parent = slider_container
        slider_value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        slider_value.BackgroundTransparency = 1
        slider_value.Position = UDim2.new(0.7, 0, 0, 0)
        slider_value.Size = UDim2.new(0.25, 0, 0, 20)
        slider_value.Font = Enum.Font.Gotham
        slider_value.Text = tostring(default_value)
        slider_value.TextColor3 = Color3.fromRGB(180, 180, 180)
        slider_value.TextSize = is_mobile and 12 or 13
        slider_value.TextXAlignment = Enum.TextXAlignment.Right
        
        slider_track.Name = "SliderTrack"
        slider_track.Parent = slider_container
        slider_track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        slider_track.BorderSizePixel = 0
        slider_track.Position = UDim2.new(0.05, 0, 0.6, 0)
        slider_track.Size = UDim2.new(0.9, 0, 0, 4)
        
        track_corner.CornerRadius = UDim.new(1, 0)
        track_corner.Parent = slider_track
        
        slider_fill.Name = "SliderFill"
        slider_fill.Parent = slider_track
        slider_fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        slider_fill.BorderSizePixel = 0
        slider_fill.Size = UDim2.new((default_value - min_value) / (max_value - min_value), 0, 1, 0)
        
        fill_corner.CornerRadius = UDim.new(1, 0)
        fill_corner.Parent = slider_fill
        
        slider_button.Name = "SliderButton"
        slider_button.Parent = slider_track
        slider_button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        slider_button.BorderSizePixel = 0
        slider_button.Position = UDim2.new((default_value - min_value) / (max_value - min_value), -8, 0, -6)
        slider_button.Size = UDim2.new(0, 16, 0, 16)
        slider_button.Font = Enum.Font.SourceSans
        slider_button.Text = ""
        slider_button.TextColor3 = Color3.fromRGB(0, 0, 0)
        slider_button.TextSize = 14
        slider_button.AutoButtonColor = false
        
        local button_corner = Instance.new("UICorner")
        button_corner.CornerRadius = UDim.new(1, 0)
        button_corner.Parent = slider_button
        
        local is_dragging = false
        local current_value = default_value
        
        local function update_slider(input)
            local relative_x = (input.Position.X - slider_track.AbsolutePosition.X) / slider_track.AbsoluteSize.X
            local clamped_x = math.clamp(relative_x, 0, 1)
            local pos = UDim2.new(clamped_x, 0, 0, 0)
            local value = math.floor(min_value + (clamped_x * (max_value - min_value)))
            
            slider_fill.Size = UDim2.new(pos.X.Scale, 0, 1, 0)
            slider_button.Position = UDim2.new(pos.X.Scale, -8, 0, -6)
            slider_value.Text = tostring(value)
            
            if value ~= current_value then
                current_value = value
                callback(value)
            end
        end
        
        local function start_dragging(input)
            is_dragging = true
            game:GetService("TweenService"):Create(slider_button, TweenInfo.new(0.15), {
                Size = UDim2.new(0, 20, 0, 20)
            }):Play()
        end
        
        local function stop_dragging()
            is_dragging = false
            game:GetService("TweenService"):Create(slider_button, TweenInfo.new(0.15), {
                Size = UDim2.new(0, 16, 0, 16)
            }):Play()
        end
        
        slider_button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                start_dragging(input)
            end
        end)
        
        slider_button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                stop_dragging()
            end
        end)
        
        slider_track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                update_slider(input)
                start_dragging(input)
            end
        end)
        
        slider_track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                stop_dragging()
            end
        end)
        
        user_input_service.InputChanged:Connect(function(input)
            if is_dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update_slider(input)
            end
        end)
        
        slider_container.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(slider_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            }):Play()
        end)
        
        slider_container.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(slider_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
        end)
    end
    
    function window_methods:dropdown(name, options, callback)
        local dropdown_height = is_mobile and 34 or 36
        
        local dropdown_container = Instance.new("Frame")
        local dropdown_corner = Instance.new("UICorner")
        local dropdown_name = Instance.new("TextLabel")
        local dropdown_button = Instance.new("TextButton")
        local dropdown_arrow = Instance.new("ImageLabel")
        local dropdown_selected = Instance.new("TextLabel")
        
        dropdown_container.Name = "DropdownContainer"
        dropdown_container.Parent = container_scroll
        dropdown_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        dropdown_container.BorderSizePixel = 0
        dropdown_container.Size = UDim2.new(0.9, 0, 0, dropdown_height)
        dropdown_container.ClipsDescendants = false
        
        dropdown_corner.CornerRadius = UDim.new(0, 6)
        dropdown_corner.Parent = dropdown_container
        
        dropdown_name.Name = "DropdownName"
        dropdown_name.Parent = dropdown_container
        dropdown_name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdown_name.BackgroundTransparency = 1
        dropdown_name.Position = UDim2.new(0.05, 0, 0, 0)
        dropdown_name.Size = UDim2.new(0.65, 0, 1, 0)
        dropdown_name.Font = Enum.Font.Gotham
        dropdown_name.Text = name
        dropdown_name.TextColor3 = Color3.fromRGB(220, 220, 220)
        dropdown_name.TextSize = is_mobile and 12 or 13
        dropdown_name.TextXAlignment = Enum.TextXAlignment.Left
        
        dropdown_button.Name = "DropdownButton"
        dropdown_button.Parent = dropdown_container
        dropdown_button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dropdown_button.Position = UDim2.new(0.7, 0, 0.22, 0)
        dropdown_button.Size = UDim2.new(0.25, 0, 0, is_mobile and 18 or 20)
        dropdown_button.Font = Enum.Font.SourceSans
        dropdown_button.Text = ""
        dropdown_button.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdown_button.TextSize = 12
        dropdown_button.AutoButtonColor = false
        
        local button_corner = Instance.new("UICorner")
        button_corner.CornerRadius = UDim.new(0, 4)
        button_corner.Parent = dropdown_button
        
        dropdown_selected.Name = "DropdownSelected"
        dropdown_selected.Parent = dropdown_button
        dropdown_selected.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdown_selected.BackgroundTransparency = 1
        dropdown_selected.Position = UDim2.new(0.05, 0, 0, 0)
        dropdown_selected.Size = UDim2.new(0.7, 0, 1, 0)
        dropdown_selected.Font = Enum.Font.Gotham
        dropdown_selected.Text = "Select"
        dropdown_selected.TextColor3 = Color3.fromRGB(200, 200, 200)
        dropdown_selected.TextSize = is_mobile and 10 or 11
        dropdown_selected.TextXAlignment = Enum.TextXAlignment.Left
        
        dropdown_arrow.Name = "DropdownArrow"
        dropdown_arrow.Parent = dropdown_button
        dropdown_arrow.BackgroundTransparency = 1
        dropdown_arrow.Position = UDim2.new(0.8, 0, 0.15, 0)
        dropdown_arrow.Size = UDim2.new(0, 12, 0, 12)
        dropdown_arrow.Image = "rbxassetid://153287088"
        dropdown_arrow.ImageColor3 = Color3.fromRGB(200, 200, 200)
        dropdown_arrow.Rotation = 90
        
        local dropdown_list = Instance.new("Frame")
        local dropdown_scroll = Instance.new("ScrollingFrame")
        local list_layout = Instance.new("UIListLayout")
        
        dropdown_list.Name = "DropdownList"
        dropdown_list.Parent = ui_lib
        dropdown_list.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        dropdown_list.BorderSizePixel = 0
        dropdown_list.Size = UDim2.new(0, dropdown_button.AbsoluteSize.X, 0, 0)
        dropdown_list.Visible = false
        dropdown_list.ZIndex = 20
        dropdown_list.ClipsDescendants = true
        
        local dropdown_shadow = Instance.new("ImageLabel")
        dropdown_shadow.Name = "DropdownShadow"
        dropdown_shadow.Parent = dropdown_list
        dropdown_shadow.BackgroundTransparency = 1
        dropdown_shadow.Size = UDim2.new(1, 15, 1, 15)
        dropdown_shadow.Position = UDim2.new(0, -8, 0, -8)
        dropdown_shadow.Image = "rbxassetid://5554236805"
        dropdown_shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        dropdown_shadow.ImageTransparency = 0.8
        dropdown_shadow.ScaleType = Enum.ScaleType.Slice
        dropdown_shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        dropdown_shadow.ZIndex = 19
        
        local list_corner = Instance.new("UICorner")
        list_corner.CornerRadius = UDim.new(0, 6)
        list_corner.Parent = dropdown_list
        
        dropdown_scroll.Name = "DropdownScroll"
        dropdown_scroll.Parent = dropdown_list
        dropdown_scroll.Active = true
        dropdown_scroll.BackgroundTransparency = 1
        dropdown_scroll.BorderSizePixel = 0
        dropdown_scroll.Size = UDim2.new(1, -6, 1, -6)
        dropdown_scroll.Position = UDim2.new(0, 3, 0, 3)
        dropdown_scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        dropdown_scroll.ScrollBarThickness = is_mobile and 5 or 3
        dropdown_scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        dropdown_scroll.ScrollBarImageTransparency = 0.3
        dropdown_scroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
        dropdown_scroll.ZIndex = 21
        
        list_layout.Parent = dropdown_scroll
        list_layout.SortOrder = Enum.SortOrder.LayoutOrder
        list_layout.Padding = UDim.new(0, 3)
        
        local is_open = false
        local selected_option = nil
        
        local function update_list_height()
            local item_count = #options
            local height = math.min(item_count * (is_mobile and 26 or 28) + 6, 140)
            dropdown_scroll.CanvasSize = UDim2.new(0, 0, 0, item_count * (is_mobile and 26 or 28))
            return height
        end
        
        local function toggle_dropdown()
            is_open = not is_open
            if is_open then
                dropdown_list.Visible = true
                dropdown_list.Position = UDim2.new(
                    0, dropdown_button.AbsolutePosition.X,
                    0, dropdown_button.AbsolutePosition.Y + dropdown_button.AbsoluteSize.Y + 4
                )
                dropdown_list.Size = UDim2.new(0, dropdown_button.AbsoluteSize.X, 0, 0)
                game:GetService("TweenService"):Create(dropdown_arrow, TweenInfo.new(0.2), {
                    Rotation = 270
                }):Play()
                game:GetService("TweenService"):Create(dropdown_button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                }):Play()
                dropdown_list:TweenSize(
                    UDim2.new(0, dropdown_button.AbsoluteSize.X, 0, update_list_height()),
                    "Out", "Quad", 0.2, true
                )
            else
                game:GetService("TweenService"):Create(dropdown_arrow, TweenInfo.new(0.2), {
                    Rotation = 90
                }):Play()
                game:GetService("TweenService"):Create(dropdown_button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                }):Play()
                dropdown_list:TweenSize(
                    UDim2.new(0, dropdown_button.AbsoluteSize.X, 0, 0),
                    "Out", "Quad", 0.2, true,
                    function()
                        dropdown_list.Visible = false
                    end
                )
            end
        end
        
        dropdown_button.MouseButton1Click:Connect(toggle_dropdown)
        dropdown_button.TouchTap:Connect(toggle_dropdown)
        
        for i, option in ipairs(options) do
            local option_button = Instance.new("TextButton")
            local option_text = Instance.new("TextLabel")
            
            option_button.Name = "Option_" .. option
            option_button.Parent = dropdown_scroll
            option_button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            option_button.BorderSizePixel = 0
            option_button.Size = UDim2.new(1, 0, 0, is_mobile and 24 or 26)
            option_button.Font = Enum.Font.SourceSans
            option_button.Text = ""
            option_button.TextColor3 = Color3.fromRGB(0, 0, 0)
            option_button.TextSize = 14
            option_button.AutoButtonColor = false
            option_button.ZIndex = 22
            
            local option_corner = Instance.new("UICorner")
            option_corner.CornerRadius = UDim.new(0, 4)
            option_corner.Parent = option_button
            
            option_text.Name = "OptionText"
            option_text.Parent = option_button
            option_text.BackgroundTransparency = 1
            option_text.Size = UDim2.new(1, -8, 1, 0)
            option_text.Position = UDim2.new(0, 4, 0, 0)
            option_text.Font = Enum.Font.Gotham
            option_text.Text = option
            option_text.TextColor3 = Color3.fromRGB(220, 220, 220)
            option_text.TextSize = is_mobile and 10 or 11
            option_text.TextXAlignment = Enum.TextXAlignment.Left
            option_text.ZIndex = 24
            
            local function select_option()
                selected_option = option
                dropdown_selected.Text = option
                toggle_dropdown()
                callback(option)
            end
            
            option_button.MouseButton1Click:Connect(select_option)
            option_button.TouchTap:Connect(select_option)
            
            option_button.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(option_button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                }):Play()
            end)
            
            option_button.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(option_button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                }):Play()
            end)
            
            option_button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    game:GetService("TweenService"):Create(option_button, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    }):Play()
                end
            end)
            
            option_button.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    game:GetService("TweenService"):Create(option_button, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    }):Play()
                end
            end)
        end
        
        update_list_height()
        
        local connection
        connection = user_input_service.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and is_open then
                local mouse_pos = user_input_service:GetMouseLocation()
                local dropdown_pos = dropdown_list.AbsolutePosition
                local dropdown_size = dropdown_list.AbsoluteSize
                
                if not (mouse_pos.X >= dropdown_pos.X and mouse_pos.X <= dropdown_pos.X + dropdown_size.X and
                       mouse_pos.Y >= dropdown_pos.Y and mouse_pos.Y <= dropdown_pos.Y + dropdown_size.Y) then
                    if is_open then
                        toggle_dropdown()
                    end
                end
            end
        end)
        
        window_frame.Destroying:Connect(function()
            if connection then
                connection:Disconnect()
            end
        end)
        
        dropdown_container.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(dropdown_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            }):Play()
        end)
        
        dropdown_container.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(dropdown_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
        end)
    end
    
    function window_methods:colorpicker(name, default_color, callback)
        local colorpicker_height = is_mobile and 34 or 36
        
        local colorpicker_container = Instance.new("Frame")
        local colorpicker_corner = Instance.new("UICorner")
        local colorpicker_name = Instance.new("TextLabel")
        local color_button = Instance.new("TextButton")
        local color_preview = Instance.new("Frame")
        local preview_corner = Instance.new("UICorner")
        
        colorpicker_container.Name = "ColorpickerContainer"
        colorpicker_container.Parent = container_scroll
        colorpicker_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        colorpicker_container.BorderSizePixel = 0
        colorpicker_container.Size = UDim2.new(0.9, 0, 0, colorpicker_height)
        
        colorpicker_corner.CornerRadius = UDim.new(0, 6)
        colorpicker_corner.Parent = colorpicker_container
        
        colorpicker_name.Name = "ColorpickerName"
        colorpicker_name.Parent = colorpicker_container
        colorpicker_name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        colorpicker_name.BackgroundTransparency = 1
        colorpicker_name.Position = UDim2.new(0.05, 0, 0, 0)
        colorpicker_name.Size = UDim2.new(0.65, 0, 1, 0)
        colorpicker_name.Font = Enum.Font.Gotham
        colorpicker_name.Text = name
        colorpicker_name.TextColor3 = Color3.fromRGB(220, 220, 220)
        colorpicker_name.TextSize = is_mobile and 12 or 13
        colorpicker_name.TextXAlignment = Enum.TextXAlignment.Left
        
        color_button.Name = "ColorButton"
        color_button.Parent = colorpicker_container
        color_button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        color_button.Position = UDim2.new(0.7, 0, 0.22, 0)
        color_button.Size = UDim2.new(0.25, 0, 0, is_mobile and 18 or 20)
        color_button.Font = Enum.Font.SourceSans
        color_button.Text = ""
        color_button.TextColor3 = Color3.fromRGB(0, 0, 0)
        color_button.TextSize = 14
        color_button.AutoButtonColor = false
        
        local button_corner = Instance.new("UICorner")
        button_corner.CornerRadius = UDim.new(0, 4)
        button_corner.Parent = color_button
        
        color_preview.Name = "ColorPreview"
        color_preview.Parent = color_button
        color_preview.BackgroundColor3 = default_color or Color3.fromRGB(0, 180, 255)
        color_preview.BorderSizePixel = 0
        color_preview.Position = UDim2.new(0.1, 0, 0.1, 0)
        color_preview.Size = UDim2.new(0.8, 0, 0, is_mobile and 14 or 16)
        
        preview_corner.CornerRadius = UDim.new(0, 3)
        preview_corner.Parent = color_preview
        
        local color_picker_frame = nil
        
        local function show_color_picker()
            if color_picker_frame then
                color_picker_frame:Destroy()
                color_picker_frame = nil
                return
            end
            
            color_picker_frame = Instance.new("Frame")
            local frame_corner = Instance.new("UICorner")
            local color_display = Instance.new("Frame")
            local display_corner = Instance.new("UICorner")
            local hex_input = Instance.new("TextBox")
            local hex_corner = Instance.new("UICorner")
            local apply_button = Instance.new("TextButton")
            local apply_corner = Instance.new("UICorner")
            
            local current_color = color_preview.BackgroundColor3
            local r, g, b = math.floor(current_color.r * 255), math.floor(current_color.g * 255), math.floor(current_color.b * 255)
            
            color_picker_frame.Name = "ColorPickerFrame"
            color_picker_frame.Parent = ui_lib
            color_picker_frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            color_picker_frame.BorderSizePixel = 0
            color_picker_frame.Position = UDim2.new(0, 0, 0, 0)
            color_picker_frame.Size = UDim2.new(0, is_mobile and 200 or 220, 0, 0)
            color_picker_frame.ZIndex = 30
            color_picker_frame.ClipsDescendants = true
            
            frame_corner.CornerRadius = UDim.new(0, 8)
            frame_corner.Parent = color_picker_frame
            
            local color_picker_shadow = Instance.new("ImageLabel")
            color_picker_shadow.Name = "ColorPickerShadow"
            color_picker_shadow.Parent = color_picker_frame
            color_picker_shadow.BackgroundTransparency = 1
            color_picker_shadow.Size = UDim2.new(1, 20, 1, 20)
            color_picker_shadow.Position = UDim2.new(0, -10, 0, -10)
            color_picker_shadow.Image = "rbxassetid://5554236805"
            color_picker_shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            color_picker_shadow.ImageTransparency = 0.8
            color_picker_shadow.ScaleType = Enum.ScaleType.Slice
            color_picker_shadow.SliceCenter = Rect.new(23, 23, 277, 277)
            color_picker_shadow.ZIndex = 29
            
            color_display.Name = "ColorDisplay"
            color_display.Parent = color_picker_frame
            color_display.BackgroundColor3 = current_color
            color_display.BorderSizePixel = 0
            color_display.Position = UDim2.new(0.05, 0, 0.05, 0)
            color_display.Size = UDim2.new(0.9, 0, 0, 30)
            
            display_corner.CornerRadius = UDim.new(0, 6)
            display_corner.Parent = color_display
            
            hex_input.Name = "HexInput"
            hex_input.Parent = color_picker_frame
            hex_input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            hex_input.BorderSizePixel = 0
            hex_input.Position = UDim2.new(0.05, 0, 0.25, 0)
            hex_input.Size = UDim2.new(0.9, 0, 0, 25)
            hex_input.Font = Enum.Font.Gotham
            hex_input.PlaceholderText = "Hex Color"
            hex_input.Text = string.format("#%02X%02X%02X", r, g, b)
            hex_input.TextColor3 = Color3.fromRGB(220, 220, 220)
            hex_input.TextSize = 12
            hex_input.ClearTextOnFocus = false
            
            hex_corner.CornerRadius = UDim.new(0, 4)
            hex_corner.Parent = hex_input
            
            local hex_padding = Instance.new("UIPadding")
            hex_padding.Parent = hex_input
            hex_padding.PaddingLeft = UDim.new(0, 8)
            hex_padding.PaddingRight = UDim.new(0, 8)
            
            local function create_rgb_slider(name, y_pos, value, color)
                local container = Instance.new("Frame")
                local name_label = Instance.new("TextLabel")
                local track = Instance.new("Frame")
                local fill = Instance.new("Frame")
                local button = Instance.new("TextButton")
                local value_label = Instance.new("TextLabel")
                
                container.Name = name .. "Container"
                container.Parent = color_picker_frame
                container.BackgroundTransparency = 1
                container.Position = UDim2.new(0.05, 0, y_pos, 0)
                container.Size = UDim2.new(0.9, 0, 0, 25)
                
                name_label.Name = name .. "Name"
                name_label.Parent = container
                name_label.BackgroundTransparency = 1
                name_label.Position = UDim2.new(0, 0, 0, 0)
                name_label.Size = UDim2.new(0.15, 0, 1, 0)
                name_label.Font = Enum.Font.Gotham
                name_label.Text = name
                name_label.TextColor3 = Color3.fromRGB(200, 200, 200)
                name_label.TextSize = 12
                name_label.TextXAlignment = Enum.TextXAlignment.Left
                
                track.Name = name .. "Track"
                track.Parent = container
                track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                track.BorderSizePixel = 0
                track.Position = UDim2.new(0.2, 0, 0.5, 0)
                track.Size = UDim2.new(0.55, 0, 0, 4)
                
                local track_corner = Instance.new("UICorner")
                track_corner.CornerRadius = UDim.new(1, 0)
                track_corner.Parent = track
                
                fill.Name = name .. "Fill"
                fill.Parent = track
                fill.BackgroundColor3 = color
                fill.BorderSizePixel = 0
                fill.Size = UDim2.new(value / 255, 0, 1, 0)
                
                local fill_corner = Instance.new("UICorner")
                fill_corner.CornerRadius = UDim.new(1, 0)
                fill_corner.Parent = fill
                
                button.Name = name .. "Button"
                button.Parent = track
                button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                button.BorderSizePixel = 0
                button.Position = UDim2.new(value / 255, -6, 0, -5)
                button.Size = UDim2.new(0, 14, 0, 14)
                button.Font = Enum.Font.SourceSans
                button.Text = ""
                button.TextColor3 = Color3.fromRGB(0, 0, 0)
                button.TextSize = 14
                button.AutoButtonColor = false
                
                local button_corner = Instance.new("UICorner")
                button_corner.CornerRadius = UDim.new(1, 0)
                button_corner.Parent = button
                
                value_label.Name = name .. "Value"
                value_label.Parent = container
                value_label.BackgroundTransparency = 1
                value_label.Position = UDim2.new(0.8, 0, 0, 0)
                value_label.Size = UDim2.new(0.2, 0, 1, 0)
                value_label.Font = Enum.Font.Gotham
                value_label.Text = tostring(value)
                value_label.TextColor3 = Color3.fromRGB(180, 180, 180)
                value_label.TextSize = 12
                value_label.TextXAlignment = Enum.TextXAlignment.Right
                
                return {container = container, track = track, fill = fill, button = button, value = value_label}
            end
            
            local r_data = create_rgb_slider("R", 0.4, r, Color3.fromRGB(255, 50, 50))
            local g_data = create_rgb_slider("G", 0.55, g, Color3.fromRGB(50, 255, 50))
            local b_data = create_rgb_slider("B", 0.7, b, Color3.fromRGB(50, 50, 255))
            
            apply_button.Name = "ApplyButton"
            apply_button.Parent = color_picker_frame
            apply_button.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
            apply_button.BorderSizePixel = 0
            apply_button.Position = UDim2.new(0.05, 0, 0.85, 0)
            apply_button.Size = UDim2.new(0.9, 0, 0, 25)
            apply_button.Font = Enum.Font.GothamSemibold
            apply_button.Text = "Apply"
            apply_button.TextColor3 = Color3.fromRGB(255, 255, 255)
            apply_button.TextSize = 13
            apply_button.AutoButtonColor = false
            
            apply_corner.CornerRadius = UDim.new(0, 6)
            apply_corner.Parent = apply_button
            
            local function update_color()
                current_color = Color3.fromRGB(r, g, b)
                color_display.BackgroundColor3 = current_color
                hex_input.Text = string.format("#%02X%02X%02X", r, g, b)
            end
            
            local function update_from_hex(hex)
                hex = hex:gsub("#", "")
                if #hex == 6 then
                    local success, color = pcall(function()
                        return Color3.fromHex(hex)
                    end)
                    if success then
                        r = math.floor(color.r * 255)
                        g = math.floor(color.g * 255)
                        b = math.floor(color.b * 255)
                        
                        r_data.fill.Size = UDim2.new(r / 255, 0, 1, 0)
                        r_data.button.Position = UDim2.new(r / 255, -6, 0, -5)
                        r_data.value.Text = tostring(r)
                        
                        g_data.fill.Size = UDim2.new(g / 255, 0, 1, 0)
                        g_data.button.Position = UDim2.new(g / 255, -6, 0, -5)
                        g_data.value.Text = tostring(g)
                        
                        b_data.fill.Size = UDim2.new(b / 255, 0, 1, 0)
                        b_data.button.Position = UDim2.new(b / 255, -6, 0, -5)
                        b_data.value.Text = tostring(b)
                        
                        update_color()
                    end
                end
            end
            
            hex_input.FocusLost:Connect(function(enter_pressed)
                if enter_pressed then
                    update_from_hex(hex_input.Text)
                end
            end)
            
            local function create_slider_logic(data, is_r, is_g, is_b)
                local is_dragging = false
                
                local function update_slider(input)
                    local relative_x = (input.Position.X - data.track.AbsolutePosition.X) / data.track.AbsoluteSize.X
                    local clamped_x = math.clamp(relative_x, 0, 1)
                    local value = math.floor(clamped_x * 255)
                    
                    data.fill.Size = UDim2.new(clamped_x, 0, 1, 0)
                    data.button.Position = UDim2.new(clamped_x, -6, 0, -5)
                    data.value.Text = tostring(value)
                    
                    if is_r then r = value
                    elseif is_g then g = value
                    elseif is_b then b = value end
                    
                    update_color()
                end
                
                local function start_dragging(input)
                    is_dragging = true
                    game:GetService("TweenService"):Create(data.button, TweenInfo.new(0.15), {
                        Size = UDim2.new(0, 18, 0, 18)
                    }):Play()
                end
                
                local function stop_dragging()
                    is_dragging = false
                    game:GetService("TweenService"):Create(data.button, TweenInfo.new(0.15), {
                        Size = UDim2.new(0, 14, 0, 14)
                    }):Play()
                end
                
                data.button.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        start_dragging(input)
                    end
                end)
                
                data.button.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        stop_dragging()
                    end
                end)
                
                data.track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        update_slider(input)
                        start_dragging(input)
                    end
                end)
                
                data.track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        stop_dragging()
                    end
                end)
                
                user_input_service.InputChanged:Connect(function(input)
                    if is_dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update_slider(input)
                    end
                end)
            end
            
            create_slider_logic(r_data, true, false, false)
            create_slider_logic(g_data, false, true, false)
            create_slider_logic(b_data, false, false, true)
            
            local function apply_color()
                callback(current_color)
                color_preview.BackgroundColor3 = current_color
                color_picker_frame:TweenSize(UDim2.new(0, is_mobile and 200 or 220, 0, 0), "Out", "Quad", 0.2, true, function()
                    color_picker_frame:Destroy()
                    color_picker_frame = nil
                end)
            end
            
            apply_button.MouseButton1Click:Connect(apply_color)
            apply_button.TouchTap:Connect(apply_color)
            
            apply_button.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(apply_button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(0, 160, 235)
                }):Play()
            end)
            
            apply_button.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(apply_button, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(0, 180, 255)
                }):Play()
            end)
            
            color_picker_frame:TweenSize(UDim2.new(0, is_mobile and 200 or 220, 0, 180), "Out", "Quad", 0.2, true)
            
            local close_connection
            close_connection = user_input_service.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and color_picker_frame then
                    local mouse_pos = user_input_service:GetMouseLocation()
                    local frame_pos = color_picker_frame.AbsolutePosition
                    local frame_size = color_picker_frame.AbsoluteSize
                    
                    if not (mouse_pos.X >= frame_pos.X and mouse_pos.X <= frame_pos.X + frame_size.X and
                           mouse_pos.Y >= frame_pos.Y and mouse_pos.Y <= frame_pos.Y + frame_size.Y) then
                        color_picker_frame:TweenSize(UDim2.new(0, is_mobile and 200 or 220, 0, 0), "Out", "Quad", 0.2, true, function()
                            color_picker_frame:Destroy()
                            color_picker_frame = nil
                            if close_connection then
                                close_connection:Disconnect()
                            end
                        end)
                    end
                end
            end)
            
            local button_pos = color_button.AbsolutePosition
            local button_size = color_button.AbsoluteSize
            local screen_size = game:GetService("Workspace").CurrentCamera.ViewportSize
            
            local right_space = screen_size.X - (button_pos.X + button_size.X)
            local left_space = button_pos.X
            
            if right_space > (is_mobile and 210 or 230) then
                color_picker_frame.Position = UDim2.new(0, button_pos.X + button_size.X + 10, 0, button_pos.Y)
            elseif left_space > (is_mobile and 210 or 230) then
                color_picker_frame.Position = UDim2.new(0, button_pos.X - (is_mobile and 210 or 230), 0, button_pos.Y)
            else
                color_picker_frame.Position = UDim2.new(0, button_pos.X, 0, button_pos.Y + button_size.Y + 10)
            end
        end
        
        color_button.MouseButton1Click:Connect(show_color_picker)
        color_button.TouchTap:Connect(show_color_picker)
        
        colorpicker_container.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(colorpicker_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            }):Play()
        end)
        
        colorpicker_container.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(colorpicker_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
        end)
    end
    
    function window_methods:textbox(name, placeholder, callback)
        local textbox_height = is_mobile and 52 or 56
        
        local textbox_container = Instance.new("Frame")
        local textbox_corner = Instance.new("UICorner")
        local textbox_name = Instance.new("TextLabel")
        local textbox_input = Instance.new("TextBox")
        local input_corner = Instance.new("UICorner")
        
        textbox_container.Name = "TextboxContainer"
        textbox_container.Parent = container_scroll
        textbox_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        textbox_container.BorderSizePixel = 0
        textbox_container.Size = UDim2.new(0.9, 0, 0, textbox_height)
        
        textbox_corner.CornerRadius = UDim.new(0, 6)
        textbox_corner.Parent = textbox_container
        
        textbox_name.Name = "TextboxName"
        textbox_name.Parent = textbox_container
        textbox_name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        textbox_name.BackgroundTransparency = 1
        textbox_name.Position = UDim2.new(0.05, 0, 0, 0)
        textbox_name.Size = UDim2.new(0.9, 0, 0, 20)
        textbox_name.Font = Enum.Font.Gotham
        textbox_name.Text = name
        textbox_name.TextColor3 = Color3.fromRGB(220, 220, 220)
        textbox_name.TextSize = is_mobile and 12 or 13
        textbox_name.TextXAlignment = Enum.TextXAlignment.Left
        
        textbox_input.Name = "TextboxInput"
        textbox_input.Parent = textbox_container
        textbox_input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        textbox_input.BorderSizePixel = 0
        textbox_input.Position = UDim2.new(0.05, 0, 0.45, 0)
        textbox_input.Size = UDim2.new(0.9, 0, 0, is_mobile and 26 or 28)
        textbox_input.Font = Enum.Font.Gotham
        textbox_input.PlaceholderText = placeholder or "Enter text..."
        textbox_input.Text = ""
        textbox_input.TextColor3 = Color3.fromRGB(220, 220, 220)
        textbox_input.TextSize = is_mobile and 11 or 12
        textbox_input.ClearTextOnFocus = false
        textbox_input.TextTruncate = Enum.TextTruncate.AtEnd
        
        input_corner.CornerRadius = UDim.new(0, 4)
        input_corner.Parent = textbox_input
        
        local text_padding = Instance.new("UIPadding")
        text_padding.Parent = textbox_input
        text_padding.PaddingLeft = UDim.new(0, 8)
        text_padding.PaddingRight = UDim.new(0, 8)
        
        textbox_input.Focused:Connect(function()
            game:GetService("TweenService"):Create(textbox_input, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)
        
        textbox_input.FocusLost:Connect(function(enter_pressed)
            game:GetService("TweenService"):Create(textbox_input, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            }):Play()
            if enter_pressed then
                callback(textbox_input.Text)
            end
        end)
        
        textbox_container.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(textbox_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            }):Play()
        end)
        
        textbox_container.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(textbox_container, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            }):Play()
        end)
    end
    
    function window_methods:label(text)
        local label_container = Instance.new("Frame")
        local label_corner = Instance.new("UICorner")
        local label_text = Instance.new("TextLabel")
        
        label_container.Name = "LabelContainer"
        label_container.Parent = container_scroll
        label_container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        label_container.BackgroundTransparency = 0
        label_container.Size = UDim2.new(0.9, 0, 0, is_mobile and 30 or 32)
        
        label_corner.CornerRadius = UDim.new(0, 6)
        label_corner.Parent = label_container
        
        label_text.Name = "LabelText"
        label_text.Parent = label_container
        label_text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        label_text.BackgroundTransparency = 1
        label_text.Size = UDim2.new(1, -10, 1, 0)
        label_text.Position = UDim2.new(0, 5, 0, 0)
        label_text.Font = Enum.Font.Gotham
        label_text.Text = text
        label_text.TextColor3 = Color3.fromRGB(180, 180, 180)
        label_text.TextSize = is_mobile and 11 or 12
        label_text.TextWrapped = true
    end
    
    function window_methods:separator()
        local separator_container = Instance.new("Frame")
        local separator_line = Instance.new("Frame")
        
        separator_container.Name = "SeparatorContainer"
        separator_container.Parent = container_scroll
        separator_container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        separator_container.BackgroundTransparency = 1
        separator_container.Size = UDim2.new(0.9, 0, 0, is_mobile and 8 or 10)
        
        separator_line.Name = "SeparatorLine"
        separator_line.Parent = separator_container
        separator_line.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        separator_line.BorderSizePixel = 0
        separator_line.Position = UDim2.new(0.1, 0, 0.5, 0)
        separator_line.Size = UDim2.new(0.8, 0, 0, 1)
    end
    
    return window_methods
end

return Library
