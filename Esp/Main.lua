--// Welcome to RMonnesyEsp Source Code | Inspired by Unnamed ESP & Many Csgo Esp Cheat


--[[
- Work in Progress
- In Development
]]--


--// Made by AdvanceFalling Team
--// We are a team of 6 developer that develope this Customizable Universal Esp :)

--[[ Credits:

    Owner: YellowGreg
    Head Developers: 'Wspboy12', 'MMSVon', 'ShadowClark'
    Developers: 'FrostBite', 'techyguy'

]]



--// [YellowGreg, Wspboy12, MMSVon. ShadowClark, FrostBite]: add function for Health, Distance, Box, Name, Skeleton, Outline, Tracer, OffScreen_Arrow & ETC
--// [YellowGreg, FrostBite, Wspboy12]: Make the fucking Esp_Settings more simple this is messy as fuck

local REsp_Settings = {
    Enabled = true,           -- Will Only Enabled only the the esp that are set to true.
    Streamable = true,        -- Won't show the esp when you are streaming.

    Keybind_Enabled = false,  --// Toggles (Need keybind)
    Keybind_Hold = false,     --// Hold and Release (Need keybind)
    Keybind = Enum.KeyCode.Q, -- Keybind (if 'Toggle' and 'Hold and release' is set to true, it wont do anything because i made it that way - Wspboy12)

    Enabled_All = {
        Enabled_All = false,  -- Enabled All the Esp, even if its false.
        Rainbow_All = false,  -- Makes every esp rainbow, even if its false,
        Distance_All = false, -- Turns on everything from Distance_Settings -> Enabled
    },

    WallCheck = false, -- this is so useless but we added it anyways(false see people through wall, but if true it does opposite)

    TeamCheck_Settings = {
        TeamCheck = true,                        -- I wont add any teamcheck in 'Esp_Settings' - YellowGreg
        TeamCheck_Color = {
            Team = Color3.fromRGB(62, 30, 225),  -- Your Team Color (you can change it if you want to)
            Enemy = Color3.fromRGB(255, 30, 30), -- Your Enemy Color (you can change it if you want to)
            FFA = Color3.fromRGB(255, 255, 255), -- if its 'Free For All' when teamcheck is ON for a game then everyone has white esp
        },
    },

    Enabled_Esp_Part = false,
    ESP_Part = { 'All' },  -- 'All', 'HumanoidRootPart', 'Body', 'Head', 'Left_Hand', 'Right_Hand', and ETC (This is stupid for a ESP, just choose 'All' - MMSVon)
    Character = 'Both',    -- 'R6', 'R15', or 'Both' (Pick both so it will work for any game - Wspboy12)

    Select_Player = false, -- Select the player you want to show (you can choose 1 or more if you want - FrostBite)
    Player = { '' },       -- will display in a gui not in the script (but you can put in a player if you want to - FrostBite)

    --// Esp Settings
    Esp_Settings = {
        Box_Esp = {
            Box_Enabled = true,
            Box_Type = 'Normal', -- 'Normal', 'Dynmaic', '3D', 'Corner', 'Filled'
        },
        Head_Esp = {
            Head_Enabled = false, -- will show a circle around the head so you will know where the head to aim at.
        },
        Health_Esp = {
            Health_Enabled = false,
        },
        Name_Esp = {
            Name_Enabled = false,
        },
        Distance_Esp = {
            Distance = false,
        },
        Cham_Esp = {
            Cham_Enabled = true,
        },
        Skeleton_Esp = {
            Skel_Enabled = true,

            Enabled_Show_Part = false, -- Will only show the part you want
            Show_Part = { 'HumanoidRootPart', 'Head' },
        },
        Tracer_Esp = {
            Tracer_Enabled = true,
            Tracer_Position = 'Bottom', -- Top, Center, or Bottom
            Tracer_PositionPart = false,
            Tracer_Position_Part = { 'Humanoid' },
        },
        BackTrack_Esp = {
            BT_Enabled = false, -- Shows the the recent position of the enemy player (but this is just a esp, NOT a features for fps games to shoot the backtrack)
        },
        OffScreen_Arrow_Esp = {
            Arrow_Enabled = true, -- Shows the offscreen of the enemy player using the arrow
        },
        Outline_Esp = {
            Outline_Enabled = false,
        },
        LookAt_Esp = {
            LookAt_Enabled = false, -- where the enemy player are looking at
        },
        PP_Esp = {
            PP_Enabled = false, -- sus esp
        },
        Circle_Esp = {          --// Looks Trash but is a esp still (Inspired by Frostware Team from Scriptblox)
            Circle_Enabled = false,
        },
    },
    --// Esp Distance
    Distance_Settings = {
        Enabled_Distance = false, -- will now turn on 'Enabled' and 'Distance'

        Enabled_All_Distance = false,
        All_Distance = 125,

        Distance = {
            Box_Esp = 120,
            Head_Esp = 120,
            Health_Esp = 120,
            Name_Esp = 120,
            Distance_Esp = 120,
            Cham_Esp = 120,
            Skeleton_Esp = 120,
            Tracer_Esp = 120,
            OffScreen_Arrow_Esp = 120,
            Outline_Esp = 120,
            LookAt_Esp = 120,
            PP_Esp = 120,
            Circle_Esp = 120,
        },

        Enabled = {
            Box_Esp = false,
            Head_Esp = false,
            Health_Esp = false,
            Name_Esp = false,
            Distance_Esp = false,
            Cham_Esp = false,
            Skeleton_Esp = false,
            Tracer_Esp = false,
            OffScreen_Arrow_Esp = false,
            Outline_Esp = false,
            LookAt_Esp = false,
            PP_Esp = false,
            Circle_Esp = false,
        },
    },
    --// Esp Design
    Esp_Design_Settings = {
        -- Box
        Box_Transparent = 0,
        Box_Thickness = 1,
        Enabled_Box_Outline = false,
        Box_Thickness_Outline = 1,
        Box_Outline_Rainbow = true,
        Box_Outline_Color = Color3.fromRGB(255, 255, 255),
        Box_Filled = false,
        Box_Rainbow = false,
        Box_Color = Color3.fromRGB(255, 255, 255),
        -- Head
        Head_Transparent = 0,
        Head_Thickness = 1,
        Enabled_Head_Outline = true,
        Head_Thickness_Outline = 1,
        Head_Outline_Rainbow = true,
        Head_Outline_Color = Color3.fromRGB(255, 255, 255),
        Head_Filled = false,
        Head_Rainbow = false,
        Head_Color = Color3.fromRGB(255, 255, 255),
        -- Health
        Health_Transparent = 0,
        Health_Thickness = 1,
        Enabled_Health_Outline = true,
        Health_Thickness_Outline = 1,
        Health_Outline_Rainbow = true,
        Health_Outline_Color = Color3.fromRGB(255, 255, 255),
        Health_Rainbow = false,
        Health_Color = Color3.fromRGB(255, 255, 255),
        -- Name
        Name_Transparent = 0,
        Name_Thickness = 1,
        Enabled_Name_Outline = true,
        Name_Thickness_Outline = 1,
        Name_Outline_Rainbow = true,
        Name_Outline_Color = Color3.fromRGB(255, 255, 255),
        Name_Rainbow = false,
        Name_Color = Color3.fromRGB(255, 255, 255),
        -- Distance
        Distance_Transparent = 0,
        Distance_Thickness = 1,
        Enabled_Distance_Outline = true,
        Distance_Thickness_Outline = 1,
        Distance_Outline_Rainbow = false,
        Distance_Outline_Color = Color3.fromRGB(255, 255, 255),
        Distance_Rainbow = false,
        Distance_Color = Color3.fromRGB(255, 255, 255),
        -- Cham
        Cham_Transparent = 0,
        Cham_Thickness = 1,
        Enabled_Cham_Outline = true,
        Cham_Thickness_Outline = 1,
        Cham_Outline_Rainbow = false,
        Cham_Outline_Color = Color3.fromRGB(255, 255, 255),
        Cham_Rainbow = false,
        Cham_Color = Color3.fromRGB(255, 255, 255),
        -- Skeleton
        Skel_Transparent = 0,
        Skel_Thickness = 1,
        Enabled_Skel_Outline = true,
        Skel_Thickness_Outline = 1,
        Skel_Outline_Rainbow = true,
        Skel_Outline_Color = Color3.fromRGB(255, 255, 255),
        Skel_Rainbow = false,
        Skel_Color = Color3.fromRGB(255, 255, 255),
        -- Tracer
        Tracer_Transparent = 0,
        Tracer_Thickness = 1,
        Enabled_Tracer_Outline = true,
        Tracer_Thickness_Outline = 1,
        Tracer_Outline_Rainbow = false,
        Tracer_Outline_Color = Color3.fromRGB(255, 255, 255),
        Tracer_Rainbow = false,
        Tracer_Color = Color3.fromRGB(255, 255, 255),
        -- BackTrack
        BT_Transparent = 0,
        BT_Thickness = 1,
        Enabled_BT_Outline = true,
        BT_Thickness_Outline = 1,
        BT_Outline_Rainbow = false,
        BT_Outline_Color = Color3.fromRGB(255, 255, 255),
        BT_Rainbow = true,
        BT_Color = Color3.fromRGB(255, 255, 255),
        -- OffScreen Arrow
        Arrow_Transparent = 0,
        Arrow_Thickness = 1,
        Enabled_Arrow_Outline = false,
        Arrow_Thickness_Outline = 1,
        Arrow_Outline_Rainbow = false,
        Arrow_Outline_Color = Color3.fromRGB(255, 255, 255),
        Arrow_Filled = false,
        Arrow_Rainbow = false,
        Arrow_Color = Color3.fromRGB(255, 255, 255),
        -- LookAt (Only 1 Line)
        LookAt_Transparent = 0,
        LookAt_Thickness = 1,
        LookAt_Rainbow = false,
        LookAt_Color = Color3.fromRGB(255, 255, 255),
        -- PP     (Only 1 Line)
        PP_Transparent = 0,
        PP_Thickness = 1,
        PP_Rainbow = false,
        PP_Color = Color3.fromRGB(255, 255, 255),
        -- Circle
        Circle_Transparent = 0,
        Circle_Thickness = 1,
        Enabled_Circle_Outline = true,
        Circle_Outline = 1,
        Circle_Outline_Rainbow = false,
        Circle_Outline_Color = Color3.fromRGB(255, 255, 255),
        Circle_Filled = false,
        Circle_Rainbow = false,
        Circle_Color = Color3.fromRGB(255, 255, 255)
    },
}

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local cache = {}
