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
local body = shared.ftfSpectrumBody
if type(body) ~= "string" or body == "" then
	body = nil
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
		error("[ftf] could not load Spectrum.lua", 0)
	end
	shared.ftfSpectrumBody = body
end

local chunk, problem = loadstring(body, "Spectrum")
if not chunk then
	error("[ftf] could not compile Spectrum.lua: " .. tostring(problem), 0)
end

local run_ok, library = pcall(chunk)
if not run_ok then
	error("[ftf] Spectrum failed to load: " .. tostring(library), 0)
end
library = library or shared.Spectrum
if type(library) ~= "table" or type(library.Window) ~= "function" then
	error("[ftf] Spectrum returned no Library", 0)
end

pcall(function()
	if library:GetProfile() ~= "flee_the_facility" then
		library:SetProfile("flee_the_facility")
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local RemoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvent")
local generation = (shared.ftfGeneration or 0) + 1
shared.ftfGeneration = generation

local function Alive()
	return shared.ftfGeneration == generation
end

if shared.ftf and type(shared.ftf.destroy) == "function" then
	pcall(shared.ftf.destroy)
end

local white = Color3.fromRGB(255, 255, 255)
local Config = {
	esp = true,
	name = true,
	distance = false,
	computer_cham = true,
	color = white,
	text_size = 13,
	hacked_color = Color3.fromRGB(90, 255, 110),

	auto_hack = true,
	hack_range = 8,
	progress = true,

	beast_cham = true,
	beast_color = Color3.fromRGB(255, 40, 40),
	beast_fill = 0.45,

	runner_cham = true,
	runner_color = Color3.fromRGB(90, 220, 255),
	runner_fill = 0.6,
	runner_esp = true,
	runner_name = true,
	runner_distance = false,
	part_cham = false,

	captured_cham = true,
	captured_color = Color3.fromRGB(255, 170, 60),
	captured_fill = 0.55,

	pod_cham = true,
	pod_esp = true,
	pod_distance = false,
	pod_color = Color3.fromRGB(60, 170, 255),
	pod_full_color = Color3.fromRGB(255, 150, 50),
	pod_full_fill = 0.45,

	exit_cham = true,
	exit_esp = true,
	exit_distance = false,
	exit_color = Color3.fromRGB(255, 220, 40),
	exit_fill = 0.6,

	locker_cham = true,
	locker_esp = true,
	locker_distance = false,
	locker_color = Color3.fromRGB(190, 140, 255),
	locker_fill = 0.6,

	vent_esp = true,
	vent_distance = false,
	vent_color = Color3.fromRGB(120, 255, 200),

	door_cham = true,
	door_esp = true,
	door_distance = false,
	door_color = Color3.fromRGB(255, 110, 200),
	door_fill = 0.55,

	unfreeze = false,
	complete = false,
	remove_doors = false,
	noclip = false,
	auto_crawl = false,

	fullbright = true,
	no_fog = true,
	fov = false,
	fov_value = 90,

	walkspeed = false,
	walk_value = 32,
	jump = false,
	jump_value = 60,
	inf_jump = false,

	watermark = true,
}

local hack_state = "idle"
local hack_progress = 0
local draw_state = { 
	active = false, 
	text = nil, 
	size = 0, 
	visible = false, 
	x = 0, 
	y = 0 
}
local hack_values = {}
local noclip_saved = {}
local door_saved = {}
local unfreeze_moving = false
local complete_moving = false
local crawl_on = false

local function Humanoid()
	local character = LP.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		return humanoid
	end
	return nil
end

local function ApplySpeed()
	local humanoid = Humanoid()
	if not humanoid then
		return
	end
	local fast = Config.walkspeed and Config.walk_value or nil
	humanoid.WalkSpeed = crawl_on and (fast or 8) or (fast or 16)
end

local function ApplyJump()
	local humanoid = Humanoid()
	if not humanoid then
		return
	end
	local value = Config.jump and Config.jump_value or nil
	if humanoid.UseJumpPower then
		humanoid.JumpPower = value or 50
	else
		humanoid.JumpHeight = value or 7.2
	end
end

local function ApplyNoclip(active)
	local character = LP.Character
	if not character then
		return
	end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			if active then
				if part.CanCollide then
					noclip_saved[part] = true
					part.CanCollide = false
				end
			elseif noclip_saved[part] then
				noclip_saved[part] = nil
				part.CanCollide = true
			end
		end
	end
end

local noclip_check = RunService.Heartbeat:Connect(function()
	if not Alive() then
		return
	end
	if Config.noclip or unfreeze_moving or complete_moving then
		ApplyNoclip(true)
	elseif next(noclip_saved) then
		ApplyNoclip(false)
	end
end)

local stats_module, stats_api
local function Stats()
	if not stats_api then
		stats_module = stats_module or LP:FindFirstChild("TempPlayerStatsModule")
		if not stats_module then
			return nil
		end
		local ok, module = pcall(require, stats_module)
		if ok and type(module) == "table" and type(module.GetValue) == "function" then
			stats_api = module
		end
	end
	return stats_api
end

local function ActionProgress()
	local stats = Stats()
	if not stats then
		return 0
	end
	local shown_ok, shown = pcall(function()
		return stats.GetValue("ShowActionPercent")
	end)
	if not shown_ok or shown ~= true then
		return 0
	end
	local value_ok, value = pcall(function()
		return stats.GetValue("ActionProgress")
	end)
	if not value_ok or type(value) ~= "number" then
		return 0
	end
	return math.clamp(value, 0, 1)
end

local window = library:Window("flee the facility", { icon = "eye", width = 340 })
local computer_tab = window:Tab("Main", { icon = "target", open = { "Computers" } })
local player_tab = window:Tab("Player", { icon = "shield", open = { "Character" } })

computer_tab:section("Auto hack", "bolt", { open = true })
computer_tab:toggle("auto hack", Config.auto_hack, function(state)
	Config.auto_hack = state
end, { icon = "bolt", feature = true, tooltip = "automatically hacks for you" })

computer_tab:slider("range", 4, 8, Config.hack_range, function(value)
	Config.hack_range = value
end, 1, "target", { suffix = " studs", tooltip = "How close computer has to be before auto hack works" })

player_tab:section("Movement", "speed", { open = true })

player_tab:toggle("walkspeed", Config.walkspeed, function(state)
	Config.walkspeed = state
	ApplySpeed()
end, { icon = "speed", feature = true })

player_tab:slider("value", 16, 80, Config.walk_value, function(value)
	Config.walk_value = value
	ApplySpeed()
end, 1, "speed", { suffix = " studs" })

player_tab:toggle("jump power", Config.jump, function(state)
	Config.jump = state
	ApplyJump()
end, { icon = "arrow" })

player_tab:slider("value", 30, 120, Config.jump_value, function(value)
	Config.jump_value = value
	ApplyJump()
end, 5, "arrow")

player_tab:toggle("infinite jump", Config.inf_jump, function(state)
	Config.inf_jump = state
end, { icon = "arrow", tooltip = "inf jump thats all" })

player_tab:toggle("noclip", Config.noclip, function(state)
	Config.noclip = state
	ApplyNoclip(state)
end, { icon = "box", feature = true, tooltip = "no collision" })

player_tab:section("Crawl", "box", { open = true })

player_tab:toggle("auto crawl", Config.auto_crawl, function(state)
	Config.auto_crawl = state
end, { icon = "box", feature = true, tooltip = "you will be in crawl mode" })

computer_tab:section("Mechanics", "shield", { open = true })

computer_tab:button("get out of freeze pod", function() -- ty narrator for this (i stole this from him hehe)
	local humanoid = Humanoid()
	if not humanoid then
		library:Notify("escaped", "no character to restart", 3, "bad")
		return
	end
	humanoid.Health = 0
	library:Notify("escaped", "character restarted, this also leaves a freeze pod", 2, "good")
end, "refresh", {
	variant = "danger",
	confirm = "Click again to restart your character",
	tooltip = "restarts your character, which gets you out of the freeze pod",
})

computer_tab:toggle("auto complete computer", Config.complete, function(state)
	Config.complete = state
end, { icon = "target", feature = true, tooltip = "goes to the nearest unfinished computer, and hacks it with auto hack, then walks you back to where you started if all finish" })

computer_tab:section("Unfreeze", "refresh", { open = true })

computer_tab:toggle("auto rescue player", Config.unfreeze, function(state)
	Config.unfreeze = state
end, { icon = "refresh", feature = true, tooltip = "your character just goes to the route to the pod" })

computer_tab:section("Doors", "box", { open = true })

computer_tab:toggle("remove all doors", Config.remove_doors, function(state)
	Config.remove_doors = state
end, { icon = "box", tooltip = "hides every door and collision is off on your client only" })

local visual = library:Window("visual", { icon = "eye", width = 330 })

local visual_world = visual:Tab("World", { icon = "eye", open = { "Visuals" } })
local visual_computers = visual:Tab("Computers", { icon = "target", open = { "Computers" } })
local visual_players = visual:Tab("Players", { icon = "user", open = { "Beast" } })
local visual_objects = visual:Tab("Objects", { icon = "box", open = { "Pods" } })
local page = visual_computers

page:section("Computers", "target", { open = true })

page:toggle("esp", Config.esp, function(state)
	Config.esp = state
end, { icon = "eye", feature = true, tooltip = "Name and distance over every computer" })

page:toggle("name", Config.name, function(state)
	Config.name = state
end, { icon = "user", tooltip = "says hacked or failed once the screen changes" })

page:toggle("studs", Config.distance, function(state)
	Config.distance = state
end, { icon = "arrow" })

page:toggle("cham", Config.computer_cham, function(state)
	Config.computer_cham = state
end, { icon = "eye", feature = true, tooltip = "Outline" })

page:colorpicker("color", Config.color, function(color)
	Config.color = color
end, "palette", {
	presets = {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(90, 220, 255),
		Color3.fromRGB(255, 200, 60),
	},
	recent = true,
})

page:colorpicker("hacked color", Config.hacked_color, function(color)
	Config.hacked_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(90, 255, 110),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(60, 200, 255),
	},
	recent = true,
})

page:toggle("progress", Config.progress, function(state)
	Config.progress = state
end, { icon = "bolt", tooltip = "Big percentage over the computer while it is being hacked" })

page:slider("text size", 9, 20, Config.text_size, function(value)
	Config.text_size = value
end, 1, "code", { suffix = " px" })

page = visual_players
page:section("Beast", "user", { open = true })

page:toggle("cham", Config.beast_cham, function(state)
	Config.beast_cham = state
end, { icon = "eye", tooltip = "grrrr." })

page:colorpicker("color", Config.beast_color, function(color)
	Config.beast_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(255, 40, 40),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(150, 90, 255),
	},
	recent = true,
})

page:slider("fill", 10, 90, math.floor(Config.beast_fill * 100), function(value)
	Config.beast_fill = value / 100
end, 5, "palette", { suffix = "%", tooltip = "higher fades the fill, outline stays" })

page:section("Runners", "eye", { open = true })

page:toggle("cham", Config.runner_cham, function(state)
	Config.runner_cham = state
end, { icon = "eye" })

page:colorpicker("color", Config.runner_color, function(color)
	Config.runner_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(90, 220, 255),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(120, 255, 140),
	},
	recent = true,
})

page:slider("fill", 10, 90, math.floor(Config.runner_fill * 100), function(value)
	Config.runner_fill = value / 100
end, 5, "palette", { suffix = "%" })

page:toggle("esp", Config.runner_esp, function(state)
	Config.runner_esp = state
end, { icon = "eye" })

page:toggle("name", Config.runner_name, function(state)
	Config.runner_name = state
end, { icon = "user" })

page:toggle("studs", Config.runner_distance, function(state)
	Config.runner_distance = state
end, { icon = "arrow" })

page:section("Captured", "box", { open = true })

page:toggle("cham", Config.captured_cham, function(state)
	Config.captured_cham = state
end, { icon = "eye", tooltip = "ruff ruff." })

page:colorpicker("color", Config.captured_color, function(color)
	Config.captured_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(255, 170, 60),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 80, 140),
	},
	recent = true,
})

page:slider("fill", 10, 90, math.floor(Config.captured_fill * 100), function(value)
	Config.captured_fill = value / 100
end, 5, "palette", { suffix = "%" })

page = visual_objects
page:toggle("cham parts", Config.part_cham, function(state)
	Config.part_cham = state
end, { icon = "box", tooltip = "Highlights every limb of the player instead of the whole body" })

page:section("Pods", "box", { open = true })

page:toggle("cham", Config.pod_cham, function(state)
	Config.pod_cham = state
end, { icon = "eye", tooltip = "The freeze pods" })

page:toggle("esp", Config.pod_esp, function(state)
	Config.pod_esp = state
end, { icon = "eye", tooltip = "Namee of freeze pod." })

page:toggle("studs", Config.pod_distance, function(state)
	Config.pod_distance = state
end, { icon = "eye", tooltip = "distance of freeze pod" })

page:colorpicker("empty", Config.pod_color, function(color)
	Config.pod_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(60, 170, 255),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(120, 255, 140),
	},
	recent = true,
})

page:colorpicker("filled", Config.pod_full_color, function(color)
	Config.pod_full_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(255, 150, 50),
		Color3.fromRGB(255, 80, 80),
		Color3.fromRGB(255, 255, 255),
	},
	recent = true,
})

page:slider("filled fill", 10, 90, math.floor(Config.pod_full_fill * 100), function(value)
	Config.pod_full_fill = value / 100
end, 5, "palette", { suffix = "%" })

page:section("Exit door", "box", { open = true })

page:toggle("cham", Config.exit_cham, function(state)
	Config.exit_cham = state
end, { icon = "eye", tooltip = "Outline the exit door" })

page:toggle("esp", Config.exit_esp, function(state)
	Config.exit_esp = state
end, { icon = "eye", tooltip = "Name over the exit door" })

page:toggle("studs", Config.exit_distance, function(state)
	Config.exit_distance = state
end, { icon = "eye", tooltip = "Shows the distance exit door" })

page:colorpicker("color", Config.exit_color, function(color)
	Config.exit_color = color
end, "palette", {
			presets = {
		Color3.fromRGB(255, 220, 40),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 150, 50),
	},
	recent = true,
})

page:slider("fill", 10, 90, math.floor(Config.exit_fill * 100), function(value)
	Config.exit_fill = value / 100
end, 5, "palette", { suffix = "%" })

page:section("Lockers", "box", { open = true })

page:toggle("cham", Config.locker_cham, function(state)
	Config.locker_cham = state
end, { icon = "eye", tooltip = "lockers i want to get stuck hehehe" })

page:toggle("esp", Config.locker_esp, function(state)
	Config.locker_esp = state
end, { icon = "eye", tooltip = "Name over locker." })

page:toggle("studs", Config.locker_distance, function(state)
	Config.locker_distance = state
end, { icon = "eye", tooltip = "the distance on locker" })

page:colorpicker("color", Config.locker_color, function(color)
	Config.locker_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(190, 140, 255),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(90, 220, 255),
	},
	recent = true,
})

page:slider("fill", 10, 90, math.floor(Config.locker_fill * 100), function(value)
	Config.locker_fill = value / 100
end, 5, "palette", { suffix = "%" })

page:section("Vents", "box", { open = true }) -- fun fact i tried to create cham esp for vent but for some reason in some maps it doesnt show vent so i just removed it and will fix it later so use the normal esp 

page:toggle("esp", Config.vent_esp, function(state)
	Config.vent_esp = state
end, { icon = "eye", tooltip = "esp on vent block" })

page:toggle("studs", Config.vent_distance, function(state)
	Config.vent_distance = state
end, { icon = "eye", tooltip = " distance esp for vent" })

page:colorpicker("color", Config.vent_color, function(color)
	Config.vent_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(120, 255, 200),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 200, 60),
	},
	recent = true,
})

page:section("Doors", "box", { open = true })

page:toggle("cham", Config.door_cham, function(state)
	Config.door_cham = state
end, { icon = "eye", tooltip = "Every door highlight " })

page:toggle("esp", Config.door_esp, function(state)
	Config.door_esp = state
end, { icon = "eye", tooltip = "Name on door." })

page:toggle("studs", Config.door_distance, function(state)
	Config.door_distance = state
end, { icon = "eye", tooltip = "distance on door" })

page:colorpicker("color", Config.door_color, function(color)
	Config.door_color = color
end, "palette", {
	presets = {
		Color3.fromRGB(255, 110, 200),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(90, 220, 255),
	},
	recent = true,
})

page:slider("fill", 10, 90, math.floor(Config.door_fill * 100), function(value)
	Config.door_fill = value / 100
end, 5, "palette", { suffix = "%" })

page = visual_world
page:section("Visuals", "eye", { open = true })

page:toggle("fullbright", Config.fullbright, function(state)
	Config.fullbright = state
end, { icon = "eye", tooltip = "brightness and ambient light at maximum" }) 

page:toggle("no fog", Config.no_fog, function(state)
	Config.no_fog = state
end, { icon = "eye", tooltip = "wow" })

page:toggle("fov", Config.fov, function(state)
	Config.fov = state
end, { icon = "eye" })

page:slider("fov value", 70, 120, Config.fov_value, function(value)
	Config.fov_value = value
end, 1, "eye", { suffix = " deg" })

local settings = library:Window("settings", { icon = "sliders", width = 320 })
local defaults = library:GetDesign()

settings:section("Config", "save", { open = true })

local autosave = settings:toggle("autosave", library:GetAutoSave(), function(state)
	library:SetAutoSave(state)
end, { icon = "save", tooltip = "saves the profile whenever something changes in the ui" })
autosave:Set(library:GetAutoSave(), true)

settings:button("save now", function()
	local ok = library:SaveConfig()
	library:Notify("config", ok and "profile saved" or (library:GetConfigError() or "could not save"), 3, ok and "good" or "bad")
end, "save", { tooltip = "writes the profile and keeps a .bak." })

settings:section("Menu", "key", { open = true })

local default_key = "P"
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

settings:section("Feature list", "list", { open = true })

if type(library.SetFeatureListVisible) == "function" then
	local _, feature_shown = library:GetFeatureList()
	local feature_toggle
	feature_toggle = settings:toggle("feature list", feature_shown == true, function(state)
		library:SetFeatureListVisible(state)
		if feature_toggle then
			feature_toggle:Set(state, false)
		end
	end, { icon = "list", tooltip = "Lists the features that is currently have on" })

	settings:toggle("colorful list", library:GetFeatureListRGB(), function(state)
		library:SetFeatureListRGB(state)
	end, { icon = "palette", tooltip = "Moves a gradient across the feature list." })

	settings:toggle("list everything", library:GetFeatureListAll(), function(state)
		library:SetFeatureListAll(state)
	end, { icon = "list", tooltip = "Includes settings that are switched off too." })
end

if type(library.SetMobileButton) == "function" then
	settings:button("mobile button", function()
		local shown = library:SetMobileButton(not library:GetMobileButton())
		library:Notify("menu", shown and "mobile button shown" or "mobile button hidden", 2, "info")
	end, "menu", { tooltip = "Floating button" })
end

settings:section("Appearance", "palette", { open = true })

settings:toggle("watermark", Config.watermark, function(state)
	Config.watermark = state
end, { icon = "info", tooltip = "computer count and what auto hack is doing thats all" })

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

settings:section("Server", "globe", { open = true })

settings:button("rejoin", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end, "refresh", { tooltip = "Rejoins this place on a fresh server." })

settings:button("server hop", function()
	task.spawn(function() -- i dont even fuckingg know why i coded it like this
		local fetched, body = pcall(function()
			return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
		end)
		if not fetched or type(body) ~= "string" then
			library:Notify("server hop", "could not list servers", 3, "bad")
			return
		end
		local decoded_ok, decoded = pcall(function()
			return game:GetService("HttpService"):JSONDecode(body)
		end)
		if not decoded_ok or type(decoded) ~= "table" or type(decoded.data) ~= "table" then
			library:Notify("server hop", "no server list", 3, "bad")
			return
		end
		local options = {}
		for _, server in ipairs(decoded.data) do
			if server.id and (server.playing or 0) < (server.maxPlayers or 0) then
				options[#options + 1] = server.id
			end
		end
		if #options == 0 then
			library:Notify("server hop", "no open server found", 3, "bad")
			return
		end
		library:Notify("server hop", "hopping", 2, "info")
		pcall(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, options[math.random(1, #options)], LP)
		end)
	end)
end, "globe", { tooltip = "jsut finds an open public server and teleports you there" })

settings:section("Script", "trash", { open = true })

settings:button("unload", function()
	shared.ftf.unload_requested = true
end, "trash", { variant = "danger", confirm = "Click again to unload" })



--[[ all of the function here so skid off it, if you want to idc ]]--
local function WorldKey()
	local names = {}
	for _, item in ipairs(workspace:GetChildren()) do
		names[#names + 1] = item.Name
	end
	return table.concat(names, ",")
end

local world_items, world_items_key = nil, nil
local function WorldItems()
	local key = WorldKey()
	if key ~= world_items_key then
		world_items_key = key
		world_items = workspace:GetDescendants()
	end
	return world_items
end

local function ComputerList()
	local found = {}
	for _, item in ipairs(WorldItems()) do
		if item.Name == "ComputerTable" and item:IsA("Model") then
			found[#found + 1] = item
		end
	end
	return found
end

local computers, computers_key = {}, nil
local function Computers()
	local key = WorldKey()
	if key ~= computers_key then
		computers_key = key
		computers = ComputerList()
	end
	return computers
end

local function PodModel(trigger)
	local best
	local node = trigger.Parent
	while node and node:IsA("Model") do
		local _, size = node:GetBoundingBox()
		if size.Magnitude > 30 then
			break
		end
		best = node
		if node.Name == "FreezePod" then
			break
		end
		node = node.Parent
	end
	return best
end

local function BoxExtents(part)
	local half = part.Size * 0.5
	local frame = part.CFrame
	local right, up, look = frame.RightVector, frame.UpVector, frame.LookVector
	return Vector3.new(math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z, math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(look.Y) * half.Z, math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z)
end

local overlap_params = OverlapParams.new()
overlap_params.MaxParts = 100
local function PodExtras(pod, bodies)
	local frame, size = pod.model:GetBoundingBox()
	local center = frame.Position
	local half = size * 0.5 + Vector3.new(2, 2, 2)
	local extras = {}
	for _, part in ipairs(workspace:GetPartBoundsInBox(frame, size + Vector3.new(4, 4, 4), overlap_params)) do
		if not bodies[part] and not part:IsDescendantOf(pod.model) then
			local offset = part.Position - center
			local extents = BoxExtents(part)
			if math.abs(offset.X) + extents.X <= half.X and math.abs(offset.Y) + extents.Y <= half.Y and math.abs(offset.Z) + extents.Z <= half.Z then
				extras[#extras + 1] = part
			end
		end
	end
	return extras
end

local function PodList()
	local found, seen, named = {}, {}, {}
	for _, item in ipairs(WorldItems()) do
		if item.Name == "PodTrigger" then
			if item:IsA("BasePart") then
				local model = PodModel(item)
				if model and not seen[model] then
					seen[model] = true
					found[#found + 1] = { model = model, trigger = item }
				end
			end
		elseif item.Name == "FreezePod" and item:IsA("Model") then
			named[#named + 1] = item
		end
	end
	for _, model in ipairs(named) do
		local covered = seen[model]
		local node = model.Parent
		while not covered and node do
			covered = seen[node]
			node = node.Parent
		end
		if not covered then
			seen[model] = true
			found[#found + 1] = { model = model, trigger = model:FindFirstChild("PodTrigger", true) }
		end
	end
	return found
end

local pods, pods_key, extras_at = {}, nil, 0
local function Pods()
	local key = WorldKey()
	if key ~= pods_key then
		pods_key = key
		pods = PodList()
		extras_at = 0
	end
	if os.clock() - extras_at >= 2 then
		extras_at = os.clock()
		local bodies = {}
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if character then
				for _, item in ipairs(character:GetDescendants()) do
					bodies[item] = true
				end
			end
		end
		for _, pod in ipairs(pods) do
			pod.extras = PodExtras(pod, bodies)
		end
	end
	return pods
end

local function NamedList(name)
	local models, parts = {}, {}
	for _, item in ipairs(WorldItems()) do
		if item.Name == name then
			if item:IsA("Model") then
				models[#models + 1] = item
			elseif item:IsA("BasePart") then
				parts[#parts + 1] = item
			end
		end
	end
	local found = {}
	if #models > 0 then
		for _, model in ipairs(models) do
			found[#found + 1] = { model = model, part = model:FindFirstChildWhichIsA("BasePart", true) }
		end
		return found
	end
	for _, part in ipairs(parts) do
		found[#found + 1] = { model = part, part = part }
	end
	return found
end

local function MergedList(names)
	local found = {}
	for _, name in ipairs(names) do
		for _, item in ipairs(NamedList(name)) do
			found[#found + 1] = item
		end
	end
	return found
end

local exits, exits_key = {}, nil
local function Exits()
	local key = WorldKey()
	if key ~= exits_key then
		exits_key = key
		exits = NamedList("ExitDoor")
	end
	return exits
end

local lockers, lockers_key = {}, nil
local function Lockers()
	local key = WorldKey()
	if key ~= lockers_key then
		lockers_key = key
		lockers = NamedList("Locker")
	end
	return lockers
end

local vents, vents_key = {}, nil
local function Vents()
	local key = WorldKey()
	if key ~= vents_key then
		vents_key = key
		local found = NamedList("Vent")
		for _, block in ipairs(NamedList("VentBlock")) do
			local covered = false
			for _, vent in ipairs(found) do
				local center = vent.model:IsA("Model") and vent.model:GetPivot().Position or vent.model.Position
				if (center - block.model.Position).Magnitude <= 8 then
					covered = true
					break
				end
			end
			if not covered then
				found[#found + 1] = block
			end
		end
		vents = found
	end
	return vents
end

local doors, doors_key = {}, nil
local function IsDone(computer)
	if hack_values[computer] == 1 then
		return true
	end
	local screen = computer:FindFirstChild("Screen", true)
	local color = screen and screen:IsA("BasePart") and screen.Color
	return color ~= nil and color.G > color.B + 0.05 and color.G > color.R + 0.05
end

local function Doors()
	local key = WorldKey()
	if key ~= doors_key then
		doors_key = key
		doors = MergedList({ "SingleDoor", "DoubleDoor" })
	end
	return doors
end

local function RestoreDoors()
	for item, saved in pairs(door_saved) do
		if item.Parent then
			if item:IsA("BasePart") then
				item.CanCollide = saved.collide
				item.Transparency = saved.transparency
				item.LocalTransparencyModifier = saved.modifier
			elseif saved.transparency then
				item.Transparency = saved.transparency
			else
				item.Enabled = saved.enabled
			end
		end
	end
	door_saved = {}
end

local function HideDoor(item)
	if door_saved[item] then
		if item:IsA("BasePart") then
			item.CanCollide = false
			item.Transparency = 1
			item.LocalTransparencyModifier = 1
		elseif item:IsA("Decal") or item:IsA("Texture") then
			item.Transparency = 1
		elseif item:IsA("SurfaceGui") or item:IsA("BillboardGui") or item:IsA("ParticleEmitter") or item:IsA("Fire") or item:IsA("Smoke") then
			item.Enabled = false
		end
		return
	end
	if item:IsA("BasePart") then
		door_saved[item] = { 
			collide = item.CanCollide, 
			transparency = item.Transparency, 
			modifier = item.LocalTransparencyModifier 
		}
		item.CanCollide = false
		item.Transparency = 1
		item.LocalTransparencyModifier = 1
	elseif item:IsA("Decal") or item:IsA("Texture") then
		door_saved[item] = { 
			transparency = item.Transparency 
		}
		item.Transparency = 1
	elseif item:IsA("SurfaceGui") or item:IsA("BillboardGui") then
		door_saved[item] = { 
			enabled = item.Enabled 
		}
		item.Enabled = false
	elseif item:IsA("ParticleEmitter") or item:IsA("Fire") or item:IsA("Smoke") then
		door_saved[item] = { 
			enabled = item.Enabled 
		}
		item.Enabled = false
	end
end

local function AddSign(part)
	if part:IsA("BasePart") and string.match(part.Name, "Trigger") and not part:FindFirstChild("ActionSign") then
		local sign = Instance.new("IntValue")
		sign.Name = "ActionSign"
		sign.Value = 0
		sign.Parent = part
	end
end

local function CleanupWorld()
	for _, item in ipairs(WorldItems()) do
		if item:IsA("Highlight") and item.Name == "ftf_vent" then
			item:Destroy()
		elseif item:IsA("SelectionBox") and item.Name == "ftf_vent_box" then
			item:Destroy()
		elseif item:IsA("BasePart") and item.Name == "VentBlock" and item.Transparency < 0.9 then
			item.Transparency = 1
		else
			AddSign(item)
		end
	end
end

local trigger_guard = workspace.DescendantAdded:Connect(AddSign)

CleanupWorld()

local function ApplyDoors()
	if Config.remove_doors then
		for _, door in ipairs(Doors()) do
			for _, item in ipairs(door.model:GetDescendants()) do
				HideDoor(item)
			end
		end
	elseif next(door_saved) then
		RestoreDoors()
	end
end

task.spawn(function()
	while Alive() do
		task.wait(0.5)
		ApplyDoors()
	end
end)

workspace.DescendantAdded:Connect(function(item)
	local name = item.Name
	if name == "ComputerTable" then
		computers_key = nil
	elseif name == "ExitDoor" then
		exits_key = nil
	elseif name == "Locker" then
		lockers_key = nil
	elseif name == "VentBlock" or name == "Vent" then
		vents_key = nil
	elseif name == "SingleDoor" or name == "DoubleDoor" then
		doors_key = nil
	elseif name == "PodTrigger" or name == "FreezePod" then
		pods_key = nil
	end
end)

local function PodOccupied(pod, players)
	for _, player in ipairs(players) do
		if pod.model:FindFirstChild(player.Name) then
			return true
		end
	end
	local trigger = pod.trigger
	if not (trigger and trigger:IsA("BasePart")) then
		return false
	end
	local half = trigger.Size * 0.5 + Vector3.new(1, 3.5, 1)
	local frame = trigger.CFrame
	for _, player in ipairs(players) do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local point = frame:PointToObjectSpace(root.Position)
			if math.abs(point.X) <= half.X and math.abs(point.Y) <= half.Y and math.abs(point.Z) <= half.Z then
				return true
			end
		end
	end
	return false
end

local function TopOf(model)
	if model:IsA("BasePart") then
		return model.Position + Vector3.new(0, model.Size.Y * 0.5, 0)
	end
	local center, size = model:GetBoundingBox()
	return center.Position + Vector3.new(0, size.Y * 0.5, 0)
end

local function IsCaptured(player)
	local gui = LP.PlayerGui:FindFirstChild("ScreenGui")
	local board = gui and gui:FindFirstChild("PlayerNamesFrame")
	if not board then
		return false
	end
	for _, frame in ipairs(board:GetChildren()) do
		if frame.Name == player.Name .. "PlayerFrame" or frame.Name:match("^" .. player.Name .. "Player") then
			local icon = frame:FindFirstChild("IconLabel", true)
			local image = icon and icon:IsA("ImageLabel") and icon.Image or ""
			if string.find(image, "118525531580207", 1, true) then
				return true
			end
		end
	end
	return false
end

local labels, runner_labels, exit_labels = {}, {}, {}
local pod_labels, locker_labels, vent_labels, door_labels = {}, {}, {}, {}
local progress_labels = {}

local function ProgressLabel(computer)
	local label = progress_labels[computer]
	if not label then
		label = Drawing.new("Text")
		label.Center = true
		label.Outline = true
		label.Visible = false
		progress_labels[computer] = label
	end
	return label
end

local progress_head = Drawing.new("Text")
progress_head.Center = true
progress_head.Outline = true
progress_head.Visible = false

local round_map = ReplicatedStorage:FindFirstChild("CurrentMap")
local round_active = ReplicatedStorage:FindFirstChild("IsGameActive")
local function ResetRound()
	for _, label in pairs(progress_labels) do
		label:Remove()
	end
	progress_labels = {}
	hack_values = {}
	hack_progress = 0
	draw_state.active = false
	draw_state.visible = false
	computers_key = nil
	pods_key = nil
	vents_key = nil
	doors_key = nil
	lockers_key = nil
	exits_key = nil
	world_items_key = nil
end

local map_signal = round_map and round_map:GetPropertyChangedSignal("Value"):Connect(ResetRound)
local round_signal = round_active and round_active:GetPropertyChangedSignal("Value"):Connect(ResetRound)

local function NewLabel()
	local name = Drawing.new("Text")
	name.Center = true
	name.Outline = true
	name.Visible = false
	local distance = Drawing.new("Text")
	distance.Center = true
	distance.Outline = true
	distance.Visible = false
	return { name = name, distance = distance }
end

local function ClearLabel(label)
	label.name.Visible = false
	label.distance.Visible = false
end

local function RemoveLabel(label)
	label.name:Remove()
	label.distance:Remove()
end

local function PlaceText(label, world, title, subtitle, view, color, fade, size)
	local point, on_screen = view:WorldToViewportPoint(world)
	if not on_screen or point.Z <= 0 then
		ClearLabel(label)
		return
	end
	local text_size = size or Config.text_size
	local y = point.Y
	if title then
		label.name.Text = title
		label.name.Size = text_size
		label.name.Position = Vector2.new(point.X, y)
		label.name.Color = color
		label.name.Transparency = fade
		label.name.Visible = true
		y = y + text_size + 1
	else
		label.name.Visible = false
	end
	if subtitle then
		label.distance.Text = subtitle
		label.distance.Size = math.max(9, Config.text_size - 1)
		label.distance.Position = Vector2.new(point.X, y)
		label.distance.Color = color
		label.distance.Transparency = fade
		label.distance.Visible = true
	else
		label.distance.Visible = false
	end
end

local chams = {}
local pod_revealed = {}
local function Reveal(store, part)
	if store[part] or string.match(part.Name, "Trigger") or part.Transparency <= 0.65 then
		return
	end
	store[part] = part.Transparency
	part.Transparency = 0.55
end

local function RestoreReveal(store)
	for part, transparency in pairs(store) do
		if part.Parent then
			part.Transparency = transparency
		end
		store[part] = nil
	end
end

local function ChamFor(model, title)
	local highlight = chams[model]
	if highlight and highlight.Parent == model then
		return highlight
	end
	highlight = Instance.new("Highlight")
	highlight.Name = title
	highlight.Adornee = model
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = model
	chams[model] = highlight
	return highlight
end

local function Paint(highlight, color, fill)
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = fill
	highlight.OutlineTransparency = 0
end

local render = RunService.RenderStepped:Connect(function()
	if not Alive() then
		return
	end
	if not Config.pod_cham then
		RestoreReveal(pod_revealed)
	end
	local view = workspace.CurrentCamera
	if not view then
		return
	end
	local character = LP.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local seen, told, painted, seen_exit = {}, {}, {}, {}
	local seen_pod, seen_locker, seen_vent, seen_door = {}, {}, {}, {}
	if hack_progress > 0 and root then
		local best = 40
		for _, computer in ipairs(Computers()) do
			if computer:IsDescendantOf(workspace) then
				local gap = (TopOf(computer) - root.Position).Magnitude
				if gap <= best then
					best = gap
					hack_values[computer] = hack_progress
				end
			end
		end
	end
	--[[ this took way to long :sob: ]]--
	if Config.esp or Config.computer_cham or Config.progress then
		for _, computer in ipairs(Computers()) do
			if computer:IsDescendantOf(workspace) then
				local done = IsDone(computer)
				local hacking_now = Config.progress and hack_values[computer] and hack_values[computer] < 1
				local color = done and Config.hacked_color or Config.color
				local top = TopOf(computer)
				if Config.esp and not hacking_now then
					local label = labels[computer]
					if not label then
						label = NewLabel()
						labels[computer] = label
					end
					local title
					if Config.name then
						if done then
							title = "hacked"
						elseif hack_values[computer] then
							title = string.format("computer %d%%", math.floor(hack_values[computer] * 100))
						else
							title = "computer"
						end
					end
					local space = Config.distance and string.format("%d studs", math.floor((top - view.CFrame.Position).Magnitude)) or nil
					PlaceText(label, top + Vector3.new(0, 1, 0), title, space, view, color, done and 0.45 or 1)
					seen[computer] = true
				end

				if Config.computer_cham then
					painted[computer] = true
					Paint(ChamFor(computer, "ftf_computer"), color, done and 0.45 or 0.85)
				end
			end
		end
	end

	if Config.progress and root then
		local shown = {}
		local primary, primary_point = nil, nil
		for _, computer in ipairs(Computers()) do
			local value = hack_values[computer]
			if value and value < 1 and computer:IsDescendantOf(workspace) then
				local label = ProgressLabel(computer)
				local anchor = TopOf(computer) + Vector3.new(0, 1.5, 0)
				local point, on_screen = view:WorldToViewportPoint(anchor)
				if on_screen and point.Z > 0 then
					label.Text = string.format("%d%%", math.floor(value * 100))
					label.Size = math.floor(Config.text_size * 2.6)
					label.Position = Vector2.new(math.clamp(point.X, 60, view.ViewportSize.X - 60), math.clamp(point.Y, 34, view.ViewportSize.Y - 50))
					label.Color = white
					label.Visible = true
					shown[computer] = true
					if not primary then
						primary, primary_point = label, point
					end
				else
					label.Visible = false
				end
			end
		end
		for computer, label in pairs(progress_labels) do
			if not shown[computer] then
				label.Visible = false
				if not computer:IsDescendantOf(workspace) then
					label:Remove()
					progress_labels[computer] = nil
				end
			end
		end
		if primary then
			draw_state.text = primary.Text
			draw_state.size = primary.Size
			draw_state.visible = true
			draw_state.x = math.floor(primary_point.X)
			draw_state.y = math.floor(primary_point.Y)
			draw_state.active = true
		else
			draw_state.visible = false
			draw_state.active = false
		end

		if not primary and hack_progress > 0 then
			local point, on_screen = view:WorldToViewportPoint(root.Position + Vector3.new(0, 3.5, 0))
			if on_screen and point.Z > 0 then
				progress_head.Text = string.format("%d%%", math.floor(hack_progress * 100))
				progress_head.Size = math.floor(Config.text_size * 2.6)
				progress_head.Position = Vector2.new(math.clamp(point.X, 60, view.ViewportSize.X - 60), math.clamp(point.Y, 34, view.ViewportSize.Y - 50))
				progress_head.Color = white
				progress_head.Visible = true
			else
				progress_head.Visible = false
			end
		else
			progress_head.Visible = false
		end
	else
		for _, label in pairs(progress_labels) do
			label.Visible = false
		end
		progress_head.Visible = false
		draw_state.active = false
		draw_state.visible = false
	end

	if Config.locker_cham or Config.locker_esp then
		for _, locker in ipairs(Lockers()) do
			if locker.model:IsDescendantOf(workspace) then
				if Config.locker_cham then
					painted[locker.model] = true
					Paint(ChamFor(locker.model, "ftf_locker"), Config.locker_color, Config.locker_fill)
				end
				if Config.locker_esp then
					local label = locker_labels[locker.model]
					if not label then
						label = NewLabel()
						locker_labels[locker.model] = label
					end
					local anchor = TopOf(locker.model)
					local space = Config.locker_distance and string.format("%d studs", math.floor((anchor - view.CFrame.Position).Magnitude)) or nil
					PlaceText(label, anchor + Vector3.new(0, 1, 0), "locker", space, view, Config.locker_color, 1)
					seen_locker[locker.model] = true
				end
			end
		end
	end

	if Config.vent_esp then
		for _, vent in ipairs(Vents()) do
			if vent.model:IsDescendantOf(workspace) then
				local label = vent_labels[vent.model]
				if not label then
					label = NewLabel()
					vent_labels[vent.model] = label
				end
				local anchor = TopOf(vent.model)
				local space = Config.vent_distance and string.format("%d studs", math.floor((anchor - view.CFrame.Position).Magnitude)) or nil
				PlaceText(label, anchor + Vector3.new(0, 1, 0), "vent", space, view, Config.vent_color, 1)
				seen_vent[vent.model] = true
			end
		end
	end

	if Config.door_cham or Config.door_esp then
		for _, door in ipairs(Doors()) do
			if door.model:IsDescendantOf(workspace) then
				if Config.door_cham then
					painted[door.model] = true
					Paint(ChamFor(door.model, "ftf_door"), Config.door_color, Config.door_fill)
				end
				if Config.door_esp then
					local label = door_labels[door.model]
					if not label then
						label = NewLabel()
						door_labels[door.model] = label
					end
					local anchor = TopOf(door.model)
					local space = Config.door_distance and string.format("%d studs", math.floor((anchor - view.CFrame.Position).Magnitude)) or nil
					PlaceText(label, anchor + Vector3.new(0, 1, 0), "door", space, view, Config.door_color, 1)
					seen_door[door.model] = true
				end
			end
		end
	end

	if Config.exit_cham or Config.exit_esp then
		for _, door in ipairs(Exits()) do
			if door.model:IsDescendantOf(workspace) then
				if Config.exit_cham then
					painted[door.model] = true
					Paint(ChamFor(door.model, "ftf_exit"), Config.exit_color, Config.exit_fill)
				end
				if Config.exit_esp then
					local label = exit_labels[door.model]
					if not label then
						label = NewLabel()
						exit_labels[door.model] = label
					end
					local anchor = TopOf(door.model)
					local space = Config.exit_distance and string.format("%d studs", math.floor((anchor - view.CFrame.Position).Magnitude)) or nil
					PlaceText(label, anchor + Vector3.new(0, 1, 0), "exit door", space, view, Config.exit_color, 1)
					seen_exit[door.model] = true
				end
			end
		end
	end

	if Config.pod_cham or Config.pod_esp then
		local players = Players:GetPlayers()
		for _, pod in ipairs(Pods()) do
			if pod.model:IsDescendantOf(workspace) then
				local full = PodOccupied(pod, players)
				local color = full and Config.pod_full_color or Config.pod_color
				local fill = full and Config.pod_full_fill or 0.7
				if Config.pod_cham then
					painted[pod.model] = true
					for _, part in ipairs(pod.model:GetDescendants()) do
						if part:IsA("BasePart") then
							Reveal(pod_revealed, part)
						end
					end
					Paint(ChamFor(pod.model, "ftf_pod"), color, fill)
					if root and (TopOf(pod.model) - root.Position).Magnitude <= 260 then
						for _, part in ipairs(pod.extras) do
							if part.Parent then
								painted[part] = true
								Reveal(pod_revealed, part)
								Paint(ChamFor(part, "ftf_pod_part"), color, fill)
							end
						end
					end
				end
				if Config.pod_esp then
					local label = pod_labels[pod.model]
					if not label then
						label = NewLabel()
						pod_labels[pod.model] = label
					end
					local anchor = TopOf(pod.model) + Vector3.new(0, 1, 0)
					local space = Config.pod_distance and string.format("%d studs", math.floor((anchor - view.CFrame.Position).Magnitude)) or nil
					PlaceText(label, anchor, full and "freeze pod full" or "freeze pod", space, view, color, 1)
					seen_pod[pod.model] = true
				end
			end
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		local other = player.Character
		if other and other ~= LP.Character and other:FindFirstChildOfClass("Humanoid") then
			local beast = other:FindFirstChild("BeastPowers") ~= nil
			if beast then
				if Config.beast_cham then
					painted[other] = true
					Paint(ChamFor(other, "ftf_beast"), Config.beast_color, Config.beast_fill)
				end
			elseif IsCaptured(player) then
				if Config.captured_cham then
					painted[other] = true
					Paint(ChamFor(other, "ftf_captured"), Config.captured_color, Config.captured_fill)
				end
			elseif Config.runner_cham then
				painted[other] = true
				Paint(ChamFor(other, "ftf_runner"), Config.runner_color, Config.runner_fill)
			end

			if Config.part_cham then
				local tone = beast and Config.beast_color or (IsCaptured(player) and Config.captured_color or Config.runner_color)
				for _, limb in ipairs(other:GetDescendants()) do
					if limb:IsA("BasePart") then
						painted[limb] = true
						Paint(ChamFor(limb, "ftf_part"), tone, 0.55)
					end
				end
			end
			if Config.runner_esp and not beast then
				local label = runner_labels[player]
				if not label then
					label = NewLabel()
					runner_labels[player] = label
				end
				local title = Config.runner_name and player.Name or nil
				local space = Config.runner_distance and string.format("%d studs", math.floor((TopOf(other) - view.CFrame.Position).Magnitude)) or nil
				PlaceText(label, TopOf(other) + Vector3.new(0, 1, 0), title, space, view, Config.runner_color, 1)
				told[player] = true
			end
		end
	end
	-- i love to copy and paste heheehe
	for computer, label in pairs(labels) do
		if not seen[computer] then
			ClearLabel(label)
			if not computer:IsDescendantOf(workspace) then
				RemoveLabel(label)
				labels[computer] = nil
			end
		end
	end
	for player, label in pairs(runner_labels) do
		if not told[player] then
			ClearLabel(label)
			local other = player.Character
			if not other or not player.Parent then
				RemoveLabel(label)
				runner_labels[player] = nil
			end
		end
	end
	for model, label in pairs(exit_labels) do
		if not seen_exit[model] then
			ClearLabel(label)
			if not model:IsDescendantOf(workspace) then
				RemoveLabel(label)
				exit_labels[model] = nil
			end
		end
	end
	for model, label in pairs(pod_labels) do
		if not seen_pod[model] then
			ClearLabel(label)
			if not model:IsDescendantOf(workspace) then
				RemoveLabel(label)
				pod_labels[model] = nil
			end
		end
	end
	for model, label in pairs(locker_labels) do
		if not seen_locker[model] then
			ClearLabel(label)
			if not model:IsDescendantOf(workspace) then
				RemoveLabel(label)
				locker_labels[model] = nil
			end
		end
	end
	for model, label in pairs(vent_labels) do
		if not seen_vent[model] then
			ClearLabel(label)
			if not model:IsDescendantOf(workspace) then
				RemoveLabel(label)
				vent_labels[model] = nil
			end
		end
	end
	for model, label in pairs(door_labels) do
		if not seen_door[model] then
			ClearLabel(label)
			if not model:IsDescendantOf(workspace) then
				RemoveLabel(label)
				door_labels[model] = nil
			end
		end
	end
	for model, highlight in pairs(chams) do
		if not painted[model] then
			highlight:Destroy()
			chams[model] = nil
		end
	end
end)

local function SendAction(down)
	RemoteEvent = RemoteEvent or ReplicatedStorage:FindFirstChild("RemoteEvent")
	if not RemoteEvent then
		return false
	end
	return (pcall(function()
		RemoteEvent:FireServer("Input", "Action", down)
	end))
end

local function SendInput(down)
	local stats = Stats()
	if not (RemoteEvent and stats) then
		return false
	end
	local ok = pcall(function()
		RemoteEvent:FireServer("Input", "Action", down)
		stats.SetValue("ActionInput", down)
	end)
	return ok
end

local function Press(hold, submit)
	if submit then
		if not SendInput(true) then
			return false
		end
	elseif not SendAction(true) then
		return false
	end
	task.delay(hold or 0.08, function()
		if submit then
			SendInput(false)
		else
			SendAction(false)
		end
	end)
	return true
end

local touch_params = OverlapParams.new()
touch_params.FilterType = Enum.RaycastFilterType.Include
touch_params.FilterDescendantsInstances = {}

local function OnComputer(computer, character)
	if not (character and character.Parent) then
		return false
	end
	touch_params.FilterDescendantsInstances = { character }
	for index = 1, 3 do
		local trigger = computer:FindFirstChild("ComputerTrigger" .. index, true)
		if trigger and trigger:IsA("BasePart") then
			if #workspace:GetPartsInPart(trigger, touch_params) > 0 then
				return true
			end
		end
	end
	return false
end

local last_said
local action_at = 0
local jump_request = UserInputService.JumpRequest:Connect(function()
	if not Alive() or not Config.inf_jump then
		return
	end
	local humanoid = Humanoid()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local function Report(state, detail)
	if last_said == state then
		return
	end
	last_said = state
	hack_state = state
end

local function NearestComputer(root)
	local best, best_gap = nil, Config.hack_range
	for _, computer in ipairs(Computers()) do
		if not IsDone(computer) then
			for index = 1, 3 do
				local trigger = computer:FindFirstChild("ComputerTrigger" .. index, true)
				local point
				if trigger and trigger:IsA("BasePart") then
					point = trigger.Position
				else
					point = (computer:GetBoundingBox()).Position
				end
				local gap = (point - root.Position).Magnitude
				if gap <= best_gap then
					best, best_gap = computer, gap
				end
			end
		end
	end
	return best, best_gap
end

local timing_at = 0
local timing_check = RunService.Heartbeat:Connect(function()
	if not Alive() or not Config.auto_hack then
		return
	end
	local character = LP.Character
	if not character or not character:FindFirstChildOfClass("Humanoid") or character:FindFirstChild("BeastPowers") then
		return
	end
	local gui = LP.PlayerGui:FindFirstChild("ScreenGui")
	local circle = gui and gui:FindFirstChild("TimingCircle", true)
	if not (circle and circle.Visible) then
		return
	end
	local pin = circle:FindFirstChild("TimingPin", true)
	local base = circle:FindFirstChild("TimingBase", true)
	if not (pin and base) then
		return
	end
	local gap = pin.Rotation - base.Rotation
	local now = os.clock()
	if gap >= 30 and gap <= 50 and now - timing_at > 0.05 then
		timing_at = now
		if Press(0.08, true) then
			Report("timing press", string.format("%.0f degrees in", gap))
		else
			Report("no key input available")
		end
	end
end)

local StopWalk
local settle_at, settle_side = 0, 1

local function Approach(computer, root, humanoid)
	local trigger, best = nil, math.huge
	for index = 1, 3 do
		local part = computer:FindFirstChild("ComputerTrigger" .. index, true)
		if part and part:IsA("BasePart") then
			local distance = (part.Position - root.Position).Magnitude
			if distance < best then
				trigger, best = part, distance
			end
		end
	end
	if not trigger then
		return
	end
	if best > 0.5 then
		humanoid:MoveTo(trigger.Position)
		Report("stepping onto the computer", string.format("%.0f studs away", best))
		return
	end
	humanoid:MoveTo(root.Position)
	if os.clock() - settle_at < 0.5 then
		return
	end
	settle_at = os.clock()
	settle_side = -settle_side
	local side = root.CFrame.RightVector * (settle_side * 0.9)
	humanoid:MoveTo(trigger.Position + Vector3.new(side.X, 0, side.Z))
	Report("shuffling onto the computer", string.format("%.0f studs away", best))
end

local function HackTick()
	if not Config.auto_hack then
		StopWalk("hack")
		Report("auto hack off")
		return
	end
	local character = LP.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not (humanoid and humanoid.Health > 0 and root) then
		Report("waiting for your character")
		return
	end
	if character:FindFirstChild("BeastPowers") then -- abit stupid but i had too
		Report("you are the beast, nothing to hack")
		return
	end
	local gui = LP.PlayerGui:FindFirstChild("ScreenGui")
	local circle = gui and gui:FindFirstChild("TimingCircle", true)
	if circle and circle.Visible then
		return
	end
	local target, gap = NearestComputer(root)
	if not target then
		StopWalk("hack")
		Report("no computer in range", string.format("get within %d studs of one", Config.hack_range))
		return
	end
	local live_stats = Stats()
	local box = gui and gui:FindFirstChild("ActionBox", true)
	local on_trigger = live_stats and live_stats.GetValue("OnTrigger") == true
	local ready = OnComputer(target, character) and (on_trigger or (box and box.Visible))
	if not ready then
		if Config.complete then
			Report("computer in range", string.format("%.0f studs away", gap))
		else
			Approach(target, root, humanoid)
		end
		return
	end
	StopWalk("hack")
	local live_goal = live_stats and live_stats.GetValue("TimingGoalPosition")
	if type(live_goal) == "number" and live_goal > 0 then
		return
	end
	if os.clock() - action_at > 0.5 then
		action_at = os.clock()
		if Press(0.15) then
			Report("hacking computer", string.format("%.0f studs away", gap))
		else
			Report("no input available")
		end
	end
end

task.spawn(function()
	while Alive() do
		task.wait(0.05)
		local ok = pcall(HackTick)
		if not ok then
			if last_said ~= "error" then
				last_said = "error"
				hack_state = "error"
				-- print("autohack stopped: " .. tostring(err))
			end
		end
	end
end)

	task.spawn(function()
	local peak = 0
	while Alive() do
		task.wait(0.1)
		local value = ActionProgress()
		if value > 0 then
			peak = math.max(peak, value)
		elseif hack_progress > 0 then
			if peak >= 0.99 then
				local character = LP.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local best, best_gap = nil, 10
				for _, computer in ipairs(Computers()) do
					local trigger = computer:FindFirstChild("ComputerTrigger1", true)
					local point = trigger and trigger:IsA("BasePart") and trigger.Position
					if point and root then
						local gap = (point - root.Position).Magnitude
						if gap <= best_gap then
							best, best_gap = computer, gap
						end
					end
				end
				if best then
					hack_values[best] = 1
				end
			end
			peak = 0
		end
		hack_progress = value
	end
end)

local lighting = game:GetService("Lighting")
local visuals = { 
	bright = nil, 
	fog = nil, 
	fov = nil 
}
local visual_hold = 0
local function CaptureLight()
	return {
		brightness = lighting.Brightness,
		ambient = lighting.Ambient,
		outdoor = lighting.OutdoorAmbient,
		shadows = lighting.GlobalShadows,
	}
end

local function CaptureFog()
	local atmos = {}
	for _, item in ipairs(lighting:GetChildren()) do
		if item:IsA("Atmosphere") then
			atmos[item] = { 
				density = item.Density, 
				haze = item.Haze 
			}
		end
	end
	return { 
		start = lighting.FogStart, 
		finish = lighting.FogEnd, 
		atmos = atmos 
	}
end

local function RestoreLight(saved)
	lighting.Brightness = saved.brightness
	lighting.Ambient = saved.ambient
	lighting.OutdoorAmbient = saved.outdoor
	lighting.GlobalShadows = saved.shadows
end

local function RestoreFog(saved)
	lighting.FogStart = saved.start
	lighting.FogEnd = saved.finish
	for item, values in pairs(saved.atmos) do
		if item.Parent then
			item.Density = values.density
			item.Haze = values.haze
		end
	end
end

local function ApplyVisuals()
	if os.clock() < visual_hold then
		return
	end
	if Config.fullbright then
		visuals.bright = visuals.bright or CaptureLight()
		lighting.Brightness = 3
		lighting.Ambient = Color3.fromRGB(210, 210, 210)
		lighting.OutdoorAmbient = Color3.fromRGB(210, 210, 210)
		lighting.GlobalShadows = false
	elseif visuals.bright then
		RestoreLight(visuals.bright)
		visuals.bright = nil
	end
	if Config.no_fog then
		visuals.fog = visuals.fog or CaptureFog()
		lighting.FogStart = 0
		lighting.FogEnd = 100000
		for item in pairs(visuals.fog.atmos) do
			if item.Parent then
				item.Density = 0
				item.Haze = 0
			end
		end
	elseif visuals.fog then
		RestoreFog(visuals.fog)
		visuals.fog = nil
	end
	local camera = workspace.CurrentCamera
	if camera then
		if Config.fov then
			visuals.fov = visuals.fov or camera.FieldOfView
			camera.FieldOfView = Config.fov_value
		elseif visuals.fov then
			camera.FieldOfView = visuals.fov
			visuals.fov = nil
		end
	end
end

local visual_map_check
visual_map_check = workspace.ChildAdded:Connect(function(child)
	if child:IsA("Folder") and child.Name:find(" by ") then
		visual_hold = os.clock() + 0.6
		visuals.bright = nil
		visuals.fog = nil
	end
end)

local crawl_track = nil
local function CrawlAnimation(humanoid)
	local character = LP.Character
	local item = character and character:FindFirstChild("AnimCrawl", true)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not (item and item:IsA("Animation") and animator) then
		return nil
	end
	local ok, track = pcall(function()
		return animator:LoadAnimation(item)
	end)
	if ok and track then
		track.Looped = true
		return track
	end
	return nil
end

local function ApplyCrawl()
	if not RemoteEvent or Config.auto_crawl == crawl_on then
		return
	end
	local humanoid = Humanoid()
	if not humanoid then
		crawl_on = false
		return
	end
	crawl_on = Config.auto_crawl
	pcall(function()
		RemoteEvent:FireServer("Input", "Crawl", crawl_on)
	end)
	humanoid.HipHeight = crawl_on and -2 or 0
	local fast = Config.walkspeed and Config.walk_value or nil
	humanoid.WalkSpeed = crawl_on and (fast or 8) or (fast or 16)
	if crawl_track then
		crawl_track:Stop()
		crawl_track = nil
	end
	if crawl_on then
		crawl_track = CrawlAnimation(humanoid)
		if crawl_track then
			crawl_track:Play(0.1, 1, 0)
		end
	end
end

task.spawn(function()
	while Alive() do
		task.wait(0.2)
		ApplySpeed()
		ApplyJump()
	end
end)

task.spawn(function()
	while Alive() do
		task.wait(0.1)
		ApplyVisuals()
		ApplyCrawl()
	end
end)

task.spawn(function()
	while Alive() do
		task.wait(0.5)
		if Config.watermark then
			local left = ReplicatedStorage:FindFirstChild("ComputersLeft")
			local clock = ReplicatedStorage:FindFirstChild("GameTimer")
			local text = string.format("flee the facility  %d computers  %d pods", #Computers(), #Pods())
			if left and left:IsA("ValueBase") then
				text = text .. string.format("  |  %d left", left.Value)
			end
			if clock and clock:IsA("ValueBase") then
				text = text .. string.format("  |  %d:%02d", math.floor(clock.Value / 60), clock.Value % 60)
			end
			if Config.progress and hack_progress > 0 then
				text = text .. string.format("  |  hacking %d%%", math.floor(hack_progress * 100))
			end
			if Config.auto_hack then
				text = text .. "  |  " .. hack_state
			end
			library:SetWatermark(text)
		else
			library:SetWatermarkVisible(false)
		end
	end
end)

local walk = { 
	owner = nil, 
	root = nil, 
	points = nil, 
	step = 1, 
	goal = nil 
}

StopWalk = function(owner)
	if owner and walk.owner ~= owner then
		return
	end
	if walk.root and walk.root.Parent then
		walk.root.Anchored = false
	end
	walk.owner, walk.root, walk.points, walk.step, walk.goal = nil, nil, nil, 1, nil
end

local function Walk(owner, root, goal, dt, reach) 
	if not goal then
		StopWalk(owner)
		return nil
	end
	if walk.owner ~= owner then
		StopWalk()
	end
	if walk.root ~= root or walk.goal ~= goal then
		StopWalk()
		walk.owner = owner
		walk.root = root
		walk.goal = goal
		local low = math.min(root.Position.Y, goal.Y) - 6
		walk.points = {
			Vector3.new(root.Position.X, low, root.Position.Z),
			Vector3.new(goal.X, low, goal.Z),
			goal,
		}
		walk.step = 1
	end
	local point = walk.points[walk.step]
	local stop = reach or 0.6
	if not point then
		if walk.root and walk.root.Parent then
			walk.root.Anchored = false
		end
		return "arrived"
	end
	local gap = point - root.Position
	if gap.Magnitude <= stop then
		walk.step = walk.step + 1
		return "moving"
	end
	local next = root.Position + gap.Unit * math.min(24 * dt, gap.Magnitude)
	local flat = Vector3.new(gap.X, 0, gap.Z)
	root.Anchored = true
	if flat.Magnitude > 0.05 then
		root.CFrame = CFrame.lookAt(next, next + flat.Unit)
	else
		root.CFrame = CFrame.new(next) * root.CFrame.Rotation
	end
	return "moving"
end

local function PlayerRoot()
	local character = LP.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not (root and humanoid and humanoid.Health > 0) then
		return nil
	end
	local stats = LP:FindFirstChild("TempPlayerStatsModule")
	local captured = stats and stats:FindFirstChild("Captured")
	if captured and captured.Value then
		return nil
	end
	return root
end

local unfreeze_home = nil
local unfreeze_fire_at = 0
local function CapturedPod(character)
	for _, pod in ipairs(Pods()) do
		local trigger = pod.trigger
		local torso = trigger and trigger:FindFirstChild("CapturedTorso")
		local event = trigger and trigger:FindFirstChild("Event")
		if trigger and event and torso and torso:IsA("ObjectValue") then
			local body = torso.Value
			if body and not body:IsDescendantOf(character) then
				return { 
					point = trigger.Position, 
					event = event 
				}
			end
		end
	end
	return nil
end

local function UnfreezeTick(dt)
	unfreeze_moving = false
	local root = PlayerRoot()
	if not Config.unfreeze or not root then
		unfreeze_home = nil
		StopWalk("unfreeze")
		return
	end
	local target = CapturedPod(LP.Character)
	if target then
		unfreeze_home = unfreeze_home or root.Position
		local status = Walk("unfreeze", root, target.point, dt)
		unfreeze_moving = status == "moving"
		if status == "arrived" and os.clock() - unfreeze_fire_at > 0.2 then
			unfreeze_fire_at = os.clock()
			RemoteEvent = RemoteEvent or ReplicatedStorage:FindFirstChild("RemoteEvent")
			if RemoteEvent then
				pcall(function()
					RemoteEvent:FireServer("Input", "Trigger", true, target.event)
					RemoteEvent:FireServer("Input", "Action", true)
				end)
			end
		end
		return
	end
	if unfreeze_home then
		local status = Walk("unfreeze", root, unfreeze_home, dt)
		unfreeze_moving = status == "moving"
		if status == "arrived" then
			unfreeze_home = nil
			StopWalk("unfreeze")
		end
		return
	end
	StopWalk("unfreeze")
end

local complete_home, complete_target, complete_trigger, complete_deadline = nil, nil, nil, 0
local complete_cooldown = {}
local complete_was = false

local function FreeKeyboard(computer, root)
	local best, best_gap = nil, math.huge
	for index = 1, 3 do
		local trigger = computer:FindFirstChild("ComputerTrigger" .. index, true)
		if trigger and trigger:IsA("BasePart") then
			local busy = false
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LP then
					local character = player.Character
					local other = character and character:FindFirstChild("HumanoidRootPart")
					if other and (other.Position - trigger.Position).Magnitude <= 4 then
						busy = true
						break
					end
				end
			end
			if not busy then
				local gap = (trigger.Position - root.Position).Magnitude
				if gap < best_gap then
					best, best_gap = trigger, gap
				end
			end
		end
	end
	return best
end

local function NextComputer(root)
	local best, best_trigger, best_gap = nil, nil, math.huge
	for _, computer in ipairs(Computers()) do
		if not IsDone(computer) and (complete_cooldown[computer] or 0) < os.clock() then
			local trigger = FreeKeyboard(computer, root)
			if trigger then
				local gap = (trigger.Position - root.Position).Magnitude
				if gap < best_gap then
					best, best_trigger, best_gap = computer, trigger, gap
				end
			end
		end
	end
	return best, best_trigger
end

local function ReturnHome(root, dt)
	if not complete_home then
		StopWalk("complete")
		return
	end
	local status = Walk("complete", root, complete_home, dt)
	complete_moving = status == "moving"
	if status == "arrived" then
		complete_home = nil
		StopWalk("complete")
	end
end

local function CompleteTick(dt)
	complete_moving = false
	if Config.complete and not complete_was then
		complete_cooldown = {}
		complete_home, complete_target, complete_trigger = nil, nil, nil
	end
	complete_was = Config.complete
	local root = PlayerRoot()
	if not Config.complete or not Config.auto_hack or not root or (Config.unfreeze and unfreeze_home) then
		complete_home, complete_target, complete_trigger = nil, nil, nil
		StopWalk("complete")
		return
	end
	local left = ReplicatedStorage:FindFirstChild("ComputersLeft")
	if left and left:IsA("ValueBase") and left.Value <= 0 then
		complete_target, complete_trigger = nil, nil
		ReturnHome(root, dt)
		return
	end
	if complete_target and (not complete_target:IsDescendantOf(workspace) or IsDone(complete_target) or not (complete_trigger and complete_trigger.Parent)) then
		complete_target, complete_trigger = nil, nil
	end
	if not complete_target then
		complete_target, complete_trigger = NextComputer(root)
		complete_deadline = 0
	end
	if not complete_target then
		ReturnHome(root, dt)
		return
	end
	local trigger = complete_trigger
	if not (trigger and trigger:IsA("BasePart")) then
		complete_cooldown[complete_target] = os.clock() + 20
		complete_target, complete_trigger = nil, nil
		return
	end
	complete_home = complete_home or root.Position
	local status = Walk("complete", root, trigger.Position, dt, 0.25)
	complete_moving = status == "moving"
	if status ~= "arrived" then
		return
	end
	local screen = complete_target:FindFirstChild("Screen", true)
	local aim = screen and screen:IsA("BasePart") and screen.Position or trigger.Position
	local face = Vector3.new(aim.X, root.Position.Y, aim.Z)
	if (face - root.Position).Magnitude > 0.5 then
		root.CFrame = CFrame.lookAt(root.Position, face)
	end
	if hack_progress > 0 then
		complete_deadline = os.clock() + 15
	elseif complete_deadline == 0 then
		complete_deadline = os.clock() + 15
	elseif os.clock() > complete_deadline then
		complete_cooldown[complete_target] = os.clock() + 20
		complete_target, complete_trigger = nil, nil
	end
end

local unfreeze_check = RunService.Heartbeat:Connect(function(dt)
	if not Alive() then
		return
	end
	pcall(UnfreezeTick, dt)
	pcall(CompleteTick, dt)
end)

local function destroy()
	StopWalk()
	trigger_guard:Disconnect()
	if map_signal then
		map_signal:Disconnect()
	end
	if round_signal then
		round_signal:Disconnect()
	end
	RestoreReveal(pod_revealed)
	RestoreDoors()
	if visual_map_check then
		visual_map_check:Disconnect()
		visual_map_check = nil
	end
	if unfreeze_check then
		unfreeze_check:Disconnect()
		unfreeze_check = nil
	end
	if noclip_check then
		noclip_check:Disconnect()
		noclip_check = nil
	end
	if render then
		render:Disconnect()
		render = nil
	end
	if timing_check then
		timing_check:Disconnect()
		timing_check = nil
	end
	if jump_request then
		jump_request:Disconnect()
		jump_request = nil
	end
	for _, label in pairs(labels) do
		RemoveLabel(label)
	end
	labels = {}
	for _, label in pairs(runner_labels) do
		RemoveLabel(label)
	end
	runner_labels = {}
	for _, label in pairs(exit_labels) do
		RemoveLabel(label)
	end
	exit_labels = {}
	for _, group in ipairs({ pod_labels, locker_labels, vent_labels, door_labels }) do
		for _, label in pairs(group) do
			RemoveLabel(label)
		end
	end
	pod_labels, locker_labels, vent_labels, door_labels = {}, {}, {}, {}
	for _, highlight in pairs(chams) do
		highlight:Destroy()
	end
	chams = {}
	if crawl_on and RemoteEvent then
		pcall(function()
			RemoteEvent:FireServer("Input", "Crawl", false)
		end)
	end
	if crawl_track then
		crawl_track:Stop()
		crawl_track = nil
	end
	if visuals.bright then
		RestoreLight(visuals.bright)
	end
	if visuals.fog then
		RestoreFog(visuals.fog)
	end
	if visuals.fov and workspace.CurrentCamera then
		workspace.CurrentCamera.FieldOfView = visuals.fov
	end
	if workspace.CurrentCamera then
		workspace.CurrentCamera.FieldOfView = 70
	end
	for part in pairs(noclip_saved) do
		if part.Parent then
			part.CanCollide = true
		end
	end
	noclip_saved = {}
	for _, label in pairs(progress_labels) do
		label:Remove()
	end
	progress_labels = {}
	progress_head:Remove()

	pcall(function()
		library:SetWatermarkVisible(false)
	end)

	if shared.ftf and shared.ftf.destroy == destroy then
		shared.ftf = nil
	end
	if library.Destroy then
		pcall(library.Destroy, library)
	end
	-- print("flee the facility unloaded")
end

shared.ftf = {
	destroy = destroy,
	config = Config,
	computers = Computers,
	pods = Pods,
	state = function()
		return hack_state
	end,
	draw = function()
		return {
			active = draw_state.active,
			text = draw_state.text,
			size = draw_state.size,
			visible = draw_state.visible,
			x = draw_state.x,
			y = draw_state.y,
		}
	end,
	unload_requested = false,
}

task.spawn(function()
	while Alive() do
		task.wait(0.3)
		if shared.ftf and shared.ftf.unload_requested then
			destroy()
			break
		end
	end
end)

-- library:Notify("flee the facility", "loaded - " .. #Computers() .. " computers, " .. #Pods() .. " pods", 3, "good")
