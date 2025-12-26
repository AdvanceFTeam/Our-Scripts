# Image
<img width="1088" height="580" alt="image" src="https://github.com/user-attachments/assets/dc3b11fd-1c85-4793-9964-9497c672266f" />


## Loadstring
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AdvanceFTeam/Our-Scripts/refs/heads/main/UI/Spectrum/main.lua"))()
```

## Creating Windows
```lua
-- Create multiple windows that automatically position themselves
local window1 = Library:Window("Main Window")
local window2 = Library:Window("Settings")
local window3 = Library:Window("Tools")
```

## Elements

### Button
```lua
window1:button("Click Me", function()
    print("Button was clicked!")
end)
```

### Toggle
```lua
window1:toggle("Toggle", function(state)
    print("Toggle:", state)
    if state then
        -- Toggle ON
    else
        -- Toggle OFF
    end
end)
```

### Slider
```lua
window1:slider("Slider", 0, 100, 50, function(value)
    print("Slider set to:", value)
    -- value is between min and max
end)
```

### Dropdown
```lua
window1:dropdown("Dropdown", {"Low", "Medium", "High", "Ultra", "Gay"}, function(selected)
    print("Selected:", selected)
    -- selected is the chosen option string
end)
```

### Color Picker
```lua
window1:colorpicker("Color", Color3.fromRGB(0, 170, 255), function(color)
    print("Selected color:", color)
    -- color is a Color3 value
end)
```

### Textbox
```lua
window1:textbox("Player Name", "Enter username", function(text)
    print("Entered text:", text)
    -- text is the input string
end)
```

### Label (Text Display)
```lua
window1:label("This is an information label")
window1:label("Supports multi-line text\nfor longer descriptions")
```

### Separator (Line)
```lua
window1:separator() -- Adds a thin line separator
```

## Complete Example
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AdvanceFTeam/Our-Scripts/refs/heads/main/UI/Spectrum/main.lua"))()

local main = Library:Window("Main")
local settings = Library:Window("Settings")

main:button("Teleport to Base", function()
    print("Teleporting...")
end)

main:toggle("Auto Farm", function(state)
    print("Auto Farm:", state)
end)

main:slider("Walk Speed", 16, 100, 16, function(value)
    print("Walk speed set to:", value)
end)

main:dropdown("Weapon", {"Sword", "Bow", "Staff", "Dagger"}, function(selected)
    print("Selected weapon:", selected)
end)

settings:label("Appearance Settings")
settings:separator()

settings:colorpicker("UI Color", Color3.fromRGB(0, 180, 255), function(color)
    print("color changed to:", color)
end)

settings:textbox("Username", "Enter your name", function(text)
    print("Username set to:", text)
end)

settings:toggle("Dark Mode", function(state)
    print("Dark mode:", state)
end)

main:Label("More features coming soon!")
```

