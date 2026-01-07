local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Cast = {}
Cast.__index = Cast

local Configuration = {
    AutoExecute = true,
    ShowNotifications = true,
    RejoinOnKick = false,
    ExecutionDelay = 0,
    ESPEnabled = true,
    BoxESP = true,
    NameESP = true,
    HealthBar = true,
    ESPDistance = 500,
    Chams = false,
    FullBright = false,
    ShowFPS = true,
    FOV = 70,
    Keybinds = {
        ToggleMenu = "RightShift",
        ToggleESP = "V",
        SpeedHack = "LeftShift",
        FlyMode = "F",
        Noclip = "N",
        TeleportSpawn = "T",
        Aimbot = "Q",
        Triggerbot = "C",
    }
}

local ThemeColors = {
    WindowBg = Color3.new(0.08, 0.08, 0.10),
    ChildBg = Color3.new(0.10, 0.10, 0.12),
    PopupBg = Color3.new(0.12, 0.12, 0.14),
    Border = Color3.new(0.20, 0.20, 0.24),
    FrameBg = Color3.new(0.14, 0.14, 0.18),
    FrameBgHovered = Color3.new(0.16, 0.16, 0.22),
    FrameBgActive = Color3.new(0.18, 0.18, 0.26),
    TitleBg = Color3.new(0.10, 0.10, 0.14),
    TitleBgActive = Color3.new(0.12, 0.12, 0.18),
    Button = Color3.new(0.20, 0.20, 0.28),
    ButtonHovered = Color3.new(0.24, 0.24, 0.34),
    ButtonActive = Color3.new(0.22, 0.22, 0.32),
    Text = Color3.new(0.92, 0.92, 0.94),
    TextDisabled = Color3.new(0.50, 0.50, 0.55),
    Header = Color3.new(0.16, 0.16, 0.22),
    Separator = Color3.new(0.24, 0.24, 0.30),
    SliderGrab = Color3.new(0.32, 0.52, 0.88),
    SliderGrabActive = Color3.new(0.36, 0.56, 0.92),
    CheckMark = Color3.new(0.92, 0.92, 0.94),
    Tab = Color3.new(0.14, 0.14, 0.20),
    TabHovered = Color3.new(0.18, 0.18, 0.26),
    TabActive = Color3.new(0.24, 0.24, 0.36),
    TabUnfocused = Color3.new(0.12, 0.12, 0.18),
}

local LayoutSystem = {
    cursor = {x = 8, y = 8},
    indent = 0,
    sameLine = false,
    lastWidth = 0,
    lineHeight = 0,
    groupStack = {},
    currentTab = nil,
    tabs = {},
    sliders = {} 
}

function Cast:Initialize(title)
    local self = setmetatable({}, Cast)
    
    self.title = title or "Cast UI v1.3"
    self.isOpen = true
    self.consoleOpen = false
    self.recordingKeybind = nil
    self.activeSliders = {}
    
    self:SetupUI()
    self:SetupConsole()
    self:SetupInput()
    
    self:CreateTab("Main")
    self:CreateTab("Visuals")
    self:CreateTab("Keybinds")
    
    self:AddLog("Cast UI v1.3 initialized")
    
    return self
end

function Cast:SetupUI()
    self.ui = Instance.new("ScreenGui")
    self.ui.Name = "CastUI"
    self.ui.ResetOnSpawn = false
    self.ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ui.Parent = PlayerGui
    
    self.window = Instance.new("Frame")
    self.window.Size = UDim2.new(0, 520, 0, 550)
    self.window.Position = UDim2.new(0.5, -260, 0.5, -275)
    self.window.BackgroundColor3 = ThemeColors.WindowBg
    self.window.BorderSizePixel = 0
    self.window.ClipsDescendants = true
    self.window.Parent = self.ui
    
    local windowStroke = Instance.new("UIStroke")
    windowStroke.Color = ThemeColors.Border
    windowStroke.Thickness = 1
    windowStroke.Parent = self.window
    
    self.titleBar = Instance.new("Frame")
    self.titleBar.Size = UDim2.new(1, 0, 0, 28)
    self.titleBar.BackgroundColor3 = ThemeColors.TitleBg
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.window
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.title
    titleLabel.TextColor3 = ThemeColors.Text
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.SourceSansSemibold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = self.titleBar
    
    local consoleBtn = Instance.new("TextButton")
    consoleBtn.Size = UDim2.new(0, 24, 0, 24)
    consoleBtn.Position = UDim2.new(1, -56, 0.5, -12)
    consoleBtn.BackgroundColor3 = ThemeColors.Button
    consoleBtn.Text = ">_"
    consoleBtn.TextColor3 = ThemeColors.Text
    consoleBtn.TextSize = 12
    consoleBtn.Font = Enum.Font.SourceSansBold
    consoleBtn.Parent = self.titleBar
    
    consoleBtn.MouseButton1Click:Connect(function()
        self:ToggleConsole()
    end)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0.5, -12)
    closeBtn.BackgroundColor3 = Color3.new(0.9, 0.3, 0.3)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = self.titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Remove()
    end)
    
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Size = UDim2.new(1, -20, 0, 32)
    self.tabContainer.Position = UDim2.new(0, 10, 0, 36)
    self.tabContainer.BackgroundTransparency = 1
    self.tabContainer.Parent = self.window
    
    self.content = Instance.new("ScrollingFrame")
    self.content.Size = UDim2.new(1, -20, 1, -108)
    self.content.Position = UDim2.new(0, 10, 0, 76)
    self.content.BackgroundTransparency = 1
    self.content.ScrollBarThickness = 4
    self.content.ScrollBarImageColor3 = ThemeColors.Border
    self.content.ScrollBarImageTransparency = 0.5
    self.content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.content.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.content.Parent = self.window
    
    self.canvas = Instance.new("Frame")
    self.canvas.Size = UDim2.new(1, 0, 0, 0)
    self.canvas.BackgroundTransparency = 1
    self.canvas.Parent = self.content
end

function Cast:SetupConsole()
    self.console = Instance.new("Frame")
    self.console.Size = UDim2.new(0, 500, 0, 300)
    self.console.Position = UDim2.new(0.5, -250, 0.5, -150)
    self.console.BackgroundColor3 = ThemeColors.PopupBg
    self.console.BorderSizePixel = 0
    self.console.Visible = false
    self.console.ZIndex = 100
    self.console.Parent = self.ui
    
    local consoleStroke = Instance.new("UIStroke")
    consoleStroke.Color = ThemeColors.Border
    consoleStroke.Thickness = 1
    consoleStroke.Parent = self.console
    
    local consoleTitle = Instance.new("TextLabel")
    consoleTitle.Size = UDim2.new(1, 0, 0, 28)
    consoleTitle.BackgroundColor3 = ThemeColors.TitleBg
    consoleTitle.Text = "Console"
    consoleTitle.TextColor3 = ThemeColors.Text
    consoleTitle.TextSize = 14
    consoleTitle.Font = Enum.Font.SourceSansSemibold
    consoleTitle.TextXAlignment = Enum.TextXAlignment.Center
    consoleTitle.TextYAlignment = Enum.TextYAlignment.Center
    consoleTitle.Parent = self.console
    
    self.consoleOutput = Instance.new("ScrollingFrame")
    self.consoleOutput.Size = UDim2.new(1, -20, 1, -80)
    self.consoleOutput.Position = UDim2.new(0, 10, 0, 36)
    self.consoleOutput.BackgroundColor3 = ThemeColors.FrameBg
    self.consoleOutput.ScrollBarThickness = 4
    self.consoleOutput.Parent = self.console
    
    local outputStroke = Instance.new("UIStroke")
    outputStroke.Color = ThemeColors.Border
    outputStroke.Thickness = 1
    outputStroke.Parent = self.consoleOutput
    
    self.consoleInput = Instance.new("TextBox")
    self.consoleInput.Size = UDim2.new(1, -20, 0, 28)
    self.consoleInput.Position = UDim2.new(0, 10, 1, -36)
    self.consoleInput.BackgroundColor3 = ThemeColors.FrameBg
    self.consoleInput.TextColor3 = ThemeColors.Text
    self.consoleInput.PlaceholderText = "Enter command..."
    self.consoleInput.PlaceholderColor3 = ThemeColors.TextDisabled
    self.consoleInput.TextSize = 14
    self.consoleInput.Font = Enum.Font.SourceSans
    self.consoleInput.Parent = self.console
    
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = ThemeColors.Border
    inputStroke.Thickness = 1
    inputStroke.Parent = self.consoleInput
    
    local consoleClose = Instance.new("TextButton")
    consoleClose.Size = UDim2.new(0, 24, 0, 24)
    consoleClose.Position = UDim2.new(1, -32, 0, 2)
    consoleClose.BackgroundColor3 = ThemeColors.Button
    consoleClose.Text = "×"
    consoleClose.TextColor3 = ThemeColors.Text
    consoleClose.TextSize = 14
    consoleClose.Font = Enum.Font.SourceSansBold
    consoleClose.Parent = self.console
    
    consoleClose.MouseButton1Click:Connect(function()
        self:ToggleConsole()
    end)
    
    local consoleDragging = false
    local consoleStartPos, consoleStartMouse
    
    consoleTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            consoleDragging = true
            consoleStartMouse = input.Position
            consoleStartPos = self.console.Position
        end
    end)
    
    consoleTitle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            consoleDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if consoleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - consoleStartMouse
            self.console.Position = UDim2.new(consoleStartPos.X.Scale, consoleStartPos.X.Offset + delta.X, 
                                               consoleStartPos.Y.Scale, consoleStartPos.Y.Offset + delta.Y)
        end
    end)
end

function Cast:SetupInput()

    local dragging = false
    local startPos, startMouse
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startMouse = input.Position
            startPos = self.window.Position
        end
    end)
    
    self.titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMouse
            self.window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                             startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    self.keybindConnection = UserInputService.InputBegan:Connect(function(input)
        if self.recordingKeybind then
            local key = input.KeyCode.Name
            if key ~= "Unknown" then
                Configuration.Keybinds[self.recordingKeybind] = key
                self:UpdateKeybindDisplay()
                self:AddLog("Keybind set: " .. self.recordingKeybind .. " -> " .. key)
                self.recordingKeybind = nil
            end
        end
    end)
    
    self.sliderConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            for sliderId, sliderData in pairs(self.activeSliders) do
                if sliderData.dragging then
                    sliderData.dragging = false
                    sliderData.updateCallback(sliderData.currentValue)
                    
                    TweenService:Create(sliderData.button, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 12, 0, 12)
                    }):Play()
                    
                    TweenService:Create(sliderData.button, TweenInfo.new(0.1), {
                        Position = UDim2.new((sliderData.currentValue - sliderData.min) / (sliderData.max - sliderData.min), -6, 0.5, -6)
                    }):Play()
                    
                    self:AddLog(sliderData.label .. " set to: " .. sliderData.currentValue .. sliderData.unit)
                    
                    self.activeSliders[sliderId] = nil
                end
            end
        end
    end)
end

function Cast:CreateTab(name)
    local tab = {
        name = name,
        button = nil,
        container = nil
    }
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 0, 0, 28)
    button.BackgroundColor3 = ThemeColors.Tab
    button.Text = name
    button.TextColor3 = ThemeColors.TextDisabled
    button.TextSize = 13
    button.Font = Enum.Font.SourceSansSemibold
    button.Parent = self.tabContainer
    
    local textSize = TextService:GetTextSize(name, 13, Enum.Font.SourceSansSemibold, Vector2.new(1000, 100))
    button.Size = UDim2.new(0, textSize.X + 24, 0, 28)
    tab.button = button
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = self.canvas
    tab.container = container
    
    button.MouseEnter:Connect(function()
        if LayoutSystem.currentTab ~= tab then
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = ThemeColors.TabHovered
            }):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if LayoutSystem.currentTab ~= tab then
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = ThemeColors.Tab
            }):Play()
        end
    end)
    
    button.MouseButton1Click:Connect(function()
        self:ChangeTab(tab)
    end)
    
    table.insert(LayoutSystem.tabs, tab)
    
    if #LayoutSystem.tabs == 1 then
        self:ChangeTab(tab)
    end
    
    return tab
end

function Cast:ChangeTab(tab)
    if LayoutSystem.currentTab then
        LayoutSystem.currentTab.button.BackgroundColor3 = ThemeColors.Tab
        LayoutSystem.currentTab.button.TextColor3 = ThemeColors.TextDisabled
        LayoutSystem.currentTab.container.Visible = false
    end
    
    tab.button.BackgroundColor3 = ThemeColors.TabActive
    tab.button.TextColor3 = ThemeColors.Text
    tab.container.Visible = true
    LayoutSystem.currentTab = tab
    
    LayoutSystem.cursor = {x = 8, y = 8}
    LayoutSystem.indent = 0
    LayoutSystem.sameLine = false
    LayoutSystem.lastWidth = 0
    LayoutSystem.lineHeight = 0
    LayoutSystem.groupStack = {}
    
    if tab.name == "Main" then
        self:RenderMainTab()
    elseif tab.name == "Visuals" then
        self:RenderVisualsTab()
    elseif tab.name == "Keybinds" then
        self:RenderKeybindsTab()
    end
    
    self:UpdateCanvasSize()
end

function Cast:RenderMainTab()
    local container = LayoutSystem.currentTab.container
    
    for _, child in ipairs(container:GetChildren()) do
        child:Destroy()
    end
    
    LayoutSystem.cursor = {x = 8, y = 8}
    
    self:AddText("Main Settings")
    self:AddSeparator()
    self:AddSpacing()
    
    local generalGroup = self:StartGroup("General", UDim2.new(1, -16, 0, 180))
    self:AddText("General Configuration")
    self:AddSeparator()
    self:AddSpacing()
    
    local autoCheck = self:AddCheckbox("Auto-Execute Scripts", Configuration.AutoExecute)
    autoCheck.MouseButton1Click:Connect(function()
        Configuration.AutoExecute = not Configuration.AutoExecute
        autoCheck.Text = Configuration.AutoExecute and "✓" or ""
        autoCheck.BackgroundColor3 = Configuration.AutoExecute and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("Auto-execute: " .. tostring(Configuration.AutoExecute))
    end)
    
    local notifCheck = self:AddCheckbox("Show Notifications", Configuration.ShowNotifications)
    notifCheck.MouseButton1Click:Connect(function()
        Configuration.ShowNotifications = not Configuration.ShowNotifications
        notifCheck.Text = Configuration.ShowNotifications and "✓" or ""
        notifCheck.BackgroundColor3 = Configuration.ShowNotifications and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("Notifications: " .. tostring(Configuration.ShowNotifications))
    end)
    
    local rejoinCheck = self:AddCheckbox("Rejoin on Kick", Configuration.RejoinOnKick)
    rejoinCheck.MouseButton1Click:Connect(function()
        Configuration.RejoinOnKick = not Configuration.RejoinOnKick
        rejoinCheck.Text = Configuration.RejoinOnKick and "✓" or ""
        rejoinCheck.BackgroundColor3 = Configuration.RejoinOnKick and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("Auto-rejoin: " .. tostring(Configuration.RejoinOnKick))
    end)
    
    self:AddSpacing()
    
    self.delaySlider = self:AddSlider("Execution Delay", Configuration.ExecutionDelay, 0, 5, "s", function(value)
        Configuration.ExecutionDelay = value
    end)
    
    self:EndGroup()
    
    self:AddSpacing()
    
    local actionsGroup = self:StartGroup("Quick Actions", UDim2.new(1, -16, 0, 180))
    self:AddText("Quick Actions")
    self:AddSeparator()
    self:AddSpacing()
    
    local execBtn = self:AddButton("Execute All")
    execBtn.MouseButton1Click:Connect(function()
        self:AddLog("Executing all scripts...")
    end)
    
    self:AddSpacing()
    
    local clearBtn = self:AddButton("Clear Console")
    clearBtn.MouseButton1Click:Connect(function()
        self:ClearConsole()
    end)
    
    self:AddSameLine()
    
    local refreshBtn = self:AddButton("Refresh UI")
    refreshBtn.MouseButton1Click:Connect(function()
        self:ChangeTab(LayoutSystem.currentTab)
    end)
    
    self:AddSpacing()
    
    local saveBtn = self:AddButton("Save Config", UDim2.new(0.45, 0, 0, 28))
    saveBtn.MouseButton1Click:Connect(function()
        self:AddLog("Configuration saved")
    end)
    
    self:AddSameLine()
    
    local loadBtn = self:AddButton("Load Config", UDim2.new(0.45, 0, 0, 28))
    loadBtn.MouseButton1Click:Connect(function()
        self:AddLog("Configuration loaded")
    end)
    
    self:EndGroup()
end

function Cast:RenderVisualsTab()
    local container = LayoutSystem.currentTab.container
    
    for _, child in ipairs(container:GetChildren()) do
        child:Destroy()
    end
    
    LayoutSystem.cursor = {x = 8, y = 8}
    
    self:AddText("Visual Settings")
    self:AddSeparator()
    self:AddSpacing()
    
    local espGroup = self:StartGroup("ESP Settings", UDim2.new(1, -16, 0, 220))
    self:AddText("ESP Configuration")
    self:AddSeparator()
    self:AddSpacing()
    
    local espCheck = self:AddCheckbox("Enable ESP", Configuration.ESPEnabled)
    espCheck.MouseButton1Click:Connect(function()
        Configuration.ESPEnabled = not Configuration.ESPEnabled
        espCheck.Text = Configuration.ESPEnabled and "✓" or ""
        espCheck.BackgroundColor3 = Configuration.ESPEnabled and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("ESP: " .. tostring(Configuration.ESPEnabled))
    end)
    
    local boxCheck = self:AddCheckbox("Box ESP", Configuration.BoxESP)
    boxCheck.MouseButton1Click:Connect(function()
        Configuration.BoxESP = not Configuration.BoxESP
        boxCheck.Text = Configuration.BoxESP and "✓" or ""
        boxCheck.BackgroundColor3 = Configuration.BoxESP and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("Box ESP: " .. tostring(Configuration.BoxESP))
    end)
    local nameCheck = self:AddCheckbox("Name ESP", Configuration.NameESP)
    nameCheck.MouseButton1Click:Connect(function()
        Configuration.NameESP = not Configuration.NameESP
        nameCheck.Text = Configuration.NameESP and "✓" or ""
        nameCheck.BackgroundColor3 = Configuration.NameESP and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("Name ESP: " .. tostring(Configuration.NameESP))
    end)
    local healthCheck = self:AddCheckbox("Health Bar", Configuration.HealthBar)
    healthCheck.MouseButton1Click:Connect(function()
        Configuration.HealthBar = not Configuration.HealthBar
        healthCheck.Text = Configuration.HealthBar and "✓" or ""
        healthCheck.BackgroundColor3 = Configuration.HealthBar and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("Health Bar: " .. tostring(Configuration.HealthBar))
    end)
    
    self:AddSpacing()
    
    self.distanceSlider = self:AddSlider("ESP Max Distance", Configuration.ESPDistance, 100, 2000, " studs", function(value)
        Configuration.ESPDistance = value
    end)
    
    self:EndGroup()
    
    self:AddSpacing()
    
    local renderGroup = self:StartGroup("Render Settings", UDim2.new(1, -16, 0, 180))
    self:AddText("Render Configuration")
    self:AddSeparator()
    self:AddSpacing()
    
    local chamsCheck = self:AddCheckbox("Wallhack (Chams)", Configuration.Chams)
    chamsCheck.MouseButton1Click:Connect(function()
        Configuration.Chams = not Configuration.Chams
        chamsCheck.Text = Configuration.Chams and "✓" or ""
        chamsCheck.BackgroundColor3 = Configuration.Chams and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("Chams: " .. tostring(Configuration.Chams))
    end)
  
    local brightCheck = self:AddCheckbox("Full Bright", Configuration.FullBright)
    brightCheck.MouseButton1Click:Connect(function()
        Configuration.FullBright = not Configuration.FullBright
        brightCheck.Text = Configuration.FullBright and "✓" or ""
        brightCheck.BackgroundColor3 = Configuration.FullBright and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("Full Bright: " .. tostring(Configuration.FullBright))
    end)
    
    local fpsCheck = self:AddCheckbox("Show FPS", Configuration.ShowFPS)
    fpsCheck.MouseButton1Click:Connect(function()
        Configuration.ShowFPS = not Configuration.ShowFPS
        fpsCheck.Text = Configuration.ShowFPS and "✓" or ""
        fpsCheck.BackgroundColor3 = Configuration.ShowFPS and ThemeColors.SliderGrab or ThemeColors.FrameBg
        self:AddLog("FPS Display: " .. tostring(Configuration.ShowFPS))
    end)
    
    self:AddSpacing()
    
    self.fovSlider = self:AddSlider("Field of View", Configuration.FOV, 30, 120, "°", function(value)
        Configuration.FOV = value
    end)
    
    self:EndGroup()
end

function Cast:RenderKeybindsTab()
    local container = LayoutSystem.currentTab.container
    
    for _, child in ipairs(container:GetChildren()) do
        child:Destroy()
    end
    
    LayoutSystem.cursor = {x = 8, y = 8}
    
    self:AddText("Keybind Settings")
    self:AddSeparator()
    self:AddSpacing()
    
    local keybindGroup = self:StartGroup("Keybind Configuration", UDim2.new(1, -16, 0, 300))
    self:AddText("Configure Keybinds")
    self:AddSeparator()
    self:AddSpacing()
    
    for name, key in pairs(Configuration.Keybinds) do
        self:AddText(name)
        self:AddSameLine(100)
        
        local keyBtn = self:AddButton(key, UDim2.new(0, 80, 0, 24))
        
        keyBtn.MouseButton1Click:Connect(function()
            if self.recordingKeybind == name then
                self.recordingKeybind = nil
                keyBtn.Text = key
                keyBtn.BackgroundColor3 = ThemeColors.Button
            else
                self.recordingKeybind = name
                keyBtn.Text = "[Press Key]"
                keyBtn.BackgroundColor3 = ThemeColors.SliderGrab
                self:AddLog("Recording keybind for: " .. name)
            end
        end)
        
        self:AddSpacing()
    end
    
    self:EndGroup()
    
    self:AddSpacing()
    
    local actionGroup = self:StartGroup("Keybind Actions", UDim2.new(1, -16, 0, 120))
    self:AddText("Keybind Management")
    self:AddSeparator()
    self:AddSpacing()
    
    local resetBtn = self:AddButton("Reset All Keybinds")
    resetBtn.MouseButton1Click:Connect(function()
        for k, _ in pairs(Configuration.Keybinds) do
            Configuration.Keybinds[k] = "None"
        end
        self:AddLog("All keybinds reset")
        self:ChangeTab(LayoutSystem.currentTab)
    end)
    
    self:AddSameLine()
    
    local exportBtn = self:AddButton("Export Keybinds")
    exportBtn.MouseButton1Click:Connect(function()
        self:AddLog("Keybinds copied to clipboard")
    end)
    
    self:AddSpacing()
    
    local importBtn = self:AddButton("Import Keybinds", UDim2.new(1, 0, 0, 28))
    importBtn.MouseButton1Click:Connect(function()
        self:AddLog("Keybinds imported")
    end)
    
    self:EndGroup()
end

function Cast:UpdateKeybindDisplay()
    if LayoutSystem.currentTab and LayoutSystem.currentTab.name == "Keybinds" then
        self:ChangeTab(LayoutSystem.currentTab)
    end
end

function Cast:UpdateCanvasSize()
    if LayoutSystem.currentTab and LayoutSystem.currentTab.container then
        local container = LayoutSystem.currentTab.container
        local maxY = 0
        
        for _, child in ipairs(container:GetChildren()) do
            local yPos = child.Position.Y.Offset + child.Size.Y.Offset
            if yPos > maxY then
                maxY = yPos
            end
        end
        
        container.Size = UDim2.new(1, 0, 0, maxY + 20)
        self.content.CanvasSize = UDim2.new(0, 0, 0, maxY + 40)
    end
end

function Cast:ToggleConsole()
    self.consoleOpen = not self.consoleOpen
    self.console.Visible = self.consoleOpen
end

function Cast:AddLog(message)
    if not self.consoleOutput then return end
    
    local timestamp = os.date("%H:%M:%S")
    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, -10, 0, 20)
    logLabel.Position = UDim2.new(0, 5, 0, #self.consoleOutput:GetChildren() * 22)
    logLabel.BackgroundTransparency = 1
    logLabel.Text = "[" .. timestamp .. "] " .. message
    logLabel.TextColor3 = ThemeColors.Text
    logLabel.TextSize = 13
    logLabel.Font = Enum.Font.SourceSans
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.Parent = self.consoleOutput
    
    self.consoleOutput.CanvasSize = UDim2.new(0, 0, 0, #self.consoleOutput:GetChildren() * 22)
    self.consoleOutput.CanvasPosition = Vector2.new(0, self.consoleOutput.CanvasSize.Y.Offset)
end

function Cast:ClearConsole()
    if self.consoleOutput then
        for _, child in ipairs(self.consoleOutput:GetChildren()) do
            child:Destroy()
        end
        self.consoleOutput.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
end

function Cast:StartGroup(name, size)
    local groupId = LayoutSystem:BeginGroup(4)
    local pos = LayoutSystem:GetCursorPos()
    
    local group = Instance.new("Frame")
    group.Size = size
    group.Position = pos
    group.BackgroundColor3 = ThemeColors.ChildBg
    group.Parent = LayoutSystem.currentTab.container
    
    if name then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = ThemeColors.Text
        label.TextSize = 13
        label.Font = Enum.Font.SourceSansSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = group
        
        LayoutSystem.cursor.y = LayoutSystem.cursor.y + 24
    end
    
    LayoutSystem:AdvanceCursor(group.AbsoluteSize.X, group.AbsoluteSize.Y)
    
    return group
end

function Cast:EndGroup()
    LayoutSystem:EndGroup()
end

function Cast:AddSeparator()
    local pos = LayoutSystem:GetCursorPos()
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -16, 0, 1)
    line.Position = pos
    line.BackgroundColor3 = ThemeColors.Separator
    line.BorderSizePixel = 0
    line.Parent = LayoutSystem.currentTab.container
    
    LayoutSystem:AdvanceCursor(line.AbsoluteSize.X, 2)
end

function Cast:AddSpacing()
    local pos = LayoutSystem:GetCursorPos()
    
    local space = Instance.new("Frame")
    space.Size = UDim2.new(1, 0, 0, 8)
    space.Position = pos
    space.BackgroundTransparency = 1
    space.Parent = LayoutSystem.currentTab.container
    
    LayoutSystem:AdvanceCursor(space.AbsoluteSize.X, 8)
end

function Cast:AddText(text)
    local pos = LayoutSystem:GetCursorPos()
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 20)
    label.Position = pos
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = ThemeColors.Text
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = LayoutSystem.currentTab.container
    
    LayoutSystem:AdvanceCursor(label.AbsoluteSize.X, 20)
    
    return label
end

function Cast:AddButton(label, size)
    local pos = LayoutSystem:GetCursorPos()
    
    local button = Instance.new("TextButton")
    button.Size = size or UDim2.new(0, 0, 0, 28)
    button.Position = pos
    button.BackgroundColor3 = ThemeColors.Button
    button.Text = label
    button.TextColor3 = ThemeColors.Text
    button.TextSize = 13
    button.Font = Enum.Font.SourceSansSemibold
    button.AutoButtonColor = false
    button.Parent = LayoutSystem.currentTab.container
    
    if not size then
        local textSize = TextService:GetTextSize(label, 13, Enum.Font.SourceSansSemibold, Vector2.new(1000, 100))
        button.Size = UDim2.new(0, textSize.X + 20, 0, 28)
    end
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = ThemeColors.ButtonHovered
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = ThemeColors.Button
        }):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.08), {
            BackgroundColor3 = ThemeColors.ButtonActive
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = ThemeColors.ButtonHovered
        }):Play()
    end)
    
    LayoutSystem:AdvanceCursor(button.AbsoluteSize.X, button.AbsoluteSize.Y)
    
    return button
end

function Cast:AddCheckbox(label, checked)
    local pos = LayoutSystem:GetCursorPos()
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 22)
    container.Position = pos
    container.BackgroundTransparency = 1
    container.Parent = LayoutSystem.currentTab.container
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 18, 0, 18)
    checkbox.Position = UDim2.new(0, 0, 0.5, -9)
    checkbox.BackgroundColor3 = checked and ThemeColors.SliderGrab or ThemeColors.FrameBg
    checkbox.Text = checked and "✓" or ""
    checkbox.TextColor3 = ThemeColors.CheckMark
    checkbox.TextSize = 14
    checkbox.Font = Enum.Font.SourceSansBold
    checkbox.AutoButtonColor = false
    checkbox.Parent = container
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -26, 1, 0)
    textLabel.Position = UDim2.new(0, 26, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = ThemeColors.Text
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = container
    
    checkbox.MouseEnter:Connect(function()
        TweenService:Create(checkbox, TweenInfo.new(0.15), {
            BackgroundColor3 = checked and ThemeColors.SliderGrabActive or ThemeColors.FrameBgHovered
        }):Play()
    end)
    
    checkbox.MouseLeave:Connect(function()
        TweenService:Create(checkbox, TweenInfo.new(0.15), {
            BackgroundColor3 = checked and ThemeColors.SliderGrab or ThemeColors.FrameBg
        }):Play()
    end)
    
    LayoutSystem:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
    
    return checkbox
end

function Cast:AddSlider(label, value, min, max, unit, updateCallback)
    local pos = LayoutSystem:GetCursorPos()
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 36)
    container.Position = pos
    container.BackgroundTransparency = 1
    container.Parent = LayoutSystem.currentTab.container
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 18)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = ThemeColors.Text
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 18)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.0f%s", value, unit)
    valueLabel.TextColor3 = ThemeColors.Text
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    k
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 24)
    track.BackgroundColor3 = ThemeColors.FrameBg
    track.BorderSizePixel = 0
    track.Parent = container
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = ThemeColors.SliderGrab
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local handle = Instance.new("TextButton")
    handle.Size = UDim2.new(0, 12, 0, 12)
    handle.Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6)
    handle.BackgroundColor3 = Color3.new(1, 1, 1)
    handle.Text = ""
    handle.Parent = track
    
    local sliderId = tostring(container)
    local sliderData = {
        dragging = false,
        currentValue = value,
        min = min,
        max = max,
        label = label,
        unit = unit,
        button = handle,
        updateCallback = updateCallback,
        track = track,
        fill = fill,
        valueLabel = valueLabel
    }
    
    local function updateSlider(mouseX)
        local relativeX = (mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        
        sliderData.currentValue = min + (max - min) * relativeX
        sliderData.currentValue = math.floor(sliderData.currentValue)
        
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        handle.Position = UDim2.new(relativeX, -6, 0.5, -6)
        valueLabel.Text = string.format("%.0f%s", sliderData.currentValue, unit)
    end
    
    handle.MouseButton1Down:Connect(function()
        sliderData.dragging = true
        self.activeSliders[sliderId] = sliderData
        
        TweenService:Create(handle, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 16, 0, 16)
        }):Play()
        
        TweenService:Create(handle, TweenInfo.new(0.1), {
            Position = UDim2.new((sliderData.currentValue - min) / (max - min), -8, 0.5, -8)
        }):Play()
    end)
    
    track.MouseButton1Down:Connect(function(x, y)
        sliderData.dragging = true
        self.activeSliders[sliderId] = sliderData
        
        updateSlider(x)
        
        TweenService:Create(handle, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 16, 0, 16)
        }):Play()
        
        TweenService:Create(handle, TweenInfo.new(0.1), {
            Position = UDim2.new((sliderData.currentValue - min) / (max - min), -8, 0.5, -8)
        }):Play()
    end)
    
    local mouseMoveConnection = UserInputService.InputChanged:Connect(function(input)
        if sliderData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    
    container.Destroying:Connect(function()
        mouseMoveConnection:Disconnect()
    end)
    
    LayoutSystem:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
    
    return sliderData.currentValue
end

function Cast:AddSameLine(spacing)
    LayoutSystem:SameLine(spacing)
end


function Cast:Remove()
    if self.ui then
        self.ui:Destroy()
    end
    
    if self.keybindConnection then
        self.keybindConnection:Disconnect()
    end
    
    if self.sliderConnection then
        self.sliderConnection:Disconnect()
    end
end


function LayoutSystem:BeginGroup(padding)
    table.insert(self.groupStack, {
        x = self.cursor.x,
        y = self.cursor.y,
        indent = self.indent
    })
    
    self.cursor.x = self.cursor.x + (padding or 8)
    self.cursor.y = self.cursor.y + (padding or 4)
    self.indent = self.indent + 8
    
    return #self.groupStack
end

function LayoutSystem:EndGroup()
    if #self.groupStack > 0 then
        local last = table.remove(self.groupStack)
        self.cursor.x = last.x
        self.cursor.y = last.y + self.lineHeight + 8
        self.indent = last.indent
        self.lineHeight = 0
    end
end

function LayoutSystem:SameLine(spacing)
    if spacing then
        self.cursor.x = self.cursor.x + spacing
    end
    self.sameLine = true
end

function LayoutSystem:GetCursorPos()
    if self.sameLine then
        self.sameLine = false
        return UDim2.new(0, self.cursor.x + self.lastWidth + 4, 0, self.cursor.y)
    end
    return UDim2.new(0, self.cursor.x, 0, self.cursor.y)
end

function LayoutSystem:AdvanceCursor(width, height)
    if not self.sameLine then
        self.lastWidth = width
        if height > self.lineHeight then
            self.lineHeight = height
        end
        self.cursor.y = self.cursor.y + height + 4
    else
        self.cursor.x = self.cursor.x + width + 4
        if height > self.lineHeight then
            self.lineHeight = height
        end
    end
end

local function Create(title)
    return Cast:Initialize(title or "Cast UI v1.3")
end

return {
    Create = Create,
    Module = Cast
}
