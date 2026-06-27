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


-- /version 2 w.i.p

-- [ section 1: services & references ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local local_player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local viewport = camera.ViewportSize

local rayparams = RaycastParams.new()
rayparams.FilterType = Enum.RaycastFilterType.Exclude
rayparams.IgnoreWater = true

-- [ section 2: configuration ]

local config = {
	-- toggleable
	enabled = true,
	players = true,
	boxes = true,
	names = true,
	tracers = true,
	health = true,
	skeletons = true,
	distance = true,
	offscreen_arrows = true,
	lookat_lines = true,
	head_circles = true,
	chams = false,
	weapon_esp = false,

	-- checks
	wall_check = false, -- useless but if some of you guys use it than im pretty shock
	team_check = false,
	team_color = false,

	-- box settings
	box_type = "corners", -- "2d", "3d", "corners", "diamond", "filled"
	box_color = Color3.fromRGB(220, 220, 220),
	box_outline = Color3.fromRGB(15, 15, 15),
	box_transparency = 0.9,
	box_thickness = 1,
	diamond_ratio = 0.6,

	-- name settings
	name_color = Color3.fromRGB(240, 240, 240),
	name_size = 13,

	-- tracer settings
	tracer_color = Color3.fromRGB(160, 160, 160),
	tracer_transparency = 0.45,
	tracer_thickness = 1,
	tracer_position = "bottom", -- "bottom", "center", "top", "mouse"

	-- health settings
	health_high = Color3.fromRGB(0, 220, 100),
	health_mid = Color3.fromRGB(255, 200, 0),
	health_low = Color3.fromRGB(230, 40, 40),
	health_bar_style = "vertical", -- "vertical", "horizontal", "text"
	health_text_size = 11,

	-- skeleton settings
	skeleton_color = Color3.fromRGB(180, 180, 180),
	skeleton_transparency = 0.55,
	skeleton_thickness = 1,

	-- distance settings
	distance_color = Color3.fromRGB(150, 150, 150),
	max_distance = 3000,

	-- offscreen arrow settings
	offscreen_color = Color3.fromRGB(230, 230, 230),
	offscreen_size = 20,
	arrow_transparency = 0.85,

	-- lookat line settings
	lookat_color = Color3.fromRGB(130, 130, 130),
	lookat_length = 8,

	-- head circle settings
	head_circle_color = Color3.fromRGB(0, 190, 255),
	head_circle_radius = 0.7,
	head_circle_sides = 16,

	-- weapon esp settings
	weapon_color = Color3.fromRGB(255, 210, 90),
	weapon_size = 10,

	-- smooth rendering
	smooth_enabled = true,
	smooth_factor = 0.15,

	-- color presets
	color_preset = "custom", -- "neon", "pastel", "retro", "fire", "midnight", "custom"
}

-- color present (premade themes)
local presets = {
	neon = {
		box = Color3.fromRGB(0, 220, 255),
		name = Color3.fromRGB(255, 255, 255),
		tracer = Color3.fromRGB(100, 200, 255),
		skeleton = Color3.fromRGB(180, 180, 180),
		distance = Color3.fromRGB(150, 150, 150),
		offscreen = Color3.fromRGB(255, 150, 50),
		lookat = Color3.fromRGB(120, 120, 120),
		head_circle = Color3.fromRGB(0, 200, 255),
		weapon = Color3.fromRGB(255, 200, 80),
		health_high = Color3.fromRGB(0, 255, 150),
		health_low = Color3.fromRGB(255, 50, 50),
	},
	pastel = {
		box = Color3.fromRGB(180, 130, 200),
		name = Color3.fromRGB(130, 180, 200),
		tracer = Color3.fromRGB(200, 180, 130),
		skeleton = Color3.fromRGB(130, 200, 180),
		distance = Color3.fromRGB(200, 130, 180),
		offscreen = Color3.fromRGB(180, 200, 130),
		lookat = Color3.fromRGB(130, 200, 200),
		head_circle = Color3.fromRGB(200, 130, 130),
		weapon = Color3.fromRGB(180, 180, 180),
		health_high = Color3.fromRGB(130, 200, 130),
		health_low = Color3.fromRGB(200, 130, 130),
	},
	retro = {
		box = Color3.fromRGB(0, 255, 0),
		name = Color3.fromRGB(0, 255, 0),
		tracer = Color3.fromRGB(0, 200, 0),
		skeleton = Color3.fromRGB(0, 255, 0),
		distance = Color3.fromRGB(0, 200, 0),
		offscreen = Color3.fromRGB(0, 255, 0),
		lookat = Color3.fromRGB(0, 200, 0),
		head_circle = Color3.fromRGB(0, 255, 0),
		weapon = Color3.fromRGB(0, 255, 0),
		health_high = Color3.fromRGB(0, 255, 0),
		health_low = Color3.fromRGB(255, 100, 0),
	},
	fire = {
		box = Color3.fromRGB(255, 100, 0),
		name = Color3.fromRGB(255, 200, 0),
		tracer = Color3.fromRGB(255, 50, 0),
		skeleton = Color3.fromRGB(255, 150, 0),
		distance = Color3.fromRGB(255, 80, 0),
		offscreen = Color3.fromRGB(255, 120, 0),
		lookat = Color3.fromRGB(255, 180, 0),
		head_circle = Color3.fromRGB(255, 100, 50),
		weapon = Color3.fromRGB(255, 200, 100),
		health_high = Color3.fromRGB(0, 255, 0),
		health_low = Color3.fromRGB(255, 0, 0),
	},
	midnight = {
		box = Color3.fromRGB(100, 150, 255),
		name = Color3.fromRGB(180, 200, 255),
		tracer = Color3.fromRGB(80, 120, 200),
		skeleton = Color3.fromRGB(120, 140, 180),
		distance = Color3.fromRGB(100, 130, 170),
		offscreen = Color3.fromRGB(150, 180, 255),
		lookat = Color3.fromRGB(90, 120, 160),
		head_circle = Color3.fromRGB(80, 180, 255),
		weapon = Color3.fromRGB(200, 220, 255),
		health_high = Color3.fromRGB(80, 200, 120),
		health_low = Color3.fromRGB(220, 60, 80),
	},
	custom = {}
}

local function applypreset(name)
	local p = presets[name]
	if not p or name == "custom" then return end
	for k, c in pairs(p) do
		if config[k .. "_color"] ~= nil then config[k .. "_color"] = c end
	end
	config.box_color = p.box
	config.tracer_color = p.tracer
	config.skeleton_color = p.skeleton
	config.distance_color = p.distance
	config.offscreen_color = p.offscreen
	config.lookat_color = p.lookat
	config.head_circle_color = p.head_circle
	config.weapon_color = p.weapon
	config.name_color = p.name
	config.health_high = p.health_high
	config.health_low = p.health_low
end

applypreset(config.color_preset)

-- [ section 3: state management ]

local cache = {}
local conns = {}
local drawref = getgenv and getgenv().Drawing or Drawing

local bones15 = {
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

local bones6 = {
	{"Head", "Torso"},
	{"Torso", "Left Arm"},
	{"Left Arm", "Left Leg"},
	{"Torso", "Right Arm"},
	{"Right Arm", "Right Leg"}
}

local edges3d = {
	{1,2}, {2,3}, {3,4}, {4,1},
	{5,6}, {6,7}, {7,8}, {8,5},
	{1,5}, {2,6}, {3,7}, {4,8}
}

-- [ section 4: utility ]
local function mkdraw(cls, props)
	if not drawref then return nil end
	local ok, obj = pcall(function() return drawref.new(cls) end)
	if not ok or not obj then return nil end
	if props then
		for k, v in pairs(props) do
			pcall(function() obj[k] = v end)
		end
	end
	return obj
end

--solara drawingg lib is weird and the drawing is stuck in your screen so yea idk :shrug:
local function kill(t)
	if type(t) ~= "table" then return end
	for _, v in pairs(t) do
		if type(v) == "table" then
			kill(v)
		elseif typeof(v) == "RBXScriptConnection" then
			pcall(function() v:Disconnect() end)
		elseif type(v) == "userdata" then
			pcall(function() v.Visible = false end)
			pcall(function() v:Remove() end)
		end
	end
end

local function hide(vis)
	if not vis then return end
	local list = {
		vis.box, vis.box_outline, vis.name_label,
		vis.health_bar, vis.health_bar_outline, vis.health_text,
		vis.distance_label, vis.tracer_line, vis.lookat_line,
		vis.arrow_fill, vis.arrow_outline, vis.weapon_label
	}
	for _, o in ipairs(list) do
		if o then pcall(function() o.Visible = false end) end
	end
	for _, l in ipairs(vis.box_corner_lines or {}) do pcall(function() l.Visible = false end) end
	for _, l in ipairs(vis.box_3d_lines or {}) do pcall(function() l.Visible = false end) end
	for _, l in ipairs(vis.box_diamond_lines or {}) do pcall(function() l.Visible = false end) end
	for _, l in ipairs(vis.head_circle_segments or {}) do pcall(function() l.Visible = false end) end
	for _, d in ipairs(vis.skeleton_cache or {}) do
		if d[1] then pcall(function() d[1].Visible = false end) end
	end
	if vis.cham then pcall(function() vis.cham.Enabled = false; vis.cham.Parent = nil end) end
end

local function ok(char, name)
	if not char then return false end
	local p = char:FindFirstChild(name)
	return p ~= nil and p.Parent ~= nil
end

local function getbones(char)
	if char:FindFirstChild("UpperTorso") then return bones15 end
	return bones6
end

local function w2s(pos)
	local ok2, r = pcall(function() return camera:WorldToViewportPoint(pos) end)
	if ok2 and r then return Vector2.new(r.X, r.Y), r.Z > 0 end
	return Vector2.new(0, 0), false
end

local function walled(pos, ignore)
	if not config.wall_check then return false end
	local origin = camera.CFrame.Position
	local dir = pos - origin
	rayparams.FilterDescendantsInstances = {local_player.Character, ignore}
	local ok2, r = pcall(function() return Workspace:Raycast(origin, dir, rayparams) end)
	return ok2 and r ~= nil
end

local function hpclr(r)
	if r > 0.5 then return config.health_mid:Lerp(config.health_high, (r - 0.5) * 2) end
	return config.health_low:Lerp(config.health_mid, r * 2)
end

local function teamclr(p, fb)
	if config.team_color and p.Team and p.Team.TeamColor then return p.Team.TeamColor.Color end
	return fb
end

local function dista(d)
	if d > config.max_distance then return 0 end
	local fs = config.max_distance * 0.7
	if d > fs then return 1 - (d - fs) / (config.max_distance - fs) end
	return 1
end

local function getweapon(char) -- thought this would be useful for fps...
	if not char then return nil end
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Tool") then return c.Name end
	end
	local bp = local_player:FindFirstChild("Backpack")
	if bp then
		for _, c in ipairs(bp:GetChildren()) do
			if c:IsA("Tool") then return c.Name end
		end
	end
	return nil
end

local function tracerstart()
	local m = config.tracer_position
	if m == "top" then return Vector2.new(viewport.X / 2, 0)
	elseif m == "center" then return Vector2.new(viewport.X / 2, viewport.Y / 2)
	elseif m == "mouse" then return UserInputService:GetMouseLocation()
	else return Vector2.new(viewport.X / 2, viewport.Y) end
end

local function lerp(a, b, t)
	if not config.smooth_enabled or not a then return b end
	return a + (b - a) * math.clamp(t, 0, 1)
end

-- [ section 5: drawing stuff ]

local function buildskel(vis, char)
	for _, d in ipairs(vis.skeleton_cache or {}) do
		if d[1] then pcall(function() d[1]:Remove() end) end
	end
	vis.skeleton_cache = {}
	local bones = getbones(char)
	for _, bp in ipairs(bones) do
		local p1, p2 = bp[1], bp[2]
		if ok(char, p1) and ok(char, p2) then
			local l = mkdraw("Line", {
				Thickness = config.skeleton_thickness,
				Color = config.skeleton_color,
				Transparency = config.skeleton_transparency,
				Visible = false
			})
			if l then table.insert(vis.skeleton_cache, {l, p1, p2}) end
		end
	end
	vis._skelbones = bones
end

-- [ section 6: esp core ]

local function mkvis(player)
	local v = {
		box_outline = mkdraw("Square", {
			Color = config.box_outline, Thickness = 2, Filled = false,
			Visible = false, Transparency = config.box_transparency
		}),
		box = mkdraw("Square", {
			Color = config.box_color, Thickness = config.box_thickness,
			Filled = false, Visible = false, Transparency = config.box_transparency
		}),
		box_corner_lines = {}, box_3d_lines = {}, box_diamond_lines = {},

		name_label = mkdraw("Text", {
			Color = config.name_color, Outline = true, Center = true,
			Size = config.name_size, Font = 2, Visible = false, Transparency = 1
		}),
		distance_label = mkdraw("Text", {
			Color = config.distance_color, Size = 11, Font = 2,
			Outline = true, Center = true, Visible = false, Transparency = 0.85
		}),
		weapon_label = mkdraw("Text", {
			Color = config.weapon_color, Size = config.weapon_size, Font = 2,
			Outline = true, Center = true, Visible = false, Transparency = 0.9
		}),
		health_text = mkdraw("Text", {
			Color = Color3.new(1, 1, 1), Size = config.health_text_size, Font = 2,
			Outline = true, Center = true, Visible = false, Transparency = 0.9
		}),

		health_bar_outline = mkdraw("Line", {
			Thickness = 5, Color = Color3.new(0, 0, 0),
			Visible = false, Transparency = 0.75
		}),
		health_bar = mkdraw("Line", {
			Thickness = 3, Visible = false, Transparency = 0.85
		}),

		tracer_line = mkdraw("Line", {
			Thickness = config.tracer_thickness, Color = config.tracer_color,
			Transparency = config.tracer_transparency, Visible = false
		}),

		arrow_fill = mkdraw("Quad", {
			Color = config.offscreen_color, Thickness = 0, Filled = true,
			Visible = false, Transparency = config.arrow_transparency
		}),
		arrow_outline = mkdraw("Quad", {
			Color = config.offscreen_color, Thickness = 2, Filled = false,
			Visible = false, Transparency = config.arrow_transparency
		}),

		lookat_line = mkdraw("Line", {
			Thickness = 1, Color = config.lookat_color,
			Visible = false, Transparency = 0.8
		}),

		head_circle_segments = {}, skeleton_cache = {}, cham = nil,

		_smooth = { box_pos = nil, box_size = nil, head_screen = nil, foot_screen = nil },
		_char = nil, _charadded = nil
	}

	local ok2, h = pcall(function()
		local hl = Instance.new("Highlight")
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Enabled = false
		return hl
	end)
	if ok2 and h then v.cham = h end

	for i = 1, 8 do
		v.box_corner_lines[i] = mkdraw("Line", {
			Thickness = 2, Color = config.box_color,
			Visible = false, Transparency = config.box_transparency
		})
	end
	for i = 1, 12 do
		v.box_3d_lines[i] = mkdraw("Line", {
			Thickness = 1, Color = config.box_color,
			Visible = false, Transparency = config.box_transparency
		})
	end
	for i = 1, 4 do
		v.box_diamond_lines[i] = mkdraw("Line", {
			Thickness = config.box_thickness, Color = config.box_color,
			Visible = false, Transparency = config.box_transparency
		})
	end
	for i = 1, config.head_circle_sides do
		v.head_circle_segments[i] = mkdraw("Line", {
			Thickness = 1, Color = config.head_circle_color,
			Visible = false, Transparency = 0.8
		})
	end

	cache[player] = v
	return v
end

local function cleanup(player)
	local v = cache[player]
	if not v then return end
	if v._charadded then pcall(function() v._charadded:Disconnect() end) end
	if v.cham then pcall(function() v.cham.Parent = nil; v.cham.Enabled = false; v.cham:Destroy() end) end
    -- hide(v) <- this could leak a tiny bit of memory but wont be visible
	kill(v)
	cache[player] = nil
end

local function cleanupall()
	for p in pairs(cache) do cleanup(p) end
	cache = {}
end

local function corners3d(root)
	local cf = root.CFrame
	local s = Vector3.new(5, 7, 2)
	local hx, hy, hz = s.X / 2, s.Y / 2, s.Z / 2
	return {
		cf * CFrame.new(-hx, -hy, -hz), cf * CFrame.new( hx, -hy, -hz),
		cf * CFrame.new( hx,  hy, -hz), cf * CFrame.new(-hx,  hy, -hz),
		cf * CFrame.new(-hx, -hy,  hz), cf * CFrame.new( hx, -hy,  hz),
		cf * CFrame.new( hx,  hy,  hz), cf * CFrame.new(-hx,  hy,  hz)
	}
end

local function update(player, v)
	local char = player.Character
	if not char then hide(v); return end

	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local hum = char:FindFirstChildOfClass("Humanoid")
	local foot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
	if not root or not head or not hum or not foot then hide(v); return end

	if config.team_check and player.Team and player.Team == local_player.Team then
		hide(v); return
	end

	local campos = camera.CFrame.Position
	local dist = (campos - root.Position).Magnitude
	if dist > config.max_distance then hide(v); return end

	if walled(root.Position, char) then hide(v); return end

	local rootscr, onscr = w2s(root.Position)
	local headraw = w2s(head.Position + Vector3.new(0, 0.5, 0))
	local footraw = w2s(foot.Position - Vector3.new(0, 0.5, 0))

	local headscr = lerp(v._smooth.head_screen, headraw, config.smooth_factor)
	local footscr = lerp(v._smooth.foot_screen, footraw, config.smooth_factor)
	v._smooth.head_screen = headscr
	v._smooth.foot_screen = footscr

	local bh = math.abs(headscr.Y - footscr.Y)
	local bw = bh * 0.5
	local cx = math.floor((headscr.X + footscr.X) / 2)
	local cy = math.floor((headscr.Y + footscr.Y) / 2)
	local szraw = Vector2.new(math.floor(bw), math.floor(bh))
	local posraw = Vector2.new(cx - szraw.X / 2, cy - szraw.Y / 2)

	local sz = v._smooth.box_size and lerp(v._smooth.box_size, szraw, config.smooth_factor) or szraw
	local pos = v._smooth.box_pos and lerp(v._smooth.box_pos, posraw, config.smooth_factor) or posraw
	v._smooth.box_size = sz
	v._smooth.box_pos = pos

	local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
	local alpha = dista(dist)

	-- offscreen arrows
	if not onscr then
		hide(v)
		if config.offscreen_arrows then
			local sc = Vector2.new(viewport.X / 2, viewport.Y / 2)
			local to = Vector2.new(rootscr.X, rootscr.Y) - sc
			if to.Magnitude > 0 then
				local dir = to.Unit
				local angle = math.atan2(dir.Y, dir.X)
				local ad = math.min(config.offscreen_size * 4, 130)
				local cl = sc + dir * ad
				local sz2 = config.offscreen_size
				local ca = math.cos(angle + math.pi / 2)
				local sa = math.sin(angle + math.pi / 2)
				local function rot(px, py)
					return cl + Vector2.new(px * ca - py * sa, px * sa + py * ca)
				end
				local tip = rot(0, 0)
				local left = rot(-sz2 * 0.35, sz2 * 0.85)
				local right = rot(sz2 * 0.35, sz2 * 0.85)
				pcall(function()
					v.arrow_fill.PointA = tip; v.arrow_fill.PointB = left
					v.arrow_fill.PointC = right; v.arrow_fill.PointD = tip
					v.arrow_fill.Color = config.offscreen_color
					v.arrow_fill.Transparency = config.arrow_transparency * alpha
					v.arrow_fill.Visible = true
				end)
				pcall(function()
					v.arrow_outline.PointA = tip; v.arrow_outline.PointB = left
					v.arrow_outline.PointC = right; v.arrow_outline.PointD = tip
					v.arrow_outline.Color = config.box_outline
					v.arrow_outline.Transparency = config.arrow_transparency * alpha
					v.arrow_outline.Visible = true
				end)
			end
		end
		return
	end

	hide(v)

	-- chams
	if config.chams and v.cham then
		local cc = teamclr(player, config.box_color)
		pcall(function()
			v.cham.Parent = char; v.cham.FillColor = cc
			v.cham.OutlineColor = config.box_outline
			v.cham.FillTransparency = 0.5; v.cham.OutlineTransparency = 0
			v.cham.Enabled = true
		end)
	end

	local bc = teamclr(player, config.box_color)

	-- box
	if config.boxes then
		local bt = config.box_type
		if bt == "2d" or bt == "filled" then
			if bt == "2d" then
				pcall(function()
					v.box.Size = sz; v.box.Position = pos; v.box.Color = bc
					v.box.Filled = false; v.box.Transparency = config.box_transparency * alpha
					v.box.Visible = true
				end)
				pcall(function()
					v.box_outline.Size = sz; v.box_outline.Position = pos
					v.box_outline.Transparency = config.box_transparency * alpha
					v.box_outline.Visible = true
				end)
			else
				pcall(function()
					v.box.Size = sz; v.box.Position = pos; v.box.Color = bc
					v.box.Filled = true; v.box.Transparency = 0.35 * alpha
					v.box.Visible = true
				end)
				pcall(function()
					v.box_outline.Size = sz; v.box_outline.Position = pos
					v.box_outline.Filled = false
					v.box_outline.Transparency = config.box_transparency * alpha
					v.box_outline.Visible = true
				end)
			end
		elseif bt == "3d" then
			local corners = corners3d(root)
			local pts = {}
			for i, c in ipairs(corners) do pts[i] = w2s(c.Position) end
			for i, e in ipairs(edges3d) do
				local l = v.box_3d_lines[i]
				if l then
					pcall(function()
						l.From = pts[e[1]]; l.To = pts[e[2]]
						l.Color = bc; l.Transparency = config.box_transparency * alpha
						l.Visible = true
					end)
				end
			end
		elseif bt == "diamond" then -- ...
			local top = Vector2.new(cx, pos.Y)
			local bot = Vector2.new(cx, pos.Y + sz.Y)
			local lft = Vector2.new(pos.X - sz.X * config.diamond_ratio, cy)
			local rgt = Vector2.new(pos.X + sz.X * (1 + config.diamond_ratio), cy)
			local dp = {top, rgt, bot, lft}
			for i = 1, 4 do
				local l = v.box_diamond_lines[i]
				if l then
					pcall(function()
						l.From = dp[i]; l.To = dp[i % 4 + 1]
						l.Color = bc; l.Transparency = config.box_transparency * alpha
						l.Visible = true
					end)
				end
			end
		else
			local cl = math.min(sz.X, sz.Y) * 0.25
			local px, py = pos.X, pos.Y
			local cdefs = {
				{px, py, px + cl, py}, {px, py, px, py + cl},
				{px + sz.X, py, px + sz.X - cl, py}, {px + sz.X, py, px + sz.X, py + cl},
				{px, py + sz.Y, px + cl, py + sz.Y}, {px, py + sz.Y, px, py + sz.Y - cl},
				{px + sz.X, py + sz.Y, px + sz.X - cl, py + sz.Y}, {px + sz.X, py + sz.Y, px + sz.X, py + sz.Y - cl}
			}
			for i, cd in ipairs(cdefs) do
				local l = v.box_corner_lines[i]
				if l then
					pcall(function()
						l.From = Vector2.new(cd[1], cd[2]); l.To = Vector2.new(cd[3], cd[4])
						l.Color = bc; l.Transparency = config.box_transparency * alpha
						l.Visible = true
					end)
				end
			end
		end
	end

	-- name
	if config.names and v.name_label then
		pcall(function()
			v.name_label.Text = string.lower(player.Name)
			v.name_label.Position = Vector2.new(cx, headscr.Y - 20)
			v.name_label.Color = bc; v.name_label.Size = config.name_size
			v.name_label.Transparency = alpha; v.name_label.Visible = true
		end)
	end

	-- weapon
	if config.weapon_esp and v.weapon_label then
		local w = getweapon(char)
		if w then
			pcall(function()
				v.weapon_label.Text = w
				v.weapon_label.Position = Vector2.new(cx, headscr.Y - 34)
				v.weapon_label.Color = config.weapon_color
				v.weapon_label.Size = config.weapon_size
				v.weapon_label.Transparency = alpha; v.weapon_label.Visible = true
			end)
		else
			pcall(function() v.weapon_label.Visible = false end)
		end
	end

	-- health bar
	if config.health then
		local hs = config.health_bar_style
		if hs == "vertical" then
			local bx = pos.X - 6
			pcall(function()
				v.health_bar_outline.From = Vector2.new(bx, headscr.Y)
				v.health_bar_outline.To = Vector2.new(bx, footscr.Y)
				v.health_bar_outline.Transparency = 0.7 * alpha
				v.health_bar_outline.Visible = true
			end)
			pcall(function()
				local bt2 = footscr.Y - (hp * bh)
				v.health_bar.From = Vector2.new(bx, footscr.Y)
				v.health_bar.To = Vector2.new(bx, bt2)
				v.health_bar.Color = hpclr(hp)
				v.health_bar.Thickness = 3
				v.health_bar.Transparency = 0.85 * alpha
				v.health_bar.Visible = true
			end)
		elseif hs == "horizontal" then
			local by = pos.Y - 5
			pcall(function()
				v.health_bar_outline.From = Vector2.new(pos.X, by)
				v.health_bar_outline.To = Vector2.new(pos.X + sz.X, by)
				v.health_bar_outline.Thickness = 4
				v.health_bar_outline.Transparency = 0.7 * alpha
				v.health_bar_outline.Visible = true
			end)
			pcall(function()
				local bw2 = sz.X * hp
				v.health_bar.From = Vector2.new(pos.X, by)
				v.health_bar.To = Vector2.new(pos.X + bw2, by)
				v.health_bar.Color = hpclr(hp)
				v.health_bar.Thickness = 2
				v.health_bar.Transparency = 0.85 * alpha
				v.health_bar.Visible = true
			end)
		elseif hs == "text" then
			pcall(function()
				v.health_text.Text = string.format("%.0f HP", hum.Health)
				v.health_text.Position = Vector2.new(pos.X - 4, cy)
				v.health_text.Color = hpclr(hp)
				v.health_text.Size = config.health_text_size
				v.health_text.Transparency = alpha; v.health_text.Visible = true
			end)
		end
	end

	-- distance
	if config.distance and v.distance_label then
		local dt = dist >= 1000 and string.format("%.1fkm", dist / 1000) or string.format("%.0fm", dist)
		pcall(function()
			v.distance_label.Text = dt
			v.distance_label.Position = Vector2.new(cx, footscr.Y + 8)
			v.distance_label.Color = config.distance_color
			v.distance_label.Transparency = 0.85 * alpha
			v.distance_label.Visible = true
		end)
	end

	-- tracer
	if config.tracers and v.tracer_line then
		local ts = tracerstart()
		local tc = teamclr(player, config.tracer_color)
		pcall(function()
			v.tracer_line.From = ts; v.tracer_line.To = Vector2.new(cx, cy)
			v.tracer_line.Color = tc; v.tracer_line.Thickness = config.tracer_thickness
			v.tracer_line.Transparency = config.tracer_transparency * alpha
			v.tracer_line.Visible = true
		end)
	end

	-- skeletons
	if config.skeletons then
		if v._char ~= char then
			buildskel(v, char)
			v._char = char
		end
		local sc = teamclr(player, config.skeleton_color)
		for _, d in ipairs(v.skeleton_cache) do
			local l, p1, p2 = d[1], d[2], d[3]
			if l and ok(char, p1) and ok(char, p2) then
				local a = w2s(char[p1].Position)
				local b = w2s(char[p2].Position)
				pcall(function()
					l.From = a; l.To = b; l.Color = sc
					l.Thickness = config.skeleton_thickness
					l.Transparency = config.skeleton_transparency * alpha
					l.Visible = true
				end)
			end
		end
	end

	-- lookat
	if config.lookat_lines and v.lookat_line then
		local le = head.Position + head.CFrame.LookVector * config.lookat_length
		local ls = w2s(le)
		pcall(function()
			v.lookat_line.From = Vector2.new(headscr.X, headscr.Y)
			v.lookat_line.To = ls; v.lookat_line.Color = config.lookat_color
			v.lookat_line.Transparency = 0.8 * alpha; v.lookat_line.Visible = true
		end)
	end

	-- head circle
	if config.head_circles then
		local ok2, rs = pcall(function()
			return camera:WorldToViewportPoint(head.Position + head.CFrame.RightVector * config.head_circle_radius)
		end)
		if ok2 and rs then
			local r2d = math.abs(rs.X - headscr.X)
			local seg = #v.head_circle_segments
			if seg > 0 then
				local step = (2 * math.pi) / seg
				for i = 1, seg do
					local a1 = (i - 1) * step
					local a2 = i * step
					local p1 = Vector2.new(headscr.X + math.cos(a1) * r2d, headscr.Y + math.sin(a1) * r2d)
					local p2 = Vector2.new(headscr.X + math.cos(a2) * r2d, headscr.Y + math.sin(a2) * r2d)
					local l = v.head_circle_segments[i]
					if l then
						pcall(function()
							l.From = p1; l.To = p2; l.Color = config.head_circle_color
							l.Transparency = 0.8 * alpha; l.Visible = true
						end)
					end
				end
			end
		end
	end
end

-- [ section 7: main update loop ]

local function syncfb()
	if api and api._raw then
		for k, val in pairs(api._raw) do syncprop(k, val) end
	end
end

local function onrender()
	syncfb()
	if not config.enabled or not config.players then
		for _, v in pairs(cache) do hide(v) end
		return
	end

	local sorted = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= local_player then
			local c = p.Character
			if c then
				local r = c:FindFirstChild("HumanoidRootPart")
				if r then
					table.insert(sorted, {p = p, d = (camera.CFrame.Position - r.Position).Magnitude})
				end
			end
		end
	end
	table.sort(sorted, function(a, b) return a.d < b.d end)

	for _, d in ipairs(sorted) do
		local v = cache[d.p]
		if not v then v = mkvis(d.p) end
		update(d.p, v)
	end

	for p, v in pairs(cache) do
		if p ~= local_player then
			local found = false
			for _, d in ipairs(sorted) do
				if d.p == p then found = true; break end
			end
			if not found then hide(v) end
		end
	end
end

-- [ section 9: event connections ]

conns.cam = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = Workspace.CurrentCamera
end)

conns.resize = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	viewport = camera.ViewportSize
end)

conns.added = Players.PlayerAdded:Connect(function(player)
	if player ~= local_player then
		local c = player.Character or player.CharacterAdded:Wait()
		if not cache[player] then mkvis(player) end
		if cache[player] then
			cache[player]._charadded = player.CharacterAdded:Connect(function(nc)
				local v = cache[player]
				if v then
					buildskel(v, nc)
					v._char = nc
					v._smooth = {box_pos = nil, box_size = nil, head_screen = nil, foot_screen = nil}
				end
			end)
		end
	end
end)

conns.removing = Players.PlayerRemoving:Connect(function(player)
	cleanup(player)
end)

conns.render = RunService.RenderStepped:Connect(onrender)

-- [ section 10: start ]

cleanupall()

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= local_player then
		local v = mkvis(p)
		v._charadded = p.CharacterAdded:Connect(function(nc)
			local vis = cache[p]
			if vis then
				buildskel(vis, nc)
				vis._char = nc
				vis._smooth = {box_pos = nil, box_size = nil, head_screen = nil, foot_screen = nil}
			end
		end)
	end
end

-- [ section 11: api return ]
-- the esp itself doesnt need this, but its a cleaner API for the loader

local api = {}
local syncprop

function api:Toggle(state)
	config.enabled = state
	config.players = state
	if not state then
		for _, v in pairs(cache) do hide(v) end
	end
end

syncprop = function(key, value)
	if key == "Players" then config.players = value
	elseif key == "TeamMates" then config.team_check = not value
	elseif key == "Tracers" then config.tracers = value
	elseif key == "Names" then config.names = value
	elseif key == "Boxes" then config.boxes = value
	elseif key == "TeamColor" then config.team_color = value
	end
end

local function readprop(key)
	if key == "Players" then return config.players end
	if key == "TeamMates" then return not config.team_check end
	if key == "Tracers" then return config.tracers end
	if key == "Names" then return config.names end
	if key == "Boxes" then return config.boxes end
	if key == "TeamColor" then return config.team_color end
	return nil
end
-- metatable on the api object: lets scripts do "api.Players = true" instead of "api:Set("Players", true)"
local mtok = false
do
	local ok2 = pcall(function()
		local t = setmetatable({}, {
			__newindex = function(t, k, v) rawset(t, k, v) end,
			__index = function(t, k) return rawget(t, k) end
		})
		t.hello = "world"
		return t.hello == "world"
	end)
	mtok = ok2
end

if mtok then
	local mt = {}
	mt.__newindex = function(self, key, value)
		syncprop(key, value)
		rawset(self, key, value)
	end
	mt.__index = function(self, key)
		local val = readprop(key)
		if val ~= nil then return val end
		return rawget(self, key)
	end
	setmetatable(api, mt)

	api.Players = true
	api.TeamMates = false
	api.Tracers = true
	api.Names = true
	api.Boxes = true
	api.TeamColor = false
else
	warn("[RMonnesy] metatable support missing: using fallback method")
	warn("[RMonnesy] use api:Set(key, value) or set properties before enable")

	api._raw = {
		Players = true, TeamMates = false, Tracers = true,
		Names = true, Boxes = true, TeamColor = false
	}

	for k, val in pairs(api._raw) do syncprop(k, val) end

	function api:Set(key, value)
		if api._raw[key] ~= nil then
			api._raw[key] = value
			syncprop(key, value)
		end
	end

	function api:Get(key)
		return api._raw[key]
	end

	api.Players = true
	api.TeamMates = false
	api.Tracers = true
	api.Names = true
	api.Boxes = true
	api.TeamColor = false
end

return api
