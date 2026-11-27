--[[

 █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗███████╗ █████╗ ██╗     ██╗     ██╗███╗   ██╗ ██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔════╝██╔════╝██╔════╝██╔══██╗██║     ██║     ██║████╗  ██║██╔════╝     ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
███████║██║  ██║██║   ██║███████║██╔██╗ ██║██║     █████╗  █████╗  ███████║██║     ██║     ██║██╔██╗ ██║██║  ███╗       ██║   █████╗  ███████║██╔████╔██║
██╔══██║██║  ██║╚██╗ ██╔╝██╔══██║██║╚██╗██║██║     ██╔══╝  ██╔══╝  ██╔══██║██║     ██║     ██║██║╚██╗██║██║   ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
██║  ██║██████╔╝ ╚████╔╝ ██║  ██║██║ ╚████║╚██████╗███████╗██║     ██║  ██║███████╗███████╗██║██║ ╚████║╚██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝

]] --
-- AdvanceFalling Team
-- New update soon, RHT Dev love watching and seeing our src :3

-- V1.45 of RHT
-- everything has been cleanup and a few code has been strip in this open src script :p
-- also this is V1.45 NOT!! V1.5 (v1.5 has more new features than this) so everything is the same

local Players = game:GetService("Players")

local SOURCE = "https://raw.githubusercontent.com/YellowGregs/Spectrum/refs/heads/main/Spectrum.lua"

local body
local remote_url = SOURCE .. "?v=" .. tostring(os.time()) .. tostring(math.random(100000, 999999))
local request_ok, remote_body = pcall(function()
	return game:HttpGet(remote_url, true)
end)
if request_ok and type(remote_body) == "string" and remote_body ~= "" and remote_body ~= "404: Not Found" then
	body = remote_body
end
if not body and type(readfile) == "function" and type(isfile) == "function" and isfile("Spectrum.lua") then
	local local_ok, local_body = pcall(readfile, "Spectrum.lua")
	if local_ok and type(local_body) == "string" and local_body ~= "" then
		body = local_body
	end
end
if not body then
	error("[Spectrum] Could not load Spectrum.lua: " .. tostring(remote_body), 0)
end

local chunk, problem = loadstring(body, "Spectrum")
if not chunk then
	error("[Spectrum] Could not compile Spectrum.lua: " .. tostring(problem), 0)
end

local run_ok, Library = pcall(chunk)
if not run_ok then
	error("[Spectrum] Spectrum failed to load: " .. tostring(Library), 0)
end
Library = Library or shared.Spectrum
if type(Library) ~= "table" or type(Library.Window) ~= "function" then
	error("[Spectrum] Spectrum returned no Library.", 0)
end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

if type(getgenv().RHT_stop) == "function" then
	pcall(getgenv().RHT_stop)
end

if type(cleardrawcache) == "function" then
	pcall(cleardrawcache)
end

local alive = true

local hitbox_on = false
local no_collide = false
local og_props = {}
local hitbox_size = 21
local hitbox_alpha = 0.6
local team_check = "Everyone"
local body_parts = {"UpperTorso", "Head", "HumanoidRootPart"}

local ws_on = false
local walk_methods = {"Vector", "CFrame"}
local walk_method = walk_methods[1]
local settings = {WalkSpeed = 16, JumpPower = 50}

local IJ = false
local inf_jump_on = false
local jp_on = false

local fly_on = false
local fly_speed = 100
local fly_smooth = 0.3

local spin_on = false
local spin_speed = 30
local spin_angle = 0
local last_spin = tick()

local players = game:GetService("Players")
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid_root_part = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)

local locations = {
	["Safezone"] = Vector3.new(141.2, 142.1, -311.8),
	["Refill Ammo Safezone"] = Vector3.new(141.3, 144.7, -294.6),
	["Safezone Vest"] = Vector3.new(134.7, 145.1, -297.7),
	["Gas Station Refill Ammo"] = Vector3.new(125.2, 142.5, -11.6)
}
local function teleport(pos)
	if humanoid_root_part then
		humanoid_root_part.CFrame = CFrame.new(pos)
	end
end

player.CharacterAdded:Connect(function(new_char)
	character = new_char
	humanoid_root_part = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
end)

local FLY_BIND = "RHT_Fly"

local function fly()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
	local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
	if not hum or not root then
		if fly_on then task.delay(0.5, fly) end
		return
	end
	local cam = Workspace.CurrentCamera

	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	hum:ChangeState(Enum.HumanoidStateType.Swimming)

	local pos = root.Position

	pcall(function() RunService:UnbindFromRenderStep(FLY_BIND) end)

	RunService:BindToRenderStep(FLY_BIND, Enum.RenderPriority.Camera.Value + 1, function(dt)
		if not fly_on then
			RunService:UnbindFromRenderStep(FLY_BIND)
			if hum.Parent then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
			return
		end
		if player.Character ~= char then
			RunService:UnbindFromRenderStep(FLY_BIND)
			if hum.Parent then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
			task.spawn(fly)
			return
		end

		root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)

		local dir = Vector3.zero
		local md = hum.MoveDirection
		if md.Magnitude > 0 then dir += Vector3.new(md.X, 0, md.Z) end
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
		if dir.Magnitude > 0 then dir = dir.Unit end
		local target = pos + (dir * fly_speed * dt)
		local before = root.Position
		root.CFrame = root.CFrame:Lerp(CFrame.new(target, target + cam.CFrame.LookVector), fly_smooth)

		local delta = root.Position - before
		if delta.Magnitude > 0 then
			cam.CFrame = cam.CFrame + delta
		end

		pos = root.Position
	end)
end

local function save(plr, part)
	if not og_props[plr] then og_props[plr] = {} end
	if not og_props[plr][part.Name] then
		og_props[plr][part.Name] = {
			CanCollide = part.CanCollide,
			Transparency = part.Transparency,
			Size = part.Size
		}
	end
end

local function restore(plr)
	if og_props[plr] then
		for name, props in pairs(og_props[plr]) do
			local part = plr.Character and plr.Character:FindFirstChild(name)
			if part and part:IsA("BasePart") then
				part.CanCollide = props.CanCollide
				part.Transparency = props.Transparency
				part.Size = props.Size
			end
		end
	end
end

local function extend(plr)
	local char = plr.Character
	if not char then return end

	for _, name in ipairs(body_parts) do
		local part = char:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			save(plr, part)
			og_props[plr][name].widened = true
			part.CanCollide = not no_collide
			part.Transparency = math.clamp(hitbox_alpha, 0, 1)
			part.Size = Vector3.new(hitbox_size, hitbox_size, hitbox_size)
		end
	end

	if no_collide then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and not table.find(body_parts, part.Name) then
				save(plr, part)
				if part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	else
		local saved = og_props[plr]
		if saved then
			for name, props in pairs(saved) do
				if not table.find(body_parts, name) then
					local part = char:FindFirstChild(name)
					if part and part:IsA("BasePart") then
						part.CanCollide = props.CanCollide
					end
				end
			end
		end
	end
end

local function enemy(plr)
	if team_check == "FFA" or team_check == "Everyone" then return true end
	return plr.Team ~= player.Team
end

local function ok_target(plr)
	if team_check == "Everyone" or team_check == "FFA" then return true end
	return enemy(plr)
end

local function _hitbox()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if ok_target(plr) then
				extend(plr)
			else
				restore(plr)
			end
		end
	end
end

local function cleanup()
	for plr in pairs(og_props) do
		if not plr.Parent or not plr.Character or not plr.Character:IsDescendantOf(game) then
			restore(plr)
			og_props[plr] = nil
		end
	end
end

local function walk(dt)
	if not alive then return end
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	if ws_on then
		local dir = hum.MoveDirection
		if dir.Magnitude > 0 then
			local amt = dir.Unit * settings.WalkSpeed * dt
			if walk_method == "Vector" then
				root.CFrame = root.CFrame + amt
			else
				root.CFrame = root.CFrame:Lerp(root.CFrame + amt, 0.5)
			end
		end
	end

	if (IJ or jp_on) and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		local h = settings.JumpPower / 3 * dt * 60
		local target = root.Position + Vector3.new(0, h, 0)
		root.CFrame = root.CFrame:Lerp(CFrame.new(target, target + root.CFrame.LookVector), 0.2)
	end

	if inf_jump_on and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial == Enum.Material.Air then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end

RunService.RenderStepped:Connect(walk)

UserInputService.JumpRequest:Connect(function()
	if not alive or not inf_jump_on then return end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 and hum.FloorMaterial == Enum.Material.Air then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local function rot_part(char)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("RootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("LowerTorso")
end

local function spin(char, dt)
	if not spin_on then return end

	local now = tick()
	local real_dt = now - last_spin
	last_spin = now
	real_dt = math.min(real_dt, 1 / 30)

	spin_angle = spin_angle + math.rad(spin_speed) * real_dt * 60

	local part = rot_part(char)
	if part then
		part.CFrame = CFrame.new(part.Position) * CFrame.Angles(0, spin_angle, 0)
	end
end

local function reset(char)
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			repeat task.wait() until hum.Health > 0
			spin_angle = 0
			last_spin = tick()
		end
	end
end

if player.Character then
	reset(player.Character)
end
player.CharacterAdded:Connect(reset)

RunService.RenderStepped:Connect(function(dt)
	if not alive or not spin_on then return end
	local char = player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			spin(char, dt)
		end
	end
end)

local aimbot_on = false
local aim_fov = 100
local aim_smooth = 0.2
local aim_part = "Head"
local aim_threshold = 30
local wallcheck_on = false
local fov_circle = Drawing.new("Circle")
local show_fov = false

fov_circle.Radius = aim_fov
fov_circle.Thickness = 2
fov_circle.Color = Color3.fromRGB(255, 255, 255)
fov_circle.Filled = false
fov_circle.Transparency = 0.8
fov_circle.Visible = false

local ray_params = RaycastParams.new()
ray_params.FilterType = Enum.RaycastFilterType.Exclude
ray_params.IgnoreWater = true

local function can_see(part)
	local cam = Workspace.CurrentCamera
	local origin = cam.CFrame.Position
	local dir = part.Position - origin
	ray_params.FilterDescendantsInstances = {player.Character}

	local result = Workspace:Raycast(origin, dir, ray_params)
	if result then
		local hit = result.Instance
		local char = hit:FindFirstAncestorWhichIsA("Model")
		if char and char:FindFirstChild("Humanoid") then
			return char == part.Parent
		end
		return false
	end
	return true
end

local function nearest()
	local closest = nil
	local best = math.huge
	local mouse = UserInputService:GetMouseLocation()
	local cam = Workspace.CurrentCamera
	local spos_out = nil

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild(aim_part) then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local part = p.Character[aim_part]
				local spos, on = cam:WorldToViewportPoint(part.Position)
				if on then
					local dist = (Vector2.new(spos.X, spos.Y) - mouse).Magnitude
					if dist <= aim_fov and dist < best then
						if not wallcheck_on or can_see(part) then
							best = dist
							closest = p
							spos_out = Vector2.new(spos.X, spos.Y)
						end
					end
				end
			end
		end
	end
	return closest, best, spos_out
end

RunService.RenderStepped:Connect(function()
	if not alive then return end
	fov_circle.Visible = aimbot_on and show_fov
	if fov_circle.Visible then
		local center = Workspace.CurrentCamera.ViewportSize / 2
		fov_circle.Position = Vector2.new(center.X, center.Y)
		fov_circle.Radius = aim_fov
	end

	local holding = touch or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	if aimbot_on and holding then
		local target, dist, screen_pos = nearest()
		if dist and dist <= aim_threshold and screen_pos then
			if touch then
				local part = target and target.Character and target.Character:FindFirstChild(aim_part)
				if part then
					local cam = Workspace.CurrentCamera
					local goal = CFrame.lookAt(cam.CFrame.Position, part.Position)
					cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(aim_smooth, 0.05, 1))
				end
			else
				local mouse = UserInputService:GetMouseLocation()
				local dir = screen_pos - mouse
				local mdist = dir.Magnitude
				if mdist > 0 and type(mousemoverel) == "function" then
					local move = dir.Unit * (mdist * aim_smooth)
					mousemoverel(move.X, move.Y)
				end
			end
		end
	end
end)

local esp_settings = {
	enabled = false,
	boxes = true,
	fill = false,
	names = true,
	health = true,
	distance = true,
	tracers = true,
	weapons = true,
	hitbox_box = false,
	chams = false,
	cham_fill = true,
	weapon_glow = true,
	rainbow = false,
	max_distance = 1500,
	thickness = 1,
	opacity = 1,
	color = Color3.fromRGB(255, 255, 255),
}

local esp_sets = {}
local esp_cache = {}
local cham_pools = {}

local ESP_FONT = (Drawing.Fonts and Drawing.Fonts.Monospace) or 3

local function new_hl()
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = false
	return highlight
end

local function new_set()
	local set = {}

	set.box = Drawing.new("Square")
	set.box.Thickness = 1
	set.box.Filled = false
	set.box.ZIndex = 2
	set.box.Visible = false

	set.fill = Drawing.new("Square")
	set.fill.Filled = true
	set.fill.ZIndex = 1
	set.fill.Visible = false

	set.health_bg = Drawing.new("Square")
	set.health_bg.Filled = true
	set.health_bg.Color = Color3.fromRGB(15, 15, 15)
	set.health_bg.Transparency = 0.5
	set.health_bg.ZIndex = 2
	set.health_bg.Visible = false

	set.health = Drawing.new("Square")
	set.health.Filled = true
	set.health.ZIndex = 3
	set.health.Visible = false

	set.name = Drawing.new("Text")
	set.name.Size = 14
	set.name.Font = ESP_FONT
	set.name.Center = true
	set.name.Outline = true
	set.name.OutlineColor = Color3.fromRGB(0, 0, 0)
	set.name.ZIndex = 3
	set.name.Visible = false

	set.distance = Drawing.new("Text")
	set.distance.Size = 13
	set.distance.Font = ESP_FONT
	set.distance.Center = true
	set.distance.Outline = true
	set.distance.OutlineColor = Color3.fromRGB(0, 0, 0)
	set.distance.ZIndex = 3
	set.distance.Visible = false

	set.tracer = Drawing.new("Line")
	set.tracer.Thickness = 1
	set.tracer.ZIndex = 2
	set.tracer.Visible = false

	set.weapon_text = Drawing.new("Text")
	set.weapon_text.Size = 13
	set.weapon_text.Font = ESP_FONT
	set.weapon_text.Center = true
	set.weapon_text.Outline = true
	set.weapon_text.OutlineColor = Color3.fromRGB(0, 0, 0)
	set.weapon_text.ZIndex = 3
	set.weapon_text.Visible = false

	set.cham = new_hl()
	set.weapon_cham = new_hl()

	return set
end

local function parts_of(set, char)
	local now = os.clock()
	local cache = esp_cache[set]
	if not cache or cache.char ~= char or (now - cache.stamp) > 2 then
		local list = {}
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				list[#list + 1] = part
			end
		end
		table.sort(list, function(a, b)
			return a.Size.X * a.Size.Y * a.Size.Z > b.Size.X * b.Size.Y * b.Size.Z
		end)
		cache = { char = char, stamp = now, parts = list }
		esp_cache[set] = cache
	end
	return cache.parts
end

local function is_draw(object)
	if typeof(object) == "Instance" then
		return true
	end
	if type(isrenderobj) == "function" then
		local ok, result = pcall(isrenderobj, object)
		return ok and result == true
	end
	return type(object) == "userdata"
end

local function each_draw(set, fn)
	for _, object in pairs(set) do
		if is_draw(object) then
			fn(object)
		end
	end
end

local function cham_hide(set)
	local pool = cham_pools[set]
	if not pool then return end
	for _, cham in ipairs(pool) do
		cham.Enabled = false
	end
end

local function cham_kill(set)
	local pool = cham_pools[set]
	cham_pools[set] = nil
	if not pool then return end
	for _, cham in ipairs(pool) do
		pcall(function() cham:Destroy() end)
	end
end

local function kill_set(set)
	esp_cache[set] = nil
	cham_kill(set)
	each_draw(set, function(object)
		pcall(function()
			if typeof(object) == "Instance" then
				object:Destroy()
			else
				object:Remove()
			end
		end)
	end)
end

local function hide_set(set)
	cham_hide(set)
	each_draw(set, function(object)
		if typeof(object) == "Instance" then
			object.Enabled = false
		else
			object.Visible = false
		end
	end)
end

local function hide_draw(set)
	each_draw(set, function(object)
		if typeof(object) ~= "Instance" then
			object.Visible = false
		end
	end)
end

local function wipe()
	for plr, set in pairs(esp_sets) do
		kill_set(set)
		esp_sets[plr] = nil
	end
end

local function rainbow(offset)
	return Color3.fromHSV((tick() * 0.15 + (offset or 0)) % 1, 0.85, 1)
end

local function paint(highlight, adornee, color, fill_transparency)
	if not adornee then
		if highlight.Enabled then
			highlight.Enabled = false
		end
		return
	end
	if highlight.Parent ~= adornee then
		highlight.Parent = adornee
	end
	if highlight.Adornee ~= adornee then
		highlight.Adornee = adornee
	end
	if highlight.FillColor ~= color then
		highlight.FillColor = color
		highlight.OutlineColor = color
	end
	if highlight.FillTransparency ~= fill_transparency then
		highlight.FillTransparency = fill_transparency
	end
	if highlight.OutlineTransparency ~= 0 then
		highlight.OutlineTransparency = 0
	end
	if not highlight.Enabled then
		highlight.Enabled = true
	end
end

local function chams(set, char, parts, plr, color, fill_transparency, hitbox_box)
	local props = (not hitbox_box) and og_props[plr] or nil
	if not props then
		cham_hide(set)
		paint(set.cham, char, color, fill_transparency)
		return
	end

	set.cham.Enabled = false
	local pool = cham_pools[set]
	if not pool then
		pool = {}
		cham_pools[set] = pool
	end

	local others = math.max(#Players:GetPlayers() - 1, 1)
	local budget = math.clamp(math.floor(160 / others), 4, 13)

	local used = 0
	for _, part in ipairs(parts) do
		if used >= budget then break end
		local parent = part.Parent
		local saved = props[part.Name]
		if not (saved and saved.widened) and not (parent and parent:IsA("Accessory")) then
			used += 1
			local cham = pool[used]
			if not cham then
				cham = new_hl()
				pool[used] = cham
			end
			paint(cham, part, color, fill_transparency)
		end
	end
	for i = used + 1, #pool do
		pool[i].Enabled = false
	end
end

local function cham_off(set)
	set.cham.Enabled = false
	cham_hide(set)
end

local function bounds(cam, parts, plr, hitbox_box)
	local props = (not hitbox_box) and og_props[plr] or nil
	local lower, upper
	for _, part in ipairs(parts) do
		local size = part.Size
		local saved = props and props[part.Name]
		if saved and saved.widened then
			size = saved.Size
		end
		local half = size * 0.5
		local lo = part.Position - half
		local hi = part.Position + half
		lower = lower and Vector3.new(math.min(lower.X, lo.X), math.min(lower.Y, lo.Y), math.min(lower.Z, lo.Z)) or lo
		upper = upper and Vector3.new(math.max(upper.X, hi.X), math.max(upper.Y, hi.Y), math.max(upper.Z, hi.Z)) or hi
	end
	if not lower then return nil end

	local cf = CFrame.new((lower + upper) * 0.5)
	local size = upper - lower
	if (cf.Position - cam.CFrame.Position):Dot(cam.CFrame.LookVector) <= 0 then return nil end

	local min_x, min_y = math.huge, math.huge
	local max_x, max_y = -math.huge, -math.huge
	local on_any = false

	for _, sx in ipairs({-1, 1}) do
		for _, sy in ipairs({-1, 1}) do
			for _, sz in ipairs({-1, 1}) do
				local world = (cf * CFrame.new(size.X * 0.5 * sx, size.Y * 0.5 * sy, size.Z * 0.5 * sz)).Position
				local screen, on = cam:WorldToViewportPoint(world)
				if on then
					on_any = true
					if screen.X < min_x then min_x = screen.X end
					if screen.X > max_x then max_x = screen.X end
					if screen.Y < min_y then min_y = screen.Y end
					if screen.Y > max_y then max_y = screen.Y end
				end
			end
		end
	end

	if not on_any or max_x <= min_x or max_y <= min_y then return nil end
	return min_x, min_y, max_x, max_y
end

local function esp_frame()
	local cam = Workspace.CurrentCamera
	if not cam then return end

	for plr, set in pairs(esp_sets) do
		if not plr.Parent then
			kill_set(set)
			esp_sets[plr] = nil
		end
	end

	if not esp_settings.enabled then
		for _, set in pairs(esp_sets) do
			hide_set(set)
		end
		return
	end

	local viewport = cam.ViewportSize
	local shown = {}

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
			if char and hum and root and hum.Health > 0 then
				local dist = (cam.CFrame.Position - root.Position).Magnitude
				if dist <= esp_settings.max_distance then
					local set = esp_sets[plr]
					if not set then
						set = new_set()
						esp_sets[plr] = set
					end
					local parts = parts_of(set, char)

					local color = esp_settings.color
					if esp_settings.rainbow then
						color = rainbow(0)
					end

					local tool = char:FindFirstChildOfClass("Tool")

					if esp_settings.chams then
						chams(set, char, parts, plr, color, esp_settings.cham_fill and 0.5 or 1, esp_settings.hitbox_box)
					else
						cham_off(set)
					end

					if tool and esp_settings.weapon_glow then
						paint(set.weapon_cham, tool, esp_settings.rainbow and rainbow(0.4) or color, 0.35)
					else
						set.weapon_cham.Enabled = false
					end

					local min_x, min_y, max_x, max_y
					if esp_settings.enabled then
						min_x, min_y, max_x, max_y = bounds(cam, parts, plr, esp_settings.hitbox_box)
					end
					if min_x then

						local box_w = max_x - min_x
						local box_h = max_y - min_y
						local box_pos = Vector2.new(min_x, min_y)
						local box_size = Vector2.new(box_w, box_h)
						local center_x = min_x + box_w * 0.5

						if esp_settings.fill then
							set.fill.Color = color
							set.fill.Transparency = 0.85
							set.fill.Position = box_pos
							set.fill.Size = box_size
							set.fill.Visible = true
						else
							set.fill.Visible = false
						end

						set.box.Color = color
						set.box.Transparency = esp_settings.opacity
						set.box.Thickness = esp_settings.thickness
						set.box.Position = box_pos
						set.box.Size = box_size
						set.box.Visible = esp_settings.boxes

						if esp_settings.health then
							local fraction = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
							local bar_w = 2
							local bar_h = math.max(box_h * fraction, 0)
							local bar_x = min_x - bar_w - 3

							set.health_bg.Position = Vector2.new(bar_x, min_y)
							set.health_bg.Size = Vector2.new(bar_w, box_h)
							set.health_bg.Visible = true

							set.health.Color = Color3.fromRGB(255, 255, 255)
							set.health.Position = Vector2.new(bar_x, min_y + (box_h - bar_h))
							set.health.Size = Vector2.new(bar_w, bar_h)
							set.health.Visible = bar_h > 0
						else
							set.health_bg.Visible = false
							set.health.Visible = false
						end

						if esp_settings.names then
							set.name.Text = plr.Name
							set.name.Color = color
							set.name.Position = Vector2.new(center_x, min_y - 18)
							set.name.Visible = true
						else
							set.name.Visible = false
						end

						if esp_settings.distance then
							set.distance.Text = math.floor(dist) .. " studs"
							set.distance.Color = color
							set.distance.Position = Vector2.new(center_x, max_y + 4)
							set.distance.Visible = true
						else
							set.distance.Visible = false
						end

						if esp_settings.tracers then
							set.tracer.Color = color
							set.tracer.Transparency = esp_settings.opacity
							set.tracer.Thickness = esp_settings.thickness
							set.tracer.From = Vector2.new(viewport.X * 0.5, viewport.Y)
							set.tracer.To = Vector2.new(center_x, max_y)
							set.tracer.Visible = true
						else
							set.tracer.Visible = false
						end

						if esp_settings.weapons and tool then
							set.weapon_text.Text = tool.Name
							set.weapon_text.Color = esp_settings.rainbow and rainbow(0.7) or color
							set.weapon_text.Position = Vector2.new(center_x, max_y + (esp_settings.distance and 22 or 6))
							set.weapon_text.Visible = true
						else
							set.weapon_text.Visible = false
						end
					else
						hide_draw(set)
					end

					shown[plr] = true
				end
			end
		end
	end

	for plr, set in pairs(esp_sets) do
		if not shown[plr] then
			hide_set(set)
		end
	end
end

local esp_cooldown = 0
local esp_reported = false

local function esp_tick()
	if not alive or os.clock() < esp_cooldown then return end
	local ok, err = pcall(esp_frame)
	if ok then return end
	wipe()
	esp_cooldown = os.clock() + 0.5
	if not esp_reported then
		esp_reported = true
		Library:Notify("ESP error", tostring(err), 8, "bad")
	end
end

RunService.RenderStepped:Connect(esp_tick)

getgenv().triggerb = false
local ch_on = false
local ch_color = Color3.fromRGB(255, 255, 255)
local ch_size = 10
local dot_size = 2
local ch_gap = 10
local trigger_delay = 0.2

local ch_lines = {
	top = Drawing.new("Line"),
	bottom = Drawing.new("Line"),
	left = Drawing.new("Line"),
	right = Drawing.new("Line")
}
local ch_dot = Drawing.new("Circle")

local function draw_ch()
	if ch_on and alive then
		local ss = Workspace.CurrentCamera.ViewportSize
		local cx, cy = ss.X / 2, ss.Y / 2

		ch_lines.top.From = Vector2.new(cx, cy - ch_gap)
		ch_lines.top.To = Vector2.new(cx, cy - ch_gap - ch_size)
		ch_lines.top.Color = ch_color
		ch_lines.top.Thickness = 2
		ch_lines.top.Visible = true

		ch_lines.bottom.From = Vector2.new(cx, cy + ch_gap)
		ch_lines.bottom.To = Vector2.new(cx, cy + ch_gap + ch_size)
		ch_lines.bottom.Color = ch_color
		ch_lines.bottom.Thickness = 2
		ch_lines.bottom.Visible = true

		ch_lines.left.From = Vector2.new(cx - ch_gap, cy)
		ch_lines.left.To = Vector2.new(cx - ch_gap - ch_size, cy)
		ch_lines.left.Color = ch_color
		ch_lines.left.Thickness = 2
		ch_lines.left.Visible = true

		ch_lines.right.From = Vector2.new(cx + ch_gap, cy)
		ch_lines.right.To = Vector2.new(cx + ch_gap + ch_size, cy)
		ch_lines.right.Color = ch_color
		ch_lines.right.Thickness = 2
		ch_lines.right.Visible = true

		ch_dot.Position = Vector2.new(cx, cy)
		ch_dot.Radius = dot_size
		ch_dot.Color = ch_color
		ch_dot.Filled = true
		ch_dot.Visible = true
	else
		for _, line in pairs(ch_lines) do line.Visible = false end
		ch_dot.Visible = false
	end
end

RunService.RenderStepped:Connect(draw_ch)

local trigger_on = false
local trigger_next = 0

local function trigger_character()
	local target = player:GetMouse().Target
	if not target then return nil end
	local model = target:FindFirstAncestorOfClass("Model")
	while model do
		if model ~= player.Character and model:FindFirstChildOfClass("Humanoid") then
			return model
		end
		model = model:FindFirstAncestorOfClass("Model")
	end
	return nil
end

RunService.Heartbeat:Connect(function()
	if not alive or not (trigger_on or getgenv().triggerb) then return end
	if os.clock() < trigger_next then return end
	if type(mouse1press) ~= "function" or type(mouse1release) ~= "function" then return end

	local model = trigger_character()
	if not model then return end

	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	local owner = Players:GetPlayerFromCharacter(model)
	if owner and not ok_target(owner) then return end

	trigger_next = os.clock() + trigger_delay
	mouse1press()
	task.delay(0.05, mouse1release)
end)

local noclip_on = false

local lighting_defaults = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	GlobalShadows = Lighting.GlobalShadows,
}
local lighting_settings = {
	fullbright = false,
}

local function light()
	if lighting_settings.fullbright then
		Lighting.Brightness = 2
		Lighting.ClockTime = 12
		Lighting.FogEnd = 100000
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = lighting_defaults.Brightness
		Lighting.ClockTime = lighting_defaults.ClockTime
		Lighting.FogEnd = lighting_defaults.FogEnd
		Lighting.Ambient = lighting_defaults.Ambient
		Lighting.OutdoorAmbient = lighting_defaults.OutdoorAmbient
		Lighting.GlobalShadows = lighting_defaults.GlobalShadows
	end
end

local MainWindow = Library:Window("AdvanceTech | Main", { icon = "target", width = 340 })
local HitboxTab = MainWindow:Tab("Hitbox", {
	icon = "sliders",
	tooltip = "Hitbox controls",
})
HitboxTab:section("Hitbox", "sliders", { open = true })
HitboxTab:toggle("Enable Hitbox", false, function(value)
	hitbox_on = value
	if not value then
		for _, plr in ipairs(Players:GetPlayers()) do restore(plr) end
		og_props = {}
	else
		_hitbox()
	end
end, { icon = "check", feature = true, tooltip = "Extends the hitbox parts of every target." })
HitboxTab:slider("Hitbox Size", 1, 50, hitbox_size, function(value)
	hitbox_size = value
	if hitbox_on then _hitbox() end
end, 1, "sliders", { showMax = true, tooltip = "Studs per body part." })
HitboxTab:slider("Hitbox Transparency", 1, 10, math.clamp(hitbox_alpha * 10, 1, 10), function(value)
	hitbox_alpha = math.clamp(value / 10, 0, 1)
	if hitbox_on then _hitbox() end
end, 1, "eye", { suffix = " / 10", tooltip = "1 is visible, 10 is invisible." })
HitboxTab:dropdown("Team Check", {"FFA", "Team-Based", "Everyone"}, team_check, function(option)
	team_check = option
	if hitbox_on then _hitbox() end
end, false, "target", { tooltip = "Who the hitbox applies to." })
HitboxTab:toggle("No Collision", false, function(value)
	no_collide = value
	if hitbox_on then _hitbox() end
end, { icon = "lock", tooltip = "Makes the whole target non-collidable while the hitbox is on." })
HitboxTab:toggle("ESP On Hitbox", false, function(value)
	esp_settings.hitbox_box = value
end, { icon = "render", tooltip = "Boxes and chams the widened hitbox instead of the real body." })

local AimbotTab = MainWindow:Tab("Aimbot", {
	icon = "target",
	tooltip = "Lock-on helpers",
})
AimbotTab:section("Aimbot", "target", { open = true })
AimbotTab:toggle("enabled", false, function(on)
	aimbot_on = on
end, { icon = "bolt", feature = true, tooltip = "Holds MouseButton2 to lock on." })
AimbotTab:toggle("wall check", false, function(on)
	wallcheck_on = on
end, { icon = "eye", tooltip = "Ignores targets behind walls." })
AimbotTab:toggle("triggerbot", false, function(on)
	trigger_on = on
	getgenv().triggerb = on
end, { icon = "bolt", feature = true, tooltip = "Fires when the crosshair is on a player." })
AimbotTab:slider("trigger delay", 0.05, 1, trigger_delay, function(val)
	trigger_delay = val
end, 0.05, "speed", { decimals = 2, suffix = " s", tooltip = "Seconds between triggerbot shots." })
AimbotTab:dropdown("target part", {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"}, aim_part, function(part)
	aim_part = part
end, false, "user", { tooltip = "Body part to aim at." })
AimbotTab:slider("lock on sensitivity", 5, 100, aim_threshold, function(val)
	aim_threshold = val
end, 1, "speed", { showMax = true, tooltip = "Pixels the target may drift before the lock drops." })
AimbotTab:slider("smoothness", 1, 10, aim_smooth * 10, function(val)
	aim_smooth = val / 10
end, 1, "sliders", { tooltip = "1 is snappy, 10 is soft." })
AimbotTab:toggle("show fov circle", false, function(on)
	show_fov = on
end, { icon = "eye", tooltip = "Draws the aim radius on screen." })
AimbotTab:slider("fov radius", 20, 500, aim_fov, function(val)
	aim_fov = val
end, 1, "target", { showMax = true, tooltip = "Radius in pixels." })
AimbotTab:colorpicker("fov circle color", fov_circle.Color, function(col)
	fov_circle.Color = col
end, "palette", { recent = true, tooltip = "Circle outline color." })

local PlayerWindow = Library:Window("AdvanceTech | Player", { icon = "user", width = 340 })
local MovementTab = PlayerWindow:Tab("Movement", {
	icon = "speed",
	tooltip = "Fly, walk and jump",
})
MovementTab:section("Fly", "bolt", { open = true })
MovementTab:toggle("Fly", false, function(value)
	fly_on = value
	if value then spawn(fly) end
end, { icon = "bolt", feature = true, tooltip = "WASD to move, Space/LeftShift up and down." })
MovementTab:slider("Fly Speed", 25, 500, fly_speed, function(value) fly_speed = value end, 1, "speed", { showMax = true })
MovementTab:slider("Fly Smoothness", 0, 1, fly_smooth, function(value) fly_smooth = value end, 0.05, "sliders", { decimals = 2, tooltip = "0 is instant, 1 is floaty." })

MovementTab:section("WalkSpeed", "speed", { open = true })
MovementTab:toggle("Enable WalkSpeed", false, function(value) ws_on = value end, { icon = "check", feature = true })
MovementTab:dropdown("Walk Method", walk_methods, walk_method, function(option) walk_method = option end, false, "target", { tooltip = "How the CFrame is moved." })
MovementTab:slider("WalkSpeed Power", 16, 500, settings.WalkSpeed, function(value) settings.WalkSpeed = value end, 1, "speed", { showMax = true })

MovementTab:section("Jump", "arrow", { open = true })
MovementTab:toggle("Enable Jump", false, function(value) IJ = value end, { icon = "check", feature = true, tooltip = "Hold Space to rise." })
MovementTab:toggle("Infinite Jump", false, function(value) inf_jump_on = value end, { icon = "arrow", feature = true, tooltip = "Jump again in midair without changing JumpPower." })
MovementTab:slider("Jump Power", 50, 200, settings.JumpPower, function(value) settings.JumpPower = value end, 1, "arrow", { showMax = true })

MovementTab:section("Collision", "lock", { open = true })
MovementTab:toggle("NoClip", false, function(enabled)
	noclip_on = enabled
	local function toggle()
		while noclip_on do
			local char = player.Character
			if char then
				for _, p in pairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
			RunService.Stepped:Wait()
		end
		local char = player.Character
		if char then
			for _, p in pairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = true end
			end
		end
	end
	if noclip_on then spawn(toggle) end
end, { icon = "lock", feature = true })

local SpinbotTab = PlayerWindow:Tab("Spinbot", {
	icon = "refresh",
	tooltip = "Character rotation",
})
SpinbotTab:section("Spinbot", "refresh", { open = true })
SpinbotTab:toggle("Enable Spinbot", false, function(state)
	spin_on = state
end, { icon = "check", feature = true })
SpinbotTab:slider("Spin Speed (deg/s)", 10, 360, spin_speed, function(val)
	spin_speed = val
end, 1, "speed", { suffix = " deg/s", showMax = true })

local VisualsWindow = Library:Window("AdvanceTech | Visuals", { icon = "eye", width = 340 })
local EspTab = VisualsWindow:Tab("ESP", {
	icon = "eye",
	tooltip = "Player boxes, names, health, tracers",
})
EspTab:section("ESP", "eye", { open = true })
EspTab:toggle("Enable ESP", false, function(value)
	esp_settings.enabled = value
	if not value then
		for _, set in pairs(esp_sets) do hide_set(set) end
	end
end, { icon = "check", feature = true, tooltip = "Draws every visible player." })
EspTab:toggle("Boxes", true, function(value) esp_settings.boxes = value end, { icon = "render" })
EspTab:toggle("Filled boxes", false, function(value) esp_settings.fill = value end, { icon = "palette" })
EspTab:toggle("Names", true, function(value) esp_settings.names = value end, { icon = "code" })
EspTab:toggle("Health bars", true, function(value) esp_settings.health = value end, { icon = "check" })
EspTab:toggle("Distance", true, function(value) esp_settings.distance = value end, { icon = "arrow" })
EspTab:toggle("Tracers", true, function(value) esp_settings.tracers = value end, { icon = "speed" })

EspTab:section("Chams & weapons", "user", { open = true })
EspTab:toggle("Chams", false, function(value)
	esp_settings.chams = value
	if not value then
		for _, set in pairs(esp_sets) do cham_off(set) end
	end
end, { icon = "render", tooltip = "Solid color over every player model." })
EspTab:toggle("Filled chams", true, function(value) esp_settings.cham_fill = value end, { icon = "palette", tooltip = "Off keeps only the outline." })
EspTab:toggle("Weapon glow", true, function(value)
	esp_settings.weapon_glow = value
	if not value then
		for _, set in pairs(esp_sets) do set.weapon_cham.Enabled = false end
	end
end, { icon = "bolt", tooltip = "Highlights the gun in their hand." })
EspTab:toggle("Weapon name", true, function(value) esp_settings.weapons = value end, { icon = "code", tooltip = "Shows the equipped weapon under each player." })
EspTab:toggle("Rainbow", false, function(value) esp_settings.rainbow = value end, { icon = "palette", tooltip = "Cycles every ESP, cham and weapon color." })

EspTab:section("Tuning", "sliders", { open = true })
EspTab:slider("Max Distance", 100, 5000, esp_settings.max_distance, function(value)
	esp_settings.max_distance = value
end, 50, "target", { showMax = true, tooltip = "Studs. Players further away are skipped." })
EspTab:slider("Thickness", 1, 5, esp_settings.thickness, function(value)
	esp_settings.thickness = value
end, 1, "sliders", { tooltip = "Line thickness for boxes and tracers." })
EspTab:slider("Opacity", 0.2, 1, esp_settings.opacity, function(value)
	esp_settings.opacity = value
end, 0.05, "eye", { decimals = 2, tooltip = "0.2 is faint, 1 is solid." })
EspTab:colorpicker("ESP Color", esp_settings.color, function(color)
	esp_settings.color = color
end, "palette", { recent = true, tooltip = "Boxes, names, health bars and tracers." })
-- EspTab:button("Clear ESP drawings", function()
-- 	wipe()
-- end, "close", { variant = "secondary", tooltip = "Removes every drawing object." })

local LightingTab = VisualsWindow:Tab("Lighting", {
	icon = "eye",
	tooltip = "Local lighting",
})
LightingTab:section("Lighting", "eye", { open = true })
LightingTab:toggle("Fullbright", false, function(value)
	lighting_settings.fullbright = value
	light()
end, { icon = "check", feature = true, tooltip = "Bright, shadowless and fog free." })

local CrosshairTab = VisualsWindow:Tab("Crosshair", {
	icon = "target",
	tooltip = "Custom crosshair",
})
CrosshairTab:section("Crosshair", "render", { open = true })
CrosshairTab:toggle("Custom Crosshair", false, function(state)
	ch_on = state
	draw_ch()
end, { icon = "eye", feature = true })
CrosshairTab:slider("Crosshair Size", 4, 20, ch_size, function(size)
	ch_size = size
	draw_ch()
end, 1, "sliders")
CrosshairTab:slider("Dot Size", 2, 10, dot_size, function(size)
	dot_size = size
	draw_ch()
end, 1, "sliders")
CrosshairTab:slider("Crosshair Gap", 6, 20, ch_gap, function(size)
	ch_gap = size
	draw_ch()
end, 1, "sliders")
CrosshairTab:colorpicker("Crosshair Color", ch_color, function(color)
	ch_color = color
	draw_ch()
end, "palette", { recent = true })

pcall(function()
	if Library:IsMobile() then
		Library:SetMobileButton(true)
	end
end)

local SettingsWindow = Library:Window("AdvanceTech | Settings", { icon = "save", width = 320 })
local LocationTab = SettingsWindow:Tab("Locations", {
	icon = "arrow",
	tooltip = "Saved map spots",
})
LocationTab:section("Locations", "target", { open = true })
local location_names = {}
for name in pairs(locations) do
	table.insert(location_names, name)
end
table.sort(location_names)

local selected_location = location_names[1]

LocationTab:dropdown("Teleport Location", location_names, location_names[1], function(selectedName)
	selected_location = selectedName
end, false, "target", { tooltip = "Pick a spot, then press Teleport." })

LocationTab:button("Teleport", function()
	local pos = locations[selected_location]
	if pos then
		teleport(pos)
	end
end, "target", { tooltip = "Moves you to the selected spot." })

local SessionTab = SettingsWindow:Tab("Session", {
	icon = "refresh",
	tooltip = "Server controls",
})
SessionTab:section("Server", "refresh", { open = true })
SessionTab:button("Rejoin Server", function()
	local joined = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
	end)
	if not joined then
		pcall(function()
			TeleportService:Teleport(game.PlaceId, player)
		end)
	end
end, "refresh", { variant = "danger", confirm = "Click again to rejoin", tooltip = "Reconnects to this server." })

local ConfigTab = SettingsWindow:Tab("Config", {
	icon = "save",
	tooltip = "Profiles, saving and interface",
})
ConfigTab:section("Profile", "save", { open = true })
ConfigTab:label("The active profile is written to Spectrum's configs folder.")
ConfigTab:textbox("Profile name", Library:GetProfile(), function(name)
	if name ~= "" then
		Library:SetProfile(name)
	end
end, "folder", { placeholder = "default", tooltip = "File name under the configs folder." })

local autosave_toggle
autosave_toggle = ConfigTab:toggle("Auto-save", Library:GetAutoSave(), function(state)
	Library:SetAutoSave(state)
	if autosave_toggle then autosave_toggle:Set(Library:GetAutoSave()) end
end, { icon = "save", tooltip = "Writes every change as it happens." })

ConfigTab:button("Save now", function()
	local ok = Library:SaveConfig()
	if ok then
		Library:Notify("Config", "Saved " .. Library:GetProfile() .. ".", 3, "good")
	else
		Library:Notify("Config", Library:GetConfigError() or "Could not save.", 3, "bad")
	end
end, "save", { tooltip = "Manual save of the active profile." })

ConfigTab:button("Load profile", function()
	Library:LoadConfig()
	Library:Notify("Config", "Loaded " .. Library:GetProfile() .. ".", 3, "info")
end, "folder", { variant = "secondary" })

ConfigTab:button("Log config path", function()
	print("[RHT] Profile:", Library:GetProfile(), "Path:", Library:GetConfigPath(), "Last error:", tostring(Library:GetConfigError()))
end, "code", { variant = "secondary" })

ConfigTab:section("Interface", "menu", { open = true })
local mobile_toggle
mobile_toggle = ConfigTab:toggle("Mobile menu button", Library:GetMobileButton(), function(state)
	local mounted = Library:SetMobileButton(state)
	if mobile_toggle then mobile_toggle:Set(mounted) end
end, { icon = "menu", tooltip = "Floating button that opens the UI on touch devices." })

local feature_toggle
feature_toggle = ConfigTab:toggle("Show feature list", true, function(state)
	Library:SetFeatureListVisible(state)
end, {
	style = "checkbox",
	icon = "list",
	feature = false,
	tooltip = "Lists active settings in the top-right corner."
})

if type(Library.SetFeatureListRGB) == "function" then
	ConfigTab:toggle("Colorful feature list", false, function(state)
		Library:SetFeatureListRGB(state)
	end, {
		icon = "palette",
		feature = false,
		tooltip = "Animates the feature list with a moving gradient."
	})
end

if type(Library.SetFeatureListAll) == "function" then
	ConfigTab:toggle("Include every setting", false, function(state)
		Library:SetFeatureListAll(state)
	end, {
		icon = "list",
		feature = false,
		tooltip = "Lists every active control, marked or not."
	})
end

local CreditsTab = SettingsWindow:Tab("Credits", {
	icon = "info",
	tooltip = "The team",
})
CreditsTab:section("Credits", "info", { open = true })
local devs = {"YellowGreg", "WspBoy12", "MMSVon", "ShadowClark", "Frostbite"}
for _, dev in ipairs(devs) do
	CreditsTab:button(dev, function()
		local roles = {
			YellowGreg = "Owner",
			WspBoy12 = "Head Developer",
			MMSVon = "Head Developer",
			ShadowClark = "Developer",
			Frostbite = "Head Developer"
		}
		print(dev .. " created " .. roles[dev])
	end, "user", { variant = "secondary" })
end
CreditsTab:button("Copy Discord Link", function()
	setclipboard("https://discord.gg/d2446gBjfq")
end, "save")

local hitbox_next = 0

RunService.Heartbeat:Connect(function()
	if not alive or not hitbox_on then return end
	local now = os.clock()
	if now < hitbox_next then return end
	hitbox_next = now + 0.25
	_hitbox()
	cleanup()
end)

getgenv().RHT_stop = function()
	if not alive then
		return
	end
	alive = false
	hitbox_on = false
	fly_on = false
	noclip_on = false
	spin_on = false
	ws_on = false
	pcall(function()
		RunService:UnbindFromRenderStep(FLY_BIND)
	end)
	pcall(wipe)
	for plr in pairs(og_props) do
		pcall(restore, plr)
	end
	og_props = {}
	pcall(function()
		lighting_settings.fullbright = false
		light()
	end)
	pcall(function()
		Library:Destroy()
	end)
end

Library:Notify("RHT DEV", "FUCK YOU, im jk i love you MELON hope you can find a way to patch me hehehe :3", 7, "good")
