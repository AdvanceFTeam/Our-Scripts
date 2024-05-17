--// Welcome To RAim

--// Made by AdvanceFalling Team



 --[[ 
   --// Will add this later in the future

    Bullet_Tracer_Settings = {
        BT_Enabled = false,
        BT_Size = 1, -- max 10
        BT_Transparent = 0.5,
        BT_Rainbow = false,
        BT_Color = Color3.fromRGB(255, 255, 255),
    },

]]--

local RAim_Settings = {
    Enabled = true,
    Smooth = 1.0, -- max is 5.0

    --// Please Turn OFF Enabled from RAim_Settings so this can work if you dont it will fucking break, or crash
    FULL_AIMLOCK = false, -- this just full on locks on to every enemy team(not your team) through the walls in the head with max FOV.

    Device = 'PC', -- 'Mobile' or 'PC' 
    Keybind = Enum.KeyCode.Q,

    Aim_Part = "Head", -- HumanoidRootPart, Body, Head, ETC
    Randomize_Aim_Part = false, -- this will aim at the closest part of a character when a crosshair or Cusomt_Crosshiar is close to it. (making it look like you have a legit aim)
    Character = 'Both', -- R6, R15, or Both (Pick both so it will work for any game.)

    WallCheck = true,
    TeamCheck = true,

    Enabled_Distance = false,
    Show_Distance_Area = true, -- Show the area as a circle to see the distance where the aimbot will lock on
    Distance_Area_Position = 'Bottom', -- 'Bottom', 'Center', 'Top'  the circle area
    Distance = 100, -- max 1000

    Select_Player = false, -- Select the player you want to aimlock to (you can choose 1 or more if you want) [ALSO: turn OFF teamcheck if you want to select your team]
    Player = {''},

    Custom_Crosshair = {
        CH_Enabled = false,
        CH_Shape = 'Default', -- Dot, Default(A Cross) 
        CH_Size = 15, -- max size 50
        CH_Transparent = 0.3,
        CH_Rainbow = false,
        CH_Color = Color3.fromRGB(255, 255, 255)
    },
    
    FOV_SETTINGS = {
        FOV_Enabled = true,
        FOV_Shape = 'Circle', -- Box, Triangle, ETC
        FOV_Transparent = 0.5,
        FOV_Size = 120, -- 120 is basic, max is 500
        FOV_Rainbow = false,
        FOV_Color = Color3.fromRGB(255,255,255),
    },

}
