
--==================================================
-- ANIME HUB v2.0
-- Anime Adventures Macro Framework
--==================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer

-- CONFIGURATION
local Config = {
    AntiAFK = false,
    AutoReconnect = false,
    AutoLoader = false,

    EventFinder = false,
    DailyChallenge = false,

    AutoStart = false,
    AutoReplay = false,
    AutoPlace = false,
    AutoUpgrade = false,
    AutoAbility = false,

    UnitPriority = {
        "Unit 1",
        "Unit 2",
        "Unit 3",
        "Unit 4",
        "Unit 5"
    },

    UpgradePriority = {
        "Unit 2",
        "Unit 1",
        "Unit 3",
        "Unit 4",
        "Unit 5"
    }
}

-- COLORS
local Theme = {
    Background = Color3.fromRGB(12, 15, 26),
    Sidebar = Color3.fromRGB(18, 23, 37),
    Card = Color3.fromRGB(27, 34, 52),
    Element = Color3.fromRGB(38, 47, 69),
    Purple = Color3.fromRGB(137, 94, 255),
    Blue = Color3.fromRGB(85, 115, 255),
    White = Color3.fromRGB(245, 247, 255),
    Muted = Color3.fromRGB(150, 161, 185),
    Green = Color3.fromRGB(60, 210, 145),
    Red = Color3.fromRGB(240, 80, 100)
}

-- CLEANUP
local Core = (gethui and gethui())
    or Player:WaitForChild("PlayerGui")

local Old = Core:FindFirstChild("AnimeHubV2")
if Old then Old:Destroy() end

-- HELPERS
local function Create(class, properties, parent)
    local object = Instance.new(class)

    for key, value in pairs(properties) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function Round(parent, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10)
    }, parent)
end

local function Label(parent, text, size, color, bold)
    return Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = text,
        TextSize = size or 12,
        TextColor3 = color or Theme.White,
        Font = bold and Enum.Font.GothamBold
            or Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local function Button(parent, text, color)
    local b = Create("TextButton", {
        BackgroundColor3 = color or Theme.Element,
        Text = text,
        TextSize = 11,
        TextColor3 = Theme.White,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, parent)

    Round(b, 8)
    return b
end

-- MAIN GUI
local Gui = Create("ScreenGui", {
    Name = "AnimeHubV2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, Core)

local Main = Create("Frame", {
    Size = UDim2.fromOffset(690, 475),
    Position = UDim2.new(0.5, -345, 0.5, -237),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0
}, Gui)

Round(Main, 14)

-- TOP BAR
local Top = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0
}, Main)

Round(Top, 14)

local Logo = Create("Frame", {
    Position = UDim2.fromOffset(15, 11),
    Size = UDim2.fromOffset(36, 36),
    BackgroundColor3 = Theme.Purple
}, Top)

Round(Logo, 10)

local LogoText = Label(Logo, "A", 19, Theme.White, true)
LogoText.Size = UDim2.fromScale(1, 1)
LogoText.TextXAlignment = Enum.TextXAlignment.Center

local Title = Label(Top, "ANIME HUB", 15, Theme.White, true)
Title.Position = UDim2.fromOffset(61, 7)
Title.Size = UDim2.fromOffset(180, 24)

local Sub = Label(Top, "ANIME ADVENTURES  •  V2.0", 9, Theme.Muted)
Sub.Position = UDim2.fromOffset(62, 30)
Sub.Size = UDim2.fromOffset(200, 15)

local Close = Button(Top, "×", Theme.Element)
Close.Size = UDim2.fromOffset(30, 30)
Close.Position = UDim2.new(1, -43, 0, 14)
Close.TextSize = 20

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

-- DRAG WINDOW
local dragging = false
local dragStart
local startPosition

Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- SIDEBAR
local Sidebar = Create("Frame", {
    Position = UDim2.fromOffset(0, 58),
    Size = UDim2.new(0, 155, 1, -58),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0
}, Main)

local Content = Create("Frame", {
    Position = UDim2.fromOffset(170, 72),
    Size = UDim2.new(1, -185, 1, -87),
    BackgroundTransparency = 1
}, Main)

local Pages = {}
local Navigation = {}

local function CreatePage(name)
    local page = Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Purple,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false
    }, Content)

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(
            0, 0, 0, layout.AbsoluteContentSize.Y + 15
        )
    end)

    Pages[name] = page
    return page
end

local function ShowPage(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end

    for pageName, button in pairs(Navigation) do
        button.BackgroundColor3 =
            pageName == name and Theme.Element or Theme.Sidebar
    end
end

local function AddNavigation(name, symbol)
    local b = Button(
        Sidebar,
        symbol .. "   " .. name,
        Theme.Sidebar
    )

    b.Name = name
    b.Size = UDim2.new(1, -16, 0, 36)
    b.Position = UDim2.fromOffset(8, 45 + (#Navigation * 43))
    b.TextXAlignment = Enum.TextXAlignment.Left

    Navigation[name] = b

    b.MouseButton1Click:Connect(function()
        ShowPage(name)
    end)
end

Label(Sidebar, "WORKSPACE", 9, Theme.Muted, true).Position =
    UDim2.fromOffset(14, 15)

AddNavigation("Dashboard", "⌂")
AddNavigation("Match Finder", "◈")
AddNavigation("Unit Priority", "★")
AddNavigation("Automation", "⚡")
AddNavigation("Settings", "⚙")

-- PAGE SETUP
local Dashboard = CreatePage("Dashboard")
local Match = CreatePage("Match Finder")
local Priority = CreatePage("Unit Priority")
local Automation = CreatePage("Automation")
local Settings = CreatePage("Settings")

-- SECTION
local function Section(parent, title, description, height)
    local frame = Create("Frame", {
        Size = UDim2.new(1, -5, 0, height or 65),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0
    }, parent)

    Round(frame, 10)

    Label(frame, title, 13, Theme.White, true).Position =
        UDim2.fromOffset(13, 8)

    Label(frame, description, 9, Theme.Muted).Position =
        UDim2.fromOffset(13, 32)

    return frame
end

-- TOGGLE
local function Toggle(parent, title, description, key)
    local row = Section(parent, title, description, 57)

    local toggle = Button(
        row,
        Config[key] and "ON" or "OFF",
        Config[key] and Theme.Purple or Theme.Element
    )

    toggle.Size = UDim2.fromOffset(48, 25)
    toggle.Position = UDim2.new(1, -60, 0.5, -12)

    toggle.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]

        toggle.Text = Config[key] and "ON" or "OFF"
        toggle.BackgroundColor3 =
            Config[key] and Theme.Purple or Theme.Element
    end)

    return row
end

-- DASHBOARD
Section(
    Dashboard,
    "Welcome to Anime Hub",
    "Your Anime Adventures macro control center."
)

Section(
    Dashboard,
    "System Status",
    "UI loaded successfully. Game actions are not connected."
)

local StartButton = Button(
    Dashboard,
    "▶   START MACRO",
    Theme.Purple
)

StartButton.Size = UDim2.new(1, -5, 0, 42)

local StatusText = Label(
    Dashboard,
    "● READY",
    11,
    Theme.Green,
    true
)

StatusText.Size = UDim2.new(1, 0, 0, 25)

local Running = false

StartButton.MouseButton1Click:Connect(function()
    Running = not Running

    if Running then
        StartButton.Text = "■   STOP MACRO"
        StartButton.BackgroundColor3 = Theme.Red
        StatusText.Text = "● RUNNING"
    else
        StartButton.Text = "▶   START MACRO"
        StartButton.BackgroundColor3 = Theme.Purple
        StatusText.Text = "● READY"
    end
end)

-- MATCH FINDER
Section(
    Match,
    "Match Finder",
    "Choose the game mode you want to configure."
)

Toggle(Match, "Event Match", "Event finder preference.", "EventFinder")
Toggle(Match, "Daily Challenge", "Daily challenge preference.", "DailyChallenge")
Toggle(Match, "Auto Start", "Start when ready.", "AutoStart")
Toggle(Match, "Auto Replay", "Replay after completion.", "AutoReplay")

-- UNIT PRIORITY
Section(
    Priority,
    "Placement Priority",
    "Move units up or down to change their order."
)

local function PriorityList(parent, title, list)
    local card = Section(parent, title, "Use arrows to change priority.", 45)

    local holder = Create("Frame", {
        Position = UDim2.fromOffset(8, 50),
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, card)

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 6)
    }, holder)

    local function Refresh()
        for _, child in ipairs(holder:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        for index, unitName in ipairs(list) do
            local row = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element
            }, holder)

            Round(row, 7)

            local name = Label(
                row,
                "#" .. index .. "   " .. unitName,
                11,
                Theme.White,
                true
            )

            name.Position = UDim2.fromOffset(10, 0)
            name.Size = UDim2.new(1, -95, 1, 0)

            local up = Button(row, "↑", Theme.Purple)
            up.Size = UDim2.fromOffset(27, 27)
            up.Position = UDim2.new(1, -62, 0.5, -13)

            local down = Button(row, "↓", Theme.Purple)
            down.Size = UDim2.fromOffset(27, 27)
            down.Position = UDim2.new(1, -32, 0.5, -13)

            up.MouseButton1Click:Connect(function()
                if index > 1 then
                    list[index], list[index - 1] =
                        list[index - 1], list[index]
                    Refresh()
                end
            end)

            down.MouseButton1Click:Connect(function()
                if index < #list then
                    list[index], list[index + 1] =
                        list[index + 1], list[index]
                    Refresh()
                end
            end)
        end

        task.defer(function()
            card.Size = UDim2.new(
                1, -5,
                0, 50 + layout.AbsoluteContentSize.Y
            )
        end)
    end

    Refresh()
end

PriorityList(Priority, "Unit Placement Order", Config.UnitPriority)
PriorityList(Priority, "Unit Upgrade Order", Config.UpgradePriority)

-- AUTOMATION
Section(
    Automation,
    "Gameplay Automation",
    "Configure the actions you want to use."
)

Toggle(Automation, "Auto Place Units", "Placement preference.", "AutoPlace")
Toggle(Automation, "Auto Upgrade", "Upgrade preference.", "AutoUpgrade")
Toggle(Automation, "Auto Ability", "Ability preference.", "AutoAbility")

-- SETTINGS
Section(
    Settings,
    "Connection Settings",
    "Connection monitoring preferences."
)

Toggle(Settings, "Anti-AFK", "Normal idle prevention.", "AntiAFK")
Toggle(Settings, "Auto Reconnect", "Reconnect preference.", "AutoReconnect")
Toggle(Settings, "Auto Loader", "Load framework on startup.", "AutoLoader")

Section(
    Settings,
    "About Anime Hub",
    "Version 2.0 | UI and priority framework."
)

-- ANTI-AFK: NORMAL IDLE PREVENTION
local AfkConnection

local function UpdateAFK()
    if AfkConnection then
        AfkConnection:Disconnect()
        AfkConnection = nil
    end

    if Config.AntiAFK then
        AfkConnection =
            Player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
    end
end

-- Monitor anti-AFK setting
task.spawn(function()
    while Gui.Parent do
        UpdateAFK()
        task.wait(3)
    end
end)

-- DEFAULT PAGE
ShowPage("Dashboard")

print("Anime Hub v2.0 loaded!")
