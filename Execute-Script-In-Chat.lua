local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ScriptGUI"
gui.Parent = LocalPlayer.PlayerGui
gui.ResetOnSpawn = false

-- Create Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80)
frame.Position = UDim2.new(0.8, -200, 0.8, -80)
frame.BackgroundTransparency = 0.5
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Create UICorner for rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = frame

-- Create TextLabel for "Script Execution"
local scriptExecutionLabel = Instance.new("TextLabel")
scriptExecutionLabel.Size = UDim2.new(0.9, -10, 0.5, -10)
scriptExecutionLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
scriptExecutionLabel.BackgroundTransparency = 1
scriptExecutionLabel.Text = "Script Execution"
scriptExecutionLabel.TextColor3 = Color3.new(1, 1, 1)
scriptExecutionLabel.TextSize = 20
scriptExecutionLabel.TextWrapped = true
scriptExecutionLabel.Parent = frame

-- Create Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 80, 0, 40)
toggleButton.Position = UDim2.new(0.75, -15, 0.75, -10)
toggleButton.AnchorPoint = Vector2.new(1, 0.5)
toggleButton.BackgroundColor3 = Color3.new(0, 1, 0)
toggleButton.Text = "ON"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextSize = 20
toggleButton.Parent = frame

-- Toggle Button Functionality
local isScriptRunning = true

toggleButton.MouseButton1Click:Connect(function()
	isScriptRunning = not isScriptRunning
	toggleButton.Text = isScriptRunning and "ON" or "OFF"
	toggleButton.BackgroundColor3 = isScriptRunning and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

-- Make the frame resizable
local resizing = false
local originalSize = frame.Size
local originalMousePos

local function updateSize(mousePos)
	local deltaY = mousePos.Y - originalMousePos.Y
	frame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, originalSize.Y.Offset + deltaY)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		resizing = true
		originalMousePos = input.Position.Y
		originalSize = frame.Size
		frame.Active = false
		UserInputService.MouseIconEnabled = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
		updateSize(input.Position)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and resizing then
		resizing = false
		frame.Active = true
		UserInputService.MouseIconEnabled = true
	end
end)

-- Chat Message Listener
LocalPlayer.Chatted:Connect(function(message)
	if not isScriptRunning then
		return
	end
	
	local success, error = pcall(function()
		local scriptFunction = loadstring(message)
		if scriptFunction then
			scriptFunction()
		else
			error = "Invalid script"
		end
	end)
	
	if not success then
		warn("Lua execution failed:", error)
		-- Send "Error" notification
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "Error: " .. error,
			Color = Color3.new(1, 0, 0)
		})
	end
	
	-- Send chat message about the script execution
	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = "Script executed: " .. message,
		Color = Color3.new(0, 0, 1)
	})
end)

-- Send initial chat message
StarterGui:SetCore("ChatMakeSystemMessage", {
	Text = "Type a script in the chat to run it.",
	Color = Color3.new(1, 1, 1)
})
