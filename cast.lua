local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Cast = {}
Cast.__index = Cast
local Config = {
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
local Theme = {
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
local Layout = {
cursor = {x = 8, y = 8},
indent = 0,
sameLine = false,
lastWidth = 0,
lineHeight = 0,
groupStack = {},
currentTab = nil,
tabs = {}
}
function Layout:BeginGroup(padding)
table.insert(self.groupStack, {x = self.cursor.x, y = self.cursor.y, indent = self.indent})
self.cursor.x = self.cursor.x + (padding or 8)
self.cursor.y = self.cursor.y + (padding or 4)
self.indent = self.indent + 8
return #self.groupStack
end
function Layout:EndGroup()
if #self.groupStack > 0 then
local last = table.remove(self.groupStack)
self.cursor.x = last.x
self.cursor.y = last.y + self.lineHeight + 8
self.indent = last.indent
self.lineHeight = 0
end
end
function Layout:SameLine(spacing)
if spacing then
self.cursor.x = self.cursor.x + spacing
end
self.sameLine = true
end
function Layout:GetCursorPos()
if self.sameLine then
self.sameLine = false
return UDim2.new(0, self.cursor.x + self.lastWidth + 4, 0, self.cursor.y)
end
return UDim2.new(0, self.cursor.x, 0, self.cursor.y)
end
function Layout:AdvanceCursor(width, height)
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
function Cast.Create(title)
local self = setmetatable({}, Cast)
self.title = title or "Cast UI"
self.open = true
self.consoleOpen = false
self.keybindRecording = nil
self.gui = Instance.new("ScreenGui")
self.gui.Name = "CastUI"
self.gui.ResetOnSpawn = false
self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
self.gui.Parent = PlayerGui
self.window = Instance.new("Frame")
self.window.Size = UDim2.new(0, 520, 0, 550)
self.window.Position = UDim2.new(0.5, -260, 0.5, -275)
self.window.BackgroundColor3 = Theme.WindowBg
self.window.BorderSizePixel = 0
self.window.ClipsDescendants = true
self.window.Parent = self.gui
local frame = Instance.new("UIStroke")
frame.Color = Theme.Border
frame.Thickness = 1
frame.Parent = self.window
self.titleBar = Instance.new("Frame")
self.titleBar.Size = UDim2.new(1, 0, 0, 28)
self.titleBar.BackgroundColor3 = Theme.TitleBg
self.titleBar.BorderSizePixel = 0
self.titleBar.Parent = self.window
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = self.title
titleLabel.TextColor3 = Theme.Text
titleLabel.TextSize = 15
titleLabel.Font = Enum.Font.SourceSansSemibold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.Parent = self.titleBar
local consoleBtn = Instance.new("TextButton")
consoleBtn.Size = UDim2.new(0, 24, 0, 24)
consoleBtn.Position = UDim2.new(1, -56, 0.5, -12)
consoleBtn.BackgroundColor3 = Theme.Button
consoleBtn.Text = ">_"
consoleBtn.TextColor3 = Theme.Text
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
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = self.titleBar
closeBtn.MouseButton1Click:Connect(function()
self:Destroy()
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
self.content.ScrollBarImageColor3 = Theme.Border
self.content.ScrollBarImageTransparency = 0.5
self.content.AutomaticCanvasSize = Enum.AutomaticSize.Y
self.content.CanvasSize = UDim2.new(0, 0, 0, 0)
self.content.Parent = self.window
self.canvas = Instance.new("Frame")
self.canvas.Size = UDim2.new(1, 0, 0, 0)
self.canvas.BackgroundTransparency = 1
self.canvas.Parent = self.content
self.console = Instance.new("Frame")
self.console.Size = UDim2.new(0, 500, 0, 300)
self.console.Position = UDim2.new(0.5, -250, 0.5, -150)
self.console.BackgroundColor3 = Theme.PopupBg
self.console.BorderSizePixel = 0
self.console.Visible = false
self.console.ZIndex = 100
self.console.Parent = self.gui
local consoleFrame = Instance.new("UIStroke")
consoleFrame.Color = Theme.Border
consoleFrame.Thickness = 1
consoleFrame.Parent = self.console
local consoleTitle = Instance.new("TextLabel")
consoleTitle.Size = UDim2.new(1, 0, 0, 28)
consoleTitle.BackgroundColor3 = Theme.TitleBg
consoleTitle.Text = "Console"
consoleTitle.TextColor3 = Theme.Text
consoleTitle.TextSize = 14
consoleTitle.Font = Enum.Font.SourceSansSemibold
consoleTitle.TextXAlignment = Enum.TextXAlignment.Center
consoleTitle.TextYAlignment = Enum.TextYAlignment.Center
consoleTitle.Parent = self.console
self.consoleOutput = Instance.new("ScrollingFrame")
self.consoleOutput.Size = UDim2.new(1, -20, 1, -80)
self.consoleOutput.Position = UDim2.new(0, 10, 0, 36)
self.consoleOutput.BackgroundColor3 = Theme.FrameBg
self.consoleOutput.ScrollBarThickness = 4
self.consoleOutput.Parent = self.console
local consoleStroke = Instance.new("UIStroke")
consoleStroke.Color = Theme.Border
consoleStroke.Thickness = 1
consoleStroke.Parent = self.consoleOutput
self.consoleInput = Instance.new("TextBox")
self.consoleInput.Size = UDim2.new(1, -20, 0, 28)
self.consoleInput.Position = UDim2.new(0, 10, 1, -36)
self.consoleInput.BackgroundColor3 = Theme.FrameBg
self.consoleInput.TextColor3 = Theme.Text
self.consoleInput.PlaceholderText = "Enter command..."
self.consoleInput.PlaceholderColor3 = Theme.TextDisabled
self.consoleInput.TextSize = 14
self.consoleInput.Font = Enum.Font.SourceSans
self.consoleInput.Parent = self.console
local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Theme.Border
inputStroke.Thickness = 1
inputStroke.Parent = self.consoleInput
local consoleClose = Instance.new("TextButton")
consoleClose.Size = UDim2.new(0, 24, 0, 24)
consoleClose.Position = UDim2.new(1, -32, 0, 2)
consoleClose.BackgroundColor3 = Theme.Button
consoleClose.Text = "×"
consoleClose.TextColor3 = Theme.Text
consoleClose.TextSize = 14
consoleClose.Font = Enum.Font.SourceSansBold
consoleClose.Parent = self.console
consoleClose.MouseButton1Click:Connect(function()
self:ToggleConsole()
end)
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
self.window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
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
self.console.Position = UDim2.new(consoleStartPos.X.Scale, consoleStartPos.X.Offset + delta.X, consoleStartPos.Y.Scale, consoleStartPos.Y.Offset + delta.Y)
end
end)
self:AddTab("Main")
self:AddTab("Visuals")
self:AddTab("Keybinds")
self:Log("Cast UI initialized")
return self
end
function Cast:AddTab(name)
local tab = {
name = name,
button = nil,
container = nil,
content = {}
}
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 0, 0, 28)
button.BackgroundColor3 = Theme.Tab
button.Text = name
button.TextColor3 = Theme.TextDisabled
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
if Layout.currentTab ~= tab then
TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.TabHovered}):Play()
end
end)
button.MouseLeave:Connect(function()
if Layout.currentTab ~= tab then
TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Tab}):Play()
end
end)
button.MouseButton1Click:Connect(function()
self:SwitchTab(tab)
end)
table.insert(Layout.tabs, tab)
if #Layout.tabs == 1 then
self:SwitchTab(tab)
end
return tab
end
function Cast:SwitchTab(tab)
if Layout.currentTab then
Layout.currentTab.button.BackgroundColor3 = Theme.Tab
Layout.currentTab.button.TextColor3 = Theme.TextDisabled
Layout.currentTab.container.Visible = false
end
tab.button.BackgroundColor3 = Theme.TabActive
tab.button.TextColor3 = Theme.Text
tab.container.Visible = true
Layout.currentTab = tab
Layout.cursor = {x = 8, y = 8}
Layout.indent = 0
Layout.sameLine = false
Layout.lastWidth = 0
Layout.lineHeight = 0
Layout.groupStack = {}
if tab.name == "Main" then
self:DrawMainTab()
elseif tab.name == "Visuals" then
self:DrawVisualsTab()
elseif tab.name == "Keybinds" then
self:DrawKeybindsTab()
end
self:UpdateCanvas()
end
function Cast:DrawMainTab()
local container = Layout.currentTab.container
for _, child in ipairs(container:GetChildren()) do
child:Destroy()
end
Layout.cursor = {x = 8, y = 8}
self:Text("Main Settings")
self:Separator()
self:Spacing()
local group = self:StartChild("General", UDim2.new(1, -16, 0, 180))
self:Text("General Configuration")
self:Separator()
self:Spacing()
local check1 = self:Checkbox("Auto-Execute Scripts", Config.AutoExecute)
check1.MouseButton1Click:Connect(function()
Config.AutoExecute = not Config.AutoExecute
check1.Text = Config.AutoExecute and "✓" or ""
check1.BackgroundColor3 = Config.AutoExecute and Theme.SliderGrab or Theme.FrameBg
self:Log("Auto-execute: " .. tostring(Config.AutoExecute))
end)
local check2 = self:Checkbox("Show Notifications", Config.ShowNotifications)
check2.MouseButton1Click:Connect(function()
Config.ShowNotifications = not Config.ShowNotifications
check2.Text = Config.ShowNotifications and "✓" or ""
check2.BackgroundColor3 = Config.ShowNotifications and Theme.SliderGrab or Theme.FrameBg
self:Log("Notifications: " .. tostring(Config.ShowNotifications))
end)
local check3 = self:Checkbox("Rejoin on Kick", Config.RejoinOnKick)
check3.MouseButton1Click:Connect(function()
Config.RejoinOnKick = not Config.RejoinOnKick
check3.Text = Config.RejoinOnKick and "✓" or ""
check3.BackgroundColor3 = Config.RejoinOnKick and Theme.SliderGrab or Theme.FrameBg
self:Log("Auto-rejoin: " .. tostring(Config.RejoinOnKick))
end)
self:Spacing()
self.sliderDelay = self:Slider("Execution Delay", Config.ExecutionDelay, 0, 5, "%.1fs")
self:EndChild()
self:Spacing()
local group2 = self:StartChild("Quick Actions", UDim2.new(1, -16, 0, 180))
self:Text("Quick Actions")
self:Separator()
self:Spacing()
local execBtn = self:Button("Execute All")
execBtn.MouseButton1Click:Connect(function()
self:Log("Executing all scripts...")
end)
self:Spacing()
local clearBtn = self:Button("Clear Console")
clearBtn.MouseButton1Click:Connect(function()
self:ClearConsole()
end)
self:SameLine()
local refreshBtn = self:Button("Refresh UI")
refreshBtn.MouseButton1Click:Connect(function()
self:SwitchTab(Layout.currentTab)
end)
self:Spacing()
local saveBtn = self:Button("Save Config", UDim2.new(0.45, 0, 0, 28))
saveBtn.MouseButton1Click:Connect(function()
self:Log("Configuration saved")
end)
self:SameLine()
local loadBtn = self:Button("Load Config", UDim2.new(0.45, 0, 0, 28))
loadBtn.MouseButton1Click:Connect(function()
self:Log("Configuration loaded")
end)
self:EndChild()
end
function Cast:DrawVisualsTab()
local container = Layout.currentTab.container
for _, child in ipairs(container:GetChildren()) do
child:Destroy()
end
Layout.cursor = {x = 8, y = 8}
self:Text("Visual Settings")
self:Separator()
self:Spacing()
local espGroup = self:StartChild("ESP Settings", UDim2.new(1, -16, 0, 220))
self:Text("ESP Configuration")
self:Separator()
self:Spacing()
local espCheck = self:Checkbox("Enable ESP", Config.ESPEnabled)
espCheck.MouseButton1Click:Connect(function()
Config.ESPEnabled = not Config.ESPEnabled
espCheck.Text = Config.ESPEnabled and "✓" or ""
espCheck.BackgroundColor3 = Config.ESPEnabled and Theme.SliderGrab or Theme.FrameBg
self:Log("ESP: " .. tostring(Config.ESPEnabled))
end)
local boxCheck = self:Checkbox("Box ESP", Config.BoxESP)
boxCheck.MouseButton1Click:Connect(function()
Config.BoxESP = not Config.BoxESP
boxCheck.Text = Config.BoxESP and "✓" or ""
boxCheck.BackgroundColor3 = Config.BoxESP and Theme.SliderGrab or Theme.FrameBg
self:Log("Box ESP: " .. tostring(Config.BoxESP))
end)
local nameCheck = self:Checkbox("Name ESP", Config.NameESP)
nameCheck.MouseButton1Click:Connect(function()
Config.NameESP = not Config.NameESP
nameCheck.Text = Config.NameESP and "✓" or ""
nameCheck.BackgroundColor3 = Config.NameESP and Theme.SliderGrab or Theme.FrameBg
self:Log("Name ESP: " .. tostring(Config.NameESP))
end)
local healthCheck = self:Checkbox("Health Bar", Config.HealthBar)
healthCheck.MouseButton1Click:Connect(function()
Config.HealthBar = not Config.HealthBar
healthCheck.Text = Config.HealthBar and "✓" or ""
healthCheck.BackgroundColor3 = Config.HealthBar and Theme.SliderGrab or Theme.FrameBg
self:Log("Health Bar: " .. tostring(Config.HealthBar))
end)
self:Spacing()
self.sliderDistance = self:Slider("ESP Max Distance", Config.ESPDistance, 100, 2000, "%.0f studs")
self:EndChild()
self:Spacing()
local renderGroup = self:StartChild("Render Settings", UDim2.new(1, -16, 0, 180))
self:Text("Render Configuration")
self:Separator()
self:Spacing()
local chamsCheck = self:Checkbox("Wallhack (Chams)", Config.Chams)
chamsCheck.MouseButton1Click:Connect(function()
Config.Chams = not Config.Chams
chamsCheck.Text = Config.Chams and "✓" or ""
chamsCheck.BackgroundColor3 = Config.Chams and Theme.SliderGrab or Theme.FrameBg
self:Log("Chams: " .. tostring(Config.Chams))
end)
local brightCheck = self:Checkbox("Full Bright", Config.FullBright)
brightCheck.MouseButton1Click:Connect(function()
Config.FullBright = not Config.FullBright
brightCheck.Text = Config.FullBright and "✓" or ""
brightCheck.BackgroundColor3 = Config.FullBright and Theme.SliderGrab or Theme.FrameBg
self:Log("Full Bright: " .. tostring(Config.FullBright))
end)
local fpsCheck = self:Checkbox("Show FPS", Config.ShowFPS)
fpsCheck.MouseButton1Click:Connect(function()
Config.ShowFPS = not Config.ShowFPS
fpsCheck.Text = Config.ShowFPS and "✓" or ""
fpsCheck.BackgroundColor3 = Config.ShowFPS and Theme.SliderGrab or Theme.FrameBg
self:Log("FPS Display: " .. tostring(Config.ShowFPS))
end)
self:Spacing()
self.sliderFOV = self:Slider("Field of View", Config.FOV, 30, 120, "%.0f°")
self:EndChild()
end
function Cast:DrawKeybindsTab()
local container = Layout.currentTab.container
for _, child in ipairs(container:GetChildren()) do
child:Destroy()
end
Layout.cursor = {x = 8, y = 8}
self:Text("Keybind Settings")
self:Separator()
self:Spacing()
local keybindGroup = self:StartChild("Keybind Configuration", UDim2.new(1, -16, 0, 300))
self:Text("Configure Keybinds")
self:Separator()
self:Spacing()
for name, key in pairs(Config.Keybinds) do
self:Text(name)
self:SameLine(100)
local keyBtn = self:Button(key, UDim2.new(0, 80, 0, 24))
keyBtn.MouseButton1Click:Connect(function()
if self.keybindRecording == name then
self.keybindRecording = nil
keyBtn.Text = key
keyBtn.BackgroundColor3 = Theme.Button
else
self.keybindRecording = name
keyBtn.Text = "[Press Key]"
keyBtn.BackgroundColor3 = Theme.SliderGrab
self:Log("Recording keybind for: " .. name)
end
end)
self:Spacing()
end
self:EndChild()
self:Spacing()
local actionGroup = self:StartChild("Keybind Actions", UDim2.new(1, -16, 0, 120))
self:Text("Keybind Management")
self:Separator()
self:Spacing()
local resetBtn = self:Button("Reset All Keybinds")
resetBtn.MouseButton1Click:Connect(function()
for k, v in pairs(Config.Keybinds) do
Config.Keybinds[k] = "None"
end
self:Log("All keybinds reset")
self:SwitchTab(Layout.currentTab)
end)
self:SameLine()
local exportBtn = self:Button("Export Keybinds")
exportBtn.MouseButton1Click:Connect(function()
self:Log("Keybinds copied to clipboard")
end)
self:Spacing()
local importBtn = self:Button("Import Keybinds", UDim2.new(1, 0, 0, 28))
importBtn.MouseButton1Click:Connect(function()
self:Log("Keybinds imported")
end)
self:EndChild()
local keyConnection = UserInputService.InputBegan:Connect(function(input)
if self.keybindRecording then
local key = input.KeyCode.Name
if key ~= "Unknown" then
Config.Keybinds[self.keybindRecording] = key
local container = Layout.currentTab.container
for _, child in ipairs(container:GetChildren()) do
if child:IsA("TextButton") and child.Text == "[Press Key]" then
child.Text = key
child.BackgroundColor3 = Theme.Button
break
end
end
self:Log("Keybind set: " .. self.keybindRecording .. " -> " .. key)
self.keybindRecording = nil
end
end
end)
end
function Cast:UpdateCanvas()
if Layout.currentTab and Layout.currentTab.container then
local container = Layout.currentTab.container
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
function Cast:Log(message)
if not self.consoleOutput then return end
local timestamp = os.date("%H:%M:%S")
local logLabel = Instance.new("TextLabel")
logLabel.Size = UDim2.new(1, -10, 0, 20)
logLabel.Position = UDim2.new(0, 5, 0, #self.consoleOutput:GetChildren() * 22)
logLabel.BackgroundTransparency = 1
logLabel.Text = "[" .. timestamp .. "] " .. message
logLabel.TextColor3 = Theme.Text
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
function Cast:StartChild(name, size)
local groupId = Layout:BeginGroup(4)
local pos = Layout:GetCursorPos()
local child = Instance.new("Frame")
child.Size = size
child.Position = pos
child.BackgroundColor3 = Theme.ChildBg
child.Parent = Layout.currentTab.container
if name then
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -10, 0, 20)
label.Position = UDim2.new(0, 5, 0, 2)
label.BackgroundTransparency = 1
label.Text = name
label.TextColor3 = Theme.Text
label.TextSize = 13
label.Font = Enum.Font.SourceSansSemibold
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = child
Layout.cursor.y = Layout.cursor.y + 24
end
Layout:AdvanceCursor(child.AbsoluteSize.X, child.AbsoluteSize.Y)
return child
end
function Cast:EndChild()
Layout:EndGroup()
end
function Cast:Separator()
local pos = Layout:GetCursorPos()
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -16, 0, 1)
line.Position = pos
line.BackgroundColor3 = Theme.Separator
line.BorderSizePixel = 0
line.Parent = Layout.currentTab.container
Layout:AdvanceCursor(line.AbsoluteSize.X, 2)
end
function Cast:Spacing()
local pos = Layout:GetCursorPos()
local space = Instance.new("Frame")
space.Size = UDim2.new(1, 0, 0, 8)
space.Position = pos
space.BackgroundTransparency = 1
space.Parent = Layout.currentTab.container
Layout:AdvanceCursor(space.AbsoluteSize.X, 8)
end
function Cast:Text(text)
local pos = Layout:GetCursorPos()
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -16, 0, 20)
label.Position = pos
label.BackgroundTransparency = 1
label.Text = text
label.TextColor3 = Theme.Text
label.TextSize = 14
label.Font = Enum.Font.SourceSans
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Center
label.Parent = Layout.currentTab.container
Layout:AdvanceCursor(label.AbsoluteSize.X, 20)
return label
end
function Cast:Button(label, size)
local pos = Layout:GetCursorPos()
local btn = Instance.new("TextButton")
btn.Size = size or UDim2.new(0, 0, 0, 28)
btn.Position = pos
btn.BackgroundColor3 = Theme.Button
btn.Text = label
btn.TextColor3 = Theme.Text
btn.TextSize = 13
btn.Font = Enum.Font.SourceSansSemibold
btn.AutoButtonColor = false
btn.Parent = Layout.currentTab.container
if not size then
local textSize = TextService:GetTextSize(label, 13, Enum.Font.SourceSansSemibold, Vector2.new(1000, 100))
btn.Size = UDim2.new(0, textSize.X + 20, 0, 28)
end
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ButtonHovered}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Button}):Play()
end)
btn.MouseButton1Down:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundColor3 = Theme.ButtonActive}):Play()
end)
btn.MouseButton1Up:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ButtonHovered}):Play()
end)
Layout:AdvanceCursor(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)
return btn
end
function Cast:Checkbox(label, checked)
local pos = Layout:GetCursorPos()
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, -16, 0, 22)
frame.Position = pos
frame.BackgroundTransparency = 1
frame.Parent = Layout.currentTab.container
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 18, 0, 18)
btn.Position = UDim2.new(0, 0, 0.5, -9)
btn.BackgroundColor3 = checked and Theme.SliderGrab or Theme.FrameBg
btn.Text = checked and "✓" or ""
btn.TextColor3 = Theme.CheckMark
btn.TextSize = 14
btn.Font = Enum.Font.SourceSansBold
btn.AutoButtonColor = false
btn.Parent = frame
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -26, 1, 0)
textLabel.Position = UDim2.new(0, 26, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = label
textLabel.TextColor3 = Theme.Text
textLabel.TextSize = 13
textLabel.Font = Enum.Font.SourceSans
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Center
textLabel.Parent = frame
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.15), {
BackgroundColor3 = checked and Theme.SliderGrabActive or Theme.FrameBgHovered
}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.15), {
BackgroundColor3 = checked and Theme.SliderGrab or Theme.FrameBg
}):Play()
end)
Layout:AdvanceCursor(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
return btn
end
function Cast:Slider(label, value, min, max, format)
local pos = Layout:GetCursorPos()
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 0, 36)
container.Position = pos
container.BackgroundTransparency = 1
container.Parent = Layout.currentTab.container
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 0, 18)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = label
textLabel.TextColor3 = Theme.Text
textLabel.TextSize = 13
textLabel.Font = Enum.Font.SourceSans
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Parent = container
local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(0, 60, 0, 18)
valueLabel.Position = UDim2.new(1, -60, 0, 0)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = string.format(format or "%.2f", value)
valueLabel.TextColor3 = Theme.Text
valueLabel.TextSize = 13
valueLabel.Font = Enum.Font.SourceSans
valueLabel.TextXAlignment = Enum.TextXAlignment.Right
valueLabel.Parent = container
local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1, 0, 0, 4)
sliderTrack.Position = UDim2.new(0, 0, 0, 24)
sliderTrack.BackgroundColor3 = Theme.FrameBg
sliderTrack.BorderSizePixel = 0
sliderTrack.Parent = container
local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
sliderFill.BackgroundColor3 = Theme.SliderGrab
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderTrack
local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 12, 0, 12)
sliderBtn.Position = UDim2.new((value - min) / (max - min), -6, 0.5, -6)
sliderBtn.BackgroundColor3 = Color3.new(1,1,1)
sliderBtn.Text = ""
sliderBtn.Parent = sliderTrack
local dragging = false
local currentValue = value
local function updateSlider(mouseX)
local relativeX = (mouseX - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
relativeX = math.clamp(relativeX, 0, 1)
currentValue = min + (max - min) * relativeX
currentValue = math.floor(currentValue * 100) / 100
sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
sliderBtn.Position = UDim2.new(relativeX, -6, 0.5, -6)
valueLabel.Text = string.format(format or "%.2f", currentValue)
end
sliderBtn.MouseButton1Down:Connect(function()
dragging = true
TweenService:Create(sliderBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 16, 0, 16)}):Play()
TweenService:Create(sliderBtn, TweenInfo.new(0.1), {Position = UDim2.new((currentValue - min) / (max - min), -8, 0.5, -8)}):Play()
end)
UserInputService.InputEnded:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = false
TweenService:Create(sliderBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 12, 0, 12)}):Play()
TweenService:Create(sliderBtn, TweenInfo.new(0.1), {Position = UDim2.new((currentValue - min) / (max - min), -6, 0.5, -6)}):Play()
if label == "Execution Delay" then
Config.ExecutionDelay = currentValue
self:Log("Execution delay set to: " .. currentValue .. "s")
elseif label == "ESP Max Distance" then
Config.ESPDistance = currentValue
self:Log("ESP distance set to: " .. currentValue .. " studs")
elseif label == "Field of View" then
Config.FOV = currentValue
self:Log("FOV set to: " .. currentValue .. "°")
end
end
end)
sliderBtn.MouseButton1Up:Connect(function()
if dragging then
dragging = false
TweenService:Create(sliderBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 12, 0, 12)}):Play()
TweenService:Create(sliderBtn, TweenInfo.new(0.1), {Position = UDim2.new((currentValue - min) / (max - min), -6, 0.5, -6)}):Play()
end
end)
UserInputService.InputChanged:Connect(function(input)
if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
updateSlider(input.Position.X)
end
end)
sliderTrack.MouseButton1Down:Connect(function(x, y)
dragging = true
updateSlider(x)
end)
sliderTrack.MouseButton1Up:Connect(function(x, y)
if dragging then
dragging = false
if label == "Execution Delay" then
Config.ExecutionDelay = currentValue
self:Log("Execution delay set to: " .. currentValue .. "s")
elseif label == "ESP Max Distance" then
Config.ESPDistance = currentValue
self:Log("ESP distance set to: " .. currentValue .. " studs")
elseif label == "Field of View" then
Config.FOV = currentValue
self:Log("FOV set to: " .. currentValue .. "°")
end
end
end)
Layout:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
return currentValue
end
function Cast:SameLine(spacing)
Layout:SameLine(spacing)
end
function Cast:Destroy()
if self.gui then
self.gui:Destroy()
end
end
local ui = Cast.Create("Cast UI v1.2")
return ui
