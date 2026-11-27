--[[
 █████╗ ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗███████╗ █████╗ ██╗     ██╗     ██╗███╗   ██╗ ██████╗     ████████╗███████╗ █████╗ ███╗   ███╗
██╔══██╗██╔══██╗██║   ██║██╔══██╗████╗  ██║██╔════╝██╔════╝██╔════╝██╔══██╗██║     ██║     ██║████╗  ██║██╔════╝     ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
███████║██║  ██║██║   ██║███████║██╔██╗ ██║██║     █████╗  █████╗  ███████║██║     ██║     ██║██╔██╗ ██║██║  ███╗       ██║   █████╗  ███████║██╔████╔██║
██╔══██║██║  ██║╚██╗ ██╔╝██╔══██║██║╚██╗██║██║     ██╔══╝  ██╔══╝  ██╔══██║██║     ██║     ██║██║╚██╗██║██║   ██║       ██║   ██╔══╝  ██╔══██║██║╚██╔╝██║
██║  ██║██████╔╝ ╚████╔╝ ██║  ██║██║ ╚████║╚██████╗███████╗██║     ██║  ██║███████╗███████╗██║██║ ╚████║╚██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚═════╝   ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
]] --
-- AdvanceFalling Team

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
	error("[pf] could not load Spectrum.lua: " .. tostring(remote_body), 0)
end

local chunk, problem = loadstring(body, "Spectrum")
if not chunk then
	error("[pf] could not compile Spectrum.lua: " .. tostring(problem), 0)
end

local run_ok, library = pcall(chunk)
if not run_ok then
	error("[pf] Spectrum failed to load: " .. tostring(library), 0)
end
library = library or shared.Spectrum
if type(library) ~= "table" or type(library.Window) ~= "function" then
	error("[pf] Spectrum returned no Library", 0)
end

pcall(function()
	if library:GetProfile() ~= "phantom_forces" then
		library:SetProfile("phantom_forces")
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local generation = (shared.pfGeneration or 0) + 1
shared.pfGeneration = generation

local function alive()
	return shared.pfGeneration == generation
end

if shared.pf and type(shared.pf.destroy) == "function" then
	pcall(shared.pf.destroy)
end

local Config = {
	esp = true,
	box = false,
	name = true,
	distance = true,
	health = true,
	tracer = true,
	tracerFrom = "Bottom",
	color = Color3.fromRGB(255, 255, 255),
	BoxThickness = 1,
	textsize = 13,
	EspRange = 400,
	targetMode = "Team Base",
	aim = false,
	aimmode = "Hold",
	aimmethod = "Mouse",
	fov = 360,
	fovCircle = false,
	smooth = 9,
	wallCheck = false,
	sticky = true,
	max_distance = 600,
	aimpart = "Head",
	watermark = true,
	cham = false,
	ChamMode = "Both",
	chamFill = 0.55,
	ChamColor = Color3.fromRGB(255, 255, 255),
	skeleton = false,
	SkeletonThickness = 1,
	crosshair = false,
	CrossStyle = "Cross",
	crossSize = 9,
	CrossGap = 4,
	CrossThickness = 1,
	crossColor = Color3.fromRGB(255, 255, 255),
	hide_crosshair = true,
	sprint = false,
	walk = false,
	walkSpeed = 14,
	walkMethod = "Velocity",
	jump = false,
	jumpPower = 29,
	jumpMethod = "Property",
	infJump = false,
}

local Stats = { rigs = 0, shown = 0, frames = 0, chams = 0, bones = 0, team = "-", friends = 0, enemies = 0, target = "-" }

local function myhumanoid()
	local ignore = workspace:FindFirstChild("Ignore")
	if not ignore then
		return nil
	end
	for _, model in ipairs(ignore:GetChildren()) do
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			return humanoid
		end
	end
	return nil
end

local function myroot()
	local humanoid = myhumanoid()
	local model = humanoid and humanoid.Parent
	return model and model:FindFirstChild("HumanoidRootPart") or nil
end

local roster_cache, roster_stamp = nil, 0

local function c_labels(node, into)
	if not node then
		return into
	end
	for _, d in ipairs(node:GetDescendants()) do
		if d:IsA("TextLabel") and d.Text ~= "" then
			into[d.Text] = true
		end
	end
	return into
end

local function roster()
	if roster_cache and os.clock() - roster_stamp < 2 then
		return roster_cache
	end

	local phantom, ghost = {}, {}
	local gui = LP:FindFirstChild("PlayerGui")
	local screen = gui and gui:FindFirstChild("LeaderboardScreenGui")
	local frame = screen and screen:FindFirstChild("DisplayScoreFrame")
	local container = frame and frame:FindFirstChild("Container")
	if container then
		c_labels(container:FindFirstChild("DisplayPhantomBoard"), phantom)
		c_labels(container:FindFirstChild("DisplayGhostBoard"), ghost)
	end

	local mine = nil
	if phantom[LP.Name] then
		mine = "PHANTOMS"
	elseif ghost[LP.Name] then
		mine = "GHOSTS"
	end

	roster_cache = {
		mine = mine,
		friends = mine == "PHANTOMS" and phantom or mine == "GHOSTS" and ghost or {},
		enemies = mine == "PHANTOMS" and ghost or mine == "GHOSTS" and phantom or {},
	}
	roster_stamp = os.clock()
	return roster_cache
end

local function name_of(model)
	local gui = model:FindFirstChild("NameTagGui", true)
	local label = gui and gui:FindFirstChild("PlayerTag", true)
	return label and label.Text or nil
end

local function head_of(model)
	local gui = model:FindFirstChild("NameTagGui", true)
	local part = gui and gui.Parent
	if part and part:IsA("BasePart") then
		return part
	end
	local best, best_y = nil, -math.huge
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") and d.Position.Y > best_y then
			best, best_y = d, d.Position.Y
		end
	end
	return best
end

local function wanted(entry, teams)
	if Config.targetMode == "Everyone" then
		return true
	end
	if teams.mine == nil then
		return true
	end
	if Config.targetMode == "FFA" then
		return entry.friend or entry.enemy
	end
	return entry.enemy
end

local function rigs()
	local out = {}
	local container = workspace:FindFirstChild("Players")
	if not container then
		return out
	end
	local teams = roster()
	for _, folder in ipairs(container:GetChildren()) do
		for _, model in ipairs(folder:GetChildren()) do
			local head = head_of(model)
			if head then
				local name = name_of(model) or "?"
				out[#out + 1] = {
					model = model,
					head = head,
					name = name,
					folder = folder.Name,
					friend = teams.friends[name] == true,
					enemy = teams.enemies[name] == true,
				}
			end
		end
	end
	return out
end

local function targets()
	local all, keep = rigs(), {}
	local teams = roster()
	for _, entry in ipairs(all) do
		if wanted(entry, teams) then
			keep[#keep + 1] = entry
		end
	end
	return keep, all
end

local ray_params = RaycastParams.new()
ray_params.FilterType = Enum.RaycastFilterType.Exclude
ray_params.FilterDescendantsInstances = {
	workspace:FindFirstChild("Players"),
	workspace:FindFirstChild("Ignore"),
	workspace:FindFirstChild("Roots"),
}

local function visible(point)
	if not Config.wallCheck then
		return true
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return false
	end
	local from = camera.CFrame.Position
	return workspace:Raycast(from, point - from, ray_params) == nil
end

local frames = {}

local function health_of(model)
	local gui = model:FindFirstChild("NameTagGui", true)
	local percent = gui and gui:FindFirstChild("Percent", true)
	if not percent or not percent:IsA("GuiObject") then
		return nil
	end
	return math.clamp(percent.Size.X.Scale, 0, 1)
end

local function NewFrame()
	local lines = {}
	for i = 1, 4 do
		local line = Drawing.new("Line")
		line.Visible = false
		lines[i] = line
	end
	local name = Drawing.new("Text")
	name.Center = true
	name.Outline = true
	name.Visible = false

	local distance = Drawing.new("Text")
	distance.Center = true
	distance.Outline = true
	distance.Visible = false

	local tracer = Drawing.new("Line")
	tracer.Thickness = 1
	tracer.Visible = false

		local bar_track = Drawing.new("Square")
	bar_track.Filled = true
	bar_track.Color = Color3.fromRGB(10, 10, 10)
	bar_track.Transparency = 0.4
	bar_track.Visible = false

	local bar_slices = {}
	for i = 1, 5 do
		local slice = Drawing.new("Square")
		slice.Filled = true
		slice.Visible = false
		bar_slices[i] = slice
	end

	local bar_edge = Drawing.new("Square")
	bar_edge.Filled = false
	bar_edge.Thickness = 1
	bar_edge.Transparency = 0.35
	bar_edge.Visible = false

	return { lines = lines, name = name, distance = distance, tracer = tracer, bar_track = bar_track, bar_slices = bar_slices, bar_edge = bar_edge }
end

local function clear_frame(frame)
	for _, line in ipairs(frame.lines) do
		line.Visible = false
	end
	frame.name.Visible = false
	frame.distance.Visible = false
	frame.tracer.Visible = false
	frame.bar_track.Visible = false
	for _, slice in ipairs(frame.bar_slices) do
		slice.Visible = false
	end
	frame.bar_edge.Visible = false
end

local function d_frames(frame)
	for _, line in ipairs(frame.lines) do
		line:Remove()
	end
	frame.name:Remove()
	frame.distance:Remove()
	frame.tracer:Remove()
	frame.bar_track:Remove()
	for _, slice in ipairs(frame.bar_slices) do
		slice:Remove()
	end
	frame.bar_edge:Remove()
end

local function TracerOrigin(viewport)
	if Config.tracerFrom == "Center" then
		return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	elseif Config.tracerFrom == "Mouse" then
		local mouse = game:GetService("UserInputService"):GetMouseLocation()
		return Vector2.new(mouse.X, mouse.Y)
	end
	return Vector2.new(viewport.X * 0.5, viewport.Y)
end

local function HealthColor(fraction)
	if fraction >= 0.5 then
		local t = (fraction - 0.5) * 2
		return Color3.fromRGB(240, 190, 60):Lerp(Color3.fromRGB(80, 220, 110), t)
	end
	local t = fraction * 2
	return Color3.fromRGB(235, 70, 70):Lerp(Color3.fromRGB(240, 190, 60), t)
end

local function DFrame(frame, model, meters, player_name, health)
	local camera = workspace.CurrentCamera
	if not (Config.box or Config.name or Config.distance or Config.tracer or Config.health) then
		clear_frame(frame)
		return
	end

	local center = model:GetBoundingBox()
	local size = model:GetExtentsSize()
	local top = camera:WorldToViewportPoint(center.Position + Vector3.new(0, size.Y * 0.55, 0))
	local bottom = camera:WorldToViewportPoint(center.Position - Vector3.new(0, size.Y * 0.55, 0))
	if top.Z <= 0 or bottom.Z <= 0 then
		clear_frame(frame)
		return
	end

	local half_height = math.clamp(math.abs(top.Y - bottom.Y) * 0.5, 5, 380)
	local half_width = half_height * 0.42
	local cx = (top.X + bottom.X) * 0.5
	local cy = (top.Y + bottom.Y) * 0.5
	local below = cy + half_height + 3

	if Config.box then
		local corners = {
			Vector2.new(cx - half_width, cy - half_height),
			Vector2.new(cx + half_width, cy - half_height),
			Vector2.new(cx + half_width, cy + half_height),
			Vector2.new(cx - half_width, cy + half_height),
		}
		for i, line in ipairs(frame.lines) do
			line.From = corners[i]
			line.To = corners[i % 4 + 1]
			line.Color = Config.color
			line.Thickness = Config.BoxThickness
			line.Visible = true
		end
	else
		for _, line in ipairs(frame.lines) do
			line.Visible = false
		end
	end

	local anchor_y = Config.box and below or cy

	frame.name.Text = player_name
	frame.name.Size = Config.textsize
	frame.name.Position = Vector2.new(cx, anchor_y)
	frame.name.Color = Config.color
	frame.name.Visible = Config.name

	frame.distance.Text = string.format("%dm", meters)
	frame.distance.Size = math.max(9, Config.textsize - 1)
	frame.distance.Position = Vector2.new(cx, Config.name and anchor_y + Config.textsize + 1 or anchor_y)
	frame.distance.Color = Config.color
	frame.distance.Visible = Config.distance

	frame.tracer.From = TracerOrigin(camera.ViewportSize)
	frame.tracer.To = Vector2.new(cx, cy)
	frame.tracer.Color = Config.color
	frame.tracer.Thickness = Config.BoxThickness
	frame.tracer.Visible = Config.tracer

		local show_bar = Config.health and health ~= nil
	frame.bar_track.Visible = show_bar
	frame.bar_edge.Visible = show_bar
	for _, slice in ipairs(frame.bar_slices) do
		slice.Visible = show_bar
	end
	if show_bar then
		local bar_width = 4
		local bar_height = half_height * 2
		local bar_x = cx - half_width - 8
		local bar_top = cy - half_height
		local filled = math.max(1, bar_height * health)
		frame.bar_track.Size = Vector2.new(bar_width, bar_height)
		frame.bar_track.Position = Vector2.new(bar_x, bar_top)

		local base = HealthColor(health)
		local count = #frame.bar_slices
		local slice_height = math.max(1, filled / count)
		for i = 1, count do
			local slice = frame.bar_slices[i]
				local shade = 0.55 + 0.45 * (i - 1) / (count - 1)
			slice.Size = Vector2.new(bar_width, slice_height)
			slice.Position = Vector2.new(bar_x, bar_top + bar_height - slice_height * i)
			slice.Color = Color3.new(base.R * shade, base.G * shade, base.B * shade)
		end

		frame.bar_edge.Size = Vector2.new(bar_width, bar_height)
		frame.bar_edge.Position = Vector2.new(bar_x, bar_top)
		frame.bar_edge.Color = Color3.fromRGB(255, 255, 255)
	end
end

local chams = {}

local function e_cham(model)
	local highlight = chams[model]
	if highlight and highlight.Parent == model then
		return highlight
	end
	highlight = Instance.new("Highlight")
	highlight.Name = "pf_cham"
	highlight.Adornee = model
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model
	chams[model] = highlight
	return highlight
end

local function s_cham(highlight)
	highlight.FillColor = Config.ChamColor
	highlight.OutlineColor = Config.ChamColor
	if Config.ChamMode == "Fill" then
		highlight.FillTransparency = Config.chamFill
		highlight.OutlineTransparency = 1
	elseif Config.ChamMode == "Outline" then
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0
	else
		highlight.FillTransparency = Config.chamFill
		highlight.OutlineTransparency = 0
	end
end

local skeletons = {}

local function n_skel()
	local lines = {}
	for i = 1, 6 do
		local line = Drawing.new("Line")
		line.Visible = false
		lines[i] = line
	end
	return lines
end

local function d_skel(lines)
	for _, line in ipairs(lines) do
		line:Remove()
	end
end

local function DrawSkeleton(lines, entry, camera)
	local model = entry.model
	local parts = {}
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") and d.Transparency < 0.95 and d.Size.Magnitude > 1 then
			parts[#parts + 1] = d
		end
	end
	if #parts == 0 then
		for _, line in ipairs(lines) do
			line.Visible = false
		end
		return false
	end

	local torso, best = nil, 0
	for _, part in ipairs(parts) do
		local volume = part.Size.X * part.Size.Y * part.Size.Z
		if volume > best then
			torso, best = part, volume
		end
	end

	local right = model:GetPivot().RightVector
	local neck = torso.Position + Vector3.new(0, torso.Size.Y * 0.5, 0)
	local hip = torso.Position - Vector3.new(0, torso.Size.Y * 0.5, 0)

		local hands, feet = {}, {}
	for _, part in ipairs(parts) do
		if part ~= torso then
			local rel = part.Position - torso.Position
			local side = rel:Dot(right)
			local lateral = math.abs(side)
			local slot = side >= 0 and 1 or 2
			if rel.Y < -torso.Size.Y * 0.4 then
				local held = feet[slot]
				if not held or part.Position.Y < held.Position.Y then
					feet[slot] = part
				end
			elseif rel.Y <= torso.Size.Y * 0.5 and lateral > torso.Size.X * 0.4 then
				local held = hands[slot]
				if not held or lateral > held.lateral then
					hands[slot] = { part = part, lateral = lateral }
				end
			end
		end
	end

	local function leg_point(slot)
		local own, other = feet[slot], feet[3 - slot]
		if own then
			return own.Position
		end
		if other then
			local lateral = (other.Position - torso.Position):Dot(right)
			local spread = math.max(math.abs(lateral), torso.Size.X * 0.22)
			return other.Position + right * ((slot == 1 and spread or -spread) - lateral)
		end
		return hip
	end

	local pairs_of_points = {
		{ entry.head.Position, neck },
		{ neck, hip },
		{ hip, leg_point(1) },
		{ hip, leg_point(2) },
		{ neck, hands[1] and hands[1].part.Position or neck },
		{ neck, hands[2] and hands[2].part.Position or neck },
	}

	local any = false
	for i, line in ipairs(lines) do
		local from, to = pairs_of_points[i][1], pairs_of_points[i][2]
		local screen_from, ok_from = camera:WorldToViewportPoint(from)
		local screen_to, ok_to = camera:WorldToViewportPoint(to)
		if ok_from and ok_to and screen_from.Z > 0 and screen_to.Z > 0 then
			line.From = Vector2.new(screen_from.X, screen_from.Y)
			line.To = Vector2.new(screen_to.X, screen_to.Y)
			line.Color = Config.ChamColor
			line.Thickness = Config.SkeletonThickness
			line.Visible = true
			any = true
		else
			line.Visible = false
		end
	end
	return any
end

local key_down = false
local toggle_aim = false

local function split_key(value)
	local out = {}
	if type(value) ~= "string" or value == "" then
		return out
	end
	for part in string.gmatch(value, "[^+]+") do
		out[#out + 1] = part
	end
	return out
end

local aim_keys = split_key("MouseButton2")

local function held_down()
	local any = false
	for _, key in ipairs(aim_keys) do
		if string.match(key, "^MouseButton%d+$") then
			local button = key == "MouseButton1" and Enum.UserInputType.MouseButton1
				or key == "MouseButton3" and Enum.UserInputType.MouseButton3
				or Enum.UserInputType.MouseButton2
			if not UserInputService:IsMouseButtonPressed(button) then
				return false
			end
			any = true
		else
			local code = Enum.KeyCode[key]
			if not code or not UserInputService:IsKeyDown(code) then
				return false
			end
			any = true
		end
	end
	return any
end

local function should_aim()
	if not Config.aim then
		return false
	end
	if Config.aimmode == "Always" then
		return true
	elseif Config.aimmode == "Toggle" then
		return toggle_aim
	end
	return key_down
end

local current = nil

local function aimtarget(entry, camera)
	local head = entry.head.Position
	if Config.aimpart == "Head" then
		return head
	end

	local box = entry.model:GetBoundingBox()
	local size = entry.model:GetExtentsSize()
	local chest = box.Position + Vector3.new(0, size.Y * 0.12, 0)

	if Config.aimpart == "Chest" then
		return chest
	elseif Config.aimpart == "Center" then
		return box.Position
	elseif Config.aimpart == "Legs" then
		return box.Position - Vector3.new(0, size.Y * 0.3, 0)
	end

	if not camera then
		return head
	end
	local viewport = camera.ViewportSize
	local middle = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	local function screen_distance(point)
		local on_screen, screen = camera:WorldToViewportPoint(point)
		if not on_screen then
			return math.huge
		end
		return (Vector2.new(screen.X, screen.Y) - middle).Magnitude
	end
	return screen_distance(head) <= screen_distance(chest) and head or chest
end

local function b_target(camera, center)
	local best, best_score = nil, Config.fov
	local scores = {}
	for _, entry in ipairs(targets()) do
		local range = (entry.head.Position - camera.CFrame.Position).Magnitude * 0.28
		if range <= Config.max_distance then
			local point = aimtarget(entry, camera)
			if visible(point) then
				local p, on_screen = camera:WorldToViewportPoint(point)
				if on_screen and p.Z > 0 then
					local score = (Vector2.new(p.X, p.Y) - center).Magnitude
					if score <= Config.fov then
						scores[entry] = score
						if score < best_score then
							best, best_score = entry, score
						end
					end
				end
			end
		end
	end
	if Config.sticky and current and scores[current] then
		return current
	end
	return best
end

local function update_a(dt)
	if not alive() then
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	if Config.aim and Config.aimmode == "Hold" then
		key_down = held_down()
	end

	local center = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
	local target = should_aim() and b_target(camera, center) or nil
	current = target

	if not target then
		Stats.target = "-"
		return
	end

	Stats.target = target.name
	local point = aimtarget(target, camera)

	if Config.aimmethod == "Mouse" and type(mousemoverel) == "function" then
		local p, on_screen = camera:WorldToViewportPoint(point)
		if on_screen and p.Z > 0 then
			mousemoverel((p.X - center.X) / Config.smooth, (p.Y - center.Y) / Config.smooth)
		end
	else
		local goal = CFrame.lookAt(camera.CFrame.Position, point)
		camera.CFrame = camera.CFrame:Lerp(goal, math.clamp(dt * Config.smooth, 0, 1))
	end
end

local function walkspeed(dt)
	local humanoid = myhumanoid()
	local root = myroot()
	if not (humanoid and root) then
		return
	end
	local direction = humanoid.MoveDirection
	if direction.Magnitude < 0.1 then
		return
	end

	local velocity = root.AssemblyLinearVelocity
	local wanted = direction.Unit * Config.walkSpeed

	if Config.walkMethod == "Impulse" then
		local gain = Vector3.new(wanted.X - velocity.X, 0, wanted.Z - velocity.Z)
		root:ApplyImpulse(gain * root.AssemblyMass)
	elseif Config.walkMethod == "CFrame" then
		root.CFrame = root.CFrame + direction.Unit * (Config.walkSpeed * dt)
	else
		root.AssemblyLinearVelocity = Vector3.new(wanted.X, velocity.Y, wanted.Z)
	end
end

local sprint_held = false
local sprint_fast = false
local sprint_tries = 0
local sprint_at = 0
local last_pace = 0

local function send_shift(down)
	pcall(function()
		game:GetService("VirtualInputManager"):SendKeyEvent(down, Enum.KeyCode.LeftShift, false, game)
	end)
end

local function r_sprint()
	if sprint_held then
		sprint_held = false
		sprint_fast = false
		sprint_tries = 0
		last_pace = 0
		send_shift(false)
	end
end

local function n_sprint()
	send_shift(false)
	task.delay(0.04, function()
		if sprint_held then
			send_shift(true)
		end
	end)
end

local function d_sprint()
	local humanoid = myhumanoid()
	if not humanoid then
		r_sprint()
		return
	end
	local aiming = should_aim() and (Config.aimmode ~= "Always" or current ~= nil)
	if aiming then
		r_sprint()
		return
	end
	if not sprint_held then
		sprint_held = true
		sprint_fast = false
		sprint_tries = 0
		sprint_at = os.clock()
		send_shift(true)
		return
	end

	local pace = humanoid.WalkSpeed
	local decaying = pace < last_pace
	last_pace = pace

	if pace >= 19 then
		sprint_fast = true
		sprint_tries = 0
		return
	end
	if not sprint_fast or decaying or humanoid.MoveDirection.Magnitude < 0.1 then
		return
	end
	if os.clock() - sprint_at < 0.25 then
		return
	end
	sprint_at = os.clock()
	sprint_tries = sprint_tries + 1
	if sprint_tries % 8 == 0 then
				sprint_at = os.clock() + 0.5
		return
	end
	n_sprint()
end

local last_state = nil
local function d_sprint()
	local humanoid = myhumanoid()
	if not humanoid then
		return
	end

	if Config.jumpMethod == "Velocity" then
		local state = humanoid:GetState()
		if state == Enum.HumanoidStateType.Jumping and last_state ~= state then
			local root = myroot()
			if root then
				local velocity = root.AssemblyLinearVelocity
				root.AssemblyLinearVelocity = Vector3.new(velocity.X, Config.jumpPower, velocity.Z)
			end
		end
		last_state = state
	else
		humanoid.UseJumpPower = true
		if math.abs(humanoid.JumpPower - Config.jumpPower) > 0.05 then
			humanoid.JumpPower = Config.jumpPower
		end
	end
end

local ija = 0 -- inf jump at
local function d_InfJump()
	local humanoid = myhumanoid()
	local root = myroot()
	if not (humanoid and root) then
		return
	end
	if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		return
	end
	local state = humanoid:GetState()
	if state == Enum.HumanoidStateType.Swimming or state == Enum.HumanoidStateType.Climbing or state == Enum.HumanoidStateType.Seated then
		return
	end
	if root.AssemblyLinearVelocity.Y > 0.5 then
		return
	end
	if os.clock() - ija < 0.06 then
		return
	end
	ija = os.clock()
	humanoid.Jump = true
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

do
	local humanoid = myhumanoid()
	if humanoid then
		Config.walkSpeed = math.clamp(math.floor(humanoid.WalkSpeed + 0.5), 14, 45)
		Config.jumpPower = math.clamp(math.floor(humanoid.JumpPower + 0.5), 29, 120)
	end
	local camera = workspace.CurrentCamera
	if camera and camera.ViewportSize.Y > 0 then
		Config.fov = math.clamp(math.floor(camera.ViewportSize.Y * 0.3), 120, 900)
	end
end

local function a_input()
	return true
end

local window = library:Window("phantom forces", { icon = "target", width = 330 })
local combat = window:Tab("Main", { icon = "target", open = { "Aimbot" } })
local misc = window:Tab("Player", { icon = "speed", open = { "Movement" } })

local visual = library:Window("visual", { icon = "eye", width = 330 })
local esp_tab = visual:Tab("ESP", { icon = "eye", open = { "ESP" } })

esp_tab:label("esp stuff")

esp_tab:section("ESP", "eye", { open = true })

local esp_toggle = esp_tab:toggle("esp", Config.esp, function(state)
	if a_input() then
		Config.esp = state
	end
end, { icon = "eye", feature = "ESP" })

esp_tab:toggle("box", Config.box, function(state)
	if a_input() then
		Config.box = state
	end
end, { icon = "target", feature = "Box", tooltip = "Outline around each player." })

esp_tab:toggle("name", Config.name, function(state)
	if a_input() then
		Config.name = state
	end
end, { icon = "user", feature = "Names" })

esp_tab:toggle("distance", Config.distance, function(state)
	if a_input() then
		Config.distance = state
	end
end, { icon = "arrow", feature = "Distance", tooltip = "Metres below the name." })

local health_toggle = esp_tab:toggle("healthbar", Config.health, function(state)
	if a_input() then
		Config.health = state
	end
end, { icon = "shield", feature = "Health bar", tooltip = "Bar left of the box, filled from PF's own health bar." })

esp_tab:toggle("tracer", Config.tracer, function(state)
	if a_input() then
		Config.tracer = state
	end
end, { icon = "arrow", feature = "Tracers" })

esp_tab:dropdown("tracer from", { "Bottom", "Center", "Mouse" }, Config.tracerFrom, function(picked)
	if a_input() then
		Config.tracerFrom = picked
	end
end, false, "arrow", { tooltip = "Where the tracer starts." })

local esp_color = esp_tab:colorpicker("color", Config.color, function(color)
	if a_input() then
		Config.color = color
	end
end, "palette", {
	presets = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 70, 70),
		Color3.fromRGB(255, 200, 60),
		Color3.fromRGB(90, 220, 255),
	},
	recent = true,
	tooltip = "Box, name, tracer and FOV circle share it.",
})

esp_tab:slider("thickness", 1, 4, Config.BoxThickness, function(value)
	if a_input() then
		Config.BoxThickness = value
	end
end, 1, "sliders", { tooltip = "Box and tracer line width." })

esp_tab:slider("text size", 9, 20, Config.textsize, function(value)
	if a_input() then
		Config.textsize = value
	end
end, 1, "code")

esp_tab:slider("esp range", 50, 1000, Config.EspRange, function(value)
	if a_input() then
		Config.EspRange = value
	end
end, 25, "arrow", { suffix = " m" })

esp_tab:dropdown("target", { "Team Base", "FFA", "Everyone" }, Config.targetMode, function(picked)
	if a_input() then
		Config.targetMode = picked
	end
end, false, "shield", {
	tooltip = "Team Base: other faction only. FFA: both sides. Everyone: every rig.",
})

-- esp_tab:section("Cham", "palette", { open = true })
--
-- local cham_toggle = esp_tab:toggle("cham", Config.cham, function(state)
-- 	if a_input() then
-- 		Config.cham = state
-- 	end
-- end, { icon = "palette", tooltip = "Coloured overlay on the rig, visible through walls." })
--
-- esp_tab:dropdown("cham mode", { "Both", "Fill", "Outline" }, Config.ChamMode, function(picked)
-- 	if a_input() then
-- 		Config.ChamMode = picked
-- 	end
-- end, false, "palette")
--
-- esp_tab:slider("cham fill", 10, 90, math.floor(Config.chamFill * 100), function(value)
-- 	if a_input() then
-- 		Config.chamFill = value / 100
-- 	end
-- end, 5, "sliders", { suffix = "%", tooltip = "Lower is more solid." })
--
-- local cham_color = esp_tab:colorpicker("cham color", Config.ChamColor, function(color)
-- 	if a_input() then
-- 		Config.ChamColor = color
-- 	end
-- end, "palette", {
-- 	presets = {
-- 		Color3.fromRGB(255, 255, 255),
-- 		Color3.fromRGB(255, 120, 120),
-- 		Color3.fromRGB(90, 220, 255),
-- 		Color3.fromRGB(255, 70, 70),
-- 	},
-- 	recent = true,
-- 	tooltip = "Cham fill, outline and skeleton all use it.",
-- })

-- esp_tab:section("Skeleton", "user", { open = true })
--
-- local skeleton_toggle = esp_tab:toggle("skeleton", Config.skeleton, function(state)
-- 	if a_input() then
-- 		Config.skeleton = state
-- 	end
-- end, { icon = "user", tooltip = "Stick figure from the rig's own parts." })
--
-- esp_tab:slider("bone thickness", 1, 4, Config.SkeletonThickness, function(value)
-- 	if a_input() then
-- 		Config.SkeletonThickness = value
-- 	end
-- end, 1, "sliders")

local cross_tab = visual:Tab("Crosshair", { icon = "target", open = { "Crosshair" } })

-- cross_tab:label("uhh.")

cross_tab:section("Crosshair", "target", { open = true })

local cross_toggle = cross_tab:toggle("crosshair", Config.crosshair, function(state)
	if a_input() then
		Config.crosshair = state
	end
end, { icon = "target", feature = "Crosshair" })

cross_tab:dropdown("style", { "Cross", "T", "Circle", "Dot" }, Config.CrossStyle, function(picked)
	if a_input() then
		Config.CrossStyle = picked
	end
end, false, "palette")

cross_tab:slider("size", 2, 30, Config.crossSize, function(value)
	if a_input() then
		Config.crossSize = value
	end
end, 1, "sliders", { suffix = " px" })

cross_tab:slider("gap", 0, 20, Config.CrossGap, function(value)
	if a_input() then
		Config.CrossGap = value
	end
end, 1, "sliders", { suffix = " px" })

cross_tab:slider("thickness", 1, 4, Config.CrossThickness, function(value)
	if a_input() then
		Config.CrossThickness = value
	end
end, 1, "sliders")

local cross_color = cross_tab:colorpicker("color", Config.crossColor, function(color)
	if a_input() then
		Config.crossColor = color
	end
end, "palette", {
	presets = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(120, 255, 140),
		Color3.fromRGB(255, 70, 70),
		Color3.fromRGB(255, 200, 60),
	},
	recent = true,
})

local hide_cross_toggle = cross_tab:toggle("hide game crosshair", Config.hide_crosshair, function(state)
	if a_input() then
		Config.hide_crosshair = state
	end
end, { icon = "eye", feature = "No game crosshair", tooltip = "Hides PF own crosshair." })

combat:label("you should know what this is")

combat:section("Aimbot", "target", { open = true })

local aim_toggle = combat:toggle("aimbot", Config.aim, function(state)
	if a_input() then
		Config.aim = state
		if not state then
			toggle_aim = false
		end
	end
end, { icon = "target", feature = "Aimbot" })

combat:dropdown("aim part", { "Head", "Chest", "Center", "Legs", "Nearest" }, Config.aimpart, function(picked)
	if a_input() then
		Config.aimpart = picked
	end
end, false, "target", { tooltip = "Where on the body the aimbot locks in" })

combat:dropdown("mode", { "Hold", "Toggle", "Always" }, Config.aimmode, function(picked)
	if a_input() then
		Config.aimmode = picked
	end
end, false, "key")

combat:dropdown("method", { "Mouse", "Camera" }, Config.aimmethod, function(picked)
	if a_input() then
		Config.aimmethod = picked
	end
end, false, "sliders", { tooltip = "mouse tracks best. Camera only nudges." })

combat:slider("fov", 60, 900, Config.fov, function(value)
	if a_input() then
		Config.fov = value
	end
end, 10, "target", { suffix = " px", tooltip = "Radius from the crosshair." })

local circle_toggle = combat:toggle("fov circle", Config.fovCircle, function(state)
	if a_input() then
		Config.fovCircle = state
	end
end, { icon = "eye", feature = "FOV circle" })

combat:slider("smooth", 1, 20, Config.smooth, function(value)
	if a_input() then
		Config.smooth = value
	end
end, 1, "speed", { tooltip = "Higher is slower." })

combat:toggle("wall check", Config.wallCheck, function(state)
	if a_input() then
		Config.wallCheck = state
	end
end, { icon = "shield", feature = "Wall check", tooltip = "On: only lockin players you can see" })

combat:toggle("sticky target", Config.sticky, function(state)
	if a_input() then
		Config.sticky = state
	end
end, { icon = "target", feature = "Sticky target", tooltip = "Stay on one player instead of switching." })

combat:slider("max range", 50, 1000, Config.max_distance, function(value)
	if a_input() then
		Config.max_distance = value
	end
end, 25, "arrow", { suffix = " m" })

combat:keybind("aim key", "MouseButton2", nil, "key", {
	mode = "hold",
	allowMouse = true,
	resetKey = "MouseButton2",
	tooltip = "Right mouse by default..",
	onChange = function(key)
		aim_keys = split_key(key)
	end,
})

misc:section("Movement", "speed", { open = true })

local sprint_toggle = misc:toggle("always sprint", Config.sprint, function(state)
	if a_input() then
		Config.sprint = state
	end
end, { icon = "speed", feature = "Always sprint", tooltip = "Holds PF's own sprint key, so PF picks the pace" })

local walk_toggle = misc:toggle("walkspeed", Config.walk, function(state)
	if a_input() then
		Config.walk = state
		if state and Config.sprint then
			library:Notify("walkspeed", "turn off always sprint so walkspeed can take over", 4, "info")
		end
	end
end, { icon = "speed", feature = "Walkspeed" })

misc:slider("speed", 14, 45, Config.walkSpeed, function(value)
	if not a_input() then
		return
	end
	Config.walkSpeed = value
end, 1, "speed", { suffix = " spd", showMax = true })

misc:dropdown("speed method", { "Velocity", "Impulse", "CFrame" }, Config.walkMethod, function(picked)
	if a_input() then
		Config.walkMethod = picked
	end
end, false, "sliders", { tooltip = "How the speed is applied." })

local jump_toggle = misc:toggle("jump power", Config.jump, function(state)
	if a_input() then
		Config.jump = state
	end
end, { icon = "arrow", feature = "Jump power" })

misc:slider("jump", 29, 120, Config.jumpPower, function(value)
	if not a_input() then
		return
	end
	Config.jumpPower = value
end, 5, "arrow", { suffix = " jp", showMax = true })

misc:dropdown("jump method", { "Property", "Velocity" }, Config.jumpMethod, function(picked)
	if a_input() then
		Config.jumpMethod = picked
	end
end, false, "sliders", { tooltip = "JumpPower property, or launch velocity." })

local inf_jump_toggle = misc:toggle("infinite jump", Config.infJump, function(state)
	if a_input() then
		Config.infJump = state
	end
end, { icon = "arrow", feature = "Infinite jump", tooltip = "GRRRR" })

local settings = library:Window("settings", { icon = "sliders", width = 320 })
local defaults = library:GetDesign()

settings:section("Config", "save", { open = true })
local profile_box = settings:textbox("profile", library:GetProfile(), nil, "folder", { placeholder = "default" })

local autosave = settings:toggle("autosave", library:GetAutoSave(), function(state)
	library:SetAutoSave(state)
end, { icon = "save", feature = false, tooltip = "Writes the profile as you change rows." })
autosave:Set(library:GetAutoSave(), true)

settings:button("save now", function()
	local name = profile_box:Get()
	local ok = library:SaveConfig(name ~= "" and name or nil)
	library:Notify("config", ok and ("saved " .. library:GetProfile()) or (library:GetConfigError() or "could not save"), 3, ok and "good" or "bad")
end, "save", { tooltip = "Writes the profile and keeps a .bak." })

settings:button("load profile", function()
	local name = profile_box:Get()
	library:LoadConfig(name ~= "" and name or nil)
	library:Notify("config", "loaded " .. library:GetProfile(), 2, "info")
end, "folder", { variant = "secondary" })

settings:section("Menu", "key", { open = true })

local default_key = "RightControl+LeftShift"
local menu_bind
menu_bind = settings:keybind("open / close ui", library:GetToggleKey(), nil, "key", {
	combo = true,
	allowMouse = false,
	resetKey = default_key,
	tooltip = "Click the pill, then hold the keys.",
	onChange = function(key)
		if not key or key == "" then
			library:SetToggleKey(default_key)
			if menu_bind then
				menu_bind:Set(default_key)
			end
			return
		end
		if key ~= library:GetToggleKey() then
			library:SetToggleKey(key)
		end
	end,
})

settings:section("Appearance", "palette", { open = true })
settings:toggle("watermark", Config.watermark, function(state)
	if a_input() then
		Config.watermark = state
	end
end, { icon = "info", feature = false, tooltip = "Live rig count, team and current target." })

local feature_shown = true
if type(library.GetFeatureList) == "function" then
	local _, shown = library:GetFeatureList()
	feature_shown = shown == true
end

if type(library.SetFeatureListVisible) == "function" then
	settings:toggle("feature list", feature_shown, function(state)
		if a_input() then
			library:SetFeatureListVisible(state)
		end
	end, { icon = "list", feature = false, tooltip = "lists what is turned on" })
end

if type(library.SetFeatureListAll) == "function" then
	settings:toggle("list every active row", library:GetFeatureListAll(), function(state)
		if a_input() then
			library:SetFeatureListAll(state)
		end
	end, { icon = "list", feature = false, tooltip = "Also lists sliders, dropdowns and keybinds." })
end

if type(library.SetFeatureListRGB) == "function" then
	settings:toggle("rainbow feature list", library:GetFeatureListRGB(), function(state)
		if a_input() then
			library:SetFeatureListRGB(state)
		end
	end, { icon = "palette", feature = false, tooltip = "rainbow gradient down the list" })
end

local accent = settings:colorpicker("accent", defaults.accent, function(color)
	library:Design({ accent = color })
end, "palette", {
	presets = {
		Color3.fromRGB(230, 162, 58),
		Color3.fromRGB(197, 84, 54),
		"#69A9FF",
		"#74C47A",
	},
	recent = true,
})

settings:button("reset theme", function()
	library:Design(defaults)
	accent:Set(defaults.accent, true)
	library:Notify("theme", "default colours restored", 2, "info")
end, "refresh", { variant = "secondary" })

settings:section("Script", "trash", { open = true })

settings:button("unload", function()
	shared.pf.unload_requested = true
end, "trash", { variant = "danger", confirm = "Click again to unload" })

toggle_aim = false

local info = Drawing.new("Text")
info.Size = 13
info.Color = Color3.fromRGB(220, 220, 220)
info.Outline = true
info.Position = Vector2.new(12, 12)
info.Visible = false

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.NumSides = 60
FovCircle.Transparency = 0.75
FovCircle.Color = Config.color
FovCircle.Visible = false

local Crosslines = {}
for _, key in ipairs({ "up", "down", "left", "right" }) do
	local line = Drawing.new("Line")
	line.Visible = false
	Crosslines[key] = line
end

local C_Circle = Drawing.new("Circle")
C_Circle.Filled = false
C_Circle.NumSides = 48
C_Circle.Visible = false

local dots = Drawing.new("Circle")
dots.Filled = true
dots.NumSides = 24
dots.Visible = false

local cross_frames, cross_hidden = {}, nil

local function game_crosshairs()
	local valid = #cross_frames > 0
	for _, frame in ipairs(cross_frames) do
		if not frame.Parent then
			valid = false
			break
		end
	end
	if valid then
		return cross_frames
	end

	local found = {}
	local gui = LP:FindFirstChild("PlayerGui")
	local hud = gui and gui:FindFirstChild("HudScreenGui")
	if hud then
		for _, item in ipairs(hud:GetDescendants()) do
			if string.find(item.Name, "DisplayCrosshairs") then
				found[#found + 1] = item
			end
		end
	end
	cross_frames = found
	return found
end

local function u_crosshair(camera)
	local center = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
	for _, line in pairs(Crosslines) do
		line.Visible = false
	end
	C_Circle.Visible = false
	dots.Visible = false

	local hide = Config.crosshair and Config.hide_crosshair
	if hide ~= cross_hidden then
		for _, frame in ipairs(game_crosshairs()) do
			frame.Visible = not hide
		end
		cross_hidden = hide
	end

	if not Config.crosshair then
		return
	end

	local style = Config.CrossStyle
	local size, gap = Config.crossSize, Config.CrossGap
	local color = Config.crossColor

	local function arm(key, from, to)
		local line = Crosslines[key]
		line.From = from
		line.To = to
		line.Color = color
		line.Thickness = Config.CrossThickness
		line.Visible = true
	end

	if style == "Circle" then
		C_Circle.Position = center
		C_Circle.Radius = size
		C_Circle.Thickness = Config.CrossThickness
		C_Circle.Color = color
		C_Circle.Visible = true
	elseif style == "Dot" then
		dots.Position = center
		dots.Radius = math.max(1, Config.CrossThickness)
		dots.Color = color
		dots.Visible = true
	else
		arm("up", Vector2.new(center.X, center.Y - gap), Vector2.new(center.X, center.Y - gap - size))
		arm("left", Vector2.new(center.X - gap, center.Y), Vector2.new(center.X - gap - size, center.Y))
		arm("right", Vector2.new(center.X + gap, center.Y), Vector2.new(center.X + gap + size, center.Y))
		if style == "Cross" then
			arm("down", Vector2.new(center.X, center.Y + gap), Vector2.new(center.X, center.Y + gap + size))
		end
	end
end

local watermark_text = nil

local function draw_watermark()
	if not Config.watermark then
		if watermark_text then
			library:SetWatermarkVisible(false)
			watermark_text = nil
		end
		return
	end
	local text = string.format("pf  %d rigs  %s  %s", Stats.rigs, Stats.team, Stats.target)
	if text ~= watermark_text then
		library:SetWatermark(text)
		watermark_text = text
	end
end

local aim_held = {}

local function input_id(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local name = input.KeyCode and input.KeyCode.Name
		return name and name ~= "Unknown" and name or nil
	end
	local name = input.UserInputType.Name
	if string.match(name, "^MouseButton%d+$") or string.match(name, "^Gamepad%d+$") then
		return name
	end
	return nil
end

local function refresh_aim()
	local held = #aim_keys > 0
	for _, key in ipairs(aim_keys) do
		if not aim_held[key] then
			held = false
			break
		end
	end
	if held and not key_down and Config.aimmode == "Toggle" then
		toggle_aim = not toggle_aim
	end
	key_down = held
end

local input_began = UserInputService.InputBegan:Connect(function(input)
	if not alive() or UserInputService:GetFocusedTextBox() then
		return
	end
	local id = input_id(input)
	if not id then
		return
	end
	aim_held[id] = true
	refresh_aim()
end)

local input_ended = UserInputService.InputEnded:Connect(function(input)
	local id = input_id(input)
	if not id then
		return
	end
	aim_held[id] = nil
	refresh_aim()
end)

local render

render = RunService.RenderStepped:Connect(function()
	if not alive() then
		if render then
			render:Disconnect()
			render = nil
		end
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local shown, all = targets()
	local teams = roster()
	Stats.rigs = #all
	Stats.shown = #shown
	Stats.team = teams.mine or "-"
	Stats.enemies = 0
	for _, entry in ipairs(all) do
		if entry.enemy then
			Stats.enemies = Stats.enemies + 1
		end
	end
	Stats.friends = #all - Stats.enemies

	local seen, cham_seen, bone_seen = {}, {}, {}
	if Config.esp or Config.cham or Config.skeleton then
		for _, entry in ipairs(shown) do
			local meters = math.floor((entry.head.Position - camera.CFrame.Position).Magnitude * 0.28)
			if meters <= Config.EspRange then
				local model = entry.model
				if Config.esp then
					seen[model] = true
					local frame = frames[model]
					if not frame then
						frame = NewFrame()
						frames[model] = frame
					end
					DFrame(frame, model, meters, entry.name, Config.health and health_of(model) or nil)
				end
				if Config.cham then
					cham_seen[model] = true
					s_cham(e_cham(model))
				end
				if Config.skeleton then
					local lines = skeletons[model]
					if not lines then
						lines = n_skel()
						skeletons[model] = lines
					end
					if DrawSkeleton(lines, entry, camera) then
						bone_seen[model] = true
					end
				end
			end
		end
	end

	local held = 0
	for model, frame in pairs(frames) do
		if seen[model] then
			held = held + 1
		else
			clear_frame(frame)
			if not model:IsDescendantOf(workspace) then
				d_frames(frame)
				frames[model] = nil
			end
		end
	end
	Stats.frames = held

	local painted = 0
	for model, highlight in pairs(chams) do
		if cham_seen[model] then
			painted = painted + 1
		else
			highlight:Destroy()
			chams[model] = nil
		end
	end
	Stats.chams = painted

	local drawn = 0
	for model, lines in pairs(skeletons) do
		if bone_seen[model] then
			drawn = drawn + 1
		else
			for _, line in ipairs(lines) do
				line.Visible = false
			end
			if not model:IsDescendantOf(workspace) then
				d_skel(lines)
				skeletons[model] = nil
			end
		end
	end
	Stats.bones = drawn

	u_crosshair(camera)

	FovCircle.Position = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
	FovCircle.Radius = Config.fov
	FovCircle.Color = Config.color
	FovCircle.Visible = Config.fovCircle

	if Stats.rigs > 0 then
		info.Text = string.format(
			"rigs %d  shown %d  %s  ->  %s",
			Stats.rigs,
			Stats.shown,
			Stats.team,
			Stats.target
		)
		info.Visible = true
	else
		info.Visible = false
	end

	draw_watermark()
end)

RunService:BindToRenderStep("pf_aim", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if alive() then
		update_a(dt)
	end
end)

local physics = RunService.Heartbeat:Connect(function(dt)
	if not alive() then
		physics:Disconnect()
		return
	end
	if Config.sprint then
		d_sprint()
	else
		r_sprint()
		if Config.walk then
			walkspeed(dt)
		end
	end
	if Config.jump then
		d_sprint()
	end
	if Config.infJump then
		d_InfJump()
	end
end)

local function destroy()
	pcall(function()
		RunService:UnbindFromRenderStep("pf_aim")
	end)
	if render then
		render:Disconnect()
		render = nil
	end
	physics:Disconnect()
	input_began:Disconnect()
	input_ended:Disconnect()
	for _, frame in pairs(frames) do
		d_frames(frame)
	end
	frames = {}
	for _, highlight in pairs(chams) do
		highlight:Destroy()
	end
	chams = {}
	for _, lines in pairs(skeletons) do
		d_skel(lines)
	end
	skeletons = {}
	for _, line in pairs(Crosslines) do
		line:Remove()
	end
	C_Circle:Remove()
	dots:Remove()
	if cross_hidden then
		for _, frame in ipairs(game_crosshairs()) do
			frame.Visible = true
		end
		cross_hidden = nil
	end
	r_sprint()
	info:Remove()
	FovCircle:Remove()

	pcall(function()
		library:SetWatermarkVisible(false)
	end)

	local humanoid = myhumanoid()
	if humanoid then
		humanoid.WalkSpeed = 14
		humanoid.JumpPower = 29
	end

	if shared.pf and shared.pf.destroy == destroy then
		shared.pf = nil
	end
	if library.Destroy then
		pcall(library.Destroy, library)
	end
	print("[pf] unloaded")
end

shared.pf = {
	destroy = destroy,
	config = Config,
	stats = Stats,
	rigs = rigs,
	targets = targets,
	roster = roster,
	humanoid = myhumanoid,
	root = myroot,
	unload_requested = false,
}

task.spawn(function()
	while alive() do
		task.wait(0.3)
		if shared.pf and shared.pf.unload_requested then
			destroy()
			break
		end
	end
end)

library:Notify("phantom forces", "loaded - " .. #rigs() .. " rigs", 3, "good")
-- print(string.format("[pf] testy - %d rigs, team %s, walk %d/%s, jump %d/%s", #rigs(), roster().mine or "?", Config.walkSpeed, Config.walkMethod, Config.jumpPower,Config.jumpMethod))
