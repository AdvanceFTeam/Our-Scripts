local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Action = game:GetService("ReplicatedStorage").MC.Remotes.Action
local OFFHAND = 10
local REFILL_DELAY = 1.5
local TOGGLE_KEY = Enum.KeyCode.J

local function hands()
	return require(Players.LocalPlayer.PlayerScripts.MC.Hands)
end

local function isTotem(item)
	return type(item) == "table" and type(item.id) == "string" and string.find(item.id, "totem") ~= nil
end

local function offhandStocked()
	return isTotem(hands().inv.offhand)
end

local function findTotem()
	local inv = hands().inv
	for slot = 1, 9 do
		if isTotem(inv.hotbar[slot]) then
			return slot
		end
	end
	for index = 1, 27 do
		if isTotem(inv.inventory[index]) then
			return index + 10
		end
	end
end

local function stock()
	local slot = findTotem()
	if not slot then
		return
	end
	Action:FireServer({ a = "inv", op = "open" })
	task.wait(0.3)
	Action:FireServer({ a = "inv", op = "key", slot = slot, target = OFFHAND })
	task.wait(0.6)
	Action:FireServer({ a = "inv", op = "close" })
end

local enabled = true
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == TOGGLE_KEY then
		enabled = not enabled
	end
end)

local last_attempt = 0
RunService.Heartbeat:Connect(function()
	if not enabled or offhandStocked() or os.clock() - last_attempt < REFILL_DELAY then
		return
	end

	last_attempt = os.clock()
	stock()
end)
