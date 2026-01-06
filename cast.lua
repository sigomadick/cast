local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Theme = {
WindowBg = Color3.new(0.06, 0.06, 0.08),
ChildBg = Color3.new(0.08, 0.08, 0.1),
PopupBg = Color3.new(0.1, 0.1, 0.12),
Border = Color3.new(0.16, 0.16, 0.2),
FrameBg = Color3.new(0.12, 0.12, 0.16),
FrameBgHovered = Color3.new(0.16, 0.16, 0.22),
FrameBgActive = Color3.new(0.18, 0.18, 0.24),
TitleBg = Color3.new(0.1, 0.1, 0.14),
TitleBgActive = Color3.new(0.12, 0.12, 0.18),
Button = Color3.new(0.14, 0.14, 0.2),
ButtonHovered = Color3.new(0.2, 0.2, 0.28),
ButtonActive = Color3.new(0.18, 0.18, 0.26),
Text = Color3.new(0.86, 0.86, 0.86),
TextDisabled = Color3.new(0.47, 0.47, 0.47),
Header = Color3.new(0.16, 0.16, 0.22),
Separator = Color3.new(0.2, 0.2, 0.26),
SliderGrab = Color3.new(0.24, 0.47, 0.78),
SliderGrabActive = Color3.new(0.27, 0.55, 0.86),
CheckMark = Color3.new(0.24, 0.47, 0.78),
}
local Cast = {}
Cast.__index = Cast
local Layout = {
cursor = {x = 8, y = 8},
indent = 0,
sameLine = false,
lastWidth = 0,
lineHeight = 0,
groupStack = {}
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
function Cast.new(title)
local self = setmetatable({}, Cast)
self.title = title or "Cast UI"
self.open = true
self.alpha = 1
self.gui = Instance.new("ScreenGui")
self.gui.Name = "CastUI"
self.gui.ResetOnSpawn = false
self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
self.gui.Parent = PlayerGui
self.window = Instance.new("Frame")
self.window.Size = UDim2.new(0, 450, 0, 500)
self.window.Position = UDim2.new(0.5, -225, 0.5, -250)
self.window.BackgroundColor3 = Theme.WindowBg
self.window.BorderSizePixel = 0
self.window.ClipsDescendants = true
self.window.Parent = self.gui
local frame = Instance.new("UIStroke")
frame.Color = Theme.Border
frame.Thickness = 1
frame.Parent = self.window
self.titleBar = Instance.new("Frame")
self.titleBar.Size = UDim2.new(1, 0, 0, 24)
self.titleBar.BackgroundColor3 = Theme.TitleBg
self.titleBar.BorderSizePixel = 0
self.titleBar.Parent = self.window
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = self.title
titleLabel.TextColor3 = Theme.Text
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSans
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center
titleLabel.Parent = self.titleBar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -24, 0, 0)
closeBtn.BackgroundColor3 = Color3.new(0.78, 0.2, 0.2)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = self.titleBar
closeBtn.MouseButton1Click:Connect(function()
self:Destroy()
end)
self.content = Instance.new("ScrollingFrame")
self.content.Size = UDim2.new(1, -16, 1, -40)
self.content.Position = UDim2.new(0, 8, 0, 32)
self.content.BackgroundTransparency = 1
self.content.ScrollBarThickness = 4
self.content.ScrollBarImageColor3 = Theme.Border
self.content.AutomaticCanvasSize = Enum.AutomaticSize.Y
self.content.CanvasSize = UDim2.new(0, 0, 0, 0)
self.content.Parent = self.window
self.canvas = Instance.new("Frame")
self.canvas.Size = UDim2.new(1, 0, 0, 0)
self.canvas.BackgroundTransparency = 1
self.canvas.Parent = self.content
local dragging = false
local startPos, startMouse
self.window.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 then
dragging = true
startMouse = input.Position
startPos = self.window.Position
end
end)
self.window.InputEnded:Connect(function(input)
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
return self
end
function Cast:Begin()
Layout.cursor = {x = 8, y = 8}
Layout.indent = 0
Layout.sameLine = false
Layout.lastWidth = 0
Layout.lineHeight = 0
Layout.groupStack = {}
end
function Cast:BeginChild(name, size, border)
local groupId = Layout:BeginGroup(4)
local pos = Layout:GetCursorPos()
local child = Instance.new("Frame")
child.Size = size or UDim2.new(1, -16, 0, 100)
child.Position = pos
child.BackgroundColor3 = Theme.ChildBg
if border then
local stroke = Instance.new("UIStroke")
stroke.Color = Theme.Border
stroke.Thickness = 1
stroke.Parent = child
end
if name then
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -8, 0, 18)
label.Position = UDim2.new(0, 4, 0, 2)
label.BackgroundTransparency = 1
label.Text = name
label.TextColor3 = Theme.Text
label.TextSize = 12
label.Font = Enum.Font.SourceSans
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = child
Layout.cursor.y = Layout.cursor.y + 20
end
child.Parent = self.canvas
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
line.Parent = self.canvas
Layout:AdvanceCursor(line.AbsoluteSize.X, 2)
end
function Cast:Spacing()
local pos = Layout:GetCursorPos()
local space = Instance.new("Frame")
space.Size = UDim2.new(1, 0, 0, 8)
space.Position = pos
space.BackgroundTransparency = 1
space.Parent = self.canvas
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
label.Parent = self.canvas
Layout:AdvanceCursor(label.AbsoluteSize.X, 20)
return label
end
function Cast:Button(label, size)
local pos = Layout:GetCursorPos()
local btn = Instance.new("TextButton")
btn.Size = size or UDim2.new(0, 0, 0, 24)
btn.Position = pos
btn.BackgroundColor3 = Theme.Button
btn.Text = label
btn.TextColor3 = Theme.Text
btn.TextSize = 14
btn.Font = Enum.Font.SourceSans
btn.AutoButtonColor = false
btn.Parent = self.canvas
if not size then
local textSize = TextService:GetTextSize(label, 14, Enum.Font.SourceSans, Vector2.new(1000, 100))
btn.Size = UDim2.new(0, textSize.X + 16, 0, 24)
end
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ButtonHovered}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Button}):Play()
end)
btn.MouseButton1Down:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundColor3 = Theme.ButtonActive}):Play()
end)
btn.MouseButton1Up:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ButtonHovered}):Play()
end)
Layout:AdvanceCursor(btn.AbsoluteSize.X, btn.AbsoluteSize.Y)
return btn
end
function Cast:Checkbox(label, checked)
local pos = Layout:GetCursorPos()
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, -16, 0, 20)
frame.Position = pos
frame.BackgroundTransparency = 1
frame.Parent = self.canvas
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
textLabel.Size = UDim2.new(1, -24, 1, 0)
textLabel.Position = UDim2.new(0, 24, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = label
textLabel.TextColor3 = Theme.Text
textLabel.TextSize = 14
textLabel.Font = Enum.Font.SourceSans
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Center
textLabel.Parent = frame
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {
BackgroundColor3 = checked and Theme.SliderGrabActive or Theme.FrameBgHovered
}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {
BackgroundColor3 = checked and Theme.SliderGrab or Theme.FrameBg
}):Play()
end)
Layout:AdvanceCursor(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
return btn, checked or false
end
function Cast:InputText(label, text, width)
local pos = Layout:GetCursorPos()
if label then
local labelFrame = Instance.new("TextLabel")
labelFrame.Size = UDim2.new(1, -16, 0, 18)
labelFrame.Position = pos
labelFrame.BackgroundTransparency = 1
labelFrame.Text = label
labelFrame.TextColor3 = Theme.Text
labelFrame.TextSize = 14
labelFrame.Font = Enum.Font.SourceSans
labelFrame.TextXAlignment = Enum.TextXAlignment.Left
labelFrame.Parent = self.canvas
Layout:AdvanceCursor(labelFrame.AbsoluteSize.X, 18)
pos = Layout:GetCursorPos()
end
local input = Instance.new("TextBox")
input.Size = width or UDim2.new(1, -16, 0, 24)
input.Position = pos
input.BackgroundColor3 = Theme.FrameBg
input.Text = text or ""
input.PlaceholderText = label or "Enter text..."
input.PlaceholderColor3 = Theme.TextDisabled
input.TextColor3 = Theme.Text
input.TextSize = 14
input.Font = Enum.Font.SourceSans
input.ClearTextOnFocus = false
input.Parent = self.canvas
local stroke = Instance.new("UIStroke")
stroke.Color = Theme.Border
stroke.Thickness = 1
stroke.Parent = input
input.Focused:Connect(function()
TweenService:Create(stroke, TweenInfo.new(0.1), {Color = Theme.SliderGrab}):Play()
TweenService:Create(input, TweenInfo.new(0.1), {BackgroundColor3 = Theme.FrameBgHovered}):Play()
end)
input.FocusLost:Connect(function()
TweenService:Create(stroke, TweenInfo.new(0.1), {Color = Theme.Border}):Play()
TweenService:Create(input, TweenInfo.new(0.1), {BackgroundColor3 = Theme.FrameBg}):Play()
end)
Layout:AdvanceCursor(input.AbsoluteSize.X, input.AbsoluteSize.Y)
return input
end
function Cast:SliderFloat(label, value, min, max, format)
local pos = Layout:GetCursorPos()
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 0, 40)
container.Position = pos
container.BackgroundTransparency = 1
container.Parent = self.canvas
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 0, 18)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = label
textLabel.TextColor3 = Theme.Text
textLabel.TextSize = 14
textLabel.Font = Enum.Font.SourceSans
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Parent = container
local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(0, 60, 0, 18)
valueLabel.Position = UDim2.new(1, -60, 0, 0)
valueLabel.BackgroundTransparency = 1
valueLabel.Text = string.format(format or "%.2f", value)
valueLabel.TextColor3 = Theme.Text
valueLabel.TextSize = 14
valueLabel.Font = Enum.Font.SourceSans
valueLabel.TextXAlignment = Enum.TextXAlignment.Right
valueLabel.Parent = container
local sliderTrack = Instance.new("Frame")
sliderTrack.Size = UDim2.new(1, 0, 0, 4)
sliderTrack.Position = UDim2.new(0, 0, 0, 26)
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
if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
updateSlider(x)
dragging = true
end)
Layout:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
return currentValue
end
function Cast:Combo(label, currentItem, items)
local pos = Layout:GetCursorPos()
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 0, 24)
container.Position = pos
container.BackgroundTransparency = 1
container.Parent = self.canvas
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 1, 0)
btn.BackgroundColor3 = Theme.Button
btn.Text = items[currentItem or 1] or label or "Select..."
btn.TextColor3 = Theme.Text
btn.TextSize = 14
btn.Font = Enum.Font.SourceSans
btn.AutoButtonColor = false
btn.Parent = container
local arrow = Instance.new("TextLabel")
arrow.Size = UDim2.new(0, 16, 1, 0)
arrow.Position = UDim2.new(1, -20, 0, 0)
arrow.BackgroundTransparency = 1
arrow.Text = "▼"
arrow.TextColor3 = Theme.TextDisabled
arrow.TextSize = 12
arrow.Font = Enum.Font.SourceSans
arrow.TextYAlignment = Enum.TextYAlignment.Center
arrow.Parent = container
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 24)
padding.Parent = btn
btn.MouseEnter:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ButtonHovered}):Play()
end)
btn.MouseLeave:Connect(function()
TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Button}):Play()
end)
local dropdownOpen = false
local dropdown
btn.MouseButton1Click:Connect(function()
if dropdownOpen then
if dropdown then dropdown:Destroy() end
dropdownOpen = false
return
end
dropdownOpen = true
dropdown = Instance.new("Frame")
dropdown.Size = UDim2.new(1, 0, 0, #items * 24 + 4)
dropdown.Position = UDim2.new(0, 0, 1, 2)
dropdown.BackgroundColor3 = Theme.PopupBg
dropdown.BorderSizePixel = 0
dropdown.ZIndex = 10
dropdown.Parent = container
for i, item in ipairs(items) do
local itemBtn = Instance.new("TextButton")
itemBtn.Size = UDim2.new(1, -4, 0, 22)
itemBtn.Position = UDim2.new(0, 2, 0, 2 + (i-1)*24)
itemBtn.BackgroundColor3 = Theme.Button
itemBtn.Text = item
itemBtn.TextColor3 = Theme.Text
itemBtn.TextSize = 14
itemBtn.Font = Enum.Font.SourceSans
itemBtn.AutoButtonColor = false
itemBtn.ZIndex = 11
itemBtn.Parent = dropdown
local itemPadding = Instance.new("UIPadding")
itemPadding.PaddingLeft = UDim.new(0, 8)
itemPadding.Parent = itemBtn
itemBtn.MouseEnter:Connect(function()
TweenService:Create(itemBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ButtonHovered}):Play()
end)
itemBtn.MouseLeave:Connect(function()
TweenService:Create(itemBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Button}):Play()
end)
itemBtn.MouseButton1Click:Connect(function()
btn.Text = item
dropdown:Destroy()
dropdownOpen = false
end)
end
end)
Layout:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
return btn
end
function Cast:ColorEdit3(label, color)
local pos = Layout:GetCursorPos()
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 0, 20)
container.Position = pos
container.BackgroundTransparency = 1
container.Parent = self.canvas
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, -60, 1, 0)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = label
textLabel.TextColor3 = Theme.Text
textLabel.TextSize = 14
textLabel.Font = Enum.Font.SourceSans
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.TextYAlignment = Enum.TextYAlignment.Center
textLabel.Parent = container
local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(0, 40, 0, 16)
colorBtn.Position = UDim2.new(1, -42, 0.5, -8)
colorBtn.BackgroundColor3 = color or Color3.new(1,1,1)
colorBtn.Text = ""
colorBtn.Parent = container
Layout:AdvanceCursor(container.AbsoluteSize.X, container.AbsoluteSize.Y)
return colorBtn
end
function Cast:Destroy()
if self.gui then
self.gui:Destroy()
end
end
